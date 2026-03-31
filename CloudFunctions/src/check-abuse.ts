import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";

const MAX_REPORTS_PER_24H = 10;
const SAME_PLATE_THRESHOLD = 3;
const BLOCK_DURATIONS: Record<number, number | null> = {
  1: 24 * 60 * 60 * 1000,      // 24 heures
  2: 72 * 60 * 60 * 1000,      // 72 heures
  3: null,                       // Definitif
};

export interface AbuseCheckResult {
  allowed: boolean;
  message?: string;
  remainingReports?: number;
}

/**
 * Verifie si un utilisateur est bloque ou depasse le rate limit.
 * Gere le blocage progressif (24h → 72h → definitif).
 * Utilise une transaction Firestore pour eviter les race conditions.
 */
export async function checkAbuse(
  uid: string,
  plateHash: string
): Promise<AbuseCheckResult> {
  const db = getFirestore();
  const abuseRef = db.collection("abuseTracking").doc(uid);
  const now = Date.now();

  // Lecture hors transaction pour le blocage actif (read-only, pas de race)
  const abuseDoc = await abuseRef.get();

  if (abuseDoc.exists) {
    const data = abuseDoc.data()!;

    if (data.blocked) {
      const blockLevel = data.blockLevel || 1;
      const blockedAt = (data.blockedAt as Timestamp)?.toMillis() || 0;
      const blockDuration = BLOCK_DURATIONS[blockLevel];

      if (blockDuration === null) {
        logger.warn(`Utilisateur ${uid} bloque definitivement`);
        return {
          allowed: false,
          message: "Votre compte a ete definitivement restreint.",
        };
      }

      if (now - blockedAt < blockDuration) {
        const remainingMs = blockDuration - (now - blockedAt);
        const remainingHours = Math.ceil(remainingMs / (60 * 60 * 1000));
        const duration = blockLevel === 1 ? "24 heures" : "72 heures";
        logger.info(`Utilisateur ${uid} bloque pour encore ${remainingHours}h`);
        return {
          allowed: false,
          message: `Votre compte est restreint pour ${duration}. Temps restant : ${remainingHours}h.`,
        };
      }

      // Blocage expire — debloquer dans la transaction ci-dessous
    }
  }

  // Compter les signalements des dernieres 24h
  const twentyFourHoursAgo = new Date(now - 24 * 60 * 60 * 1000);
  const recentReports = await db
    .collection("reports")
    .where("reporterUid", "==", uid)
    .where("createdAt", ">=", twentyFourHoursAgo)
    .get();

  const reportCount = recentReports.size;

  if (reportCount >= MAX_REPORTS_PER_24H) {
    logger.warn(`Rate limit atteint pour ${uid}: ${reportCount} signalements en 24h`);
    return {
      allowed: false,
      message: `Limite de ${MAX_REPORTS_PER_24H} signalements par 24h atteinte. Reessayez plus tard.`,
    };
  }

  // Detection pattern abusif
  const samePlateReports = recentReports.docs.filter(
    (doc) => doc.data().plateHash === plateHash
  );

  // Transaction pour les ecritures — empeche le double-tap de contourner le rate limit
  return db.runTransaction(async (transaction) => {
    const freshAbuse = await transaction.get(abuseRef);
    const freshData = freshAbuse.exists ? freshAbuse.data()! : {};

    // Debloquer si le blocage a expire
    if (freshData.blocked && freshData.blockLevel) {
      const blockDuration = BLOCK_DURATIONS[freshData.blockLevel];
      const blockedAt = (freshData.blockedAt as Timestamp)?.toMillis() || 0;
      if (blockDuration !== null && now - blockedAt >= blockDuration) {
        transaction.update(abuseRef, { blocked: false });
      }
    }

    if (samePlateReports.length >= SAME_PLATE_THRESHOLD) {
      const currentLevel = freshData.blockLevel || 0;
      const newLevel = Math.min(currentLevel + 1, 3);

      transaction.set(
        abuseRef,
        {
          blocked: true,
          blockLevel: newLevel,
          blockedAt: FieldValue.serverTimestamp(),
          lastReportAt: FieldValue.serverTimestamp(),
          reportCount24h: reportCount,
        },
        { merge: true }
      );

      const messages: Record<number, string> = {
        1: "Votre compte est temporairement restreint pour 24 heures.",
        2: "Votre compte est restreint pour 72 heures.",
        3: "Votre compte a ete definitivement restreint.",
      };

      logger.warn(`Blocage niveau ${newLevel} pour ${uid} — pattern abusif detecte`);
      return {
        allowed: false,
        message: messages[newLevel],
      } as AbuseCheckResult;
    }

    // Mettre a jour le tracking atomiquement
    transaction.set(
      abuseRef,
      {
        lastReportAt: FieldValue.serverTimestamp(),
        reportCount24h: reportCount + 1,
      },
      { merge: true }
    );

    return {
      allowed: true,
      remainingReports: MAX_REPORTS_PER_24H - reportCount - 1,
    } as AbuseCheckResult;
  });
}

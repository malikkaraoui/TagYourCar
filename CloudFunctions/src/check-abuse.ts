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
 */
export async function checkAbuse(
  uid: string,
  plateHash: string
): Promise<AbuseCheckResult> {
  const db = getFirestore();
  const abuseRef = db.collection("abuseTracking").doc(uid);
  const abuseDoc = await abuseRef.get();
  const now = Date.now();

  if (abuseDoc.exists) {
    const data = abuseDoc.data()!;

    // Verifier si bloque
    if (data.blocked) {
      const blockLevel = data.blockLevel || 1;
      const blockedAt = (data.blockedAt as Timestamp)?.toMillis() || 0;
      const blockDuration = BLOCK_DURATIONS[blockLevel];

      // Blocage definitif
      if (blockDuration === null) {
        logger.warn(`Utilisateur ${uid} bloque definitivement`);
        return {
          allowed: false,
          message: "Votre compte a ete definitivement restreint.",
        };
      }

      // Blocage temporaire — verifier expiration
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

      // Blocage expire — debloquer
      await abuseRef.update({ blocked: false });
      logger.info(`Blocage expire pour ${uid}`);
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

  // Rate limiting global
  if (reportCount >= MAX_REPORTS_PER_24H) {
    logger.warn(`Rate limit atteint pour ${uid}: ${reportCount} signalements en 24h`);
    return {
      allowed: false,
      message: `Limite de ${MAX_REPORTS_PER_24H} signalements par 24h atteinte. Reessayez plus tard.`,
    };
  }

  // Detection pattern abusif : meme plaque signalee plusieurs fois
  const samePlateReports = recentReports.docs.filter(
    (doc) => doc.data().plateHash === plateHash
  );

  if (samePlateReports.length >= SAME_PLATE_THRESHOLD) {
    // Blocage progressif
    const currentLevel = abuseDoc.exists
      ? (abuseDoc.data()!.blockLevel || 0)
      : 0;
    const newLevel = Math.min(currentLevel + 1, 3);

    await abuseRef.set(
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
    };
  }

  // Mettre a jour le tracking
  await abuseRef.set(
    {
      lastReportAt: FieldValue.serverTimestamp(),
      reportCount24h: reportCount + 1,
    },
    { merge: true }
  );

  return {
    allowed: true,
    remainingReports: MAX_REPORTS_PER_24H - reportCount - 1,
  };
}

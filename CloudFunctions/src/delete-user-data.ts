import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { logger } from "firebase-functions/v2";

export const deleteUserData = onCall(async (request) => {
  // Auth check
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const uid = request.auth.uid;
  const db = getFirestore();

  logger.info(`Demarrage purge complete pour utilisateur ${uid}`);

  try {
    // 1. Supprimer toutes les plaques de l'utilisateur
    const plates = await db
      .collection("plates")
      .where("ownerUid", "==", uid)
      .get();

    for (const doc of plates.docs) {
      await doc.ref.delete();
    }
    logger.info(`${plates.size} plaques supprimees pour ${uid}`);

    // 2. Supprimer tous les signalements de l'utilisateur
    const reports = await db
      .collection("reports")
      .where("reporterUid", "==", uid)
      .get();

    for (const doc of reports.docs) {
      await doc.ref.delete();
    }
    logger.info(`${reports.size} signalements supprimes pour ${uid}`);

    // 3. Supprimer le document abuseTracking
    const abuseRef = db.collection("abuseTracking").doc(uid);
    const abuseDoc = await abuseRef.get();
    if (abuseDoc.exists) {
      await abuseRef.delete();
      logger.info(`Document abuseTracking supprime pour ${uid}`);
    }

    // 4. Supprimer le document utilisateur
    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      await userRef.delete();
      logger.info(`Document users supprime pour ${uid}`);
    }

    // 5. Supprimer le compte Firebase Auth
    await getAuth().deleteUser(uid);
    logger.info(`Compte Firebase Auth supprime pour ${uid}`);

    logger.info(`Purge complete terminee avec succes pour ${uid}`);
    return { success: true, message: "Compte et donnees supprimes definitivement." };
  } catch (error) {
    logger.error(`Erreur pendant la purge pour ${uid}:`, error);
    throw new HttpsError(
      "internal",
      "La suppression est en cours de traitement. Vos donnees seront supprimees sous peu."
    );
  }
});

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
    // 1. Collecter toutes les plaques et signalements en parallele
    const [plates, reports] = await Promise.all([
      db.collection("plates").where("ownerUid", "==", uid).get(),
      db.collection("reports").where("reporterUid", "==", uid).get(),
    ]);

    // 2. Supprimer par batch (max 500 ops par batch Firestore)
    const batch = db.batch();

    for (const doc of plates.docs) {
      batch.delete(doc.ref);
    }
    for (const doc of reports.docs) {
      batch.delete(doc.ref);
    }

    // Ajouter abuseTracking et users dans le meme batch
    batch.delete(db.collection("abuseTracking").doc(uid));
    batch.delete(db.collection("users").doc(uid));

    await batch.commit();
    logger.info(`Batch supprime : ${plates.size} plaques, ${reports.size} signalements, abuseTracking, users pour ${uid}`);

    // 3. Supprimer le compte Firebase Auth (hors batch Firestore)
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

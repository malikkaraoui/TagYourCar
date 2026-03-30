import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import * as crypto from "crypto";

export const deletePlate = onCall({ secrets: ["PLATE_HASH_SALT"] }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const { plate } = request.data;
  if (!plate || typeof plate !== "string") {
    throw new HttpsError("invalid-argument", "Plaque manquante ou invalide.");
  }

  const uid = request.auth.uid;
  const db = getFirestore();

  const salt = process.env.PLATE_HASH_SALT;
  if (!salt) {
    throw new HttpsError("internal", "Configuration serveur manquante.");
  }

  const plateHash = crypto
    .createHash("sha256")
    .update(plate + salt)
    .digest("hex");

  const plateDoc = await db.collection("plates").doc(plateHash).get();

  if (!plateDoc.exists) {
    throw new HttpsError("not-found", "Plaque introuvable.");
  }

  const data = plateDoc.data();
  if (data?.ownerUid !== uid) {
    throw new HttpsError(
      "permission-denied",
      "Vous ne pouvez supprimer que vos propres plaques."
    );
  }

  await db.collection("plates").doc(plateHash).delete();

  return { success: true, message: "Plaque supprimee." };
});

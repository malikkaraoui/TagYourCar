import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import * as crypto from "crypto";

export const verifyOwnership = onCall(async (request) => {
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
    return { verified: false, reason: "Plaque non enregistree." };
  }

  const data = plateDoc.data();
  if (data?.ownerUid !== uid) {
    return { verified: false, reason: "Cette plaque appartient a un autre utilisateur." };
  }

  // Mark as verified
  await db.collection("plates").doc(plateHash).update({ verified: true });

  return { verified: true, message: "Propriete confirmee." };
});

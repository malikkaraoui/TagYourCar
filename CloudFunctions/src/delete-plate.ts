import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import * as crypto from "crypto";

export const deletePlate = onCall({ secrets: ["PLATE_HASH_SALT"] }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const { plate, plateHash: directHash } = request.data;

  const uid = request.auth.uid;
  const db = getFirestore();

  let plateHash: string;

  if (directHash && typeof directHash === "string") {
    // Suppression par hash direct (depuis le client qui a déjà le doc ID)
    plateHash = directHash;
  } else if (plate && typeof plate === "string") {
    // Suppression par texte de plaque (hashage côté serveur)
    const salt = process.env.PLATE_HASH_SALT;
    if (!salt) {
      throw new HttpsError("internal", "Configuration serveur manquante.");
    }
    plateHash = crypto
      .createHash("sha256")
      .update(plate + salt)
      .digest("hex");
  } else {
    throw new HttpsError("invalid-argument", "Plaque manquante ou invalide.");
  }

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

  const userRef = db.collection("users").doc(uid);
  const userDoc = await userRef.get();
  const favoritePlateHash = userDoc.data()?.favoritePlateHash;
  const shouldClearFavorite = data?.isFavorite === true || favoritePlateHash === plateHash;

  const batch = db.batch();
  batch.delete(plateDoc.ref);

  if (shouldClearFavorite) {
    batch.set(userRef, { favoritePlateHash: null }, { merge: true });
  }

  await batch.commit();

  return { success: true, message: "Plaque supprimee." };
});

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import * as crypto from "crypto";

const MAX_PLATES_PER_USER = 5;

export const hashPlate = onCall({ secrets: ["PLATE_HASH_SALT"] }, async (request) => {
  // Auth check
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const { plate } = request.data;
  if (!plate || typeof plate !== "string") {
    throw new HttpsError("invalid-argument", "Plaque manquante ou invalide.");
  }

  // Validate French plate format
  const plateRegex = /^[A-Z]{2}-[0-9]{3}-[A-Z]{2}$/;
  if (!plateRegex.test(plate)) {
    throw new HttpsError(
      "invalid-argument",
      "Format de plaque invalide. Utilisez le format AA-123-AA."
    );
  }

  const uid = request.auth.uid;
  const db = getFirestore();

  // Check plate limit (max 5)
  const userPlates = await db
    .collection("plates")
    .where("ownerUid", "==", uid)
    .get();

  if (userPlates.size >= MAX_PLATES_PER_USER) {
    throw new HttpsError(
      "resource-exhausted",
      "Limite de 5 plaques atteinte."
    );
  }

  // Hash plate with salt
  const salt = process.env.PLATE_HASH_SALT;
  if (!salt) {
    throw new HttpsError("internal", "Configuration serveur manquante.");
  }

  const plateHash = crypto
    .createHash("sha256")
    .update(plate + salt)
    .digest("hex");

  // Check if plate already registered
  const existingPlate = await db.collection("plates").doc(plateHash).get();
  if (existingPlate.exists) {
    const data = existingPlate.data();
    if (data?.ownerUid === uid) {
      throw new HttpsError(
        "already-exists",
        "Cette plaque est deja enregistree sur votre compte."
      );
    } else {
      throw new HttpsError(
        "already-exists",
        "Cette plaque est deja enregistree par un autre utilisateur."
      );
    }
  }

  // Store plate
  await db.collection("plates").doc(plateHash).set({
    ownerUid: uid,
    addedAt: new Date(),
    verified: false,
  });

  return { success: true, message: "Plaque enregistree avec succes." };
});

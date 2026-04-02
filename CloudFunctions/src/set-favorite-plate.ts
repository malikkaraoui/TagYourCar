import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";

export const setFavoritePlate = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const rawPlateHash = request.data?.plateHash;
  if (
    rawPlateHash !== null &&
    rawPlateHash !== undefined &&
    (typeof rawPlateHash !== "string" || rawPlateHash.trim().length === 0)
  ) {
    throw new HttpsError("invalid-argument", "Favori invalide.");
  }

  const plateHash = typeof rawPlateHash === "string" ? rawPlateHash : null;
  const uid = request.auth.uid;
  const db = getFirestore();

  if (plateHash) {
    const targetPlateDoc = await db.collection("plates").doc(plateHash).get();
    if (!targetPlateDoc.exists) {
      throw new HttpsError("not-found", "Plaque introuvable.");
    }

    if (targetPlateDoc.data()?.ownerUid !== uid) {
      throw new HttpsError(
        "permission-denied",
        "Vous ne pouvez modifier que vos propres plaques."
      );
    }
  }

  const userPlates = await db
    .collection("plates")
    .where("ownerUid", "==", uid)
    .get();

  const batch = db.batch();
  userPlates.docs.forEach((plateDoc) => {
    batch.update(plateDoc.ref, {
      isFavorite: plateHash !== null && plateDoc.id === plateHash,
    });
  });

  batch.set(
    db.collection("users").doc(uid),
    { favoritePlateHash: plateHash },
    { merge: true }
  );

  await batch.commit();

  return {
    success: true,
    favoritePlateHash: plateHash,
  };
});
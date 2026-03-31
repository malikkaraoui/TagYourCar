import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import * as crypto from "crypto";

export const submitReport = onCall(
  { secrets: ["PLATE_HASH_SALT"] },
  async (request) => {
    // Auth check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentification requise.");
    }

    const { zone, problemType, vehicleColor, plate } = request.data;

    // Validation
    if (!zone || !problemType || !vehicleColor || !plate) {
      throw new HttpsError(
        "invalid-argument",
        "Donnees de signalement incompletes."
      );
    }

    const plateRegex = /^[A-Z]{2}-[0-9]{3}-[A-Z]{2}$/;
    if (!plateRegex.test(plate)) {
      throw new HttpsError(
        "invalid-argument",
        "Format de plaque invalide."
      );
    }

    const uid = request.auth.uid;
    const db = getFirestore();

    // Hash plate with salt
    const salt = process.env.PLATE_HASH_SALT;
    if (!salt) {
      throw new HttpsError("internal", "Configuration serveur manquante.");
    }

    const plateHash = crypto
      .createHash("sha256")
      .update(plate + salt)
      .digest("hex");

    // Check if plate is registered
    const plateDoc = await db.collection("plates").doc(plateHash).get();

    if (!plateDoc.exists) {
      // FR17 : zero donnee stockee pour plaque non enregistree
      return { success: true, registered: false };
    }

    // Create report document
    await db.collection("reports").add({
      reporterUid: uid,
      plateHash: plateHash,
      zone: zone,
      problemType: problemType,
      vehicleColor: vehicleColor,
      partialPlate: plate.substring(0, 2) + "-" + plate.substring(3, 4) + "xx-" + plate.substring(7),
      createdAt: FieldValue.serverTimestamp(),
      status: "pending",
    });

    return { success: true, registered: true };
  }
);

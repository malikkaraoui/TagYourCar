import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions/v2";

export const onReportCreated = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.error("Pas de donnees dans le document report");
      return;
    }

    const report = snapshot.data();
    const db = getFirestore();

    // Trouver le proprietaire de la plaque
    const plateDoc = await db
      .collection("plates")
      .doc(report.plateHash)
      .get();

    if (!plateDoc.exists) {
      logger.warn("Plaque non trouvee pour le report — pas de notification");
      return;
    }

    const ownerUid = plateDoc.data()?.ownerUid;
    if (!ownerUid) {
      logger.warn("Proprietaire non trouve pour la plaque");
      return;
    }

    // Ne pas notifier le proprietaire s'il se signale lui-meme
    if (ownerUid === report.reporterUid) {
      logger.info("Le signaleur est le proprietaire — pas de notification");
      return;
    }

    // Trouver le fcmToken du proprietaire
    const userDoc = await db.collection("users").doc(ownerUid).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      logger.warn("Pas de fcmToken pour le proprietaire — notification impossible");
      await snapshot.ref.update({ status: "failed" });
      return;
    }

    // Construire le message de notification (FR19)
    const problemLabels: Record<string, string> = {
      headlights_on: "vos phares sont allumes",
      hood_open: "votre capot est ouvert",
      charge_flap_open: "votre trappe de charge est ouverte",
      flat_tire_front: "vous avez un pneu a plat (avant)",
      other_front: "un probleme a ete signale (avant)",
      window_open: "votre vitre est ouverte",
      door_ajar: "votre portiere est mal fermee",
      sunroof_open: "votre toit ouvrant est ouvert",
      other_middle: "un probleme a ete signale (milieu)",
      taillights_on: "vos feux sont allumes",
      fuel_flap_open: "votre trappe a essence est ouverte",
      trunk_open: "votre coffre est ouvert",
      flat_tire_rear: "vous avez un pneu a plat (arriere)",
      other_rear: "un probleme a ete signale (arriere)",
    };

    const problemText = problemLabels[report.problemType] || "un probleme a ete signale";
    const partialPlate = report.partialPlate || "votre vehicule";

    // Incrementer le compteur de badge non-lus
    const userRef = db.collection("users").doc(ownerUid);
    const { FieldValue } = await import("firebase-admin/firestore");
    await userRef.update({ unreadBadge: FieldValue.increment(1) });
    const updatedUser = await userRef.get();
    const badgeCount = updatedUser.data()?.unreadBadge || 1;

    // Envoyer la notification FCM
    try {
      await getMessaging().send({
        token: fcmToken,
        notification: {
          title: "TagYourCar",
          body: `Quelqu'un vous signale que ${problemText} sur ${partialPlate}.`,
        },
        data: {
          reportId: event.params.reportId,
          zone: report.zone,
          problemType: report.problemType,
          vehicleColor: report.vehicleColor,
          partialPlate: report.partialPlate || "",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: badgeCount,
            },
          },
        },
      });

      await snapshot.ref.update({ status: "delivered" });
      logger.info(`Notification envoyee au proprietaire de ${partialPlate} (badge: ${badgeCount})`);
    } catch (error) {
      logger.error("Erreur envoi notification FCM:", error);
      await snapshot.ref.update({ status: "failed" });
    }
  }
);

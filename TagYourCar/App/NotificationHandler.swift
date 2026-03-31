import Foundation
import UserNotifications
import os

/// Gere les notifications push et le deep linking vers le detail signalement
@MainActor
final class NotificationHandler: NSObject, ObservableObject {
    @Published var pendingReport: ReportNotificationData?
    @Published var showReportDetail = false

    private let logger = Logger(subsystem: "com.tagyourcar", category: "NotificationHandler")

    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let reportId = userInfo["reportId"] as? String, !reportId.isEmpty else {
            logger.warning("Notification recue sans reportId — ignore")
            return
        }

        let data = ReportNotificationData(userInfo: userInfo)
        pendingReport = data
        showReportDetail = true
        logger.info("Notification de signalement recue — reportId: \(reportId)")
    }

    func dismissDetail() {
        pendingReport = nil
        showReportDetail = false
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationHandler: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Afficher la notification meme quand l'app est au premier plan
        return [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let reportId = response.notification.request.content.userInfo["reportId"] as? String ?? ""
        let zone = response.notification.request.content.userInfo["zone"] as? String ?? ""
        let problemType = response.notification.request.content.userInfo["problemType"] as? String ?? ""
        let vehicleColor = response.notification.request.content.userInfo["vehicleColor"] as? String ?? ""
        let partialPlate = response.notification.request.content.userInfo["partialPlate"] as? String ?? ""

        await MainActor.run {
            let data = ReportNotificationData(
                reportId: reportId,
                zone: zone,
                problemType: problemType,
                vehicleColor: vehicleColor,
                partialPlate: partialPlate
            )
            pendingReport = data
            showReportDetail = true
            logger.info("Notification de signalement recue — reportId: \(reportId)")
        }
    }
}

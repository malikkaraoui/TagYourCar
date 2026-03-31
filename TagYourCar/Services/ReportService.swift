import Foundation
import FirebaseCore
import FirebaseFunctions
import os

@MainActor
final class ReportService: ObservableObject {
    private lazy var functions: Functions? = {
        guard FirebaseApp.app() != nil else { return nil }
        return Functions.functions()
    }()

    private let logger = Logger(subsystem: "com.tagyourcar", category: "ReportService")

    func submitReport(
        zone: VehicleZone,
        problemType: ProblemType,
        vehicleColor: VehicleColor,
        plate: String,
        reporterUid: String
    ) async throws -> ReportResult {
        guard let functions else {
            logger.error("Envoi de signalement impossible sans Firebase Functions")
            throw TagYourCarError.firebaseNotConfigured
        }

        let data: [String: Any] = [
            "zone": zone.rawValue,
            "problemType": problemType.rawValue,
            "vehicleColor": vehicleColor.rawValue,
            "plate": plate,
        ]

        let result: HTTPSCallableResult
        do {
            result = try await functions.httpsCallable("submitReport").call(data)
        } catch {
            let nsError = error as NSError
            // resource-exhausted = anti-abus (rate limit ou blocage)
            if nsError.domain == "com.firebase.functions" || nsError.code == 8 {
                let message = nsError.localizedDescription
                logger.warning("Signalement bloque par anti-abus : \(message)")
                throw TagYourCarError.reportBlocked(message)
            }
            throw TagYourCarError.reportFailed
        }

        guard let responseData = result.data as? [String: Any] else {
            throw TagYourCarError.reportFailed
        }

        let registered = responseData["registered"] as? Bool ?? false

        if registered {
            logger.info("Signalement envoye — proprietaire sera notifie")
            return .sent
        } else {
            logger.info("Plaque non enregistree — aucune donnee stockee")
            return .notRegistered
        }
    }
}

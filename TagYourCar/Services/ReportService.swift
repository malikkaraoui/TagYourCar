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
        plate: String
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
            logger.warning("Erreur signalement — domain: \(nsError.domain), code: \(nsError.code), message: \(nsError.localizedDescription)")
            // resource-exhausted (code 8) = anti-abus (rate limit ou blocage)
            if nsError.code == 8 {
                // Le message vient de la Cloud Function (déjà en FR)
                let message = nsError.localizedDescription
                if message.contains("restreint") || message.contains("Limite") {
                    throw TagYourCarError.reportBlocked(message)
                }
                throw TagYourCarError.reportBlocked("Trop de signalements. Réessayez plus tard.")
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

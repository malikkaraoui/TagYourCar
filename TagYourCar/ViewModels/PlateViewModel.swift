import Foundation
import UserNotifications
import os

@MainActor
final class PlateViewModel: ObservableObject {
    @Published var plateInput = ""
    @Published var plates: [Plate] = []
    @Published var state: ViewState = .idle
    @Published var errorMessage: String?
    @Published var showAddPlate = false

    private let plateService: PlateService
    private let logger = Logger(subsystem: "com.tagyourcar", category: "PlateViewModel")

    static let maxPlates = 5

    init(plateService: PlateService) {
        self.plateService = plateService
    }

    // MARK: - Validation

    var formattedPlate: String {
        PlateValidator.format(plateInput)
    }

    var isPlateValid: Bool {
        PlateValidator.isValid(formattedPlate)
    }

    var canAddPlate: Bool {
        isPlateValid && plates.count < Self.maxPlates
    }

    var hasReachedLimit: Bool {
        plates.count >= Self.maxPlates
    }

    // MARK: - Actions

    func loadPlates(for uid: String) async {
        state = .loading
        await plateService.fetchPlates(for: uid)
        plates = plateService.plates
        state = .loaded
    }

    func addPlate(for uid: String) async {
        guard canAddPlate else { return }
        state = .loading
        errorMessage = nil

        do {
            let isFirstPlate = plates.isEmpty
            try await plateService.addPlate(formattedPlate, for: uid)
            plates = plateService.plates
            plateInput = ""
            showAddPlate = false
            state = .loaded

            if isFirstPlate {
                await requestNotificationPermission()
            }

            logger.info("Plate added successfully")
        } catch {
            state = .error(mapError(error))
            errorMessage = mapError(error)
            logger.error("Failed to add plate: \(error.localizedDescription)")
        }
    }

    func deletePlate(_ plateText: String, for uid: String) async {
        state = .loading
        errorMessage = nil

        do {
            try await plateService.deletePlate(plateText, for: uid)
            plates = plateService.plates
            state = .loaded
            logger.info("Plate deleted successfully")
        } catch {
            state = .error("Erreur lors de la suppression.")
            errorMessage = "Erreur lors de la suppression. Reessayez."
            logger.error("Failed to delete plate: \(error.localizedDescription)")
        }
    }

    func resetInput() {
        plateInput = ""
        errorMessage = nil
    }

    // MARK: - Notifications (FR20)

    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                logger.info("Notification permission granted")
            } else {
                logger.info("Notification permission denied by user")
            }
        } catch {
            logger.error("Notification permission request failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Error Mapping

    private func mapError(_ error: Error) -> String {
        let nsError = error as NSError
        let message = nsError.localizedDescription.lowercased()

        if message.contains("limite") || message.contains("resource-exhausted") {
            return "Limite de 5 plaques atteinte."
        } else if message.contains("deja enregistree") || message.contains("already-exists") {
            return "Cette plaque est deja enregistree."
        } else if message.contains("format") || message.contains("invalid-argument") {
            return "Format de plaque invalide."
        } else {
            return "Erreur lors de l'ajout de la plaque. Reessayez."
        }
    }
}

import Foundation
import os

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedZone: VehicleZone?
    @Published var selectedProblem: ProblemType?
    @Published var selectedColor: VehicleColor?
    @Published var plateText = ""
    @Published var currentStep: ReportStep = .zone
    @Published var state: ViewState = .idle
    @Published var reportResult: ReportResult?
    @Published var showConfirmation = false
    @Published var isSubmitting = false

    private let reportService: ReportService
    private let logger = Logger(subsystem: "com.tagyourcar", category: "ReportViewModel")

    init(reportService: ReportService = ReportService()) {
        self.reportService = reportService
    }

    enum ReportStep: Int, Comparable {
        case zone = 0
        case problem = 1
        case color = 2
        case plate = 3

        static func < (lhs: ReportStep, rhs: ReportStep) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    // MARK: - Actions

    func selectZone(_ zone: VehicleZone) {
        selectedZone = zone
        selectedProblem = nil
        selectedColor = nil
        currentStep = .problem
        logger.info("Zone selectionnee : \(zone.rawValue)")
    }

    func selectProblem(_ problem: ProblemType) {
        selectedProblem = problem
        selectedColor = nil
        currentStep = .color
        logger.info("Probleme selectionne : \(problem.rawValue)")
    }

    func goBackToZone() {
        selectedZone = nil
        selectedProblem = nil
        selectedColor = nil
        currentStep = .zone
        logger.info("Retour a la selection de zone")
    }

    func goBackToProblem() {
        selectedProblem = nil
        selectedColor = nil
        currentStep = .problem
        logger.info("Retour a la selection de probleme")
    }

    func selectColor(_ color: VehicleColor) {
        selectedColor = color
        plateText = ""
        currentStep = .plate
        logger.info("Couleur selectionnee : \(color.rawValue)")
    }

    func goBackToColor() {
        selectedColor = nil
        plateText = ""
        currentStep = .color
        logger.info("Retour a la selection de couleur")
    }

    func submitReport() async {
        guard let zone = selectedZone,
              let problem = selectedProblem,
              let color = selectedColor,
              isPlateValid,
              !isSubmitting else { return }

        isSubmitting = true
        state = .loading

        do {
            let result = try await reportService.submitReport(
                zone: zone,
                problemType: problem,
                vehicleColor: color,
                plate: formattedPlate
            )
            reportResult = result
            showConfirmation = true
            state = .loaded
            logger.info("Signalement soumis — resultat : \(String(describing: result))")
        } catch {
            state = .error(mapError(error))
            logger.error("Echec envoi signalement : \(error.localizedDescription)")
        }

        isSubmitting = false
    }

    func resetReport() {
        selectedZone = nil
        selectedProblem = nil
        selectedColor = nil
        plateText = ""
        currentStep = .zone
        state = .idle
        reportResult = nil
        showConfirmation = false
        isSubmitting = false
        logger.info("Signalement reinitialise")
    }

    private func mapError(_ error: Error) -> String {
        if let tycError = error as? TagYourCarError {
            return tycError.errorDescription ?? "Erreur inconnue."
        }
        return "Erreur lors de l'envoi du signalement. Reessayez."
    }

    // MARK: - Computed

    var availableProblems: [ProblemType] {
        guard let zone = selectedZone else { return [] }
        return ProblemType.problems(for: zone)
    }

    var formattedPlate: String {
        PlateValidator.format(plateText)
    }

    var isPlateValid: Bool {
        PlateValidator.isValid(formattedPlate)
    }

    var stepTitle: String {
        switch currentStep {
        case .zone: return "Ou est le probleme ?"
        case .problem: return "Quel probleme ?"
        case .color: return "Couleur du vehicule"
        case .plate: return "Plaque d'immatriculation"
        }
    }
}

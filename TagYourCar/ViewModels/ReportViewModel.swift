import Foundation
import os

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedZone: VehicleZone?
    @Published var selectedProblem: ProblemType?
    @Published var selectedColor: VehicleColor?
    @Published var currentStep: ReportStep = .zone
    @Published var state: ViewState = .idle

    private let logger = Logger(subsystem: "com.tagyourcar", category: "ReportViewModel")

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

    func resetReport() {
        selectedZone = nil
        selectedProblem = nil
        selectedColor = nil
        currentStep = .zone
        state = .idle
        logger.info("Signalement reinitialise")
    }

    // MARK: - Computed

    var availableProblems: [ProblemType] {
        guard let zone = selectedZone else { return [] }
        return ProblemType.problems(for: zone)
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

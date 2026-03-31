import SwiftUI
import UIKit

struct ProblemTypePicker: View {
    let zone: VehicleZone
    @Binding var selectedProblem: ProblemType?
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)

    private var problems: [ProblemType] {
        ProblemType.problems(for: zone)
    }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.lg) {
            ForEach(problems, id: \.rawValue) { problem in
                problemButton(for: problem)
            }
        }
        .padding(Theme.Spacing.lg)
    }

    @ViewBuilder
    private func problemButton(for problem: ProblemType) -> some View {
        let isSelected = selectedProblem == problem

        Button {
            impactMedium.prepare()
            impactMedium.impactOccurred()
            selectedProblem = problem
        } label: {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: sfSymbol(for: problem))
                    .font(.system(size: 32))
                    .frame(width: 64, height: 64)
                    .background(isSelected ? Theme.Colors.accentPrimary : Theme.Colors.bgCard)
                    .foregroundStyle(isSelected ? Theme.Colors.textOnAccent : Theme.Colors.accentSubtle)
                    .cornerRadius(Theme.Radius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                            .stroke(isSelected ? Theme.Colors.accentInteractive : Theme.Colors.bgSeparator, lineWidth: 2)
                    )
                    .scaleEffect(isSelected ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
        }
        .accessibilityLabel(accessibilityLabel(for: problem))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sfSymbol(for problem: ProblemType) -> String {
        switch problem {
        // Zone avant
        case .headlightsOn: return "light.beacon.max"
        case .hoodOpen: return "car.top.radiator.coolant.fill"
        case .chargeFlapOpen: return "bolt.car"
        case .flatTireFront: return "circle.slash"
        case .otherFront: return "questionmark.circle"
        // Zone milieu
        case .windowOpen: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .doorAjar: return "door.left.hand.open"
        case .sunroofOpen: return "sun.max"
        case .otherMiddle: return "questionmark.circle"
        // Zone arriere
        case .taillightsOn: return "light.beacon.max"
        case .fuelFlapOpen: return "fuelpump"
        case .trunkOpen: return "shippingbox"
        case .flatTireRear: return "circle.slash"
        case .otherRear: return "questionmark.circle"
        }
    }

    private func accessibilityLabel(for problem: ProblemType) -> String {
        switch problem {
        case .headlightsOn: return "Phares allumes"
        case .hoodOpen: return "Capot ouvert"
        case .chargeFlapOpen: return "Trappe de charge ouverte"
        case .flatTireFront: return "Pneu a plat avant"
        case .otherFront: return "Autre probleme zone avant"
        case .windowOpen: return "Vitre ouverte"
        case .doorAjar: return "Portiere mal fermee"
        case .sunroofOpen: return "Toit ouvrant ouvert"
        case .otherMiddle: return "Autre probleme zone milieu"
        case .taillightsOn: return "Feux allumes"
        case .fuelFlapOpen: return "Trappe a essence ouverte"
        case .trunkOpen: return "Coffre ouvert"
        case .flatTireRear: return "Pneu a plat arriere"
        case .otherRear: return "Autre probleme zone arriere"
        }
    }
}

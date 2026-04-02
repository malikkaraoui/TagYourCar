import SwiftUI
import UIKit

struct ProblemTypePicker: View {
    let zone: VehicleZone
    @Binding var selectedProblem: ProblemType?

    private var problems: [ProblemType] {
        ProblemType.problems(for: zone)
    }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
            ForEach(problems, id: \.rawValue) { problem in
                problemTile(for: problem)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    @ViewBuilder
    private func problemTile(for problem: ProblemType) -> some View {
        let isSelected = selectedProblem == problem

        SelectionTile(isSelected: isSelected, action: { selectedProblem = problem }) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: sfSymbol(for: problem))
                    .font(.system(size: Theme.Sizing.tileIconRegular))
                    .frame(width: 48, height: 48)
                    .foregroundStyle(isSelected ? Theme.Colors.accentInteractive : Theme.Colors.accentSubtle)

                Text(displayLabel(for: problem))
                    .font(Theme.Typography.captionSmall)
                    .foregroundStyle(isSelected ? Theme.Colors.accentInteractive : Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, Theme.Spacing.md)
            .padding(.horizontal, Theme.Spacing.sm)
        }
        .accessibilityLabel(displayLabel(for: problem))
    }

    // MARK: - Icones SF Symbols

    private func sfSymbol(for problem: ProblemType) -> String {
        switch problem {
        case .headlightsOn: return "light.beacon.max"
        case .hoodOpen: return "car.front.waves.up"
        case .chargeFlapOpen: return "bolt.car"
        case .flatTireFront: return "circle.slash"
        case .otherFront: return "questionmark.circle"
        case .windowOpen: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .doorAjar: return "door.left.hand.open"
        case .sunroofOpen: return "sun.max"
        case .otherMiddle: return "questionmark.circle"
        case .taillightsOn: return "light.beacon.max"
        case .fuelFlapOpen: return "fuelpump"
        case .trunkOpen: return "shippingbox"
        case .flatTireRear: return "circle.slash"
        case .otherRear: return "questionmark.circle"
        }
    }

    // MARK: - Labels

    private func displayLabel(for problem: ProblemType) -> String {
        switch problem {
        case .headlightsOn: return "Phares allumés"
        case .hoodOpen: return "Capot ouvert"
        case .chargeFlapOpen: return "Trappe de charge"
        case .flatTireFront: return "Pneu à plat"
        case .otherFront: return "Autre"
        case .windowOpen: return "Vitre ouverte"
        case .doorAjar: return "Portière ouverte"
        case .sunroofOpen: return "Toit ouvrant"
        case .otherMiddle: return "Autre"
        case .taillightsOn: return "Feux allumés"
        case .fuelFlapOpen: return "Trappe essence"
        case .trunkOpen: return "Coffre ouvert"
        case .flatTireRear: return "Pneu à plat"
        case .otherRear: return "Autre"
        }
    }
}

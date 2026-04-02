import SwiftUI
import UIKit

struct ColorSwatchGrid: View {
    @Binding var selectedColor: VehicleColor?

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
            ForEach(VehicleColor.allCases, id: \.rawValue) { color in
                colorTile(for: color)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    @ViewBuilder
    private func colorTile(for color: VehicleColor) -> some View {
        let isSelected = selectedColor == color

        SelectionTile(isSelected: isSelected, action: { selectedColor = color }) {
            VStack(spacing: Theme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.Radius.sm)
                        .fill(swiftUIColor(for: color))
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                .stroke(neutralBorder(for: color), lineWidth: 1)
                        )

                    if color == .other {
                        Image(systemName: "questionmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(checkmarkColor(for: color))
                    }
                }

                Text(displayLabel(for: color))
                    .font(Theme.Typography.captionSmall)
                    .foregroundStyle(isSelected ? Theme.Colors.accentInteractive : Theme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .padding(Theme.Spacing.sm)
        }
        .accessibilityLabel(displayLabel(for: color))
    }

    // MARK: - Couleurs

    private func swiftUIColor(for color: VehicleColor) -> Color {
        switch color {
        case .white: return .white
        case .black: return .black
        case .gray: return .gray
        case .silver: return Color(white: 0.78)
        case .blue: return .blue
        case .red: return .red
        case .green: return .green
        case .beige: return Color(red: 0.96, green: 0.87, blue: 0.70)
        case .yellow: return .yellow
        case .orange: return .orange
        case .brown: return .brown
        case .other: return Theme.Colors.bgSecondary
        }
    }

    private func neutralBorder(for color: VehicleColor) -> Color {
        switch color {
        case .white, .beige, .yellow, .silver:
            return Theme.Colors.bgSeparator
        default:
            return .clear
        }
    }

    private func checkmarkColor(for color: VehicleColor) -> Color {
        switch color {
        case .white, .yellow, .beige, .silver, .other:
            return Theme.Colors.accentPrimary
        default:
            return .white
        }
    }

    private func displayLabel(for color: VehicleColor) -> String {
        switch color {
        case .white: return "Blanc"
        case .black: return "Noir"
        case .gray: return "Gris"
        case .silver: return "Argent"
        case .blue: return "Bleu"
        case .red: return "Rouge"
        case .green: return "Vert"
        case .beige: return "Beige"
        case .yellow: return "Jaune"
        case .orange: return "Orange"
        case .brown: return "Marron"
        case .other: return "Autre"
        }
    }
}

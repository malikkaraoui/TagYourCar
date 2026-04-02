import SwiftUI
import UIKit

struct CarZoneSelector: View {
    @Binding var selectedZone: VehicleZone?
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Zone avant
            zoneButton(for: .front)

            // Zone milieu
            zoneButton(for: .middle)

            // Zone arriere
            zoneButton(for: .rear)
        }
        .padding(Theme.Spacing.lg)
    }

    @ViewBuilder
    private func zoneButton(for zone: VehicleZone) -> some View {
        let isSelected = selectedZone == zone

        Button {
            impactMedium.prepare()
            impactMedium.impactOccurred(intensity: 0.8)
            selectedZone = zone
        } label: {
            ZoneShape(zone: zone)
                .fill(isSelected ? Theme.Colors.accentInteractive : Theme.Colors.bgCard)
                .frame(height: zoneHeight(for: zone))
                .overlay(
                    ZoneShape(zone: zone)
                        .stroke(isSelected ? Theme.Colors.accentInteractive : Theme.Colors.bgSeparator, lineWidth: isSelected ? 2 : 1)
                )
                .overlay {
                    VStack(spacing: Theme.Spacing.xs) {
                        zoneIcon(for: zone)
                            .font(.system(size: 28, weight: .medium))
                        Text(zoneLabel(for: zone))
                            .font(Theme.Typography.captionSmall)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    .foregroundStyle(isSelected ? Theme.Colors.textOnAccent : Theme.Colors.textSecondary)
                }
                .cardShadow()
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isSelected)
        .accessibilityLabel(accessibilityLabel(for: zone))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func zoneHeight(for zone: VehicleZone) -> CGFloat {
        switch zone {
        case .front: return 120
        case .middle: return 100
        case .rear: return 110
        }
    }

    @ViewBuilder
    private func zoneIcon(for zone: VehicleZone) -> some View {
        switch zone {
        case .front:
            Image(systemName: "car.front.waves.up")
        case .middle:
            Image(systemName: "car.side")
        case .rear:
            Image(systemName: "car.rear")
        }
    }

    private func zoneLabel(for zone: VehicleZone) -> String {
        switch zone {
        case .front: return "Avant"
        case .middle: return "Milieu"
        case .rear: return "Arrière"
        }
    }

    private func accessibilityLabel(for zone: VehicleZone) -> String {
        switch zone {
        case .front: return "Zone avant du vehicule"
        case .middle: return "Zone milieu du vehicule"
        case .rear: return "Zone arrière du véhicule"
        }
    }
}

// Forme arrondie differente selon la zone pour simuler la silhouette
struct ZoneShape: Shape {
    let zone: VehicleZone

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        switch zone {
        case .front:
            return RoundedCornerShape(topLeft: radius * 2, topRight: radius * 2, bottomLeft: radius, bottomRight: radius).path(in: rect)
        case .middle:
            return RoundedCornerShape(topLeft: radius / 2, topRight: radius / 2, bottomLeft: radius / 2, bottomRight: radius / 2).path(in: rect)
        case .rear:
            return RoundedCornerShape(topLeft: radius, topRight: radius, bottomLeft: radius * 2, bottomRight: radius * 2).path(in: rect)
        }
    }
}

struct RoundedCornerShape: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX, y: rect.minY + topRight), radius: topRight)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY), radius: bottomRight)
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft), radius: bottomLeft)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.minX + topLeft, y: rect.minY), radius: topLeft)
        return path
    }
}

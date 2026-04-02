import SwiftUI

struct ReportDetailView: View {
    let reportData: ReportNotificationData
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                Spacer()

                // Icone zone
                Image(systemName: zoneIcon)
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.Colors.accentPrimary)

                // Type de probleme
                Text(problemLabel)
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                // Details
                VStack(spacing: Theme.Spacing.md) {
                    detailRow(icon: "car.top.door.front.left.open", label: "Zone", value: zoneLabel)
                    detailRow(icon: "paintpalette", label: "Couleur", value: colorLabel)
                    detailRow(icon: "number", label: "Plaque", value: reportData.partialPlate)
                    detailRow(icon: "clock", label: "Signale", value: reportData.formattedTime ?? "À l'instant")
                }
                .padding(Theme.Spacing.lg)
                .background(Theme.Colors.bgCard)
                .cornerRadius(Theme.Radius.lg)
                .cardShadow()
                .padding(.horizontal, Theme.Spacing.lg)

                Spacer()

                Text("Vous savez quoi faire.")
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .padding(.bottom, Theme.Spacing.lg)
            }
            .background(Theme.Colors.bgPrimary.ignoresSafeArea())
            .navigationTitle("Signalement reçu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { onDismiss() }
                        .foregroundStyle(Theme.Colors.accentInteractive)
                        .accessibilityLabel("Fermer le detail du signalement")
                }
            }
        }
    }

    @ViewBuilder
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Theme.Colors.accentSubtle)
                .frame(width: 24)
            Text(label)
                .font(Theme.Typography.bodySmall)
                .foregroundStyle(Theme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) : \(value)")
    }

    private var zoneIcon: String {
        switch reportData.zone {
        case "front": return "car.front.waves.up"
        case "middle": return "car.side"
        case "rear": return "car.rear"
        default: return "car"
        }
    }

    private var zoneLabel: String {
        switch reportData.zone {
        case "front": return "Avant"
        case "middle": return "Milieu"
        case "rear": return "Arrière"
        default: return reportData.zone
        }
    }

    private var problemLabel: String {
        let labels: [String: String] = [
            "headlights_on": "Phares allumés",
            "hood_open": "Capot ouvert",
            "charge_flap_open": "Trappe de charge ouverte",
            "flat_tire_front": "Pneu à plat (avant)",
            "other_front": "Problème signalé (avant)",
            "window_open": "Vitre ouverte",
            "door_ajar": "Portière mal fermée",
            "sunroof_open": "Toit ouvrant ouvert",
            "other_middle": "Problème signalé (milieu)",
            "taillights_on": "Feux allumés",
            "fuel_flap_open": "Trappe à essence ouverte",
            "trunk_open": "Coffre ouvert",
            "flat_tire_rear": "Pneu à plat (arriere)",
            "other_rear": "Problème signalé (arriere)",
        ]
        return labels[reportData.problemType] ?? "Problème signalé"
    }

    private var colorLabel: String {
        let labels: [String: String] = [
            "white": "Blanc", "black": "Noir", "gray": "Gris", "silver": "Argent",
            "blue": "Bleu", "red": "Rouge", "green": "Vert", "beige": "Beige",
            "yellow": "Jaune", "orange": "Orange", "brown": "Marron", "other": "Autre",
        ]
        return labels[reportData.vehicleColor] ?? reportData.vehicleColor
    }
}

/// Donnees extraites de la notification push
struct ReportNotificationData {
    let reportId: String
    let zone: String
    let problemType: String
    let vehicleColor: String
    let partialPlate: String
    var formattedTime: String?

    init(userInfo: [AnyHashable: Any]) {
        self.reportId = userInfo["reportId"] as? String ?? ""
        self.zone = userInfo["zone"] as? String ?? ""
        self.problemType = userInfo["problemType"] as? String ?? ""
        self.vehicleColor = userInfo["vehicleColor"] as? String ?? ""
        self.partialPlate = userInfo["partialPlate"] as? String ?? ""
        self.formattedTime = nil
    }

    init(reportId: String, zone: String, problemType: String, vehicleColor: String, partialPlate: String) {
        self.reportId = reportId
        self.zone = zone
        self.problemType = problemType
        self.vehicleColor = vehicleColor
        self.partialPlate = partialPlate
        self.formattedTime = nil
    }
}

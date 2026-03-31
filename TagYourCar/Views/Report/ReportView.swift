import SwiftUI

struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Indicateur d'etape
                stepIndicator

                Spacer()

                // Contenu selon l'etape
                switch viewModel.currentStep {
                case .zone:
                    zoneStep
                case .problem:
                    problemStep
                case .color:
                    colorStep
                case .plate:
                    plateStep
                }

                Spacer()
            }
            .background(Theme.Colors.bgPrimary.ignoresSafeArea())
            .navigationTitle("Signaler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.currentStep != .zone {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                goBack()
                            }
                        } label: {
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "chevron.left")
                                Text("Retour")
                            }
                            .foregroundStyle(Theme.Colors.accentInteractive)
                        }
                        .accessibilityLabel("Retour a l'etape precedente")
                    }
                }
            }
        }
    }

    // MARK: - Indicateur d'etape

    private var stepIndicator: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(0..<4) { index in
                Capsule()
                    .fill(index <= viewModel.currentStep.rawValue
                          ? Theme.Colors.accentPrimary
                          : Theme.Colors.bgSeparator)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.sm)
        .animation(.easeInOut(duration: 0.25), value: viewModel.currentStep)
    }

    // MARK: - Etape 1 : Selection de zone

    private var zoneStep: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text(viewModel.stepTitle)
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Colors.textPrimary)

            CarZoneSelector(selectedZone: Binding(
                get: { viewModel.selectedZone },
                set: { zone in
                    if let zone {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.selectZone(zone)
                        }
                    }
                }
            ))
        }
        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
    }

    // MARK: - Etape 2 : Selection de probleme

    private var problemStep: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text(viewModel.stepTitle)
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Colors.textPrimary)

            if let zone = viewModel.selectedZone {
                ProblemTypePicker(zone: zone, selectedProblem: Binding(
                    get: { viewModel.selectedProblem },
                    set: { problem in
                        if let problem {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.selectProblem(problem)
                            }
                        }
                    }
                ))
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
    }

    // MARK: - Etape 3 : Selection de couleur

    private var colorStep: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text(viewModel.stepTitle)
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Colors.textPrimary)

            ColorSwatchGrid(selectedColor: Binding(
                get: { viewModel.selectedColor },
                set: { color in
                    if let color {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.selectColor(color)
                        }
                    }
                }
            ))
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
    }

    // MARK: - Etape 4 : Saisie plaque

    private var plateStep: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text(viewModel.stepTitle)
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Colors.textPrimary)

            Text("Saisissez la plaque du vehicule")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)

            PlateTextField(text: $viewModel.plateText, isValid: viewModel.isPlateValid)
                .padding(.horizontal, Theme.Spacing.xl)
                .accessibilityLabel("Champ plaque d'immatriculation")
                .accessibilityHint("Format AA-123-AA. L'envoi sera automatique.")

            if viewModel.isPlateValid {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.Colors.success)
                    Text("Plaque valide — envoi en cours...")
                        .font(Theme.Typography.bodySmall)
                        .foregroundStyle(Theme.Colors.success)
                }
                .transition(.opacity)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
        .onChange(of: viewModel.plateText) { _ in
            if viewModel.isPlateValid {
                // Envoi automatique — Story 3.3 implementera la logique backend
            }
        }
    }

    // MARK: - Navigation arriere

    private func goBack() {
        switch viewModel.currentStep {
        case .zone:
            break
        case .problem:
            viewModel.goBackToZone()
        case .color:
            viewModel.goBackToProblem()
        case .plate:
            viewModel.goBackToColor()
        }
    }
}

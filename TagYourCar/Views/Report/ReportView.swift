import SwiftUI

struct ReportView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ReportViewModel()

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    stepIndicator

                    Spacer()

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
                    if viewModel.currentStep != .zone && !viewModel.isSubmitting {
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
            .disabled(viewModel.showConfirmation)

            // Ecran de confirmation par-dessus
            if viewModel.showConfirmation, let result = viewModel.reportResult {
                ConfirmationView(
                    variant: result == .sent ? .success : .notRegistered,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.resetReport()
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showConfirmation)
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

    // MARK: - Etape 4 : Saisie plaque + envoi automatique

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
                .disabled(viewModel.isSubmitting)

            if viewModel.isSubmitting {
                HStack(spacing: Theme.Spacing.sm) {
                    ProgressView()
                        .tint(Theme.Colors.accentPrimary)
                    Text("Envoi en cours...")
                        .font(Theme.Typography.bodySmall)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .transition(.opacity)
            } else if case .error(let message) = viewModel.state {
                Text(message)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
        .onChange(of: viewModel.plateText) { _ in
            if viewModel.isPlateValid && !viewModel.isSubmitting {
                let uid = authService.currentUser?.uid ?? ""
                Task {
                    await viewModel.submitReport(uid: uid)
                }
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

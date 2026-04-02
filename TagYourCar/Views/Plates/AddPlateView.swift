import SwiftUI

struct AddPlateView: View {
    @ObservedObject var viewModel: PlateViewModel
    let uid: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                Text("Ajouter une plaque")
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Saisissez votre plaque d'immatriculation au format français.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)

                PlateTextField(text: $viewModel.plateInput, isValid: viewModel.isPlateValid)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Theme.Typography.bodySmall)
                        .foregroundStyle(Theme.Colors.error)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(Theme.Colors.accentPrimary)
                    Text("Votre plaque est chiffrée et illisible, même par nous.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .padding(.top, Theme.Spacing.xs)

                Spacer()

                Button {
                    Task { await viewModel.addPlate(for: uid) }
                } label: {
                    Group {
                        if viewModel.state == .loading {
                            ProgressView()
                                .tint(Theme.Colors.textOnAccent)
                        } else {
                            Text("Enregistrer la plaque")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(viewModel.canAddPlate ? Theme.Colors.accentInteractive : Theme.Colors.accentMuted)
                    .foregroundStyle(Theme.Colors.textOnAccent)
                    .cornerRadius(Theme.Radius.md)
                }
                .disabled(!viewModel.canAddPlate || viewModel.state == .loading)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.lg)
            .background(Theme.Colors.bgPrimary.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        viewModel.resetInput()
                        dismiss()
                    }
                    .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            .onDisappear {
                viewModel.resetInput()
            }
        }
    }
}

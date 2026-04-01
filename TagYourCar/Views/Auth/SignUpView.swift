import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var passwordVisible = false

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Créer un compte")
                        .font(Theme.Typography.h1)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text("Rejoignez la communauté TagYourCar")
                        .font(Theme.Typography.bodySmall)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Theme.Spacing.md) {
                    HStack(spacing: Theme.Spacing.sm) {
                        TextField("Prénom", text: $viewModel.firstName)
                            .textContentType(.givenName)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.bgCard)
                            .cornerRadius(Theme.Radius.md)
                            .accessibilityLabel("Prénom")

                        TextField("Nom", text: $viewModel.lastName)
                            .textContentType(.familyName)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.bgCard)
                            .cornerRadius(Theme.Radius.md)
                            .accessibilityLabel("Nom de famille")
                    }

                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.bgCard)
                        .cornerRadius(Theme.Radius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.md)
                                .stroke(
                                    !viewModel.email.isEmpty && !viewModel.isEmailValid
                                        ? Theme.Colors.error
                                        : Theme.Colors.bgSeparator,
                                    lineWidth: 1
                                )
                        )
                        .accessibilityLabel("Email")
                        .accessibilityHint(viewModel.email.isEmpty ? "Entrez votre email" : viewModel.isEmailValid ? "Email valide" : "Email invalide")

                    ZStack(alignment: .trailing) {
                        Group {
                            if passwordVisible {
                                TextField("Mot de passe (6 caracteres min.)", text: $viewModel.password)
                                    .textContentType(.newPassword)
                            } else {
                                SecureField("Mot de passe (6 caracteres min.)", text: $viewModel.password)
                                    .textContentType(.newPassword)
                            }
                        }
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(Theme.Spacing.md)
                        .padding(.trailing, 44)
                        .background(Theme.Colors.bgCard)
                        .cornerRadius(Theme.Radius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.md)
                                .stroke(
                                    !viewModel.password.isEmpty && !viewModel.isPasswordValid
                                        ? Theme.Colors.error
                                        : Theme.Colors.bgSeparator,
                                    lineWidth: 1
                                )
                        )

                        Button {
                            passwordVisible.toggle()
                        } label: {
                            Image(systemName: passwordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(Theme.Colors.textSecondary)
                                .padding(.trailing, Theme.Spacing.md)
                        }
                        .accessibilityLabel(passwordVisible ? "Masquer le mot de passe" : "Afficher le mot de passe")
                    }
                    .accessibilityLabel("Mot de passe")
                    .accessibilityHint("Minimum 6 caractères")
                }

                // CGU Checkbox
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Button {
                        viewModel.cguAccepted.toggle()
                    } label: {
                        Image(systemName: viewModel.cguAccepted ? "checkmark.square.fill" : "square")
                            .foregroundStyle(viewModel.cguAccepted ? Theme.Colors.accentPrimary : Theme.Colors.textSecondary)
                            .font(.title3)
                    }
                    .accessibilityLabel("Case à cocher CGU")
                    .accessibilityValue(viewModel.cguAccepted ? "Cochée" : "Non cochée")
                    .accessibilityHint("Cochez pour accepter les conditions générales")

                    Text("J'accepte les [Conditions Générales d'Utilisation](https://tagyourcar.com/cgu) et la [Politique de Confidentialité](https://tagyourcar.com/confidentialite)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .tint(Theme.Colors.accentInteractive)
                }
                .padding(.top, Theme.Spacing.xs)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Theme.Typography.bodySmall)
                        .foregroundStyle(Theme.Colors.error)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("Erreur: \(errorMessage)")
                }

                Button {
                    Task { await viewModel.signUp() }
                } label: {
                    Group {
                        if viewModel.state == .loading {
                            ProgressView()
                                .tint(Theme.Colors.textOnAccent)
                        } else {
                            Text("S'inscrire")
                                .font(Theme.Typography.bodyMedium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(viewModel.canSignUp ? Theme.Colors.accentInteractive : Theme.Colors.accentMuted)
                    .foregroundStyle(Theme.Colors.textOnAccent)
                    .cornerRadius(Theme.Radius.lg)
                }
                .disabled(!viewModel.canSignUp || viewModel.state == .loading)
                .accentGlow()
                .opacity(viewModel.canSignUp ? 1 : 0.6)
                .accessibilityLabel(viewModel.state == .loading ? "Inscription en cours" : "Bouton s'inscrire")
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.Colors.bgPrimary.ignoresSafeArea())
        .navigationBarBackButtonHidden(false)
    }
}

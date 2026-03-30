import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                Text("Creer un compte")
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Theme.Spacing.md) {
                    HStack(spacing: Theme.Spacing.sm) {
                        TextField("Prenom", text: $viewModel.firstName)
                            .textContentType(.givenName)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.bgCard)
                            .cornerRadius(Theme.Radius.md)

                        TextField("Nom", text: $viewModel.lastName)
                            .textContentType(.familyName)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.bgCard)
                            .cornerRadius(Theme.Radius.md)
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

                    SecureField("Mot de passe (6 caracteres min.)", text: $viewModel.password)
                        .textContentType(.newPassword)
                        .padding(Theme.Spacing.md)
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
                }

                // CGU Checkbox
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Image(systemName: viewModel.cguAccepted ? "checkmark.square.fill" : "square")
                        .foregroundStyle(viewModel.cguAccepted ? Theme.Colors.accentPrimary : Theme.Colors.textSecondary)
                        .font(.title3)
                        .onTapGesture {
                            viewModel.cguAccepted.toggle()
                        }

                    Text("J'accepte les [Conditions Generales d'Utilisation](https://tagyourcar.com/cgu) et la [Politique de Confidentialite](https://tagyourcar.com/confidentialite)")
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
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(viewModel.canSignUp ? Theme.Colors.accentInteractive : Theme.Colors.accentMuted)
                    .foregroundStyle(Theme.Colors.textOnAccent)
                    .cornerRadius(Theme.Radius.md)
                }
                .disabled(!viewModel.canSignUp || viewModel.state == .loading)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.lg)
        }
        .background(Theme.Colors.bgPrimary.ignoresSafeArea())
        .navigationBarBackButtonHidden(false)
    }
}

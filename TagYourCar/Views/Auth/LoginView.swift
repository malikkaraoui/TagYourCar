import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: AuthViewModel

    @State private var showSignUp = false

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                Spacer()

                Text("TagYourCar")
                    .font(Theme.Typography.display)
                    .foregroundStyle(Theme.Colors.accentPrimary)

                VStack(spacing: Theme.Spacing.md) {
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

                    SecureField("Mot de passe", text: $viewModel.password)
                        .textContentType(.password)
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

                    if !viewModel.password.isEmpty && !viewModel.isPasswordValid {
                        Text("6 caracteres minimum")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Theme.Typography.bodySmall)
                        .foregroundStyle(Theme.Colors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task { await viewModel.signIn() }
                } label: {
                    Group {
                        if viewModel.state == .loading {
                            ProgressView()
                                .tint(Theme.Colors.textOnAccent)
                        } else {
                            Text("Se connecter")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(viewModel.canSignIn ? Theme.Colors.accentInteractive : Theme.Colors.accentMuted)
                    .foregroundStyle(Theme.Colors.textOnAccent)
                    .cornerRadius(Theme.Radius.md)
                }
                .disabled(!viewModel.canSignIn || viewModel.state == .loading)

                Button("Pas encore de compte ? S'inscrire") {
                    showSignUp = true
                }
                .font(Theme.Typography.bodySmall)
                .foregroundStyle(Theme.Colors.accentInteractive)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .background(Theme.Colors.bgPrimary.ignoresSafeArea())
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authService: authService)
            }
        }
    }
}

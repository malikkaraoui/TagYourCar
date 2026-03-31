import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: AuthViewModel

    @State private var showSignUp = false

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    Spacer().frame(height: Theme.Spacing.xl)

                    Text("TagYourCar")
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.accentPrimary)

                    // Social Sign-In Buttons
                    VStack(spacing: Theme.Spacing.sm) {
                        SignInWithAppleButton(.signIn) { request in
                            let (_, hashedNonce) = authService.prepareAppleSignIn()
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = hashedNonce
                        } onCompletion: { result in
                            Task {
                                switch result {
                                case .success(let authorization):
                                    do {
                                        try await authService.handleAppleSignIn(authorization: authorization)
                                    } catch {
                                        viewModel.errorMessage = "Connexion Apple echouee."
                                    }
                                case .failure:
                                    break // Annulation silencieuse
                                }
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(Theme.Radius.md)
                        .accessibilityLabel("Se connecter avec Apple")

                        Button {
                            Task {
                                do {
                                    try await authService.signInWithGoogle()
                                } catch let error as GIDSignInError where error.code == .canceled {
                                    return // Annulation silencieuse
                                } catch {
                                    viewModel.errorMessage = "Connexion Google echouee."
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Continuer avec Google")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.bgCard)
                            .foregroundStyle(Theme.Colors.textPrimary)
                            .cornerRadius(Theme.Radius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.md)
                                    .stroke(Theme.Colors.bgSeparator, lineWidth: 1)
                            )
                        }
                        .accessibilityLabel("Se connecter avec Google")

                        Button {
                            Task {
                                do {
                                    try await authService.signInWithGitHub()
                                } catch {
                                    let nsError = error as NSError
                                    if nsError.code == AuthErrorCode.webContextCancelled.rawValue || nsError.code == AuthErrorCode.webContextAlreadyPresented.rawValue {
                                        return // Annulation silencieuse
                                    }
                                    viewModel.errorMessage = "Connexion GitHub echouee."
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                Text("Continuer avec GitHub")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.bgCard)
                            .foregroundStyle(Theme.Colors.textPrimary)
                            .cornerRadius(Theme.Radius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.md)
                                    .stroke(Theme.Colors.bgSeparator, lineWidth: 1)
                            )
                        }
                        .accessibilityLabel("Se connecter avec GitHub")
                    }

                    // Separator
                    HStack {
                        Rectangle().frame(height: 1).foregroundStyle(Theme.Colors.bgSeparator)
                        Text("ou").font(Theme.Typography.caption).foregroundStyle(Theme.Colors.textSecondary)
                        Rectangle().frame(height: 1).foregroundStyle(Theme.Colors.bgSeparator)
                    }

                    // Email fields
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
                            .accessibilityLabel("Champ email")
                            .accessibilityHint(viewModel.email.isEmpty ? "Entrez votre adresse email" : viewModel.isEmailValid ? "Email valide" : "Email invalide")

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
                            .accessibilityLabel("Champ mot de passe")
                            .accessibilityHint("Minimum 6 caracteres")

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
                            .accessibilityLabel("Erreur: \(errorMessage)")
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
                    .accessibilityLabel(viewModel.state == .loading ? "Connexion en cours" : "Bouton se connecter")

                    Button("Pas encore de compte ? S'inscrire") {
                        showSignUp = true
                    }
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.accentInteractive)
                    .accessibilityLabel("Créer un compte")

                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.Colors.bgPrimary.ignoresSafeArea())
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(authService: authService)
            }
        }
    }
}

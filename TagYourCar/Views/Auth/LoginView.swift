import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: AuthViewModel

    @State private var showSignUp = false
    @State private var passwordVisible = false

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {

                    // En-tête compact pour éviter l'effet "deuxième splash"
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Theme.Colors.accentInteractive)

                            Text("TagYourCar")
                                .font(Theme.Typography.h1)
                                .foregroundStyle(Theme.Colors.textPrimary)
                        }

                        Text("Connectez-vous pour signaler un problème ou recevoir vos alertes véhicule.")
                            .font(Theme.Typography.bodySmall)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.xs)

                    // Social Sign-In Buttons
                    // Note : Sign in with Apple nécessite un compte Apple Developer Program (99$/an)
                    // Le bouton sera réactivé une fois le compte souscrit
                    VStack(spacing: Theme.Spacing.sm) {

                        Button {
                            Task {
                                do {
                                    try await authService.signInWithGoogle()
                                } catch let error as GIDSignInError where error.code == .canceled {
                                    return // Annulation silencieuse
                                } catch {
                                    viewModel.errorMessage = "Connexion Google échouée."
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
                                    viewModel.errorMessage = "Connexion GitHub échouée."
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

                        ZStack(alignment: .trailing) {
                            Group {
                                if passwordVisible {
                                    TextField("Mot de passe", text: $viewModel.password)
                                        .textContentType(.password)
                                } else {
                                    SecureField("Mot de passe", text: $viewModel.password)
                                        .textContentType(.password)
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
                        .accessibilityLabel("Champ mot de passe")
                        .accessibilityHint("Minimum 6 caracteres")

                        if !viewModel.password.isEmpty && !viewModel.isPasswordValid {
                            Text("6 caractères minimum")
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
                                    .font(Theme.Typography.bodyMedium)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.canSignIn ? Theme.Colors.accentInteractive : Theme.Colors.accentMuted)
                        .foregroundStyle(Theme.Colors.textOnAccent)
                        .cornerRadius(Theme.Radius.lg)
                    }
                    .disabled(!viewModel.canSignIn || viewModel.state == .loading)
                    .accentGlow()
                    .opacity(viewModel.canSignIn ? 1 : 0.6)
                    .accessibilityLabel(viewModel.state == .loading ? "Connexion en cours" : "Bouton se connecter")

                    Button {
                        showSignUp = true
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            Text("Pas encore de compte ?")
                                .foregroundStyle(Theme.Colors.textSecondary)
                            Text("S'inscrire")
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.accentInteractive)
                        }
                        .font(Theme.Typography.bodySmall)
                    }
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

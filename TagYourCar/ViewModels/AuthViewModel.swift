import Foundation
import os

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var cguAccepted = false
    @Published var state: ViewState = .idle
    @Published var errorMessage: String?

    private let authService: AuthService
    private let logger = Logger(subsystem: "com.tagyourcar", category: "AuthViewModel")

    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Validation

    var isEmailValid: Bool {
        let pattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: pattern) != nil
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    var canSignIn: Bool {
        isEmailValid && isPasswordValid
    }

    var canSignUp: Bool {
        isEmailValid && isPasswordValid && !firstName.isEmpty && !lastName.isEmpty && cguAccepted
    }

    // MARK: - Actions

    func signIn() async {
        state = .loading
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
            state = .loaded
        } catch {
            state = .error(mapError(error))
            errorMessage = mapError(error)
            logger.error("Sign in failed: \(error.localizedDescription)")
        }
    }

    func signUp() async {
        state = .loading
        errorMessage = nil
        do {
            try await authService.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            state = .loaded
        } catch {
            state = .error(mapError(error))
            errorMessage = mapError(error)
            logger.error("Sign up failed: \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            resetFields()
        } catch {
            logger.error("Sign out failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func resetFields() {
        email = ""
        password = ""
        firstName = ""
        lastName = ""
        cguAccepted = false
        state = .idle
        errorMessage = nil
    }

    private func mapError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case 17008:
            return "Adresse email invalide."
        case 17009, 17004:
            return "Email ou mot de passe incorrect."
        case 17007:
            return "Un compte avec cet email existe deja."
        case 17026:
            return "Le mot de passe doit contenir au moins 6 caracteres."
        case 17020:
            return "Pas de connexion internet. Verifiez votre reseau."
        default:
            return "Une erreur est survenue. Reessayez."
        }
    }
}

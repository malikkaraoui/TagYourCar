import Foundation
import AuthenticationServices

@MainActor
protocol AuthServiceProtocol: ObservableObject {
    var currentUser: AppUser? { get }
    var isAuthenticated: Bool { get }

    func signUp(email: String, password: String, firstName: String, lastName: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func prepareAppleSignIn() -> (nonce: String, hashedNonce: String)
    func handleAppleSignIn(authorization: ASAuthorization) async throws
    func signInWithGoogle() async throws
    func signInWithGitHub() async throws
    func updateProfile(firstName: String, lastName: String) async throws
}

extension AuthService: AuthServiceProtocol {}

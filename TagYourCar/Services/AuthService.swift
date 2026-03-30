import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import os

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var needsCGUAcceptance = false

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let logger = Logger(subsystem: "com.tagyourcar", category: "AuthService")
    private nonisolated(unsafe) var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    init() {
        listenToAuthState()
    }

    // MARK: - Auth State Listener

    private func listenToAuthState() {
        authStateListener = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let firebaseUser {
                    self.isAuthenticated = true
                    await self.fetchOrCreateUser(firebaseUser: firebaseUser)
                } else {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }

    // MARK: - Email Sign Up

    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        let displayName = "\(firstName) \(lastName)"

        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()

        let appUser = AppUser(
            uid: result.user.uid,
            email: email,
            displayName: displayName,
            createdAt: Date()
        )

        try db.collection("users").document(result.user.uid).setData(from: appUser)
        self.currentUser = appUser
        logger.info("User signed up via email: \(result.user.uid)")
    }

    // MARK: - Email Sign In

    func signIn(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        await fetchOrCreateUser(firebaseUser: result.user)
        logger.info("User signed in via email: \(result.user.uid)")
    }

    // MARK: - Apple Sign-In

    func prepareAppleSignIn() -> (nonce: String, hashedNonce: String) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)
        return (nonce, hashedNonce)
    }

    func handleAppleSignIn(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let nonce = currentNonce else {
            throw TagYourCarError.unknownError
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        let result = try await auth.signIn(with: credential)
        await fetchOrCreateUser(firebaseUser: result.user)
        logger.info("User signed in via Apple: \(result.user.uid)")
    }

    // MARK: - Google Sign-In

    func signInWithGoogle() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw TagYourCarError.unknownError
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw TagYourCarError.unknownError
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await auth.signIn(with: credential)
        await fetchOrCreateUser(firebaseUser: authResult.user)
        logger.info("User signed in via Google: \(authResult.user.uid)")
    }

    // MARK: - GitHub Sign-In

    func signInWithGitHub() async throws {
        let provider = OAuthProvider(providerID: "github.com")

        let credential = try await provider.credential(with: nil)
        let result = try await auth.signIn(with: credential)
        await fetchOrCreateUser(firebaseUser: result.user)
        logger.info("User signed in via GitHub: \(result.user.uid)")
    }

    // MARK: - Sign Out

    func signOut() throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        isAuthenticated = false
        logger.info("User signed out")
    }

    // MARK: - Fetch or Create User

    private func fetchOrCreateUser(firebaseUser: FirebaseAuth.User) async {
        do {
            let document = try await db.collection("users").document(firebaseUser.uid).getDocument()
            if document.exists {
                self.currentUser = try document.data(as: AppUser.self)
            } else {
                let appUser = AppUser(
                    uid: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName ?? "",
                    createdAt: Date()
                )
                try db.collection("users").document(firebaseUser.uid).setData(from: appUser)
                self.currentUser = appUser
                logger.info("Created Firestore user for social sign-in: \(firebaseUser.uid)")
            }
        } catch {
            logger.error("Failed to fetch/create user: \(error.localizedDescription)")
        }
    }

    // MARK: - Crypto Helpers

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

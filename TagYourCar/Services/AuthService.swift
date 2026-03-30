import Foundation
import FirebaseAuth
import FirebaseFirestore
import os

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let logger = Logger(subsystem: "com.tagyourcar", category: "AuthService")
    private nonisolated(unsafe) var authStateListener: AuthStateDidChangeListenerHandle?

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
                    await self.fetchUser(uid: firebaseUser.uid)
                } else {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        }
    }

    // MARK: - Sign Up

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
        logger.info("User signed up: \(result.user.uid)")
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        await fetchUser(uid: result.user.uid)
        logger.info("User signed in: \(result.user.uid)")
    }

    // MARK: - Sign Out

    func signOut() throws {
        try auth.signOut()
        currentUser = nil
        isAuthenticated = false
        logger.info("User signed out")
    }

    // MARK: - Fetch User

    private func fetchUser(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try document.data(as: AppUser.self)
        } catch {
            logger.error("Failed to fetch user: \(error.localizedDescription)")
        }
    }
}

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import GoogleSignIn
import os

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var isReady = false
    @Published var needsCGUAcceptance = false

    private var auth: Auth? {
        guard FirebaseApp.app() != nil else { return nil }
        return Auth.auth()
    }
    private var db: Firestore? {
        guard FirebaseApp.app() != nil else { return nil }
        return Firestore.firestore()
    }
    private let logger = Logger(subsystem: "com.tagyourcar", category: "AuthService")
    private nonisolated(unsafe) var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    private var authListenerStarted = false
    private var isFirebaseConfigured: Bool {
        FirebaseApp.app() != nil
    }
    var hasResolvedInitialRoute: Bool {
        isReady || isAuthenticated || currentUser != nil
    }

    init() {
        // Restaurer le profil depuis le cache local pour un affichage instantané
        restoreCachedUser()
    }

    // MARK: - Cache local (UserDefaults)

    private static let cachedUserKey = "com.tagyourcar.cachedUser"

    private func cacheUser(_ user: AppUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: Self.cachedUserKey)
        }
    }

    private func restoreCachedUser() {
        guard let data = UserDefaults.standard.data(forKey: Self.cachedUserKey) else { return }
        guard let user = try? JSONDecoder().decode(AppUser.self, from: data) else {
            logger.error("Cache utilisateur invalide — purge du profil local")
            clearCachedUser()
            return
        }

        currentUser = user
        isAuthenticated = true
        logger.info("Profil restauré depuis le cache local : \(user.uid)")
    }

    private func clearCachedUser() {
        UserDefaults.standard.removeObject(forKey: Self.cachedUserKey)
    }

    func activateIfNeeded() {
        guard isFirebaseConfigured else {
            logger.warning("Firebase non configuré — authentification indisponible tant que GoogleService-Info.plist est absent")
            isReady = true
            return
        }

        let localFirebaseUser = auth?.currentUser
        applyLocalSession(firebaseUser: localFirebaseUser)

        guard !authListenerStarted else { return }
        listenToAuthState()
    }

    private func applyLocalSession(firebaseUser: FirebaseAuth.User?) {
        guard let firebaseUser else {
            isAuthenticated = false
            currentUser = nil
            clearCachedUser()
            isReady = true
            return
        }

        isAuthenticated = true

        if currentUser?.uid != firebaseUser.uid {
            let bootstrappedUser = AppUser(
                uid: firebaseUser.uid,
                email: firebaseUser.email ?? currentUser?.email ?? "",
                displayName: firebaseUser.displayName ?? currentUser?.displayName ?? "",
                createdAt: currentUser?.createdAt ?? Date()
            )
            currentUser = bootstrappedUser
            cacheUser(bootstrappedUser)
        }

        isReady = true
    }

    // MARK: - Auth State Listener

    private func listenToAuthState() {
        guard authStateListener == nil else { return }
        guard let auth else {
            logger.warning("Auth indisponible — listener non initialise")
            return
        }

        authListenerStarted = true

        authStateListener = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let firebaseUser {
                    self.applyLocalSession(firebaseUser: firebaseUser)
                } else {
                    self.applyLocalSession(firebaseUser: nil)
                }
            }
        }
    }

    // MARK: - Email Sign Up

    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        activateIfNeeded()

        guard let auth, let db else {
            logger.warning("Tentative d'inscription sans configuration Firebase")
            throw TagYourCarError.firebaseNotConfigured
        }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        let result = try await auth.createUser(withEmail: normalizedEmail, password: password)
        let displayName = [normalizedFirstName, normalizedLastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        do {
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()

            let appUser = AppUser(
                uid: result.user.uid,
                email: normalizedEmail,
                displayName: displayName,
                createdAt: Date()
            )

            try await db.collection("users").document(result.user.uid).setData(from: appUser)
            self.currentUser = appUser
            self.isAuthenticated = true
            cacheUser(appUser)
            logger.info("User signed up via email: \(result.user.uid)")
        } catch {
            logger.error("Finalisation inscription email echouee: \(error.localizedDescription)")

            do {
                try await result.user.delete()
                logger.info("Rollback utilisateur Auth apres echec Firestore: \(result.user.uid)")
            } catch {
                logger.error("Rollback utilisateur Auth impossible: \(error.localizedDescription)")
            }

            throw error
        }
    }

    // MARK: - Email Sign In

    func signIn(email: String, password: String) async throws {
        activateIfNeeded()

        guard let auth else {
            logger.warning("Tentative de connexion sans configuration Firebase")
            throw TagYourCarError.firebaseNotConfigured
        }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let result = try await auth.signIn(withEmail: normalizedEmail, password: password)
        await fetchOrCreateUser(
            uid: result.user.uid,
            email: result.user.email ?? normalizedEmail,
            displayName: result.user.displayName ?? currentUser?.displayName ?? ""
        )
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
        activateIfNeeded()

        guard let auth else {
            logger.warning("Tentative de connexion Apple sans configuration Firebase")
            throw TagYourCarError.firebaseNotConfigured
        }

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
        await fetchOrCreateUser(
            uid: result.user.uid,
            email: result.user.email ?? currentUser?.email ?? "",
            displayName: result.user.displayName ?? currentUser?.displayName ?? ""
        )
        logger.info("User signed in via Apple: \(result.user.uid)")
    }

    // MARK: - Google Sign-In

    func signInWithGoogle() async throws {
        activateIfNeeded()

        guard let auth else {
            logger.warning("Tentative de connexion Google sans configuration Firebase")
            throw TagYourCarError.firebaseNotConfigured
        }

        // Configurer GIDSignIn si ce n'est pas déjà fait (nécessaire après deconnexion)
        if GIDSignIn.sharedInstance.configuration == nil,
           let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

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
        await fetchOrCreateUser(
            uid: authResult.user.uid,
            email: authResult.user.email ?? currentUser?.email ?? "",
            displayName: authResult.user.displayName ?? currentUser?.displayName ?? ""
        )
        logger.info("User signed in via Google: \(authResult.user.uid)")
    }

    // MARK: - GitHub Sign-In

    func signInWithGitHub() async throws {
        activateIfNeeded()

        guard let auth else {
            logger.warning("Tentative de connexion GitHub sans configuration Firebase")
            throw TagYourCarError.firebaseNotConfigured
        }

        let provider = OAuthProvider(providerID: "github.com")

        let credential = try await provider.credential(with: nil)
        let result = try await auth.signIn(with: credential)
        await fetchOrCreateUser(
            uid: result.user.uid,
            email: result.user.email ?? currentUser?.email ?? "",
            displayName: result.user.displayName ?? currentUser?.displayName ?? ""
        )
        logger.info("User signed in via GitHub: \(result.user.uid)")
    }

    // MARK: - Update Profile

    func updateProfile(firstName: String, lastName: String) async throws {
        guard let auth, let db, let user = auth.currentUser else {
            throw TagYourCarError.unknownError
        }

        let displayName = "\(firstName) \(lastName)"
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()

        try await db.collection("users").document(user.uid).updateData([
            "displayName": displayName
        ])

        let updatedUser = AppUser(
            uid: user.uid,
            email: currentUser?.email ?? user.email ?? "",
            displayName: displayName,
            createdAt: currentUser?.createdAt ?? Date()
        )
        currentUser = updatedUser
        cacheUser(updatedUser)

        logger.info("Profile updated: \(displayName)")
    }

    // MARK: - Delete Account (FR4, FR26 — RGPD)

    func deleteAccount() async throws {
        guard let auth, let functions = {
            guard FirebaseApp.app() != nil else { return nil as Functions? }
            return Functions.functions()
        }() else {
            throw TagYourCarError.firebaseNotConfigured
        }

        logger.info("Demarrage suppression de compte")
        let _ = try await functions.httpsCallable("deleteUserData").call()

        // Detacher le listener AVANT de modifier l'etat pour eviter
        // qu'il ne remette isAuthenticated = true en parallele
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
            authStateListener = nil
            authListenerStarted = false
        }

        // Invalider la session locale immédiatement
        try? auth.signOut()
        clearCachedUser()
        currentUser = nil
        isAuthenticated = false
        logger.info("Compte supprimé et déconnecté")
    }

    // MARK: - Sign Out

    func signOut() throws {
        if let auth {
            try auth.signOut()
        } else {
            logger.warning("Sign out sans configuration Firebase")
        }

        GIDSignIn.sharedInstance.signOut()
        clearCachedUser()
        currentUser = nil
        isAuthenticated = false
        logger.info("User signed out")
    }

    // MARK: - Fetch or Create User

    private func fetchOrCreateUser(uid: String, email: String, displayName: String) async {
        guard let db else {
            logger.warning("Firestore indisponible — utilisateur non synchronise")
            return
        }

        do {
            let document = try await db.collection("users").document(uid).getDocument()
            if document.exists {
                let user = try document.data(as: AppUser.self)
                self.currentUser = user
                cacheUser(user)
            } else {
                let appUser = AppUser(
                    uid: uid,
                    email: email,
                    displayName: displayName,
                    createdAt: Date()
                )
                try await db.collection("users").document(uid).setData(from: appUser)
                self.currentUser = appUser
                cacheUser(appUser)
                logger.info("Created Firestore user for social sign-in: \(uid)")
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

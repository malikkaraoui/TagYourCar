import Foundation
import AuthenticationServices
@testable import TagYourCar

@MainActor
final class MockAuthService: ObservableObject, AuthServiceProtocol {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false

    // Tracking calls
    var signUpCalled = false
    var signInCalled = false
    var signOutCalled = false
    var signInWithGoogleCalled = false
    var signInWithGitHubCalled = false
    var prepareAppleSignInCalled = false
    var handleAppleSignInCalled = false

    // Captured arguments
    var lastSignUpEmail: String?
    var lastSignUpPassword: String?
    var lastSignUpFirstName: String?
    var lastSignUpLastName: String?
    var lastSignInEmail: String?
    var lastSignInPassword: String?

    // Configurable behavior
    var shouldThrowOnSignUp = false
    var shouldThrowOnSignIn = false
    var shouldThrowOnSignOut = false
    var shouldThrowOnGoogle = false
    var shouldThrowOnGitHub = false
    var shouldThrowOnApple = false
    var errorToThrow: Error = TagYourCarError.unknownError

    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        signUpCalled = true
        lastSignUpEmail = email
        lastSignUpPassword = password
        lastSignUpFirstName = firstName
        lastSignUpLastName = lastName

        if shouldThrowOnSignUp { throw errorToThrow }

        let user = AppUser(uid: "mock-uid", email: email, displayName: "\(firstName) \(lastName)", createdAt: Date())
        currentUser = user
        isAuthenticated = true
    }

    func signIn(email: String, password: String) async throws {
        signInCalled = true
        lastSignInEmail = email
        lastSignInPassword = password

        if shouldThrowOnSignIn { throw errorToThrow }

        let user = AppUser(uid: "mock-uid", email: email, displayName: "Test User", createdAt: Date())
        currentUser = user
        isAuthenticated = true
    }

    func signOut() throws {
        signOutCalled = true
        if shouldThrowOnSignOut { throw errorToThrow }
        currentUser = nil
        isAuthenticated = false
    }

    func prepareAppleSignIn() -> (nonce: String, hashedNonce: String) {
        prepareAppleSignInCalled = true
        return ("mock-nonce", "mock-hashed-nonce")
    }

    func handleAppleSignIn(authorization: ASAuthorization) async throws {
        handleAppleSignInCalled = true
        if shouldThrowOnApple { throw errorToThrow }

        let user = AppUser(uid: "apple-uid", email: "apple@test.com", displayName: "Apple User", createdAt: Date())
        currentUser = user
        isAuthenticated = true
    }

    func signInWithGoogle() async throws {
        signInWithGoogleCalled = true
        if shouldThrowOnGoogle { throw errorToThrow }

        let user = AppUser(uid: "google-uid", email: "google@test.com", displayName: "Google User", createdAt: Date())
        currentUser = user
        isAuthenticated = true
    }

    func signInWithGitHub() async throws {
        signInWithGitHubCalled = true
        if shouldThrowOnGitHub { throw errorToThrow }

        let user = AppUser(uid: "github-uid", email: "github@test.com", displayName: "GitHub User", createdAt: Date())
        currentUser = user
        isAuthenticated = true
    }

    // Profile
    var updateProfileCalled = false
    var lastFirstName: String?
    var lastLastName: String?
    var shouldThrowOnUpdateProfile = false

    func updateProfile(firstName: String, lastName: String) async throws {
        updateProfileCalled = true
        lastFirstName = firstName
        lastLastName = lastName
        if shouldThrowOnUpdateProfile { throw errorToThrow }
        currentUser = AppUser(uid: currentUser?.uid ?? "uid", email: currentUser?.email ?? "", displayName: "\(firstName) \(lastName)", createdAt: Date())
    }
}

import XCTest
@testable import TagYourCar

@MainActor
final class AuthViewModelTests: XCTestCase {

    private var mockService: MockAuthService!
    private var viewModel: AuthViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockAuthService()
        viewModel = AuthViewModel(authService: mockService)
    }

    // =========================================================
    // MARK: - Email Validation
    // =========================================================

    func testEmptyEmailIsInvalid() {
        viewModel.email = ""
        XCTAssertFalse(viewModel.isEmailValid)
    }

    func testValidEmail() {
        viewModel.email = "test@example.com"
        XCTAssertTrue(viewModel.isEmailValid)
    }

    func testEmailWithoutAtIsInvalid() {
        viewModel.email = "testexample.com"
        XCTAssertFalse(viewModel.isEmailValid)
    }

    func testEmailWithoutDomainIsInvalid() {
        viewModel.email = "test@"
        XCTAssertFalse(viewModel.isEmailValid)
    }

    func testEmailWithSpecialCharsIsValid() {
        viewModel.email = "user.name+tag@domain.co.uk"
        XCTAssertTrue(viewModel.isEmailValid)
    }

    func testEmailWithSpacesIsInvalid() {
        viewModel.email = "test @example.com"
        XCTAssertFalse(viewModel.isEmailValid)
    }

    // =========================================================
    // MARK: - Password Validation
    // =========================================================

    func testEmptyPasswordIsInvalid() {
        viewModel.password = ""
        XCTAssertFalse(viewModel.isPasswordValid)
    }

    func testPasswordTooShortIsInvalid() {
        viewModel.password = "12345"
        XCTAssertFalse(viewModel.isPasswordValid)
    }

    func testPasswordExactly6CharsIsValid() {
        viewModel.password = "123456"
        XCTAssertTrue(viewModel.isPasswordValid)
    }

    func testPasswordLongerThan6IsValid() {
        viewModel.password = "mysecurepassword"
        XCTAssertTrue(viewModel.isPasswordValid)
    }

    // =========================================================
    // MARK: - canSignIn (bouton connexion)
    // =========================================================

    func testCanSignInFalseWhenBothEmpty() {
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.canSignIn)
    }

    func testCanSignInFalseWhenOnlyEmail() {
        viewModel.email = "test@example.com"
        viewModel.password = ""
        XCTAssertFalse(viewModel.canSignIn)
    }

    func testCanSignInFalseWhenOnlyPassword() {
        viewModel.email = ""
        viewModel.password = "123456"
        XCTAssertFalse(viewModel.canSignIn)
    }

    func testCanSignInFalseWhenEmailInvalid() {
        viewModel.email = "invalid"
        viewModel.password = "123456"
        XCTAssertFalse(viewModel.canSignIn)
    }

    func testCanSignInFalseWhenPasswordTooShort() {
        viewModel.email = "test@example.com"
        viewModel.password = "123"
        XCTAssertFalse(viewModel.canSignIn)
    }

    func testCanSignInTrueWhenBothValid() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        XCTAssertTrue(viewModel.canSignIn)
    }

    // =========================================================
    // MARK: - canSignUp (bouton inscription)
    // =========================================================

    func testCanSignUpFalseWhenCGUNotAccepted() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = false
        XCTAssertFalse(viewModel.canSignUp)
    }

    func testCanSignUpFalseWhenFirstNameEmpty() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = ""
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = true
        XCTAssertFalse(viewModel.canSignUp)
    }

    func testCanSignUpFalseWhenLastNameEmpty() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = ""
        viewModel.cguAccepted = true
        XCTAssertFalse(viewModel.canSignUp)
    }

    func testCanSignUpFalseWhenEmailInvalid() {
        viewModel.email = "invalid"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = true
        XCTAssertFalse(viewModel.canSignUp)
    }

    func testCanSignUpFalseWhenPasswordTooShort() {
        viewModel.email = "test@example.com"
        viewModel.password = "12"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = true
        XCTAssertFalse(viewModel.canSignUp)
    }

    func testCanSignUpTrueWhenAllValid() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = true
        XCTAssertTrue(viewModel.canSignUp)
    }

    // =========================================================
    // MARK: - Initial State
    // =========================================================

    func testInitialStateIsIdle() {
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testInitialErrorMessageIsNil() {
        XCTAssertNil(viewModel.errorMessage)
    }

    func testInitialFieldsAreEmpty() {
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertTrue(viewModel.firstName.isEmpty)
        XCTAssertTrue(viewModel.lastName.isEmpty)
        XCTAssertFalse(viewModel.cguAccepted)
    }

    // =========================================================
    // MARK: - signIn() — succes
    // =========================================================

    func testSignInSuccessSetsStateLoaded() async {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"

        await viewModel.signIn()

        XCTAssertTrue(mockService.signInCalled)
        XCTAssertEqual(mockService.lastSignInEmail, "test@example.com")
        XCTAssertEqual(mockService.lastSignInPassword, "123456")
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSignInSuccessSetsLoadingDuringCall() async {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"

        // Avant l'appel
        XCTAssertEqual(viewModel.state, .idle)

        await viewModel.signIn()

        // Apres l'appel
        XCTAssertEqual(viewModel.state, .loaded)
    }

    // =========================================================
    // MARK: - signIn() — erreurs
    // =========================================================

    func testSignInErrorSetsErrorState() async {
        mockService.shouldThrowOnSignIn = true
        mockService.errorToThrow = TagYourCarError.unknownError
        viewModel.email = "test@example.com"
        viewModel.password = "123456"

        await viewModel.signIn()

        XCTAssertTrue(mockService.signInCalled)
        XCTAssertNotNil(viewModel.errorMessage)
        if case .error = viewModel.state {} else {
            XCTFail("State devrait etre .error")
        }
    }

    func testSignInErrorMessageIsInFrench() async {
        mockService.shouldThrowOnSignIn = true
        mockService.errorToThrow = NSError(domain: "", code: 17009)
        viewModel.email = "test@example.com"
        viewModel.password = "123456"

        await viewModel.signIn()

        XCTAssertEqual(viewModel.errorMessage, "Email ou mot de passe incorrect.")
    }

    func testSignInInvalidEmailErrorMessage() async {
        mockService.shouldThrowOnSignIn = true
        mockService.errorToThrow = NSError(domain: "", code: 17008)
        viewModel.email = "test@example.com"
        viewModel.password = "123456"

        await viewModel.signIn()

        XCTAssertEqual(viewModel.errorMessage, "Adresse email invalide.")
    }

    func testSignInNetworkErrorMessage() async {
        mockService.shouldThrowOnSignIn = true
        mockService.errorToThrow = NSError(domain: "", code: 17020)
        viewModel.email = "test@example.com"
        viewModel.password = "123456"

        await viewModel.signIn()

        XCTAssertEqual(viewModel.errorMessage, "Pas de connexion internet. Verifiez votre reseau.")
    }

    func testSignInUnknownErrorMessage() async {
        mockService.shouldThrowOnSignIn = true
        mockService.errorToThrow = NSError(domain: "", code: 99999)
        viewModel.email = "test@example.com"
        viewModel.password = "123456"

        await viewModel.signIn()

        XCTAssertTrue(viewModel.errorMessage?.contains("Une erreur est survenue") == true)
        XCTAssertTrue(viewModel.errorMessage?.contains("Reessayez.") == true)
    }

    func testSignInClearsExistingErrorOnNewAttempt() async {
        // Premier appel echoue
        mockService.shouldThrowOnSignIn = true
        mockService.errorToThrow = NSError(domain: "", code: 17009)
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        await viewModel.signIn()
        XCTAssertNotNil(viewModel.errorMessage)

        // Deuxieme appel reussit
        mockService.shouldThrowOnSignIn = false
        await viewModel.signIn()
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.state, .loaded)
    }

    // =========================================================
    // MARK: - signUp() — succes
    // =========================================================

    func testSignUpSuccessSetsStateLoaded() async {
        viewModel.email = "new@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"

        await viewModel.signUp()

        XCTAssertTrue(mockService.signUpCalled)
        XCTAssertEqual(mockService.lastSignUpEmail, "new@example.com")
        XCTAssertEqual(mockService.lastSignUpPassword, "123456")
        XCTAssertEqual(mockService.lastSignUpFirstName, "Jean")
        XCTAssertEqual(mockService.lastSignUpLastName, "Dupont")
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertNil(viewModel.errorMessage)
    }

    // =========================================================
    // MARK: - signUp() — erreurs
    // =========================================================

    func testSignUpDuplicateEmailErrorMessage() async {
        mockService.shouldThrowOnSignUp = true
        mockService.errorToThrow = NSError(domain: "", code: 17007)
        viewModel.email = "existing@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"

        await viewModel.signUp()

        XCTAssertEqual(viewModel.errorMessage, "Un compte avec cet email existe deja.")
    }

    func testSignUpWeakPasswordErrorMessage() async {
        mockService.shouldThrowOnSignUp = true
        mockService.errorToThrow = NSError(domain: "", code: 17026)
        viewModel.email = "new@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"

        await viewModel.signUp()

        XCTAssertEqual(viewModel.errorMessage, "Le mot de passe doit contenir au moins 6 caracteres.")
    }

    func testSignUpErrorSetsErrorState() async {
        mockService.shouldThrowOnSignUp = true
        viewModel.email = "new@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"

        await viewModel.signUp()

        if case .error = viewModel.state {} else {
            XCTFail("State devrait etre .error")
        }
    }

    // =========================================================
    // MARK: - signOut()
    // =========================================================

    func testSignOutCallsService() {
        viewModel.signOut()
        XCTAssertTrue(mockService.signOutCalled)
    }

    func testSignOutResetsAllFields() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = true

        viewModel.signOut()

        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertTrue(viewModel.firstName.isEmpty)
        XCTAssertTrue(viewModel.lastName.isEmpty)
        XCTAssertFalse(viewModel.cguAccepted)
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSignOutAfterErrorResetsState() async {
        // D'abord creer un etat d'erreur
        mockService.shouldThrowOnSignIn = true
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        await viewModel.signIn()
        XCTAssertNotNil(viewModel.errorMessage)

        // Sign out doit tout reset
        mockService.shouldThrowOnSignOut = false
        viewModel.signOut()
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.state, .idle)
    }
}

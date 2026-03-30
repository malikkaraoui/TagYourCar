import XCTest
@testable import TagYourCar

@MainActor
final class AuthViewModelTests: XCTestCase {

    private var authService: AuthService!
    private var viewModel: AuthViewModel!

    override func setUp() {
        super.setUp()
        authService = AuthService()
        viewModel = AuthViewModel(authService: authService)
    }

    // MARK: - Email Validation

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

    // MARK: - Password Validation

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

    // MARK: - Sign In Validation

    func testCanSignInRequiresBothFields() {
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.canSignIn)

        viewModel.email = "test@example.com"
        viewModel.password = ""
        XCTAssertFalse(viewModel.canSignIn)

        viewModel.email = ""
        viewModel.password = "123456"
        XCTAssertFalse(viewModel.canSignIn)

        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        XCTAssertTrue(viewModel.canSignIn)
    }

    // MARK: - Sign Up Validation

    func testCanSignUpRequiresAllFieldsAndCGU() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = false
        XCTAssertFalse(viewModel.canSignUp)

        viewModel.cguAccepted = true
        XCTAssertTrue(viewModel.canSignUp)
    }

    func testCanSignUpRequiresFirstName() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = ""
        viewModel.lastName = "Dupont"
        viewModel.cguAccepted = true
        XCTAssertFalse(viewModel.canSignUp)
    }

    func testCanSignUpRequiresLastName() {
        viewModel.email = "test@example.com"
        viewModel.password = "123456"
        viewModel.firstName = "Jean"
        viewModel.lastName = ""
        viewModel.cguAccepted = true
        XCTAssertFalse(viewModel.canSignUp)
    }

    // MARK: - Initial State

    func testInitialStateIsIdle() {
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(viewModel.errorMessage)
    }
}

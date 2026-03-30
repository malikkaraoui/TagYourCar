import XCTest
@testable import TagYourCar

final class PlateValidatorTests: XCTestCase {

    // =========================================================
    // MARK: - isValid()
    // =========================================================

    func testValidPlateFormat() {
        XCTAssertTrue(PlateValidator.isValid("AB-123-CD"))
    }

    func testValidPlateAllLetters() {
        XCTAssertTrue(PlateValidator.isValid("ZZ-999-ZZ"))
    }

    func testValidPlateMinValues() {
        XCTAssertTrue(PlateValidator.isValid("AA-001-AA"))
    }

    func testInvalidPlateLowercase() {
        XCTAssertFalse(PlateValidator.isValid("ab-123-cd"))
    }

    func testInvalidPlateNoDashes() {
        XCTAssertFalse(PlateValidator.isValid("AB123CD"))
    }

    func testInvalidPlateTooShort() {
        XCTAssertFalse(PlateValidator.isValid("AB-12-CD"))
    }

    func testInvalidPlateTooLong() {
        XCTAssertFalse(PlateValidator.isValid("AB-1234-CD"))
    }

    func testInvalidPlateExtraChars() {
        XCTAssertFalse(PlateValidator.isValid("ABC-123-CD"))
    }

    func testInvalidPlateEmpty() {
        XCTAssertFalse(PlateValidator.isValid(""))
    }

    func testInvalidPlateSpaces() {
        XCTAssertFalse(PlateValidator.isValid("AB 123 CD"))
    }

    func testInvalidPlateSpecialChars() {
        XCTAssertFalse(PlateValidator.isValid("A@-123-CD"))
    }

    // =========================================================
    // MARK: - format()
    // =========================================================

    func testFormatAddsHyphens() {
        XCTAssertEqual(PlateValidator.format("AB123CD"), "AB-123-CD")
    }

    func testFormatForcesUppercase() {
        XCTAssertEqual(PlateValidator.format("ab123cd"), "AB-123-CD")
    }

    func testFormatStripsSpaces() {
        XCTAssertEqual(PlateValidator.format("AB 123 CD"), "AB-123-CD")
    }

    func testFormatLimitsLength() {
        let result = PlateValidator.format("AB123CDEXTRA")
        XCTAssertEqual(result.count, 9) // AA-123-AA = 9 chars
    }

    func testFormatEmptyInput() {
        XCTAssertEqual(PlateValidator.format(""), "")
    }

    func testFormatPartialInput() {
        XCTAssertEqual(PlateValidator.format("AB"), "AB")
    }

    func testFormatPartialWithNumbers() {
        XCTAssertEqual(PlateValidator.format("AB12"), "AB-12")
    }
}

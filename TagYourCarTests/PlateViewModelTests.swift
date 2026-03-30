import XCTest
@testable import TagYourCar

@MainActor
final class PlateViewModelTests: XCTestCase {

    private var plateService: PlateService!
    private var viewModel: PlateViewModel!

    override func setUp() {
        super.setUp()
        plateService = PlateService()
        viewModel = PlateViewModel(plateService: plateService)
    }

    // =========================================================
    // MARK: - Validation plaque
    // =========================================================

    func testEmptyInputIsInvalid() {
        viewModel.plateInput = ""
        XCTAssertFalse(viewModel.isPlateValid)
    }

    func testValidPlateInputIsValid() {
        viewModel.plateInput = "AB-123-CD"
        XCTAssertTrue(viewModel.isPlateValid)
    }

    func testPartialPlateIsInvalid() {
        viewModel.plateInput = "AB-12"
        XCTAssertFalse(viewModel.isPlateValid)
    }

    func testLowercaseFormattedIsValid() {
        viewModel.plateInput = "ab123cd"
        // formattedPlate convertit en majuscules + tirets
        XCTAssertTrue(viewModel.isPlateValid)
    }

    func testNoSeparatorsFormattedIsValid() {
        viewModel.plateInput = "EF456GH"
        XCTAssertTrue(viewModel.isPlateValid)
    }

    // =========================================================
    // MARK: - formattedPlate
    // =========================================================

    func testFormattedPlateAddsHyphens() {
        viewModel.plateInput = "AB123CD"
        XCTAssertEqual(viewModel.formattedPlate, "AB-123-CD")
    }

    func testFormattedPlateUppercases() {
        viewModel.plateInput = "ab123cd"
        XCTAssertEqual(viewModel.formattedPlate, "AB-123-CD")
    }

    // =========================================================
    // MARK: - canAddPlate (bouton enregistrer)
    // =========================================================

    func testCanAddPlateWhenValidAndUnderLimit() {
        viewModel.plateInput = "AB-123-CD"
        viewModel.plates = []
        XCTAssertTrue(viewModel.canAddPlate)
    }

    func testCannotAddPlateWhenInvalid() {
        viewModel.plateInput = "AB"
        viewModel.plates = []
        XCTAssertFalse(viewModel.canAddPlate)
    }

    func testCannotAddPlateWhenAtLimit() {
        viewModel.plateInput = "AB-123-CD"
        viewModel.plates = (0..<5).map { i in
            Plate(id: "hash\(i)", ownerUid: "uid", addedAt: Date(), verified: false)
        }
        XCTAssertFalse(viewModel.canAddPlate)
    }

    func testCanAddPlateWith4Existing() {
        viewModel.plateInput = "AB-123-CD"
        viewModel.plates = (0..<4).map { i in
            Plate(id: "hash\(i)", ownerUid: "uid", addedAt: Date(), verified: false)
        }
        XCTAssertTrue(viewModel.canAddPlate)
    }

    // =========================================================
    // MARK: - hasReachedLimit
    // =========================================================

    func testHasReachedLimitFalseWhenEmpty() {
        viewModel.plates = []
        XCTAssertFalse(viewModel.hasReachedLimit)
    }

    func testHasReachedLimitTrueAt5() {
        viewModel.plates = (0..<5).map { i in
            Plate(id: "hash\(i)", ownerUid: "uid", addedAt: Date(), verified: false)
        }
        XCTAssertTrue(viewModel.hasReachedLimit)
    }

    func testHasReachedLimitFalseAt4() {
        viewModel.plates = (0..<4).map { i in
            Plate(id: "hash\(i)", ownerUid: "uid", addedAt: Date(), verified: false)
        }
        XCTAssertFalse(viewModel.hasReachedLimit)
    }

    // =========================================================
    // MARK: - maxPlates constant
    // =========================================================

    func testMaxPlatesIs5() {
        XCTAssertEqual(PlateViewModel.maxPlates, 5)
    }

    // =========================================================
    // MARK: - resetInput
    // =========================================================

    func testResetInputClearsFields() {
        viewModel.plateInput = "AB-123-CD"
        viewModel.errorMessage = "Une erreur"
        viewModel.resetInput()
        XCTAssertTrue(viewModel.plateInput.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    // =========================================================
    // MARK: - Initial state
    // =========================================================

    func testInitialStateIsIdle() {
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testInitialPlatesEmpty() {
        XCTAssertTrue(viewModel.plates.isEmpty)
    }

    func testInitialPlateInputEmpty() {
        XCTAssertTrue(viewModel.plateInput.isEmpty)
    }

    func testInitialErrorMessageNil() {
        XCTAssertNil(viewModel.errorMessage)
    }

    func testInitialShowAddPlateFalse() {
        XCTAssertFalse(viewModel.showAddPlate)
    }
}

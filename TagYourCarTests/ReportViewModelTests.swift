import XCTest
@testable import TagYourCar

@MainActor
final class ReportViewModelTests: XCTestCase {

    private var viewModel: ReportViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ReportViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Etat initial

    func testInitialState() {
        XCTAssertNil(viewModel.selectedZone)
        XCTAssertNil(viewModel.selectedProblem)
        XCTAssertNil(viewModel.selectedColor)
        XCTAssertEqual(viewModel.currentStep, .zone)
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Selection de zone

    func testSelectZoneSetsZoneAndAdvancesToProblem() {
        viewModel.selectZone(.front)

        XCTAssertEqual(viewModel.selectedZone, .front)
        XCTAssertEqual(viewModel.currentStep, .problem)
    }

    func testSelectZoneResetsSubsequentSelections() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)

        viewModel.selectZone(.rear)

        XCTAssertEqual(viewModel.selectedZone, .rear)
        XCTAssertNil(viewModel.selectedProblem)
        XCTAssertNil(viewModel.selectedColor)
        XCTAssertEqual(viewModel.currentStep, .problem)
    }

    func testSelectZoneMiddle() {
        viewModel.selectZone(.middle)

        XCTAssertEqual(viewModel.selectedZone, .middle)
        XCTAssertEqual(viewModel.currentStep, .problem)
    }

    func testSelectZoneRear() {
        viewModel.selectZone(.rear)

        XCTAssertEqual(viewModel.selectedZone, .rear)
        XCTAssertEqual(viewModel.currentStep, .problem)
    }

    // MARK: - Selection de probleme

    func testSelectProblemSetsProblemAndAdvancesToColor() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)

        XCTAssertEqual(viewModel.selectedProblem, .headlightsOn)
        XCTAssertEqual(viewModel.currentStep, .color)
    }

    func testSelectProblemResetsColor() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)

        viewModel.selectProblem(.hoodOpen)

        XCTAssertEqual(viewModel.selectedProblem, .hoodOpen)
        XCTAssertNil(viewModel.selectedColor)
    }

    // MARK: - Reset

    func testResetReportClearsEverything() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)

        viewModel.resetReport()

        XCTAssertNil(viewModel.selectedZone)
        XCTAssertNil(viewModel.selectedProblem)
        XCTAssertNil(viewModel.selectedColor)
        XCTAssertEqual(viewModel.currentStep, .zone)
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Navigation arriere

    func testGoBackToZoneResetsAll() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)

        viewModel.goBackToZone()

        XCTAssertNil(viewModel.selectedZone)
        XCTAssertNil(viewModel.selectedProblem)
        XCTAssertEqual(viewModel.currentStep, .zone)
    }

    func testGoBackToProblemKeepsZone() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)

        viewModel.goBackToProblem()

        XCTAssertEqual(viewModel.selectedZone, .front)
        XCTAssertNil(viewModel.selectedProblem)
        XCTAssertEqual(viewModel.currentStep, .problem)
    }

    // MARK: - Problemes disponibles par zone

    func testAvailableProblemsForFront() {
        viewModel.selectZone(.front)

        let problems = viewModel.availableProblems
        XCTAssertEqual(problems.count, 5)
        XCTAssertTrue(problems.contains(.headlightsOn))
        XCTAssertTrue(problems.contains(.hoodOpen))
        XCTAssertTrue(problems.contains(.chargeFlapOpen))
        XCTAssertTrue(problems.contains(.flatTireFront))
        XCTAssertTrue(problems.contains(.otherFront))
    }

    func testAvailableProblemsForMiddle() {
        viewModel.selectZone(.middle)

        let problems = viewModel.availableProblems
        XCTAssertEqual(problems.count, 4)
        XCTAssertTrue(problems.contains(.windowOpen))
        XCTAssertTrue(problems.contains(.doorAjar))
        XCTAssertTrue(problems.contains(.sunroofOpen))
        XCTAssertTrue(problems.contains(.otherMiddle))
    }

    func testAvailableProblemsForRear() {
        viewModel.selectZone(.rear)

        let problems = viewModel.availableProblems
        XCTAssertEqual(problems.count, 5)
        XCTAssertTrue(problems.contains(.taillightsOn))
        XCTAssertTrue(problems.contains(.fuelFlapOpen))
        XCTAssertTrue(problems.contains(.trunkOpen))
        XCTAssertTrue(problems.contains(.flatTireRear))
        XCTAssertTrue(problems.contains(.otherRear))
    }

    func testAvailableProblemsEmptyWhenNoZone() {
        XCTAssertTrue(viewModel.availableProblems.isEmpty)
    }

    // MARK: - Step title

    func testStepTitleForZone() {
        XCTAssertEqual(viewModel.stepTitle, "Où est le problème ?")
    }

    func testStepTitleForProblem() {
        viewModel.selectZone(.front)
        XCTAssertEqual(viewModel.stepTitle, "Quel problème ?")
    }

    func testStepTitleForColor() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)
        XCTAssertEqual(viewModel.stepTitle, "Couleur du véhicule")
    }

    func testStepTitleForPlate() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)
        viewModel.selectColor(.blue)
        XCTAssertEqual(viewModel.stepTitle, "Plaque d'immatriculation")
    }

    // MARK: - Selection de couleur

    func testSelectColorSetsColorAndAdvancesToPlate() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)
        viewModel.selectColor(.blue)

        XCTAssertEqual(viewModel.selectedColor, .blue)
        XCTAssertEqual(viewModel.currentStep, .plate)
    }

    func testSelectColorResetsPlateText() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)
        viewModel.selectColor(.red)
        viewModel.plateText = "AB-123-CD"

        viewModel.selectColor(.blue)

        XCTAssertEqual(viewModel.selectedColor, .blue)
        XCTAssertTrue(viewModel.plateText.isEmpty)
    }

    // MARK: - Navigation arriere couleur

    func testGoBackToColorKeepsZoneAndProblem() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)
        viewModel.selectColor(.red)

        viewModel.goBackToColor()

        XCTAssertEqual(viewModel.selectedZone, .front)
        XCTAssertEqual(viewModel.selectedProblem, .headlightsOn)
        XCTAssertNil(viewModel.selectedColor)
        XCTAssertTrue(viewModel.plateText.isEmpty)
        XCTAssertEqual(viewModel.currentStep, .color)
    }

    // MARK: - Validation plaque

    func testIsPlateValidWithValidPlate() {
        viewModel.plateText = "AB-123-CD"
        XCTAssertTrue(viewModel.isPlateValid)
    }

    func testIsPlateValidWithInvalidPlate() {
        viewModel.plateText = "AB-12"
        XCTAssertFalse(viewModel.isPlateValid)
    }

    func testIsPlateValidWithEmptyText() {
        XCTAssertFalse(viewModel.isPlateValid)
    }

    func testFormattedPlate() {
        viewModel.plateText = "ab123cd"
        XCTAssertEqual(viewModel.formattedPlate, "AB-123-CD")
    }

    // MARK: - Flow complet

    func testFullFlowZoneToProblemToColorToPlate() {
        viewModel.selectZone(.rear)
        XCTAssertEqual(viewModel.currentStep, .problem)

        viewModel.selectProblem(.trunkOpen)
        XCTAssertEqual(viewModel.currentStep, .color)

        viewModel.selectColor(.white)
        XCTAssertEqual(viewModel.currentStep, .plate)

        viewModel.plateText = "XY-789-ZZ"
        XCTAssertTrue(viewModel.isPlateValid)

        XCTAssertEqual(viewModel.selectedZone, .rear)
        XCTAssertEqual(viewModel.selectedProblem, .trunkOpen)
        XCTAssertEqual(viewModel.selectedColor, .white)
    }

    func testResetClearsPlateText() {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)
        viewModel.selectColor(.black)
        viewModel.plateText = "AB-123-CD"

        viewModel.resetReport()

        XCTAssertTrue(viewModel.plateText.isEmpty)
        XCTAssertNil(viewModel.selectedColor)
        XCTAssertEqual(viewModel.currentStep, .zone)
        XCTAssertNil(viewModel.reportResult)
        XCTAssertFalse(viewModel.showConfirmation)
        XCTAssertFalse(viewModel.isSubmitting)
    }

    // MARK: - Submit report (guards)

    func testSubmitReportRequiresAllFields() async {
        viewModel.plateText = "AB-123-CD"
        await viewModel.submitReport()

        XCTAssertFalse(viewModel.isSubmitting)
        XCTAssertFalse(viewModel.showConfirmation)
    }

    func testSubmitReportRequiresValidPlate() async {
        viewModel.selectZone(.front)
        viewModel.selectProblem(.headlightsOn)
        viewModel.selectColor(.blue)
        viewModel.plateText = "AB-12" // invalide

        await viewModel.submitReport()

        XCTAssertFalse(viewModel.showConfirmation)
    }

    // MARK: - Submit report (avec mock service)

    func testSubmitReportSuccessSent() async {
        let mock = MockReportService()
        mock.resultToReturn = .sent
        let vm = ReportViewModel(reportService: mock)

        vm.selectZone(.front)
        vm.selectProblem(.headlightsOn)
        vm.selectColor(.blue)
        vm.plateText = "AB-123-CD"

        await vm.submitReport()

        XCTAssertTrue(mock.submitReportCalled)
        XCTAssertEqual(mock.lastZone, .front)
        XCTAssertEqual(mock.lastProblemType, .headlightsOn)
        XCTAssertEqual(mock.lastVehicleColor, .blue)
        XCTAssertEqual(mock.lastPlate, "AB-123-CD")
        XCTAssertEqual(vm.reportResult, .sent)
        XCTAssertTrue(vm.showConfirmation)
        XCTAssertFalse(vm.isSubmitting)
    }

    func testSubmitReportSuccessNotRegistered() async {
        let mock = MockReportService()
        mock.resultToReturn = .notRegistered
        let vm = ReportViewModel(reportService: mock)

        vm.selectZone(.rear)
        vm.selectProblem(.trunkOpen)
        vm.selectColor(.white)
        vm.plateText = "XY-789-ZZ"

        await vm.submitReport()

        XCTAssertEqual(vm.reportResult, .notRegistered)
        XCTAssertTrue(vm.showConfirmation)
    }

    func testSubmitReportNetworkError() async {
        let mock = MockReportService()
        mock.shouldThrow = true
        mock.errorToThrow = TagYourCarError.reportFailed
        let vm = ReportViewModel(reportService: mock)

        vm.selectZone(.front)
        vm.selectProblem(.headlightsOn)
        vm.selectColor(.red)
        vm.plateText = "AB-123-CD"

        await vm.submitReport()

        XCTAssertTrue(mock.submitReportCalled)
        XCTAssertNil(vm.reportResult)
        XCTAssertFalse(vm.showConfirmation)
        XCTAssertFalse(vm.isSubmitting)
        if case .error = vm.state {} else {
            XCTFail("State devrait etre .error apres echec")
        }
    }

    func testSubmitReportBlocked() async {
        let mock = MockReportService()
        mock.shouldThrow = true
        mock.errorToThrow = TagYourCarError.reportBlocked("Trop de signalements.")
        let vm = ReportViewModel(reportService: mock)

        vm.selectZone(.middle)
        vm.selectProblem(.windowOpen)
        vm.selectColor(.black)
        vm.plateText = "ZZ-999-AA"

        await vm.submitReport()

        if case .error(let msg) = vm.state {
            XCTAssertTrue(msg.contains("signalements"))
        } else {
            XCTFail("State devrait etre .error avec message anti-abus")
        }
    }

    func testSubmitReportPreventsDoubleSubmission() async {
        let mock = MockReportService()
        let vm = ReportViewModel(reportService: mock)

        vm.selectZone(.front)
        vm.selectProblem(.headlightsOn)
        vm.selectColor(.blue)
        vm.plateText = "AB-123-CD"

        // Simuler isSubmitting deja en cours
        vm.isSubmitting = true
        await vm.submitReport()

        XCTAssertFalse(mock.submitReportCalled)
    }

    // MARK: - ReportStep comparable

    func testReportStepComparable() {
        XCTAssertTrue(ReportViewModel.ReportStep.zone < ReportViewModel.ReportStep.problem)
        XCTAssertTrue(ReportViewModel.ReportStep.problem < ReportViewModel.ReportStep.color)
        XCTAssertTrue(ReportViewModel.ReportStep.color < ReportViewModel.ReportStep.plate)
    }
}

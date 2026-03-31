import XCTest
@testable import TagYourCar

final class ViewStateTests: XCTestCase {

    func testViewStateEquality() {
        XCTAssertEqual(ViewState.idle, ViewState.idle)
        XCTAssertEqual(ViewState.loading, ViewState.loading)
        XCTAssertEqual(ViewState.loaded, ViewState.loaded)
        XCTAssertEqual(ViewState.error("test"), ViewState.error("test"))
        XCTAssertNotEqual(ViewState.idle, ViewState.loading)
        XCTAssertNotEqual(ViewState.error("a"), ViewState.error("b"))
    }
}

final class ProblemTypeTests: XCTestCase {

    func testFrontZoneProblems() {
        let problems = ProblemType.problems(for: .front)
        XCTAssertEqual(problems.count, 5)
        XCTAssertTrue(problems.contains(.headlightsOn))
        XCTAssertTrue(problems.contains(.hoodOpen))
        XCTAssertTrue(problems.contains(.chargeFlapOpen))
        XCTAssertTrue(problems.contains(.flatTireFront))
        XCTAssertTrue(problems.contains(.otherFront))
    }

    func testMiddleZoneProblems() {
        let problems = ProblemType.problems(for: .middle)
        XCTAssertEqual(problems.count, 4)
        XCTAssertTrue(problems.contains(.windowOpen))
        XCTAssertTrue(problems.contains(.doorAjar))
        XCTAssertTrue(problems.contains(.sunroofOpen))
        XCTAssertTrue(problems.contains(.otherMiddle))
    }

    func testRearZoneProblems() {
        let problems = ProblemType.problems(for: .rear)
        XCTAssertEqual(problems.count, 5)
        XCTAssertTrue(problems.contains(.taillightsOn))
        XCTAssertTrue(problems.contains(.fuelFlapOpen))
        XCTAssertTrue(problems.contains(.trunkOpen))
        XCTAssertTrue(problems.contains(.flatTireRear))
        XCTAssertTrue(problems.contains(.otherRear))
    }

    func testAllZonesCovered() {
        var allProblems: [ProblemType] = []
        for zone in VehicleZone.allCases {
            allProblems.append(contentsOf: ProblemType.problems(for: zone))
        }
        XCTAssertEqual(allProblems.count, 14)
    }
}

final class VehicleColorTests: XCTestCase {

    func testAllColorsCount() {
        XCTAssertEqual(VehicleColor.allCases.count, 12)
    }
}

final class TagYourCarErrorTests: XCTestCase {

    func testErrorDescriptions() {
        XCTAssertNotNil(TagYourCarError.plateInvalidFormat.errorDescription)
        XCTAssertNotNil(TagYourCarError.plateLimitReached.errorDescription)
        XCTAssertNotNil(TagYourCarError.plateAlreadyRegistered.errorDescription)
        XCTAssertNotNil(TagYourCarError.reportFailed.errorDescription)
        XCTAssertNotNil(TagYourCarError.notificationPermissionDenied.errorDescription)
        XCTAssertNotNil(TagYourCarError.firebaseNotConfigured.errorDescription)
        XCTAssertNotNil(TagYourCarError.unknownError.errorDescription)
    }
}

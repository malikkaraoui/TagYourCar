import Foundation
@testable import TagYourCar

@MainActor
final class MockReportService: ReportServiceProtocol {
    var submitReportCalled = false
    var lastZone: VehicleZone?
    var lastProblemType: ProblemType?
    var lastVehicleColor: VehicleColor?
    var lastPlate: String?

    var resultToReturn: ReportResult = .sent
    var shouldThrow = false
    var errorToThrow: Error = TagYourCarError.reportFailed

    func submitReport(
        zone: VehicleZone,
        problemType: ProblemType,
        vehicleColor: VehicleColor,
        plate: String
    ) async throws -> ReportResult {
        submitReportCalled = true
        lastZone = zone
        lastProblemType = problemType
        lastVehicleColor = vehicleColor
        lastPlate = plate

        if shouldThrow { throw errorToThrow }
        return resultToReturn
    }
}

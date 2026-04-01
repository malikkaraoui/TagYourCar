import Foundation

@MainActor
protocol ReportServiceProtocol {
    func submitReport(
        zone: VehicleZone,
        problemType: ProblemType,
        vehicleColor: VehicleColor,
        plate: String
    ) async throws -> ReportResult
}

extension ReportService: ReportServiceProtocol {}

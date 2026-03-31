import Foundation

struct Report: Codable, Identifiable {
    var id: String?
    let reporterUid: String
    let plateHash: String
    let zone: VehicleZone
    let problemType: ProblemType
    let vehicleColor: VehicleColor
    let createdAt: Date
    let status: ReportStatus
}

enum ReportStatus: String, Codable {
    case pending = "pending"
    case delivered = "delivered"
    case failed = "failed"
}

enum ReportResult {
    case sent
    case notRegistered
}

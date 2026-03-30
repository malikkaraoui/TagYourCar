import Foundation

enum ProblemType: String, Codable {
    // Zone avant
    case headlightsOn = "headlights_on"
    case hoodOpen = "hood_open"
    case chargeFlapOpen = "charge_flap_open"
    case flatTireFront = "flat_tire_front"
    case otherFront = "other_front"

    // Zone milieu
    case windowOpen = "window_open"
    case doorAjar = "door_ajar"
    case sunroofOpen = "sunroof_open"
    case otherMiddle = "other_middle"

    // Zone arriere
    case taillightsOn = "taillights_on"
    case fuelFlapOpen = "fuel_flap_open"
    case trunkOpen = "trunk_open"
    case flatTireRear = "flat_tire_rear"
    case otherRear = "other_rear"

    static func problems(for zone: VehicleZone) -> [ProblemType] {
        switch zone {
        case .front:
            return [.headlightsOn, .hoodOpen, .chargeFlapOpen, .flatTireFront, .otherFront]
        case .middle:
            return [.windowOpen, .doorAjar, .sunroofOpen, .otherMiddle]
        case .rear:
            return [.taillightsOn, .fuelFlapOpen, .trunkOpen, .flatTireRear, .otherRear]
        }
    }
}

import Foundation

struct Plate: Identifiable, Equatable {
    let id: String // plateHash (document ID)
    let ownerUid: String
    let addedAt: Date
    let verified: Bool
    var isFavorite: Bool = false
    let displayPlate: String // Masquage partiel lisible : AB-•••-CD
}

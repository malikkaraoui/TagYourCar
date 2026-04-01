import Foundation

struct Plate: Identifiable, Equatable {
    let id: String // plateHash (document ID)
    let ownerUid: String
    let addedAt: Date
    let verified: Bool
    var isFavorite: Bool = false

    /// Masque la plaque pour l'affichage : AB-1xx-CD
    /// Le hash ne contient pas la plaque originale, donc on affiche juste un identifiant partiel du hash
    var maskedDisplay: String {
        let prefix = String(id.prefix(4)).uppercased()
        return "••-•••-\(prefix)"
    }
}

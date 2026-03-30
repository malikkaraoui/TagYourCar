import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    let email: String
    let displayName: String
    let createdAt: Date
}

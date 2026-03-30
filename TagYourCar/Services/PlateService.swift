import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import os

@MainActor
final class PlateService: ObservableObject {
    @Published var plates: [Plate] = []

    private lazy var db: Firestore? = {
        guard FirebaseApp.app() != nil else { return nil }
        return Firestore.firestore()
    }()
    private lazy var functions: Functions? = {
        guard FirebaseApp.app() != nil else { return nil }
        return Functions.functions()
    }()
    private let logger = Logger(subsystem: "com.tagyourcar", category: "PlateService")

    init() {
        if FirebaseApp.app() == nil {
            logger.warning("Firebase non configure — PlateService fonctionne en mode degrade")
        }
    }

    // MARK: - Add Plate

    func addPlate(_ plateText: String, for uid: String) async throws {
        guard let functions else {
            logger.warning("Ajout de plaque impossible sans Firebase Functions")
            throw TagYourCarError.unknownError
        }

        let result = try await functions.httpsCallable("hashPlate").call(["plate": plateText])

        guard let data = result.data as? [String: Any],
              let success = data["success"] as? Bool, success else {
            throw TagYourCarError.unknownError
        }

        await fetchPlates(for: uid)
        logger.info("Plate added for user \(uid)")
    }

    // MARK: - Delete Plate

    func deletePlate(_ plateText: String, for uid: String) async throws {
        guard let functions else {
            logger.warning("Suppression de plaque impossible sans Firebase Functions")
            throw TagYourCarError.unknownError
        }

        let result = try await functions.httpsCallable("deletePlate").call(["plate": plateText])

        guard let data = result.data as? [String: Any],
              let success = data["success"] as? Bool, success else {
            throw TagYourCarError.unknownError
        }

        await fetchPlates(for: uid)
        logger.info("Plate deleted for user \(uid)")
    }

    // MARK: - Verify Ownership

    func verifyOwnership(_ plateText: String) async throws -> Bool {
        guard let functions else {
            logger.warning("Verification impossible sans Firebase Functions")
            throw TagYourCarError.unknownError
        }

        let result = try await functions.httpsCallable("verifyOwnership").call(["plate": plateText])

        guard let data = result.data as? [String: Any],
              let verified = data["verified"] as? Bool else {
            throw TagYourCarError.unknownError
        }

        return verified
    }

    // MARK: - Fetch User Plates

    func fetchPlates(for uid: String) async {
        guard let db else {
            plates = []
            logger.warning("Lecture des plaques ignoree — Firestore non configure")
            return
        }

        do {
            let snapshot = try await db.collection("plates")
                .whereField("ownerUid", isEqualTo: uid)
                .getDocuments()

            self.plates = snapshot.documents.compactMap { doc in
                let data = doc.data()
                return Plate(
                    id: doc.documentID,
                    ownerUid: data["ownerUid"] as? String ?? "",
                    addedAt: (data["addedAt"] as? Timestamp)?.dateValue() ?? Date(),
                    verified: data["verified"] as? Bool ?? false
                )
            }
            logger.info("Fetched \(self.plates.count) plates for user \(uid)")
        } catch {
            logger.error("Failed to fetch plates: \(error.localizedDescription)")
        }
    }
}

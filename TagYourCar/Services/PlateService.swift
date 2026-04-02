import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import os

@MainActor
final class PlateService: ObservableObject {
    @Published var plates: [Plate] = []

    private var db: Firestore? {
        guard FirebaseApp.app() != nil else { return nil }
        return Firestore.firestore()
    }
    private var functions: Functions? {
        guard FirebaseApp.app() != nil else { return nil }
        return Functions.functions()
    }
    private let logger = Logger(subsystem: "com.tagyourcar", category: "PlateService")

    // MARK: - Add Plate

    func addPlate(_ plateText: String, for uid: String) async throws {
        guard let functions else {
            logger.error("Ajout de plaque impossible sans Firebase Functions")
            throw TagYourCarError.firebaseNotConfigured
        }

        let result: HTTPSCallableResult
        do {
            result = try await functions.httpsCallable("hashPlate").call(["plate": plateText])
        } catch {
            let message = (error as NSError).localizedDescription.lowercased()

            if message.contains("votre compte") {
                await fetchPlates(for: uid)
                throw TagYourCarError.plateAlreadyRegisteredOnAccount
            }

            if message.contains("autre utilisateur") || message.contains("already-exists") {
                throw TagYourCarError.plateAlreadyRegistered
            }

            throw error
        }

        guard let data = result.data as? [String: Any],
              let success = data["success"] as? Bool, success else {
            throw TagYourCarError.unknownError
        }

        await fetchPlates(for: uid)
        logger.info("Plate added for user \(uid)")
    }

    // MARK: - Delete Plate

    func deletePlate(_ plateHash: String, for uid: String) async throws {
        guard let functions else {
            logger.error("Suppression de plaque impossible sans Firebase Functions")
            throw TagYourCarError.firebaseNotConfigured
        }

        let result = try await functions.httpsCallable("deletePlate").call(["plateHash": plateHash])

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
            logger.error("Verification impossible sans Firebase Functions")
            throw TagYourCarError.firebaseNotConfigured
        }

        let result = try await functions.httpsCallable("verifyOwnership").call(["plate": plateText])

        guard let data = result.data as? [String: Any],
              let verified = data["verified"] as? Bool else {
            throw TagYourCarError.unknownError
        }

        return verified
    }

    // MARK: - Favorite Plate

    func updateFavoritePlate(_ plateHash: String?, for uid: String) async throws {
        guard let functions else {
            logger.error("Favori impossible sans Firebase Functions")
            throw TagYourCarError.firebaseNotConfigured
        }

        let payload = plateHash.map { ["plateHash": $0] } ?? [:]

        let result = try await functions.httpsCallable("setFavoritePlate").call(payload)

        guard let data = result.data as? [String: Any],
              let success = data["success"] as? Bool, success else {
            throw TagYourCarError.unknownError
        }

        for index in plates.indices {
            plates[index].isFavorite = plates[index].id == plateHash
        }

        logger.info("Favori persiste pour user \(uid) : \(plateHash ?? "aucun")")
    }

    // MARK: - Fetch User Plates

    func fetchPlates(for uid: String) async {
        guard let db else {
            plates = []
            logger.error("Lecture des plaques ignoree — Firestore non configure")
            return
        }

        do {
            let platesSnapshot = try await db.collection("plates")
                .whereField("ownerUid", isEqualTo: uid)
                .limit(to: 10) // Sécurité: limite même si business logic = 5
                .getDocuments()

            self.plates = platesSnapshot.documents.compactMap { doc in
                let data = doc.data()
                return Plate(
                    id: doc.documentID,
                    ownerUid: data["ownerUid"] as? String ?? "",
                    addedAt: (data["addedAt"] as? Timestamp)?.dateValue() ?? Date(),
                    verified: data["verified"] as? Bool ?? false,
                    isFavorite: data["isFavorite"] as? Bool ?? false,
                    displayPlate: data["displayPlate"] as? String ?? "Plaque à restaurer"
                )
            }
            logger.info("Fetched \(self.plates.count) plates for user \(uid)")
        } catch {
            logger.error("Failed to fetch plates: \(error.localizedDescription)")
        }
    }
}

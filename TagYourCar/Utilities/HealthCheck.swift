import Foundation
import FirebaseCore
import os

/// Utilitaire pour vérifier la santé de l'application au démarrage
enum HealthCheck {
    private static let logger = Logger(subsystem: "com.tagyourcar", category: "HealthCheck")

    static func scheduleStartupChecks() {
        DispatchQueue.global(qos: .utility).async {
            performStartupChecks()
        }
    }
    
    /// Vérifie que Firebase est correctement configuré
    static func verifyFirebaseConfiguration() -> Bool {
        guard FirebaseApp.app() != nil else {
            logger.error("❌ Firebase n'est pas configuré")
            return false
        }
        
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            logger.error("❌ GoogleService-Info.plist est manquant")
            return false
        }
        
        logger.info("✅ Firebase est correctement configuré")
        return true
    }
    
    /// Vérifie toutes les conditions requises pour le bon fonctionnement de l'app
    static func performStartupChecks() {
        logger.info("🔍 Démarrage des vérifications de santé...")
        
        // Vérifier Firebase
        let firebaseOK = verifyFirebaseConfiguration()
        
        // Vérifier les capabilities
        #if targetEnvironment(simulator)
        logger.info("📱 Exécution sur simulateur")
        #else
        logger.info("📱 Exécution sur device")
        #endif
        
        // Résumé
        if firebaseOK {
            logger.info("✅ Tous les checks sont OK")
        } else {
            logger.warning("⚠️ Certains checks ont échoué - l'app peut ne pas fonctionner correctement")
        }
    }
}

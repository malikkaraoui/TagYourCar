import Foundation

enum TagYourCarError: LocalizedError {
    case plateInvalidFormat
    case plateLimitReached
    case plateAlreadyRegisteredOnAccount
    case plateAlreadyRegistered
    case reportFailed
    case reportBlocked(String)
    case notificationPermissionDenied
    case firebaseNotConfigured
    case networkError(Error)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .plateInvalidFormat:
            return "Le format de la plaque est invalide. Utilisez le format AA-123-AA."
        case .plateLimitReached:
            return "Vous avez atteint la limite de 5 plaques enregistrées."
        case .plateAlreadyRegisteredOnAccount:
            return "Cette plaque vous appartient déjà et elle est déjà enregistrée sur votre compte."
        case .plateAlreadyRegistered:
            return "Cette plaque est déjà enregistrée par un autre utilisateur."
        case .reportFailed:
            return "Le signalement n'a pas pu être envoyé. Réessayez."
        case .reportBlocked(let message):
            return message
        case .notificationPermissionDenied:
            return "Les notifications sont désactivées. Activez-les dans les réglages."
        case .firebaseNotConfigured:
            return "L'application n'est pas correctement configurée. Vérifiez votre connexion."
        case .networkError(let error):
            return "Erreur réseau. Vérifiez votre connexion."
        case .unknownError:
            return "Une erreur inattendue est survenue."
        }
    }
}

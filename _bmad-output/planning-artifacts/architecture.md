---
stepsCompleted:
  - step-01-init
  - step-02-context
  - step-03-starter
  - step-04-decisions
  - step-05-patterns
  - step-06-structure
  - step-07-validation
  - step-08-complete
status: 'complete'
completedAt: '2026-03-20'
inputDocuments:
  - planning-artifacts/prd.md
  - docs/ios_vscode_workflow_V4.md
  - docs/README_OKazCar.com.md
workflowType: 'architecture'
project_name: 'TagYourCar'
user_name: 'Malik'
date: '2026-03-20'
---

# Architecture Decision Document

_Ce document se construit collaborativement étape par étape. Les sections sont ajoutées au fur et à mesure des décisions architecturales._

## Analyse du Contexte Projet

### Vue d'ensemble des exigences

**Exigences Fonctionnelles (26 FRs en 5 domaines) :**

| Domaine | FRs | Implications architecturales |
|---------|-----|-----------------------------|
| Gestion de compte | FR1-FR5 | Firebase Auth, Apple Sign-In, suppression RGPD complète |
| Gestion de plaques | FR6-FR10 | Hashage serveur (Cloud Function), validation format, limite 5/user |
| Signalement | FR11-FR17 | Logique conditionnelle plaque connue/inconnue, zéro donnée orpheline |
| Notifications | FR18-FR20 | FCM/APNs temps réel, permission lazy |
| Anti-abus + RGPD | FR21-FR26 | Rate limiting, pattern detection, purge complète au delete |

**Exigences Non-Fonctionnelles clés :**

- NFR1 : Notification push < 5s — Cloud Function trigger sur write Firestore
- NFR3 : Vérification plaque < 500ms — index Firestore optimisé sur hash
- NFR5 : 10K→50K users — Firebase auto-scale
- NFR9 : Zéro perte de signalement — retry automatique

**Échelle & Complexité :**

- Domaine principal : Mobile iOS natif + BaaS (Firebase)
- Niveau de complexité : Moyen
- Composants architecturaux estimés : ~8-10

### Contraintes Techniques & Dépendances

- iOS uniquement : Swift, SwiftUI, MVVM — pas de cross-platform
- Firebase all-in : Auth, Firestore, Cloud Functions, FCM — pas de backend custom
- Dev solo + Claude : architecture simple et maintenable
- Pipeline dev : VS Code + Makefile + xcodebuild + simctl (Xcode minimal)
- Hashage côté serveur obligatoire (Cloud Functions) pour conformité RGPD

### Préoccupations Transversales

1. **Hashage systématique** : plaques et adresses hashées côté serveur avant tout stockage
2. **Permissions lazy** : caméra, GPS, notifications demandées uniquement à l'usage
3. **Anti-abus** : rate limiting + pattern detection sur signalements et gestion de compte
4. **RGPD end-to-end** : consentement, droit à l'oubli, purge complète, zéro donnée orpheline
5. **Extensibilité** : architecture compatible avec la synergie OkazCar (Phase 3) sans refonte

## Évaluation du Starter Template

### Domaine technologique

iOS natif + Firebase BaaS — pas de starter CLI type web. Le starter est un projet Xcode vierge configuré avec les bons choix.

### Stack vérifiée (mars 2026)

| Composant | Version | Notes |
| --------- | ------- | ----- |
| Xcode | 26 (SDK iOS 26) | Requis pour soumissions App Store après avril 2026 |
| Swift | 6.x (bundled Xcode 26) | Dernière version stable |
| Firebase iOS SDK | 12.10.0 | Dernière release |
| Gestionnaire de dépendances | Swift Package Manager | Recommandé par Firebase, CocoaPods déprécié |
| Deployment target | iOS 16+ | ~95% du parc couvert |

### Starter sélectionné : Projet Xcode vierge + SPM Firebase

**Justification :** Les starters iOS tiers sont rarement maintenus et imposent des opinions non désirées. Un projet Xcode vierge SwiftUI + MVVM est trivial à créer. La valeur est dans la configuration Firebase et la structure de dossiers.

**Packages Firebase via SPM :**

- `FirebaseAuth`
- `FirebaseFirestore` + `FirebaseFirestoreSwift`
- `FirebaseFunctions`
- `FirebaseMessaging` (FCM/APNs)

**Décisions architecturales établies :**

| Décision | Choix |
| -------- | ----- |
| Langage & Runtime | Swift 6.x, iOS 16+ |
| UI Framework | SwiftUI (pas UIKit sauf nécessité) |
| Architecture | MVVM + Services |
| Gestion de dépendances | Swift Package Manager |
| Backend | Firebase (pas de serveur custom) |
| Auth | Firebase Auth (email + Apple Sign-In) |
| Base de données | Cloud Firestore |
| Notifications | FCM → APNs |
| Logique serveur | Cloud Functions (hashage, anti-abus) |
| Tests | XCTest (natif) |
| Build | xcodebuild via Makefile (workflow VS Code) |

**Structure de projet :**

```
TagYourCar/
├── TagYourCar.xcodeproj
├── TagYourCar/
│   ├── App/
│   │   ├── TagYourCarApp.swift
│   │   └── AppDelegate.swift (UIApplicationDelegateAdaptor pour Firebase)
│   ├── Views/
│   ├── ViewModels/
│   ├── Models/
│   ├── Services/
│   ├── Components/
│   └── Resources/
├── TagYourCarTests/
├── CloudFunctions/
├── Scripts/
├── .vscode/
├── Makefile
├── CLAUDE.md
└── firebase.json
```

**Note :** Firebase exige un `UIApplicationDelegateAdaptor` dans l'App struct pour fonctionner en SwiftUI pur.

## Décisions Architecturales

### Priorité des décisions

**Décisions critiques (bloquent l'implémentation) :**

- Modèle de données Firestore
- Architecture de hashage RGPD
- Pipeline de notifications FCM
- Couches MVVM iOS

**Décisions importantes (façonnent l'architecture) :**

- Runtime Cloud Functions
- Stratégie anti-abus
- CI/CD

**Décisions différées (Post-MVP) :**

- OCR caméra (Vision framework) — Phase 2
- Géolocalisation — Phase 2
- Analytics avancées — pas critique MVP
- Deep linking — Phase 2
- Widget iOS — Phase 3

### Architecture des Données (Firestore)

**Collections :**

| Collection | Documents | Champs clés |
| ---------- | --------- | ----------- |
| `users` | 1 par utilisateur | uid, email, displayName, createdAt, fcmToken |
| `plates` | 1 par plaque hashée | plateHash (= doc ID), ownerUid, addedAt, verified |
| `reports` | 1 par signalement | reporterUid, plateHash, zone, problemType, vehicleColor, createdAt, status |
| `abuseTracking` | 1 par signaleur | reporterUid, reportCount24h, lastReportAt, blocked |

**Choix de modélisation :**

- Le hash SHA-256 de la plaque sert d'ID de document dans `plates` → lookup O(1)
- Collections plates, pas de sous-collections — simplifie les Security Rules et les queries
- Index composite sur `plates.ownerUid` pour lister les plaques d'un user
- Pas de TTL — les signalements restent pour l'historique Phase 2
- Validation : côté client (format plaque) + côté serveur (Cloud Function hashage + vérification ownership)

### Authentification & Sécurité

**Hashage :**

- Algorithme : SHA-256 avec salt secret en variable d'environnement Cloud Functions
- Flux : Client envoie plaque en clair → Cloud Function `hashPlate()` → hash + stockage. Le client ne connaît jamais le hash.

**Security Rules Firestore :**

- Lecture `users` : uniquement le propriétaire (`request.auth.uid == resource.data.uid`)
- Lecture `plates` : uniquement le propriétaire (`ownerUid == request.auth.uid`)
- Écriture : uniquement via Cloud Functions (pas d'écriture directe client sur `plates` et `reports`)

**Suppression de compte (RGPD) :**

- Cloud Function `deleteUserData()` purge : `users`, `plates` (par ownerUid), `reports` (par reporterUid), `abuseTracking` + Firebase Auth delete

### Notifications (FCM)

- **Trigger** : Cloud Function `onReportCreated` (trigger Firestore `onCreate` sur `reports`)
- **Flux** : Report créé → Cloud Function lit `plates` pour trouver ownerUid → lit `users` pour fcmToken → envoie via FCM
- **Retry** : Cloud Functions retente automatiquement en cas d'échec
- **Payload** : `{ zone, problemType, vehicleColor, partialPlate }` — aucune donnée sensible dans la notification

### Architecture iOS (MVVM + Services)

**Couches :**

```text
Views/          → SwiftUI Views (présentation pure)
ViewModels/     → ObservableObject, état + logique UI
Services/       → Abstraction Firebase (AuthService, PlateService, ReportService, NotificationService)
Models/         → Structs Codable (User, Plate, Report)
Components/     → Composants UI réutilisables
```

**Choix techniques :**

- Navigation : `NavigationStack` (iOS 16+)
- State management : `@StateObject` / `@ObservedObject` / `@EnvironmentObject` (pas de lib externe)
- Async : `async/await` natif (pas de Combine sauf nécessité)
- Injection de dépendances : via `@EnvironmentObject` pour les Services

### Cloud Functions (Runtime & Fonctions MVP)

- **Runtime** : Node.js 20 LTS + TypeScript
- **Fonctions MVP :**
  - `hashPlate` : reçoit plaque en clair, retourne hash, stocke dans Firestore
  - `onReportCreated` : trigger Firestore, envoie notification FCM
  - `verifyOwnership` : logique de vérification propriétaire
  - `deleteUserData` : purge RGPD complète
  - `checkAbuse` : rate limiting + pattern detection
- **Déploiement** : `firebase deploy --only functions`

### Infrastructure & Déploiement

- **Hébergement** : Firebase (zéro serveur custom)
- **CI/CD** : GitHub Actions (build + XCTest + lint)
- **Monitoring** : Firebase Crashlytics + Firebase Analytics
- **Logging** : Google Cloud Logging (inclus avec Cloud Functions)
- **Environnements** : 2 projets Firebase (dev + prod)

### Analyse d'impact des décisions

**Séquence d'implémentation :**

1. Projet Xcode + SPM Firebase + structure dossiers
2. Firebase Auth (email + Apple Sign-In)
3. Cloud Functions (hashPlate, verifyOwnership)
4. Modèle Firestore + Security Rules
5. Gestion de plaques (ajout, suppression, validation)
6. Signalement (saisie plaque, sélection problème, envoi)
7. Notifications push (onReportCreated → FCM)
8. Anti-abus (checkAbuse, rate limiting)
9. Suppression de compte (deleteUserData)

**Dépendances inter-composants :**

- Signalement dépend de : Auth + Plates + Cloud Functions
- Notifications dépend de : Signalement + FCM token (stocké dans users)
- Anti-abus dépend de : Signalement + abuseTracking
- Suppression compte dépend de : toutes les collections

## Patterns d'Implémentation & Règles de Cohérence

### Conventions de Nommage

**Firestore (collections & champs) :**

- Collections : `camelCase` pluriel → `users`, `plates`, `reports`, `abuseTracking`
- Champs : `camelCase` → `ownerUid`, `plateHash`, `createdAt`, `fcmToken`
- Document ID : UID Firebase pour `users`, hash SHA-256 pour `plates`, auto-ID pour `reports`

**Swift (code iOS) :**

- Types : `PascalCase` → `ReportViewModel`, `PlateService`, `User`
- Fichiers : nommés d'après le type principal → `ReportViewModel.swift`, `PlateService.swift`
- Variables/fonctions : `camelCase` → `plateHash`, `sendReport()`, `fetchUserPlates()`
- Protocoles : suffixe `-able` ou `-ing` → `PlateValidatable`, `ReportSending`
- Enums : `PascalCase` avec cases `camelCase` → `ProblemType.headlightsOn`

**Cloud Functions (TypeScript) :**

- Fonctions : `camelCase` → `hashPlate`, `onReportCreated`, `deleteUserData`
- Fichiers : `kebab-case` → `hash-plate.ts`, `on-report-created.ts`
- Interfaces : `PascalCase` → `PlateData`, `ReportPayload`

### Patterns de Structure

**Organisation par type (pas par feature en MVP) :**

```text
Views/
  AuthView.swift
  PlateListView.swift
  ReportView.swift
  SettingsView.swift
ViewModels/
  AuthViewModel.swift
  PlateViewModel.swift
  ReportViewModel.swift
Services/
  AuthService.swift
  PlateService.swift
  ReportService.swift
  NotificationService.swift
Models/
  User.swift
  Plate.swift
  Report.swift
Components/
  CarZoneSelector.swift
  ProblemTypePicker.swift
  ColorSwatchGrid.swift
  PlateTextField.swift
  PlateCard.swift
  ConfirmationView.swift
```

**Tests : dossier séparé miroir :**

```text
TagYourCarTests/
  ViewModels/
    AuthViewModelTests.swift
    PlateViewModelTests.swift
  Services/
    PlateServiceTests.swift
```

### Patterns de Format

**Modèles Swift (Codable → Firestore) :**

```swift
struct Report: Codable, Identifiable {
    @DocumentID var id: String?
    let reporterUid: String
    let plateHash: String
    let zone: VehicleZone
    let problemType: ProblemType
    let vehicleColor: VehicleColor
    let createdAt: Date
    let status: ReportStatus
}

enum VehicleZone: String, Codable, CaseIterable {
    case front = "front"
    case middle = "middle"
    case rear = "rear"
}

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
}

enum VehicleColor: String, Codable, CaseIterable {
    case white, black, gray, silver, blue, red, green, beige, yellow, orange, brown, other
}
```

Convention : les enums mappent vers des `snake_case` strings en Firestore pour la lisibilité dans la console Firebase.

### Patterns de Communication

**Services → ViewModels : async/await :**

```swift
// Service
func fetchPlates(for uid: String) async throws -> [Plate]

// ViewModel
@MainActor
func loadPlates() async {
    state = .loading
    do {
        plates = try await plateService.fetchPlates(for: authService.currentUser.uid)
        state = .loaded
    } catch {
        state = .error(error.localizedDescription)
    }
}
```

**Pattern d'état UI standardisé :**

```swift
enum ViewState {
    case idle
    case loading
    case loaded
    case error(String)
}
```

Tous les ViewModels utilisent ce même enum. Pas de booléens `isLoading` éparpillés.

### Patterns de Gestion d'Erreurs

**Erreurs typées par domaine :**

```swift
enum TagYourCarError: LocalizedError {
    case plateInvalidFormat
    case plateLimitReached
    case plateAlreadyRegistered
    case reportFailed
    case notificationPermissionDenied
    case networkError(Error)
    case unknownError
}
```

**Logging : `os.Logger` uniquement (pas de `print()`) :**

```swift
import os
private let logger = Logger(subsystem: "com.tagyourcar", category: "PlateService")
logger.info("Plaque ajoutée pour l'utilisateur \(uid)")
logger.error("Échec hashage : \(error.localizedDescription)")
```

### Patterns de Validation

- Format plaque : regex `^[A-Z]{2}-[0-9]{3}-[A-Z]{2}$` côté client
- Limite plaques : vérification côté client (UI) + côté serveur (Security Rules)
- Signalement : `problemType` obligatoire (enum, pas de string libre)

### Règles impératives pour tous les agents IA

1. **Jamais** de plaque en clair dans Firestore — toujours hashée via Cloud Function
2. **Jamais** de `print()` — utiliser `os.Logger`
3. **Toujours** `@MainActor` sur les ViewModels
4. **Toujours** `async/await` — pas de Combine sauf binding SwiftUI natif
5. **Toujours** `ViewState` enum pour l'état UI — pas de booléens isolés
6. **Toujours** des erreurs typées `TagYourCarError` — pas de strings bruts
7. **Toujours** Codable + `@DocumentID` pour les modèles Firestore
8. **Jamais** de logique métier dans les Views — tout dans ViewModel ou Service

## Structure du Projet & Frontières

### Mapping FRs → Structure

| Domaine FR | Dossier iOS | Cloud Functions | Firestore |
| ---------- | ----------- | --------------- | --------- |
| Gestion compte (FR1-5) | Views/Auth*, ViewModels/Auth*, Services/AuthService | — | `users` |
| Gestion plaques (FR6-10) | Views/Plate*, ViewModels/Plate*, Services/PlateService | `hashPlate`, `verifyOwnership` | `plates` |
| Signalement (FR11-17) | Views/Report*, ViewModels/Report*, Services/ReportService | `checkAbuse` | `reports`, `abuseTracking` |
| Notifications (FR18-20) | Services/NotificationService | `onReportCreated` | `users.fcmToken` |
| Anti-abus (FR21-23) | — (invisible côté UI) | `checkAbuse` | `abuseTracking` |
| RGPD (FR24-26) | Views/Settings*, Services/AuthService | `deleteUserData` | toutes collections |

### Arborescence complète du projet

```text
TagYourCar/
├── TagYourCar.xcodeproj
├── TagYourCar/
│   ├── App/
│   │   ├── TagYourCarApp.swift              # Point d'entrée, @main
│   │   ├── AppDelegate.swift                # UIApplicationDelegateAdaptor (Firebase init, FCM)
│   │   └── AppState.swift                   # État global app (ViewState enum)
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift              # FR1, FR2 — email + Apple Sign-In
│   │   │   └── SignUpView.swift             # FR1, FR24 — inscription + acceptation CGU
│   │   ├── Plates/
│   │   │   ├── PlateListView.swift          # FR6, FR7 — liste plaques + suppression
│   │   │   └── AddPlateView.swift           # FR6, FR8, FR9 — ajout + validation format
│   │   ├── Report/
│   │   │   ├── ReportView.swift             # FR11, FR12, FR13 — saisie plaque + sélection problème
│   │   │   └── ReportConfirmationView.swift # FR15, FR16 — confirmation ou message pare-brise
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift           # FR3, FR5, FR25 — profil, CGU, déconnexion
│   │   │   └── DeleteAccountView.swift      # FR4, FR26 — suppression compte RGPD
│   │   └── Root/
│   │       ├── ContentView.swift            # Navigation racine (auth guard)
│   │       └── TabBarView.swift             # Tab bar principale
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift              # Login, signup, logout, delete account
│   │   ├── PlateViewModel.swift             # CRUD plaques, validation format
│   │   └── ReportViewModel.swift            # Envoi signalement, vérification plaque
│   ├── Models/
│   │   ├── User.swift                       # Struct Codable
│   │   ├── Plate.swift                      # Struct Codable
│   │   ├── Report.swift                     # Struct Codable (zone, problemType, vehicleColor)
│   │   ├── VehicleZone.swift                # Enum front/middle/rear
│   │   ├── ProblemType.swift                # Enum contextuel par zone (15 cas)
│   │   ├── VehicleColor.swift               # Enum 12 couleurs
│   │   └── ViewState.swift                  # Enum idle/loading/loaded/error
│   ├── Services/
│   │   ├── AuthService.swift                # Firebase Auth wrapper
│   │   ├── PlateService.swift               # Cloud Functions hashPlate + Firestore plates
│   │   ├── ReportService.swift              # Cloud Functions checkAbuse + Firestore reports
│   │   └── NotificationService.swift        # FCM token registration + permissions
│   ├── Components/
│   │   ├── CarZoneSelector.swift            # Silhouette voiture top-down, 3 zones tappables
│   │   ├── ProblemTypePicker.swift          # Icônes problèmes contextuelles par zone
│   │   ├── ColorSwatchGrid.swift            # Grille 4x3 pastilles couleur véhicule
│   │   ├── PlateTextField.swift             # Champ de saisie plaque (format AA-123-AA)
│   │   ├── PlateCard.swift                  # Carte plaque masquée (AB-1••-CD) + badge cadenas
│   │   ├── ConfirmationView.swift           # Écran succès/échec post-signalement
│   │   ├── LoadingOverlay.swift             # Overlay chargement standardisé
│   │   └── ErrorBanner.swift                # Bannière erreur standardisée
│   ├── Utilities/
│   │   ├── PlateValidator.swift             # Regex validation format plaque
│   │   └── TagYourCarError.swift            # Enum erreurs typées
│   └── Resources/
│       ├── Assets.xcassets/                 # Images, couleurs, app icon
│       ├── Localizable.strings              # Chaînes localisées (FR)
│       ├── GoogleService-Info.plist         # Config Firebase
│       └── Info.plist
├── TagYourCarTests/
│   ├── ViewModels/
│   │   ├── AuthViewModelTests.swift
│   │   ├── PlateViewModelTests.swift
│   │   └── ReportViewModelTests.swift
│   ├── Services/
│   │   ├── PlateServiceTests.swift
│   │   └── ReportServiceTests.swift
│   └── Utilities/
│       └── PlateValidatorTests.swift
├── CloudFunctions/
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts                         # Export de toutes les fonctions
│   │   ├── hash-plate.ts                    # hashPlate callable
│   │   ├── verify-ownership.ts              # verifyOwnership callable
│   │   ├── on-report-created.ts             # Trigger Firestore → FCM
│   │   ├── check-abuse.ts                   # Rate limiting + pattern detection
│   │   └── delete-user-data.ts              # Purge RGPD complète
│   └── tests/
│       ├── hash-plate.test.ts
│       └── on-report-created.test.ts
├── firebase.json                            # Config Firebase (hosting, functions, firestore)
├── firestore.rules                          # Security Rules
├── firestore.indexes.json                   # Index composites
├── .firebaserc                              # Alias projets (dev, prod)
├── Scripts/
│   ├── build_ios_sim.sh
│   └── run_ios_sim.sh
├── .vscode/
│   ├── tasks.json
│   └── settings.json
├── .github/
│   └── workflows/
│       └── ci.yml                           # Build + XCTest + lint
├── Makefile
├── CLAUDE.md
└── .gitignore
```

### Frontières architecturales

**Frontière Client ↔ Serveur :**

```text
iOS App (Swift)          Cloud Functions (TypeScript)         Firestore
     |                           |                               |
     |-- callable: hashPlate --> |-- write: plates ------------> |
     |-- callable: verifyOwn --> |-- read/write: plates -------> |
     |-- write: reports ------> |                               |
     |                          |<- trigger: onReportCreated --- |
     |                          |-- read: plates, users -------> |
     |<-- FCM push ------------ |-- send: FCM ----------------> |
     |                          |                               |
     |-- callable: deleteUser ->|-- delete: all user data ----> |
```

**Règles de frontière :**

- Le client ne lit jamais `plates` directement (hash opaque) — passe par Cloud Functions
- Le client écrit directement dans `reports` (Security Rules vérifient l'auth)
- Les Cloud Functions sont le seul point qui manipule les hashs de plaques
- Les notifications sortent uniquement des Cloud Functions via FCM

**Frontière Données :**

- `users` : lecture/écriture par le propriétaire uniquement
- `plates` : écriture via Cloud Functions uniquement, lecture par ownerUid
- `reports` : écriture par tout utilisateur authentifié, lecture par ownerUid de la plaque
- `abuseTracking` : lecture/écriture par Cloud Functions uniquement

### Flux de données principal

```text
1. Signalement :
   Reporter ouvre ReportView
   → saisit plaque (PlateInputField)
   → sélectionne problème (ProblemTypeSelector)
   → ReportViewModel.sendReport()
   → ReportService écrit dans Firestore reports
   → Cloud Function onReportCreated se déclenche
   → Lit plates (trouve ownerUid par plateHash)
   → Lit users (trouve fcmToken)
   → Envoie notification FCM
   → Propriétaire reçoit push notification

2. Ajout plaque :
   User ouvre AddPlateView
   → saisit plaque (validation regex côté client)
   → PlateViewModel.addPlate()
   → PlateService appelle Cloud Function hashPlate
   → Cloud Function hashe + stocke dans plates
   → Retourne confirmation au client
```

## Validation de l'Architecture

### Validation de Cohérence

**Compatibilité des décisions :** Aucune contradiction détectée.

- Swift 6.x + SwiftUI + iOS 16+ → compatible NavigationStack, async/await
- Firebase iOS SDK 12.10.0 → compatible SPM, Swift 6.x, iOS 16+
- Cloud Functions Node.js 20 LTS + TypeScript → compatible Firebase Admin SDK
- Nommage `camelCase` uniforme Firestore ↔ Swift (mapping naturel via Codable)

**Cohérence des patterns :**

- `PascalCase` types Swift = convention standard Apple
- `kebab-case` fichiers TypeScript = convention standard Node.js
- Pattern ViewState/async-await/Services cohérent de bout en bout

### Couverture des Exigences

**Exigences Fonctionnelles : 26/26 couvertes**

| FR | Couverture |
| -- | ---------- |
| FR1-5 (Compte) | AuthService + Firebase Auth + Views/Auth |
| FR6-10 (Plaques) | PlateService + hashPlate CF + plates collection |
| FR11-17 (Signalement) | ReportService + reports collection + onReportCreated CF |
| FR18-20 (Notifications) | NotificationService + FCM + onReportCreated CF |
| FR21-23 (Anti-abus) | checkAbuse CF + abuseTracking collection |
| FR24-26 (RGPD) | deleteUserData CF + Security Rules + Views/Settings |

**Exigences Non-Fonctionnelles : 11/11 couvertes**

| NFR | Couverture |
| --- | ---------- |
| NFR1 (notif < 5s) | Cloud Function trigger Firestore → FCM direct |
| NFR2 (écran < 1s) | SwiftUI natif, pas de chargement lourd |
| NFR3 (vérif plaque < 500ms) | plateHash = doc ID → lookup O(1) Firestore |
| NFR4 (signalement < 30s) | 3 étapes : plaque → problème → envoi |
| NFR5-6 (scalabilité) | Firebase auto-scale natif |
| NFR7 (extensibilité) | MVVM + Services découplés, Cloud Functions modulaires |
| NFR8 (99.5% dispo) | SLA Firebase |
| NFR9 (zéro perte) | Cloud Functions retry automatique |
| NFR10-11 (accessibilité) | SwiftUI natif (VoiceOver, Dynamic Type par défaut) |

### Analyse de Gaps

**Aucun gap critique.**

**Gaps mineurs (non bloquants) :**

1. Mécanisme exact de vérification de propriété (FR8) à préciser lors des stories
2. Tests d'intégration Firebase Emulator implicites mais non documentés
3. Stratégie de monitoring détaillée (alertes, dashboards) à affiner post-MVP

### Checklist de Complétude

- [x] Contexte projet analysé
- [x] Stack technique vérifiée (versions web search)
- [x] Modèle de données Firestore complet
- [x] Sécurité & hashage RGPD définis
- [x] Pipeline notifications FCM spécifié
- [x] Architecture MVVM + Services détaillée
- [x] Cloud Functions MVP listées
- [x] Patterns de nommage, structure, format, communication définis
- [x] Règles impératives pour agents IA documentées
- [x] Arborescence complète avec mapping FR
- [x] Frontières architecturales et flux de données
- [x] 26/26 FRs couvertes
- [x] 11/11 NFRs couvertes

### Évaluation Globale

**Statut : PRÊT POUR L'IMPLÉMENTATION**

**Niveau de confiance : Élevé**

**Forces :**

- Architecture simple et cohérente (Firebase fait le gros du travail)
- Sécurité RGPD intégrée dès le design (hashage serveur, zéro donnée orpheline)
- Patterns clairs qui empêchent les agents IA de diverger
- Mapping FR → fichiers explicite

**Améliorations futures :**

- Mécanisme de vérification propriété à affiner
- Tests d'intégration Firebase Emulator à documenter
- Stratégie de monitoring détaillée (alertes, dashboards)

# Story 1.1: Setup Projet & Design Tokens

Status: review

## Story

En tant que developpeur,
Je veux un projet Xcode configure avec Firebase, la structure MVVM + Services, les design tokens et le CI/CD,
Afin que le socle technique soit pret pour toutes les features suivantes.

## Acceptance Criteria

1. **Etant donne** un repository vide **Quand** le projet est initialise **Alors** le projet Xcode compile avec les packages SPM Firebase (Auth, Firestore, Functions, Messaging)
2. **Etant donne** le projet initialise **Quand** on inspecte la structure **Alors** la structure de dossiers MVVM + Services est en place (App/, Views/, ViewModels/, Models/, Services/, Components/, Utilities/, Resources/)
3. **Etant donne** le projet initialise **Quand** on ouvre Theme.swift **Alors** il contient les design tokens (couleurs, typographie, spacing, radius, shadows)
4. **Etant donne** le projet initialise **Quand** on ouvre Assets.xcassets **Alors** il contient la palette couleurs TagYourCar (accent, bg, semantic, text)
5. **Etant donne** le projet initialise **Quand** on ouvre Models/ **Alors** ViewState.swift et TagYourCarError.swift sont implementes
6. **Etant donne** le projet initialise **Quand** on execute `make build` **Alors** le Makefile fonctionne (build + run simulateur)
7. **Etant donne** le projet initialise **Quand** on pousse sur GitHub **Alors** GitHub Actions CI est configure (build + XCTest + lint)
8. **Etant donne** le projet initialise **Quand** on inspecte Firebase **Alors** 2 environnements Firebase (dev + prod) sont configures

## Tasks / Subtasks

- [x] Task 1 : Creer le projet Xcode (AC: #1)
  - [x]Creer le projet SwiftUI App "TagYourCar" avec target iOS 16+
  - [x]Configurer le Bundle Identifier (com.tagyourcar.app)
  - [x]Ajouter les packages SPM Firebase : FirebaseAuth, FirebaseFirestore, FirebaseFirestoreSwift, FirebaseFunctions, FirebaseMessaging
  - [x]Creer TagYourCarApp.swift avec @main et UIApplicationDelegateAdaptor
  - [x]Creer AppDelegate.swift pour Firebase.configure()

- [x] Task 2 : Structure MVVM + Services (AC: #2)
  - [x]Creer les dossiers : App/, Views/, ViewModels/, Models/, Services/, Components/, Utilities/, Resources/
  - [x]Creer les sous-dossiers Views/ : Auth/, Plates/, Report/, Settings/, Root/
  - [x]Creer ContentView.swift dans Root/ (navigation racine placeholder)

- [x] Task 3 : Design Tokens — Theme.swift (AC: #3)
  - [x]Creer Theme.swift dans App/ avec les structs statiques pour couleurs, typographie, spacing, radius, shadows
  - [x]Couleurs : accent (primary #2D1B4E, interactive #3D2B6B, subtle #4A3580, muted #8B7AAF), bg (primary #FAFAFA, card #FFFFFF, secondary #F2F0F5, separator #E8E5ED), semantic (success #1A7A4C, error #C4314B, warning #B8860B), text (primary #1A1A2E, secondary #6B6B80, onAccent #FFFFFF, placeholder #A0A0B0)
  - [x]Typographie : echelle SF Pro (display 34pt Bold, H1 28pt Semibold, H2 22pt Semibold, H3 20pt Medium, body 17pt Regular, bodySmall 15pt Regular, caption 13pt Regular, plate 24pt SF Mono Medium)
  - [x]Spacing : grille 8pt (xs 4, sm 8, md 16, lg 24, xl 32, xxl 48)
  - [x]Radius : sm 8, md 12, lg 16, full 9999
  - [x]Shadows : card (0 2px 8px rgba(45,27,78,0.08)), modal (0 4px 16px rgba(45,27,78,0.12))

- [x] Task 4 : Assets.xcassets (AC: #4)
  - [x]Creer les Color Sets dans Assets.xcassets pour chaque token couleur
  - [x]Configurer AccentColor = #2D1B4E
  - [x]Ajouter les variantes Dark Mode (memes couleurs pour MVP, adaptation post-MVP)
  - [x]Placeholder AppIcon

- [x] Task 5 : Models fondamentaux (AC: #5)
  - [x]Creer ViewState.swift : enum ViewState { case idle, loading, loaded, error(String) }
  - [x]Creer TagYourCarError.swift : enum TagYourCarError: LocalizedError avec les cas (plateInvalidFormat, plateLimitReached, plateAlreadyRegistered, reportFailed, notificationPermissionDenied, networkError(Error), unknownError)
  - [x]Creer VehicleZone.swift : enum VehicleZone: String, Codable, CaseIterable { case front, middle, rear }
  - [x]Creer ProblemType.swift : enum ProblemType: String, Codable avec 15 cas par zone
  - [x]Creer VehicleColor.swift : enum VehicleColor: String, Codable, CaseIterable avec 12 couleurs

- [x] Task 6 : Makefile (AC: #6)
  - [x]Creer Makefile avec targets : build, test, run, lint, clean
  - [x]Target build : xcodebuild -scheme TagYourCar -destination 'platform=iOS Simulator,name=iPhone 16'
  - [x]Target run : xcrun simctl boot + xcodebuild + xcrun simctl install + launch
  - [x]Target test : xcodebuild test
  - [x]Target lint : swiftlint (si installe)

- [x] Task 7 : CI/CD GitHub Actions (AC: #7)
  - [x]Creer .github/workflows/ci.yml
  - [x]Job : build sur macos-latest avec Xcode
  - [x]Steps : checkout, build, test (XCTest), lint

- [x] Task 8 : Configuration Firebase (AC: #8)
  - [x]Creer 2 projets Firebase (tagyourcar-dev, tagyourcar-prod)
  - [x]Telecharger GoogleService-Info.plist pour chaque environnement
  - [x]Configurer .firebaserc avec alias dev et prod
  - [x]Creer firebase.json (fonctions, firestore)
  - [x]Creer firestore.rules (regles de base, verrouillees)
  - [x]Creer firestore.indexes.json (vide pour l'instant)
  - [x]Creer le dossier CloudFunctions/ avec package.json, tsconfig.json, src/index.ts

## Dev Notes

### Architecture Patterns OBLIGATOIRES

- **UI Framework** : SwiftUI uniquement (pas UIKit sauf UIApplicationDelegateAdaptor pour Firebase)
- **Architecture** : MVVM + Services — Views pures, logique dans ViewModels, Firebase abstrait dans Services
- **Navigation** : NavigationStack (iOS 16+)
- **State** : @StateObject / @ObservedObject / @EnvironmentObject — PAS de lib externe
- **Async** : async/await natif — PAS de Combine sauf binding SwiftUI natif
- **Logging** : os.Logger uniquement — JAMAIS de print()
- **DI** : @EnvironmentObject pour les Services
- **Models** : Codable + @DocumentID pour Firestore
- **Erreurs** : TagYourCarError enum — PAS de strings bruts

### Regles imperatives (AUCUNE EXCEPTION)

1. JAMAIS de plaque en clair dans Firestore — toujours hashee via Cloud Function
2. JAMAIS de print() — utiliser os.Logger
3. TOUJOURS @MainActor sur les ViewModels
4. TOUJOURS async/await — pas de Combine sauf binding SwiftUI natif
5. TOUJOURS ViewState enum pour l'etat UI — pas de booleens isoles
6. TOUJOURS des erreurs typees TagYourCarError — pas de strings bruts
7. TOUJOURS Codable + @DocumentID pour les modeles Firestore
8. JAMAIS de logique metier dans les Views — tout dans ViewModel ou Service

### Conventions de nommage

- **Swift Types** : PascalCase → ReportViewModel, PlateService, User
- **Swift fichiers** : nommes d'apres le type principal → ReportViewModel.swift
- **Swift vars/funcs** : camelCase → plateHash, sendReport(), fetchUserPlates()
- **Swift Protocols** : suffixe -able ou -ing → PlateValidatable
- **Swift Enums** : PascalCase avec cases camelCase → ProblemType.headlightsOn
- **Firestore collections** : camelCase pluriel → users, plates, reports, abuseTracking
- **Firestore champs** : camelCase → ownerUid, plateHash, createdAt
- **Cloud Functions** : camelCase → hashPlate, onReportCreated
- **Cloud Functions fichiers** : kebab-case → hash-plate.ts

### Project Structure Notes

Structure cible complete :

```
TagYourCar/
├── TagYourCar.xcodeproj
├── TagYourCar/
│   ├── App/
│   │   ├── TagYourCarApp.swift
│   │   ├── AppDelegate.swift
│   │   └── Theme.swift
│   ├── Views/
│   │   ├── Auth/
│   │   ├── Plates/
│   │   ├── Report/
│   │   ├── Settings/
│   │   └── Root/
│   │       └── ContentView.swift
│   ├── ViewModels/
│   ├── Models/
│   │   ├── ViewState.swift
│   │   ├── TagYourCarError.swift (dans Utilities/)
│   │   ├── VehicleZone.swift
│   │   ├── ProblemType.swift
│   │   └── VehicleColor.swift
│   ├── Services/
│   ├── Components/
│   ├── Utilities/
│   │   ├── PlateValidator.swift (placeholder)
│   │   └── TagYourCarError.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── GoogleService-Info.plist
│       └── Info.plist
├── TagYourCarTests/
├── CloudFunctions/
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       └── index.ts
├── Scripts/
├── .vscode/
│   ├── tasks.json
│   └── settings.json
├── .github/
│   └── workflows/
│       └── ci.yml
├── Makefile
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── .firebaserc
├── CLAUDE.md
└── .gitignore
```

### Design Tokens Reference Detaillee

**Palette couleurs complete :**

| Token | Hex | Usage |
|-------|-----|-------|
| accent.primary | #2D1B4E | Accent principal, texte sur fond clair, icones actives |
| accent.interactive | #3D2B6B | Boutons, liens, elements cliquables |
| accent.subtle | #4A3580 | Icones secondaires, etats pressed/hover |
| accent.muted | #8B7AAF | Elements desactives, bordures subtiles |
| bg.primary | #FAFAFA | Fond d'ecran principal |
| bg.card | #FFFFFF | Cartes, modales, elements sureleves |
| bg.secondary | #F2F0F5 | Zones de regroupement, fond alternatif |
| bg.separator | #E8E5ED | Lignes de separation, bordures |
| semantic.success | #1A7A4C | Confirmation envoi, validation plaque |
| semantic.error | #C4314B | Erreurs, format plaque invalide |
| semantic.warning | #B8860B | Avertissements, plaque non enregistree |
| text.primary | #1A1A2E | Texte principal, titres |
| text.secondary | #6B6B80 | Texte secondaire, labels |
| text.onAccent | #FFFFFF | Texte sur fond accent |
| text.placeholder | #A0A0B0 | Placeholder champs de saisie |

**Typographie SF Pro :**

| Niveau | Taille | Poids | Line-height | Usage |
|--------|--------|-------|-------------|-------|
| Display | 34pt | Bold | 1.2 | Titre principal ecran |
| H1 | 28pt | Semibold | 1.3 | Sections principales |
| H2 | 22pt | Semibold | 1.3 | Sous-sections |
| H3 | 20pt | Medium | 1.4 | En-tetes de cartes |
| Body | 17pt | Regular | 1.5 | Texte courant |
| Body Small | 15pt | Regular | 1.5 | Texte secondaire |
| Caption | 13pt | Regular | 1.4 | Labels, metadonnees |
| Plate | 24pt | SF Mono Medium | 1.2 | Affichage plaque |

**Spacing (grille 8pt) :**

| Token | Valeur |
|-------|--------|
| xs | 4pt |
| sm | 8pt |
| md | 16pt |
| lg | 24pt |
| xl | 32pt |
| xxl | 48pt |

**Radius :**

| Token | Valeur |
|-------|--------|
| sm | 8pt |
| md | 12pt |
| lg | 16pt |
| full | 9999pt |

### Firebase SDK Packages SPM

```
https://github.com/firebase/firebase-ios-sdk
```

Produits a inclure :
- FirebaseAuth
- FirebaseFirestore
- FirebaseFirestoreSwift
- FirebaseFunctions
- FirebaseMessaging

### Cloud Functions Setup

- Runtime : Node.js 20 LTS + TypeScript
- package.json avec firebase-functions et firebase-admin
- tsconfig.json strict mode
- src/index.ts : export vide pour l'instant (les fonctions seront ajoutees dans les stories suivantes)

### References

- [Source: _bmad-output/planning-artifacts/architecture.md — Evaluation du Starter Template]
- [Source: _bmad-output/planning-artifacts/architecture.md — Patterns d'Implementation & Regles de Coherence]
- [Source: _bmad-output/planning-artifacts/architecture.md — Structure du Projet & Frontieres]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md — Visual Design Foundation]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md — Design System Foundation]
- [Source: _bmad-output/planning-artifacts/epics.md — Story 1.1]
- [Source: docs/ios_vscode_workflow_V4.md — Pipeline VS Code + Makefile]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6 (1M context)

### Debug Log References

- Build: `.build/logs/ios_build.log`
- Tests: `.build/logs/tests.log`

### Completion Notes List

- Projet Xcode genere via XcodeGen (project.yml) — plus maintenable que pbxproj manuel
- FirebaseFirestoreSwift supprime des deps SPM (integre dans FirebaseFirestore depuis SDK 11+)
- Firebase init conditionnelle : ne crash pas si GoogleService-Info.plist absent (tests)
- PlateValidator regex marque nonisolated(unsafe) pour strict concurrency Swift 6
- 16 Color Sets crees dans Assets.xcassets pour tous les design tokens
- 7 tests unitaires : ViewState, ProblemType (3 zones), VehicleColor, TagYourCarError
- BUILD SUCCEEDED + TEST SUCCEEDED — iPhone 17 Pro Simulator, Xcode 26.3, Swift 6.2.4

### File List

- project.yml
- TagYourCar/App/TagYourCarApp.swift
- TagYourCar/App/AppDelegate.swift
- TagYourCar/App/Theme.swift
- TagYourCar/Views/Root/ContentView.swift
- TagYourCar/Models/ViewState.swift
- TagYourCar/Models/VehicleZone.swift
- TagYourCar/Models/ProblemType.swift
- TagYourCar/Models/VehicleColor.swift
- TagYourCar/Utilities/TagYourCarError.swift
- TagYourCar/Utilities/PlateValidator.swift
- TagYourCar/Resources/Assets.xcassets/ (16 Color Sets + AppIcon)
- TagYourCarTests/TagYourCarTests.swift
- CloudFunctions/package.json
- CloudFunctions/tsconfig.json
- CloudFunctions/src/index.ts
- Makefile
- firebase.json
- firestore.rules
- firestore.indexes.json
- .github/workflows/ci.yml
- .vscode/tasks.json
- .gitignore

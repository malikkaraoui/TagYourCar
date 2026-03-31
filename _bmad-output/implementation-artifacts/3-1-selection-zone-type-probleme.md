# Story 3.1 : Selection de Zone & Type de Probleme

Status: review

## Story

En tant qu'utilisateur,
Je veux taper sur une zone de la voiture et voir les problemes correspondants,
Afin de localiser visuellement le probleme sans effort.

## Criteres d'acceptation

1. **AC1 — Affichage silhouette voiture** : Quand l'utilisateur ouvre l'onglet "Signaler", la silhouette voiture top-down apparait avec 3 zones tappables (avant/milieu/arriere). Aucun texte ni label — language-agnostic.

2. **AC2 — Selection de zone** : Quand l'utilisateur tape sur une zone, la zone passe en accent violet avec haptique light (.light). Les icones problemes contextuelles s'affichent selon FR12 :
   - Avant : phares allumes, capot ouvert, trappe de charge ouverte, pneu a plat, autre
   - Milieu : vitre ouverte, portiere mal fermee, toit ouvrant ouvert, autre
   - Arriere : feux allumes, trappe a essence ouverte, coffre ouvert, pneu a plat, autre

3. **AC3 — Selection de probleme** : Quand l'utilisateur tape sur une icone probleme, le probleme est selectionne avec haptique medium (.medium) et scale 0.95. La transition vers l'etape couleur se declenche.

4. **AC4 — Accessibilite VoiceOver** : Chaque zone est annoncee ("Zone avant du vehicule", "Zone milieu du vehicule", "Zone arriere du vehicule"). Chaque probleme a un label VoiceOver descriptif.

5. **AC5 — Performance** : L'ecran de signalement charge en < 1 seconde (NFR2).

## Taches / Sous-taches

- [x] Tache 1 : Creer le composant CarZoneSelector (AC: #1, #2, #4)
  - [x] 1.1 Creer `Components/CarZoneSelector.swift` avec 3 zones tappables
  - [x] 1.2 Designer la silhouette voiture en formes SwiftUI (3 rectangles arrondis empiles verticalement)
  - [x] 1.3 Implementer les etats : default (gris `bgSecondary`), selected (accent `accentPrimary`)
  - [x] 1.4 Ajouter haptique `UIImpactFeedbackGenerator(.light)` au tap zone
  - [x] 1.5 Ajouter labels VoiceOver sur chaque zone

- [x] Tache 2 : Creer le composant ProblemTypePicker (AC: #2, #3, #4)
  - [x] 2.1 Creer `Components/ProblemTypePicker.swift` avec grille d'icones contextuelles
  - [x] 2.2 Mapper chaque ProblemType vers un SF Symbol (voir table ci-dessous)
  - [x] 2.3 Taille minimum 64x64pt par icone (zone tappable)
  - [x] 2.4 Implementer animation scale 0.95 + accent au tap
  - [x] 2.5 Ajouter haptique `UIImpactFeedbackGenerator(.medium)` a la selection
  - [x] 2.6 Ajouter labels VoiceOver descriptifs en francais

- [x] Tache 3 : Creer ReportViewModel (AC: #1, #2, #3)
  - [x] 3.1 Creer `ViewModels/ReportViewModel.swift` avec @MainActor
  - [x] 3.2 @Published : selectedZone, selectedProblem, currentStep, state
  - [x] 3.3 Methode selectZone(_:) avec transition vers etape 2
  - [x] 3.4 Methode selectProblem(_:) avec transition vers etape 3 (couleur — Story 3.2)
  - [x] 3.5 Methode resetReport() pour revenir a l'etape 1

- [x] Tache 4 : Creer ReportView et remplacer le placeholder (AC: #1, #5)
  - [x] 4.1 Creer `Views/Report/ReportView.swift` avec le flow multi-etapes
  - [x] 4.2 Etape 1 : CarZoneSelector (cette story)
  - [x] 4.3 Etape 2 : ProblemTypePicker (cette story)
  - [x] 4.4 Placeholder pour etapes 3-4 (couleur + plaque — Story 3.2)
  - [x] 4.5 Remplacer `ReportPlaceholderView()` par `ReportView()` dans ContentView.swift

- [x] Tache 5 : Tests unitaires
  - [x] 5.1 Creer `TagYourCarTests/ReportViewModelTests.swift`
  - [x] 5.2 Tester selectZone met a jour selectedZone et currentStep
  - [x] 5.3 Tester selectProblem met a jour selectedProblem et currentStep
  - [x] 5.4 Tester resetReport remet tout a zero
  - [x] 5.5 Tester ProblemType.problems(for:) retourne les bons problemes par zone
  - [x] 5.6 Verifier que le build compile (`make build`) et les tests passent (`make test`)

## Notes Dev

### Fichiers a creer

| Fichier | Emplacement |
|---------|------------|
| CarZoneSelector.swift | TagYourCar/Components/ |
| ProblemTypePicker.swift | TagYourCar/Components/ |
| ReportViewModel.swift | TagYourCar/ViewModels/ |
| ReportView.swift | TagYourCar/Views/Report/ |
| ReportViewModelTests.swift | TagYourCarTests/ |

### Fichiers a modifier

| Fichier | Modification |
|---------|-------------|
| ContentView.swift | Remplacer ReportPlaceholderView par ReportView + injecter ReportViewModel |

### Modeles existants a reutiliser (NE PAS recreer)

- `VehicleZone.swift` (Models/) — enum front/middle/rear, deja CaseIterable
- `ProblemType.swift` (Models/) — 15 cas, methode `problems(for zone:)` deja implementee
- `VehicleColor.swift` (Models/) — 12 couleurs, deja CaseIterable
- `ViewState.swift` (Models/) — enum idle/loading/loaded/error
- `TagYourCarError.swift` (Utilities/) — contient deja `.reportFailed`

### Mapping SF Symbols pour ProblemType

| ProblemType | SF Symbol | Zone |
|-------------|-----------|------|
| headlightsOn | `headlight.high.beam.fill` | Avant |
| hoodOpen | `car.top.radiator.coolant.fill` | Avant |
| chargeFlapOpen | `ev.plug.dc.ccs2` | Avant |
| flatTireFront | `circle.slash` | Avant |
| otherFront | `questionmark.circle` | Avant |
| windowOpen | `window.casement` | Milieu |
| doorAjar | `car.side` | Milieu |
| sunroofOpen | `sun.max` | Milieu |
| otherMiddle | `questionmark.circle` | Milieu |
| taillightsOn | `taillight.fog.rear` | Arriere |
| fuelFlapOpen | `fuelpump` | Arriere |
| trunkOpen | `car.top.trunk.open.fill` | Arriere |
| flatTireRear | `circle.slash` | Arriere |
| otherRear | `questionmark.circle` | Arriere |

**IMPORTANT** : Verifier la disponibilite iOS 16+ de chaque SF Symbol. Certains sont iOS 17+. Si indisponible, utiliser un fallback generique (ex: `exclamationmark.triangle` pour les problemes, `car` pour les zones).

### Patterns a suivre (extraits du code existant)

**ViewModel pattern** (comme PlateViewModel) :
```swift
@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedZone: VehicleZone?
    @Published var selectedProblem: ProblemType?
    @Published var currentStep: ReportStep = .zone
    @Published var state: ViewState = .idle

    private let logger = Logger(subsystem: "com.tagyourcar", category: "ReportViewModel")

    enum ReportStep {
        case zone, problem, color, plate
    }
}
```

**Haptique** (comme PlateViewModel — preparer juste avant l'action) :
```swift
private let impactLight = UIImpactFeedbackGenerator(style: .light)
private let impactMedium = UIImpactFeedbackGenerator(style: .medium)

func selectZone(_ zone: VehicleZone) {
    impactLight.prepare()
    impactLight.impactOccurred()
    selectedZone = zone
    currentStep = .problem
}
```

**Theme** (toujours utiliser Theme.Colors, Theme.Typography, Theme.Spacing) :
```swift
.foregroundStyle(Theme.Colors.accentPrimary)
.font(Theme.Typography.h2)
.padding(Theme.Spacing.lg)
```

### Contraintes iOS 16+

- PAS de `Observable` macro (iOS 17+)
- PAS de `onChange` avec 2 params (iOS 17+)
- PAS de `Tab` pour TabView (iOS 18+)
- Utiliser `@StateObject` / `@ObservedObject` / `@EnvironmentObject`
- Utiliser `NavigationStack` (OK iOS 16+)

### Architecture — Regles imperatives

1. **Jamais** de logique metier dans les Views — tout dans ViewModel
2. **Toujours** `@MainActor` sur les ViewModels
3. **Toujours** `ViewState` enum pour l'etat UI
4. **Toujours** `os.Logger` — pas de `print()`
5. **Toujours** les design tokens Theme — pas de valeurs en dur
6. **Toujours** des labels VoiceOver sur les composants custom interactifs

### Structure de Navigation

Le ContentView.swift actuel utilise un TabView avec 2 onglets :
1. "Signaler" (exclamationmark.triangle) — actuellement ReportPlaceholderView → **remplacer par ReportView**
2. "Mes plaques" (car.fill) — PlateListView

Le ReportView doit gerer en interne le flow multi-etapes (zone → probleme → couleur → plaque) via le currentStep du ViewModel. Pas de NavigationStack supplementaire pour les etapes — utiliser des transitions/animations.

### Scope de cette story

Cette story couvre **uniquement les etapes 1 et 2** du flow :
- Etape 1 : Selection de zone (CarZoneSelector)
- Etape 2 : Selection de probleme (ProblemTypePicker)

Les etapes 3 (couleur) et 4 (plaque + envoi) sont couvertes par la Story 3.2. Le ReportView doit prevoir des placeholders pour ces etapes futures.

### Project Structure Notes

- Alignement avec la structure MVVM + Services existante
- Components/ pour les composants reutilisables (CarZoneSelector, ProblemTypePicker)
- Views/Report/ pour la vue principale du flow
- ViewModels/ pour la logique de signalement
- Pas de ReportService necessaire pour cette story (pas d'appel backend)

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.1] — Criteres d'acceptation BDD
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#CarZoneSelector] — Specs composant zone
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#ProblemTypePicker] — Specs composant probleme
- [Source: _bmad-output/planning-artifacts/architecture.md#Patterns] — Conventions nommage, patterns MVVM
- [Source: TagYourCar/Models/ProblemType.swift] — Methode problems(for:) existante
- [Source: TagYourCar/Models/VehicleZone.swift] — Enum zones existant
- [Source: TagYourCar/ViewModels/PlateViewModel.swift] — Pattern ViewModel + haptic de reference

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6 (1M context)

### Debug Log References

- Build initial echoue : HealthCheck.swift reference ancienne dans xcodeproj → resolu par `make generate`
- Build final : BUILD SUCCEEDED
- Tests : 107 tests, 0 failures (18 nouveaux ReportViewModelTests)

### Completion Notes List

- CarZoneSelector : 3 zones avec formes arrondies differenciees (avant bombee, milieu plat, arriere bombee), haptique light, VoiceOver
- ProblemTypePicker : grille LazyVGrid 3 colonnes, 14 SF Symbols mappes, animation scale 0.95, haptique medium, VoiceOver
- ReportViewModel : flow multi-etapes (zone → probleme → color → plate), navigation avant/arriere, reset complet
- ReportView : indicateur d'etape 4 capsules, transitions animees, placeholders etapes 3-4 pour Story 3.2
- ContentView : placeholder supprime, ReportView branche dans le TabView
- 18 tests unitaires couvrant : etat initial, selection zone, selection probleme, reset, navigation arriere, problemes par zone, step titles, ReportStep comparable

### Change Log

- 2026-03-31 : Implementation complete Story 3.1 — tous les AC satisfaits

### File List

- TagYourCar/Components/CarZoneSelector.swift (CREE)
- TagYourCar/Components/ProblemTypePicker.swift (CREE)
- TagYourCar/ViewModels/ReportViewModel.swift (CREE)
- TagYourCar/Views/Report/ReportView.swift (CREE)
- TagYourCar/Views/Root/ContentView.swift (MODIFIE — ReportPlaceholderView supprime, ReportView branche)
- TagYourCarTests/ReportViewModelTests.swift (CREE)

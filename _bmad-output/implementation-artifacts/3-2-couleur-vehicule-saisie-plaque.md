# Story 3.2 : Couleur du Vehicule & Saisie de Plaque

Status: in-progress

## Story

En tant qu'utilisateur,
Je veux choisir la couleur du vehicule puis saisir la plaque,
Afin que le signalement soit complet et que le proprietaire puisse confirmer que c'est bien sa voiture.

## Criteres d'acceptation

1. **AC1 — Grille couleurs** : Une grille 4x3 de pastilles rondes apparait (12 couleurs). Chaque pastille fait minimum 44x44pt. La pastille "autre" affiche une icone "?".

2. **AC2 — Selection couleur** : Quand l'utilisateur tape une pastille, bordure accent + check avec haptique light. Transition vers saisie plaque.

3. **AC3 — Saisie plaque** : Le PlateTextField auto-formate en AA-123-AA (tirets auto, majuscules forcees). Placeholder "AA-123-AA" en SF Pro Mono 24pt Medium.

4. **AC4 — Envoi automatique** : Quand la plaque est valide, l'envoi se declenche automatiquement sans bouton "Envoyer" (FR13).

5. **AC5 — Accessibilite** : Labels VoiceOver sur chaque couleur et sur le champ plaque.

## Taches / Sous-taches

- [ ] Tache 1 : Creer ColorSwatchGrid (AC: #1, #2, #5)
  - [ ] 1.1 Creer `Components/ColorSwatchGrid.swift` avec grille 4x3
  - [ ] 1.2 Pastilles rondes 44x44pt minimum, couleurs SwiftUI
  - [ ] 1.3 Pastille "autre" avec icone "?"
  - [ ] 1.4 Etat selected : bordure accent + check
  - [ ] 1.5 Haptique light a la selection
  - [ ] 1.6 Labels VoiceOver sur chaque pastille

- [ ] Tache 2 : Etendre ReportViewModel (AC: #2, #4)
  - [ ] 2.1 Ajouter @Published plateText
  - [ ] 2.2 Methode selectColor(_:) avec transition vers etape plaque
  - [ ] 2.3 Methode goBackToColor() pour navigation arriere
  - [ ] 2.4 Computed isPlateValid via PlateValidator
  - [ ] 2.5 Computed formattedPlate via PlateValidator

- [ ] Tache 3 : Remplacer placeholders dans ReportView (AC: #1, #2, #3, #4)
  - [ ] 3.1 Etape couleur : ColorSwatchGrid avec binding selectedColor
  - [ ] 3.2 Etape plaque : PlateTextField existant + auto-envoi quand valide
  - [ ] 3.3 Gerer navigation arriere couleur → probleme et plaque → couleur

- [ ] Tache 4 : Tests unitaires
  - [ ] 4.1 Tester selectColor met a jour selectedColor et currentStep
  - [ ] 4.2 Tester goBackToColor garde zone et probleme
  - [ ] 4.3 Tester isPlateValid et formattedPlate
  - [ ] 4.4 Tester le flow complet zone → probleme → couleur → plaque
  - [ ] 4.5 Build + tests passent

## Dev Notes

### Fichiers a creer
- TagYourCar/Components/ColorSwatchGrid.swift

### Fichiers a modifier
- TagYourCar/ViewModels/ReportViewModel.swift
- TagYourCar/Views/Report/ReportView.swift
- TagYourCarTests/ReportViewModelTests.swift

### Composants existants a reutiliser
- PlateTextField (Components/) — champ de saisie plaque avec auto-format
- PlateValidator (Utilities/) — regex validation + formatting
- VehicleColor (Models/) — 12 couleurs CaseIterable

### Mapping couleurs SwiftUI pour VehicleColor
| VehicleColor | Color SwiftUI |
|---|---|
| white | .white |
| black | .black |
| gray | .gray |
| silver | Color(white: 0.78) |
| blue | .blue |
| red | .red |
| green | .green |
| beige | Color(red: 0.96, green: 0.87, blue: 0.70) |
| yellow | .yellow |
| orange | .orange |
| brown | .brown |
| other | — (icone "?" sur fond gris) |

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6 (1M context)

### Completion Notes List

### File List

# Story 3.3 : Envoi du Signalement & Notification Push

Status: in-progress

## Story

En tant qu'utilisateur,
Je veux que mon signalement soit envoye et le proprietaire notifie instantanement,
Afin que le proprietaire puisse agir sur le probleme signale.

## Criteres d'acceptation

1. **AC1 — Envoi rapport** : Quand une plaque valide est saisie, ReportService appelle la Cloud Function submitReport avec zone, problemType, vehicleColor, plate.

2. **AC2 — Cloud Function submitReport** : La CF hashe la plaque, verifie si enregistree. Si oui, cree le document report dans Firestore. Si non, retourne registered: false (FR17 — zero donnee).

3. **AC3 — Cloud Function onReportCreated** : Quand un report est cree, la CF lit plates pour ownerUid, lit users pour fcmToken, envoie FCM (FR15, FR18).

4. **AC4 — Confirmation succes** : Ecran avec animation check + fond vert + haptique heavy. Texte "C'est envoye ! Le proprietaire sera notifie." Auto-dismiss 2 secondes, retour accueil.

5. **AC5 — Notification payload** : Type probleme, zone, couleur, plaque partielle (FR19).

## Taches / Sous-taches

- [ ] Tache 1 : Creer le modele Report.swift (AC: #1)
  - [ ] 1.1 Struct Codable avec reporterUid, plateHash, zone, problemType, vehicleColor, createdAt, status

- [ ] Tache 2 : Creer ReportService.swift (AC: #1)
  - [ ] 2.1 Creer `Services/ReportService.swift` avec pattern PlateService
  - [ ] 2.2 Methode submitReport(zone, problem, color, plate, uid) async throws -> ReportResult
  - [ ] 2.3 ReportResult enum : sent (plaque enregistree), notRegistered (plaque inconnue)

- [ ] Tache 3 : Cloud Functions submitReport + onReportCreated (AC: #2, #3, #5)
  - [ ] 3.1 Creer `CloudFunctions/src/submit-report.ts`
  - [ ] 3.2 Creer `CloudFunctions/src/on-report-created.ts`
  - [ ] 3.3 Mettre a jour `CloudFunctions/src/index.ts` avec les exports

- [ ] Tache 4 : Creer ConfirmationView (AC: #4)
  - [ ] 4.1 Creer `Components/ConfirmationView.swift` — variante succes
  - [ ] 4.2 Animation check + fond vert + haptique heavy
  - [ ] 4.3 Auto-dismiss 2 secondes

- [ ] Tache 5 : Integrer dans ReportViewModel + ReportView (AC: #1, #4)
  - [ ] 5.1 Ajouter submitReport() dans ReportViewModel
  - [ ] 5.2 Brancher auto-envoi dans ReportView quand plaque valide
  - [ ] 5.3 Afficher ConfirmationView apres envoi reussi
  - [ ] 5.4 Injecter ReportService + AuthService dans ReportView

- [ ] Tache 6 : Tests unitaires
  - [ ] 6.1 Tests ReportViewModel submitReport
  - [ ] 6.2 Build + tests passent

## Dev Notes

### Fichiers a creer
- TagYourCar/Models/Report.swift
- TagYourCar/Services/ReportService.swift
- TagYourCar/Components/ConfirmationView.swift
- CloudFunctions/src/submit-report.ts
- CloudFunctions/src/on-report-created.ts

### Fichiers a modifier
- TagYourCar/ViewModels/ReportViewModel.swift
- TagYourCar/Views/Report/ReportView.swift
- TagYourCar/Views/Root/ContentView.swift (injection ReportService)
- CloudFunctions/src/index.ts

### Pattern backend existant
Le client appelle une Cloud Function via `functions.httpsCallable("submitReport").call(data)`.
La CF hashe la plaque cote serveur, verifie en base, cree ou non le report.

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6 (1M context)

### Completion Notes List

### File List

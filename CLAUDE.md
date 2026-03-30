# CLAUDE.md — TagYourCar

## Projet
- Nom : TagYourCar
- Description : App communautaire iOS pour signaler des problèmes sur les véhicules (phares allumés, vitre ouverte, mal garé) via la plaque d'immatriculation
- Plateforme : iOS (Swift natif, SwiftUI, MVVM)
- Backend : Firebase (Firestore, Auth, Cloud Functions, APNs)

## Règles de communication
- **Langue** : Français exclusivement — conversation, documents, artifacts, titres de stories/epics, acceptance criteria, user stories, TOUT sans exception (y compris BMAD config `communication_language` et `document_output_language`). Aucun anglais nulle part.
- **Date et heure** : Toujours afficher la date et l'heure courante dans chaque réponse et chaque document produit (format : `📅 YYYY-MM-DD HH:MM`)

## Workflow de développement
- Pipeline : Claude Code → VS Code → Makefile → xcodebuild + simctl → Simulator
- Voir `docs/ios_vscode_workflow_V4.md` pour le guide complet
- Xcode uniquement pour : signing, capabilities, debug LLDB/Instruments, archive/upload App Store

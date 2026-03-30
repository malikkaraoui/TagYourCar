---
stepsCompleted: [1, 2, 3]
inputDocuments: []
session_topic: 'TagYourCar — Application communautaire iOS/Android de signalement véhicule'
session_goals: 'Définir la vision complète MVP → V2 → Long terme, valider les choix techniques et produit'
selected_approach: 'Party Mode — Brainstorming multi-agents BMAD complet'
techniques_used: ['party-mode', 'multi-agent-discussion', 'divergent-thinking']
ideas_generated: []
context_file: ''
---

# Brainstorming Session Results — TagYourCar

**Facilitateur:** Malik
**Date:** 📅 2026-03-20 12:38
**Agents participants:** John (PM), Sally (UX), Winston (Architecte), Amelia (Dev), Quinn (QA), Bob (SM)

---

## Session Overview

**Topic:** TagYourCar — Application communautaire mobile pour signaler des problèmes sur les véhicules (phares allumés, vitre ouverte, mal garé) via la plaque d'immatriculation.

**Goals:** Explorer et structurer la vision produit complète sur 3 étapes évolutives, valider les choix techniques et UX, poser les bases du MVP.

---

## Vision Produit — 3 Étapes

### Étape 1 — MVP
- Enregistrer sa plaque d'immatriculation (+ email optionnel)
- Signaler un problème sur un véhicule via une interface visuelle (zéro clavier)
- Notification push au propriétaire
- Système de points / réputation communautaire
- Gratuit

### Étape 2 — Intégration Véhicule
- Apple CarPlay / Android Auto
- Expérience embarquée

### Étape 3 — Vision Long Terme
- Communication véhicule-à-véhicule
- La donnée est la propriété de la voiture (elle envoie, elle reçoit)
- Les marques ne communiquent pas entre elles — TagYourCar comble ce vide
- MCP pour véhicules : discussion initiée par l'humain → protocole automobile autonome
- Passerelle avec OkazCar (okazcar.com, propriété de Malik) quand les deux apps sont en prod

---

## Décisions Produit Actées

### UX — Signalement

**3 zones visuelles (vue de dessus du véhicule) :**

**Avant :**
- Capot
- Phare
- Plaque
- Pneu
- Pare-choc

**Centre :**
- Pare-brise
- Portière avant
- Portière arrière
- Toit ouvrant
- Habitacle

**Arrière :**
- Coffre
- Phares
- Échappement
- Plaque
- Pare-choc
- Pneu

**Flow de signalement (4 taps, zéro texte) :**
1. Saisie plaque (clavier avec normalisation, pas d'OCR au MVP) → check vert ✅ (dans la base) / check rouge ❌ (pas enregistré)
2. Sélection zone sur la silhouette (Avant / Centre / Arrière)
3. Sélection élément dans la zone
4. Sélection statut/problème prédéfini → Envoi

**Pas de saisie clavier pour le message** — élimine barrière de langue, spam, friction. Statuts prédéfinis uniquement.

**Saisie de plaque intelligente :**
- Accepte tous formats : `ab123cd`, `AB-123-CD`, `AB 123 CD`
- Normalisation en temps réel
- Clavier alphanumérique restreint aux caractères valides par pays
- France MVP (SIV `AA-123-AA` + ancien format), Europe en V2
- OCR Vision Framework en V2

### Inscription & Vérification Anti-Fraude

- Sign in with Apple (obligatoire) + email/password en fallback
- Vérification physique du véhicule : vidéo où l'utilisateur marche autour du véhicule
- Détection anti-fake :
  - **Gyroscope + Accéléromètre** : vérifie que l'utilisateur bouge réellement (pas assis sur une chaise à filmer une photo)
  - **OCR on-device** : matcher la plaque visible dans la vidéo avec celle déclarée
  - **LiDAR** (si disponible) : détection de profondeur, anti-photo-d'une-photo
- **Validation 90% on-device** (Core ML, Vision, ARKit, CoreMotion) — zéro Cloud Vision API, zéro coût serveur
- 24h pour soumettre la vérification, pas de messages reçus pendant la vérification
- Profil affiche "En vérification ⏳" pendant le process

### Scoring & Anti-Spam

- Système de réputation type eBay/Uber
- Le destinataire note si l'info reçue était pertinente → impact direct sur le score de l'émetteur
- Seuils :
  - > 3 signalements/jour → flag activité inhabituelle
  - > 5 signalements/jour → blocage temporaire automatique
  - > 3 signalements notés "faux" → avertissement
  - > 5 faux → ban temporaire 7 jours
  - Récidive après ban → ban permanent
- Fréquence réaliste d'usage : ~1 signalement/semaine max

### Transfert de Propriété

- Si quelqu'un tente d'enregistrer une plaque déjà prise → demande envoyée au propriétaire actuel
- Propriétaire actuel a 48h pour répondre :
  - **Accepte** → nouveau proprio lance sa vérification vidéo
  - **Refuse** → il doit refaire le tour de son véhicule (même process que l'inscription). S'il le fait → transfert refusé. S'il ne le fait pas en 48h → transfert ouvert.
  - **Ignore (timeout 48h)** → transfert ouvert au demandeur
- Zéro document, zéro support humain — tout se prouve par présence physique
- Bonus : historique des transferts de propriété = data précieuse (mini-Carfax communautaire)

### Module de vérification unique réutilisable

```
verifyVehicleOwnership(userId, plateHash) → VideoCapture + Gyro + OCR Match + LiDAR
```
Utilisé pour : inscription initiale, contestation transfert, re-vérification future.

---

## Décisions Techniques Actées

### Stack

- **iOS** : Swift natif, SwiftUI, MVVM
- **Android** : Kotlin natif (dans la foulée, pas de cross-platform)
- **Backend** : Firebase (Firestore + Auth + Cloud Functions)
- **Notifications** : APNs direct (zéro tiers, zéro FCM)
- **Validation** : 100% on-device (Core ML, Vision, ARKit, CoreMotion)
- **Workflow dev** : VS Code + Claude Code + Makefile → `make run` (voir `docs/ios_vscode_workflow_V4.md`)

### Frameworks Apple Natifs

- `VNRecognizeTextRequest` (Vision) → OCR plaque
- `AVFoundation` → capture photo/vidéo
- `ARKit` + LiDAR → détection profondeur anti-fake
- `CMMotionManager` (CoreMotion) → vérification mouvement réel
- `UserNotifications` + APNs → push
- `FirebaseFirestore` via SPM → base de données
- `FirebaseAuth` via SPM → authentification

### Modèle de Données

```
vehicles: { plateHash, ownerId, verificationStatus, verificationMedia[], createdAt }
alerts: { targetPlateHash, zone, element, status, reporterUid, reporterScore, timestamp, feedbackStatus }
users: { uid, authProvider, reputationScore, alertsSent, alertsReceived, bannedUntil? }
```

### Architecture

```
TagYourCar (standalone)
├── Firebase Auth (Sign in with Apple + email)
├── Firestore (vehicles, alerts, users)
├── Cloud Functions (APNs routing)
└── On-device (Core ML, Vision, ARKit, CoreMotion)
```

- iOS utilise APNs, Android utilisera FCM — Cloud Functions gèrent le routing
- Coût serveur MVP = 0€ (Firebase Spark gratuit : 50K lectures/jour, 20K écritures/jour, 1GB stockage)
- Prévoyance écosystème : même algo de hash plaque `SHA256(normalize(plate))` que OkazCar, mais zéro couplage

### Cloisonnement OkazCar

- **TagYourCar et OkazCar = deux projets 100% indépendants**
- Backend séparé, auth séparée, data séparée
- Connexion future uniquement quand les deux sont en prod et prouvées
- Seul point commun prévu : même format de hash de plaque pour faciliter le JOIN futur

---

## Écrans MVP

1. **Onboarding** — vérification véhicule (vidéo guidée)
2. **Signalement** — silhouette → zone → élément → statut → envoi
3. **Mes alertes** — alertes reçues + feedback "info utile ?"
4. **Profil / Réglages** — voir détail ci-dessous

### Profil & Réglages

**Mon profil :**

- Nom, prénom
- Photo de profil
- Score / réputation
- Badges

**Mes véhicules :**

- Ajouter un véhicule (multi-véhicules, max 5 par compte)
- Au-delà de 5 → contact obligatoire (pro, flotte, business à monter)
- Supprimer un véhicule
- Statut de vérification par véhicule

**Historique :**

- Alertes envoyées
- Alertes reçues (+ retour OK / NOT OK du destinataire)

**Réglages :**

- Changer la langue
- Gérer les autorisations (caméra, notifications, localisation)
- Activer la localisation (sécurité : une voiture ne peut pas être physiquement à deux endroits en même temps)
- Partager l'application
- Supprimer son compte

**V2 :**

- Ajouter un numéro de téléphone (alerte SMS en complément du push)

---

## Questions Ouvertes (à traiter dans le PRD)

- Liste exacte des statuts/problèmes prédéfinis par élément
- Règles précises de ban progressif (durées, paliers)
- Politique de confidentialité / RGPD (hash plaque, données de localisation)
- Modèle économique (gratuit mais... freemium ? pub ? premium ?)
- Stratégie de lancement / acquisition premiers utilisateurs (effet réseau)
- Localisation comme anti-fraude : règles de cohérence géographique à définir

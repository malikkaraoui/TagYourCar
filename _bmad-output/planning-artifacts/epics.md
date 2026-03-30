---
stepsCompleted:
  - step-01-validate-prerequisites
  - step-02-design-epics
  - step-03-create-stories
  - step-04-final-validation
inputDocuments:
  - planning-artifacts/prd.md
  - planning-artifacts/architecture.md
  - planning-artifacts/ux-design-specification.md
---

# TagYourCar - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for TagYourCar, decomposing the requirements from the PRD, UX Design, and Architecture into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: L'utilisateur peut creer un compte via email, Apple Sign-In, Google Sign-In ou GitHub Sign-In
FR2: L'utilisateur peut se connecter a son compte
FR3: L'utilisateur peut se deconnecter
FR4: L'utilisateur peut supprimer definitivement son compte — purge complete Firebase (Auth, Firestore users, plates par ownerUid, reports par reporterUid, abuseTracking, fcmToken). Zero trace residuelle. La Cloud Function deleteUserData enchaine toutes les suppressions et confirme le succes.
FR5: L'utilisateur peut consulter et modifier son nom et prenom uniquement. L'email et le provider d'authentification (Apple, Google, GitHub) ne sont pas modifiables.
FR6: L'utilisateur peut enregistrer une plaque d'immatriculation sur son compte (max 5)
FR7: L'utilisateur peut supprimer une plaque de son compte
FR8: Le systeme verifie que l'utilisateur est le proprietaire de la plaque avant enregistrement
FR9: Le systeme valide le format de la plaque francaise (AA-123-AA)
FR10: Le systeme hashe les plaques avant stockage en base
FR11: L'utilisateur peut saisir manuellement une plaque pour signaler un probleme
FR12: L'utilisateur peut selectionner un type de probleme predefini contextuel par zone (avant: phares allumes, capot ouvert, trappe de charge ouverte, pneu a plat, autre / milieu: vitre ouverte, portiere mal fermee, toit ouvrant ouvert, autre / arriere: feux allumes, trappe a essence ouverte, coffre ouvert, pneu a plat, autre)
FR13: L'utilisateur peut envoyer un signalement en moins de 30 secondes
FR14: Le systeme verifie si la plaque signalee est enregistree dans la base
FR15: Si la plaque est enregistree, le systeme declenche une notification au proprietaire
FR16: Si la plaque n'est pas enregistree, le systeme affiche un message invitant a laisser un mot sur le pare-brise
FR17: Le systeme ne conserve aucune donnee quand la plaque signalee n'est pas enregistree
FR18: Le proprietaire recoit une notification push en temps reel quand un probleme est signale sur son vehicule
FR19: La notification contient le type de probleme, la zone, la couleur du vehicule et l'identifiant partiel de la plaque concernee
FR20: Le systeme demande la permission de notifications push uniquement a l'enregistrement de la premiere plaque
FR21: Le systeme applique un rate limiting sur les signalements par utilisateur
FR22: Le systeme detecte les patterns abusifs (signalements repetes sur une meme plaque par le meme utilisateur)
FR23: Le systeme peut bloquer un signaleur identifie comme abusif
FR24: L'utilisateur doit accepter les CGU et la politique de confidentialite a l'inscription
FR25: L'utilisateur peut consulter les CGU et la politique de confidentialite a tout moment
FR26: La suppression de compte entraine la suppression de toutes les donnees associees (plaques, profil, signalements, abuseTracking)

### NonFunctional Requirements

NFR1: Notification push delivree en < 5 secondes apres signalement
NFR2: Ecran de signalement charge en < 1 seconde
NFR3: Verification de plaque en base en < 500ms
NFR4: Flux complet de signalement realisable en < 30 secondes
NFR5: Support de 10 000 utilisateurs a 3 mois et 50 000+ a 12 mois sans degradation
NFR6: Firebase auto-scale gere les pics sans provisionnement manuel
NFR7: Architecture extensible (OCR, geolocalisation) sans refonte
NFR8: Disponibilite 99.5%+ (SLA Firebase)
NFR9: Aucune perte de signalement — retry automatique en cas d'echec de notification
NFR10: Standards iOS d'accessibilite respectes (VoiceOver, Dynamic Type)
NFR11: Contraste et taille de texte conformes aux guidelines Apple HIG

### Additional Requirements

**Architecture :**

- Starter template : projet Xcode vierge + SPM Firebase (structure dossiers MVVM + Services)
- Cloud Functions Node.js 20 LTS + TypeScript : hashPlate, onReportCreated, verifyOwnership, deleteUserData, checkAbuse
- Modele Firestore : collections users, plates (doc ID = hash SHA-256), reports (auto-ID), abuseTracking
- Security Rules Firestore strictes : lecture par proprietaire uniquement, ecriture plates/reports via Cloud Functions
- SHA-256 avec salt secret en variable d'environnement Cloud Functions
- CI/CD : GitHub Actions (build + XCTest + lint)
- Monitoring : Firebase Crashlytics + Analytics
- 2 environnements Firebase (dev + prod)
- Sequence d'implementation en 9 etapes (projet → auth → CF → Firestore → plaques → signalement → notifs → anti-abus → suppression)
- Firebase Auth providers : email, Apple Sign-In, Google Sign-In, GitHub Sign-In

**UX :**

- Flow signalement inverse (psychologie bebe) : zone voiture → type probleme → couleur vehicule → plaque (4 etapes, fun-first friction-last)
- 6 composants custom : CarZoneSelector, ProblemTypePicker, ColorSwatchGrid, PlateTextField, PlateCard, ConfirmationView
- Problemes contextuels par zone : avant (phares, capot, trappe charge, pneu, autre) / milieu (vitre, portiere, toit ouvrant, autre) / arriere (feux, trappe essence, coffre, pneu, autre)
- Grille 12 pastilles couleur vehicule (blanc, noir, gris, argent, bleu, rouge, vert, beige, jaune, orange, marron, autre)
- Haptique graduee : light (tap zone) → medium (selection probleme) → heavy (envoi)
- Envoi automatique quand plaque valide (pas de bouton "Envoyer" separe)
- Ecran Profil/Parametres : politique de confidentialite, CGU, lien site web, version app, deconnexion, suppression compte
- WCAG AA : contraste 4.5:1, VoiceOver sur tous composants custom, Dynamic Type, Reduce Motion
- Design tokens centralises (Theme.swift + Assets.xcassets) : palette couleurs, typographie SF Pro, spacing grille 8pt

### FR Coverage Map

| FR | Epic | Description |
|---|---|---|
| FR1 | Epic 1 | Creation compte (email, Apple, Google, GitHub) |
| FR2 | Epic 1 | Connexion |
| FR3 | Epic 1 | Deconnexion |
| FR4 | Epic 4 | Suppression compte + purge complete |
| FR5 | Epic 2 | Modification nom/prenom |
| FR6 | Epic 2 | Enregistrement plaque (max 5) |
| FR7 | Epic 2 | Suppression plaque |
| FR8 | Epic 2 | Verification propriete |
| FR9 | Epic 2 | Validation format plaque |
| FR10 | Epic 2 | Hashage plaque |
| FR11 | Epic 3 | Saisie plaque pour signalement |
| FR12 | Epic 3 | Selection probleme contextuel par zone |
| FR13 | Epic 3 | Signalement < 30 secondes |
| FR14 | Epic 3 | Verification plaque en base |
| FR15 | Epic 3 | Notification si plaque enregistree |
| FR16 | Epic 3 | Message pare-brise si plaque non enregistree |
| FR17 | Epic 3 | Zero donnee si plaque non enregistree |
| FR18 | Epic 3 | Notification push temps reel |
| FR19 | Epic 3 | Contenu notification (probleme + zone + couleur + plaque) |
| FR20 | Epic 2 | Permission notifications a la 1ere plaque |
| FR21 | Epic 4 | Rate limiting |
| FR22 | Epic 4 | Detection patterns abusifs |
| FR23 | Epic 4 | Blocage signaleur abusif |
| FR24 | Epic 1 | Acceptation CGU a l'inscription |
| FR25 | Epic 2 | Consultation CGU/politique a tout moment |
| FR26 | Epic 4 | Suppression donnees a la suppression compte |

## Epic List

### Epic 1: Foundation & Authentification
L'utilisateur peut creer un compte, se connecter, se deconnecter et accepter les CGU. Le socle technique est en place (projet Xcode, Firebase, Cloud Functions, design tokens, CI/CD).
**FRs couvertes:** FR1, FR2, FR3, FR24

### Epic 2: Profil & Gestion de Plaques
L'utilisateur peut gerer son profil (nom/prenom), enregistrer jusqu'a 5 plaques securisees (hashage SHA-256), et acceder aux parametres (CGU, politique de confidentialite, site web, version app).
**FRs couvertes:** FR5, FR6, FR7, FR8, FR9, FR10, FR20, FR25

### Epic 3: Signalement & Notifications
L'utilisateur peut signaler un probleme sur un vehicule via le flow inverse (zone voiture → type probleme → couleur → plaque) et le proprietaire recoit une notification push en temps reel. Gestion du cas plaque non enregistree (message pare-brise).
**FRs couvertes:** FR11, FR12, FR13, FR14, FR15, FR16, FR17, FR18, FR19

### Epic 4: Protection & Conformite RGPD
Le systeme est protege contre les abus (rate limiting, detection patterns, blocage) et l'utilisateur peut supprimer definitivement son compte avec purge complete de toutes ses donnees Firebase.
**FRs couvertes:** FR4, FR21, FR22, FR23, FR26

## Epic 1 : Foundation & Authentification

L'utilisateur peut creer un compte, se connecter, se deconnecter et accepter les CGU. Le socle technique est en place.

### Story 1.1 : Setup Projet & Design Tokens

En tant que developpeur,
Je veux un projet Xcode configure avec Firebase, la structure MVVM + Services, les design tokens et le CI/CD,
Afin que le socle technique soit pret pour toutes les features suivantes.

**Criteres d'acceptation :**

**Etant donne** un repository vide
**Quand** le projet est initialise
**Alors** le projet Xcode compile avec les packages SPM Firebase (Auth, Firestore, Functions, Messaging)
**Et** la structure de dossiers MVVM + Services est en place (App/, Views/, ViewModels/, Models/, Services/, Components/, Utilities/, Resources/)
**Et** Theme.swift contient les design tokens (couleurs, typographie, spacing, radius, shadows)
**Et** Assets.xcassets contient la palette couleurs TagYourCar
**Et** ViewState.swift et TagYourCarError.swift sont implementes
**Et** le Makefile fonctionne (build + run simulateur)
**Et** GitHub Actions CI est configure (build + XCTest + lint)
**Et** 2 environnements Firebase (dev + prod) sont configures

### Story 1.2 : Inscription & Connexion Email + CGU

En tant qu'utilisateur,
Je veux creer un compte par email et me connecter,
Afin d'avoir un compte securise pour utiliser TagYourCar.

**Criteres d'acceptation :**

**Etant donne** que l'utilisateur n'a pas de compte
**Quand** il ouvre l'app pour la premiere fois
**Alors** l'ecran de login s'affiche avec les options d'authentification
**Et** il peut s'inscrire par email avec mot de passe

**Etant donne** l'inscription par email
**Quand** l'utilisateur remplit ses informations
**Alors** il doit accepter les CGU et la politique de confidentialite avant de finaliser (FR24)
**Et** un document user est cree dans Firestore (uid, email, displayName, createdAt)

**Etant donne** un compte existant
**Quand** l'utilisateur saisit son email et mot de passe
**Alors** il est connecte et redirige vers l'ecran d'accueil (FR2)

**Etant donne** que l'utilisateur saisit un email invalide ou un mot de passe trop court
**Quand** il tente de s'inscrire ou de se connecter
**Alors** un message d'erreur explicite s'affiche sous le champ concerne
**Et** le bouton de validation reste desactive tant que le format est invalide

**Etant donne** que l'utilisateur saisit un mot de passe incorrect
**Quand** il tente de se connecter
**Alors** un message d'erreur s'affiche : "Email ou mot de passe incorrect"
**Et** aucune indication sur lequel des deux est faux (securite)

**Etant donne** une erreur reseau pendant l'inscription ou la connexion
**Quand** la requete Firebase echoue
**Alors** un banner non-bloquant s'affiche avec un message humain et un retry automatique en arriere-plan

**Etant donne** que l'utilisateur est connecte
**Quand** il choisit de se deconnecter
**Alors** sa session est fermee et il revient a l'ecran de login (FR3)

### Story 1.3 : Authentification Sociale (Apple, Google, GitHub)

En tant qu'utilisateur,
Je veux me connecter via Apple, Google ou GitHub en un tap,
Afin de m'inscrire plus rapidement sans creer un mot de passe.

**Criteres d'acceptation :**

**Etant donne** l'ecran de login
**Quand** l'utilisateur choisit Apple Sign-In
**Alors** le flow Apple Sign-In natif se declenche et le compte est cree/connecte (FR1)
**Et** les CGU doivent etre acceptees a la premiere connexion (FR24)

**Etant donne** l'ecran de login
**Quand** l'utilisateur choisit Google Sign-In
**Alors** le flow Google OAuth se declenche et le compte est cree/connecte (FR1)

**Etant donne** l'ecran de login
**Quand** l'utilisateur choisit GitHub Sign-In
**Alors** le flow GitHub OAuth se declenche et le compte est cree/connecte (FR1)

**Etant donne** que l'utilisateur annule le flow OAuth (Apple, Google ou GitHub)
**Quand** il ferme la fenetre d'authentification sans terminer
**Alors** l'app revient a l'ecran de login sans erreur ni message intrusif

**Etant donne** une erreur reseau pendant l'authentification sociale
**Quand** le flow OAuth echoue
**Alors** un banner non-bloquant s'affiche avec un message humain et un retry automatique en arriere-plan

**Etant donne** un utilisateur connecte via un provider social
**Quand** il se deconnecte et se reconnecte
**Alors** son compte existant est retrouve et ses donnees sont intactes

## Epic 2 : Profil & Gestion de Plaques

L'utilisateur peut gerer son profil, enregistrer jusqu'a 5 plaques securisees et acceder aux parametres.

### Story 2.1 : Cloud Functions Hashage & Verification

En tant que systeme,
Je veux hasher les plaques cote serveur et verifier la propriete,
Afin que les donnees sensibles soient protegees conformement au RGPD.

**Criteres d'acceptation :**

**Etant donne** qu'un utilisateur authentifie appelle la Cloud Function hashPlate avec une plaque en clair
**Quand** la fonction recoit la plaque
**Alors** elle hashe la plaque en SHA-256 avec le salt secret en variable d'environnement
**Et** elle stocke le document dans la collection plates (plateHash = doc ID, ownerUid, addedAt, verified)
**Et** elle retourne une confirmation au client sans exposer le hash

**Etant donne** qu'un utilisateur appelle verifyOwnership
**Quand** la verification est lancee
**Alors** le systeme confirme ou refuse la propriete de la plaque (FR8)

**Etant donne** qu'un utilisateur a deja 5 plaques enregistrees
**Quand** il tente d'en ajouter une 6eme
**Alors** la Cloud Function refuse avec une erreur explicite

**Etant donne** qu'une plaque est deja enregistree par un autre utilisateur
**Quand** un second utilisateur tente de l'enregistrer
**Alors** la Cloud Function refuse l'enregistrement

### Story 2.2 : Ecran Mes Plaques & Ajout de Plaque

En tant qu'utilisateur,
Je veux enregistrer mes plaques d'immatriculation,
Afin de recevoir des notifications quand quelqu'un signale un probleme sur mon vehicule.

**Criteres d'acceptation :**

**Etant donne** que l'utilisateur accede a l'onglet "Mes plaques"
**Quand** il n'a aucune plaque enregistree
**Alors** un etat vide s'affiche avec le CTA "Ajouter votre premiere plaque"

**Etant donne** que l'utilisateur tape "Ajouter une plaque"
**Quand** il saisit une plaque
**Alors** le champ PlateTextField auto-formate en AA-123-AA avec tirets automatiques et majuscules forcees (FR9)
**Et** la validation live affiche bordure verte si format valide, rouge sinon

**Etant donne** une plaque au format valide
**Quand** l'utilisateur confirme l'ajout
**Alors** la Cloud Function hashPlate est appelee (FR10)
**Et** la plaque apparait dans la liste sous forme de PlateCard masquee (AB-1xx-CD) avec badge cadenas (FR6)

**Etant donne** que c'est la premiere plaque enregistree
**Quand** l'ajout est confirme
**Alors** le systeme demande la permission de notifications push (FR20)

### Story 2.3 : Suppression de Plaque

En tant qu'utilisateur,
Je veux supprimer une plaque de mon compte,
Afin de ne plus recevoir de notifications pour un vehicule que je ne possede plus.

**Criteres d'acceptation :**

**Etant donne** que l'utilisateur a des plaques enregistrees
**Quand** il swipe une PlateCard vers la gauche
**Alors** une action "Supprimer" apparait

**Etant donne** que l'utilisateur confirme la suppression
**Quand** la suppression est executee
**Alors** le document plate est supprime de Firestore (FR7)
**Et** la plaque disparait de la liste

**Etant donne** que l'utilisateur supprime sa derniere plaque
**Quand** la liste est vide
**Alors** l'etat vide s'affiche a nouveau avec le CTA d'ajout

### Story 2.4 : Profil & Parametres

En tant qu'utilisateur,
Je veux acceder a mon profil et aux parametres de l'app,
Afin de modifier mes informations et consulter les conditions legales.

**Criteres d'acceptation :**

**Etant donne** que l'utilisateur est sur l'ecran "Mes plaques"
**Quand** il tape l'icone profil dans la navigation bar
**Alors** l'ecran Profil/Parametres s'affiche

**Etant donne** l'ecran Profil
**Quand** l'utilisateur modifie son nom ou prenom
**Alors** les modifications sont sauvegardees dans Firestore (FR5)
**Et** l'email et le provider d'authentification ne sont pas modifiables

**Etant donne** l'ecran Parametres
**Quand** l'utilisateur consulte les elements
**Alors** il voit : politique de confidentialite, CGU, lien site web TagYourCar, version de l'app (FR25)
**Et** chaque lien ouvre le contenu correspondant

## Epic 3 : Signalement & Notifications

L'utilisateur peut signaler un probleme sur un vehicule via le flow inverse et le proprietaire recoit une notification push en temps reel.

### Story 3.1 : Selection de Zone & Type de Probleme

En tant qu'utilisateur,
Je veux taper sur une zone de la voiture et voir les problemes correspondants,
Afin de localiser visuellement le probleme sans effort.

**Criteres d'acceptation :**

**Etant donne** que l'utilisateur ouvre l'onglet "Signaler"
**Quand** l'ecran s'affiche
**Alors** la silhouette voiture top-down SVG apparait avec 3 zones tappables (avant/milieu/arriere)
**Et** aucun texte ni label — language-agnostic

**Etant donne** que l'utilisateur tape sur une zone
**Quand** la zone est selectionnee
**Alors** la zone passe en accent violet avec haptique light
**Et** les icones problemes contextuelles s'affichent (FR12) :
- Avant : phares allumes, capot ouvert, trappe de charge ouverte, pneu a plat, autre
- Milieu : vitre ouverte, portiere mal fermee, toit ouvrant ouvert, autre
- Arriere : feux allumes, trappe a essence ouverte, coffre ouvert, pneu a plat, autre

**Etant donne** que les icones sont affichees
**Quand** l'utilisateur tape sur un probleme
**Alors** le probleme est selectionne avec haptique medium et scale 0.95
**Et** la transition vers l'etape couleur se declenche

**Etant donne** que VoiceOver est active
**Quand** l'utilisateur navigue sur le CarZoneSelector
**Alors** chaque zone est annoncee ("Zone avant du vehicule", "Zone milieu", "Zone arriere")

### Story 3.2 : Couleur du Vehicule & Saisie de Plaque

En tant qu'utilisateur,
Je veux choisir la couleur du vehicule puis saisir la plaque,
Afin que le signalement soit complet et que le proprietaire puisse confirmer que c'est bien sa voiture.

**Criteres d'acceptation :**

**Etant donne** que l'utilisateur a selectionne un probleme
**Quand** l'ecran couleur s'affiche
**Alors** une grille 4x3 de pastilles rondes apparait (12 couleurs : blanc, noir, gris, argent, bleu, rouge, vert, beige, jaune, orange, marron, autre)
**Et** chaque pastille fait minimum 44x44pt
**Et** la pastille "autre" affiche une icone "?"

**Etant donne** que l'utilisateur tape une pastille
**Quand** la couleur est selectionnee
**Alors** la pastille affiche une bordure accent + check avec haptique light
**Et** la transition vers la saisie plaque se declenche

**Etant donne** que l'ecran saisie plaque s'affiche
**Quand** le clavier alphanum s'ouvre automatiquement
**Alors** le PlateTextField auto-formate en AA-123-AA (tirets auto, majuscules forcees)
**Et** le placeholder affiche "AA-123-AA" en SF Pro Mono 24pt Medium

**Etant donne** que l'utilisateur saisit une plaque au format valide
**Quand** le format est complet
**Alors** l'envoi se declenche automatiquement sans bouton "Envoyer" (FR13)

### Story 3.3 : Envoi du Signalement & Notification Push

En tant qu'utilisateur,
Je veux que mon signalement soit envoye et le proprietaire notifie instantanement,
Afin que le proprietaire puisse agir sur le probleme signale.

**Criteres d'acceptation :**

**Etant donne** qu'une plaque valide est saisie et l'envoi se declenche
**Quand** le ReportService ecrit dans Firestore reports
**Alors** le document report contient : reporterUid, plateHash, problemType, zone, vehicleColor, createdAt, status (FR14)

**Etant donne** qu'un report est cree dans Firestore
**Quand** la Cloud Function onReportCreated se declenche
**Alors** elle lit plates pour trouver ownerUid par plateHash
**Et** elle lit users pour trouver le fcmToken
**Et** elle envoie une notification FCM (FR15, FR18)
**Et** la notification contient : type de probleme, zone, couleur du vehicule, plaque partielle (FR19)
**Et** la notification est delivree en < 5 secondes (NFR1)

**Etant donne** que la plaque signalee est enregistree
**Quand** l'envoi est confirme
**Alors** l'ecran de confirmation succes s'affiche : animation check + fond vert + haptique heavy
**Et** texte "C'est envoye ! Le proprietaire sera notifie."
**Et** auto-dismiss apres 2 secondes, retour a l'ecran d'accueil

### Story 3.4 : Plaque Non Enregistree & Carte Pare-Brise

En tant qu'utilisateur,
Je veux etre informe quand la plaque n'est pas sur TagYourCar,
Afin de pouvoir quand meme agir en laissant un mot physique.

**Criteres d'acceptation :**

**Etant donne** qu'un signalement est envoye
**Quand** la plaque n'est pas enregistree dans Firestore (FR14)
**Alors** aucun document report n'est sauvegarde en base (FR17)
**Et** l'ecran de confirmation echec s'affiche avec haptique notification

**Etant donne** que l'ecran plaque non enregistree s'affiche
**Quand** l'utilisateur le voit
**Alors** le ton est encourageant : "Ce conducteur n'est pas encore sur TagYourCar" (FR16)
**Et** un CTA "Carte pare-brise" propose d'ouvrir/partager une fiche a glisser dans le joint de vitre

**Etant donne** que l'utilisateur tape le CTA carte pare-brise
**Quand** l'action est declenchee
**Alors** une sheet modale s'ouvre avec la fiche (lien pour imprimer ou partager)

**Etant donne** que l'utilisateur ferme la sheet ou ignore le CTA
**Quand** il quitte l'ecran
**Alors** retour a l'ecran d'accueil (silhouette voiture)

### Story 3.5 : Reception & Consultation du Signalement

En tant que proprietaire,
Je veux recevoir et consulter le detail d'un signalement sur mon vehicule,
Afin de pouvoir agir rapidement sur le probleme signale.

**Criteres d'acceptation :**

**Etant donne** qu'un signalement est envoye sur une de mes plaques
**Quand** la notification push arrive
**Alors** le texte est humain : "Quelqu'un vous signale que vos phares sont allumes sur AB-1xx-CD" (FR18, FR19)
**Et** la notification est visible sur l'ecran verrouille

**Etant donne** que le proprietaire tape sur la notification
**Quand** l'app s'ouvre
**Alors** l'ecran detail signalement s'affiche avec : type de probleme, zone concernee, couleur du vehicule signale, horodatage

**Etant donne** que le proprietaire consulte le detail
**Quand** il a fini
**Alors** pas de bouton "repondre" — l'utilisateur sait quoi faire
**Et** il peut fermer et revenir a l'ecran d'accueil

## Epic 4 : Protection & Conformite RGPD

Le systeme est protege contre les abus et l'utilisateur peut supprimer definitivement son compte avec purge complete de toutes ses donnees Firebase.

### Story 4.1 : Anti-Abus — Rate Limiting & Blocage Progressif

En tant que systeme,
Je veux limiter le nombre de signalements par utilisateur et appliquer un blocage progressif en cas d'abus,
Afin de proteger la communaute contre le spam et le harcelement.

**Criteres d'acceptation :**

**Etant donne** qu'un utilisateur envoie un signalement
**Quand** la Cloud Function checkAbuse est appelee
**Alors** elle verifie le compteur de signalements sur les dernieres 24h dans abuseTracking (FR21)
**Et** si le compteur depasse le seuil autorise, le signalement est refuse avec un message explicite

**Etant donne** qu'un utilisateur signale la meme plaque plusieurs fois
**Quand** la Cloud Function detecte ce pattern
**Alors** elle identifie le comportement comme abusif (FR22)
**Et** le champ blocked passe a true avec une duree de 24h (FR23)
**Et** le champ blockLevel passe a 1
**Et** l'utilisateur recoit un message : "Votre compte est temporairement restreint pour 24 heures"

**Etant donne** qu'un utilisateur deja bloque une premiere fois (blockLevel = 1) recidive apres la levee du blocage
**Quand** la Cloud Function detecte a nouveau un pattern abusif
**Alors** le blocage passe a 72h
**Et** le champ blockLevel passe a 2
**Et** l'utilisateur recoit un message : "Votre compte est restreint pour 72 heures"

**Etant donne** qu'un utilisateur deja bloque deux fois (blockLevel = 2) recidive a nouveau
**Quand** la Cloud Function detecte un troisieme pattern abusif
**Alors** le blocage devient definitif (pas de date d'expiration)
**Et** le champ blockLevel passe a 3
**Et** l'utilisateur recoit un message : "Votre compte a ete definitivement restreint"

**Etant donne** qu'un utilisateur est bloque (quel que soit le niveau)
**Quand** il tente d'envoyer un signalement
**Alors** le signalement est refuse
**Et** un message lui indique la duree restante du blocage (ou definitif si blockLevel = 3)

**Etant donne** que le rate limiting est actif
**Quand** un utilisateur non-abusif envoie un signalement dans les limites
**Alors** le signalement passe normalement sans friction supplementaire

### Story 4.2 : Suppression de Compte & Purge Complete

En tant qu'utilisateur,
Je veux supprimer definitivement mon compte et toutes mes donnees,
Afin d'exercer mon droit a l'oubli conformement au RGPD.

**Criteres d'acceptation :**

**Etant donne** que l'utilisateur est sur l'ecran Profil/Parametres
**Quand** il tape "Supprimer mon compte"
**Alors** un ecran de confirmation s'affiche avec un avertissement clair : "Cette action est irreversible. Toutes vos donnees seront supprimees."

**Etant donne** que l'utilisateur confirme la suppression
**Quand** la Cloud Function deleteUserData est appelee
**Alors** elle supprime dans cet ordre :

- tous les documents plates ou ownerUid == uid de l'utilisateur
- tous les documents reports ou reporterUid == uid de l'utilisateur
- le document abuseTracking de l'utilisateur
- le document users de l'utilisateur
- le compte Firebase Auth de l'utilisateur
**Et** chaque suppression est verifiee avant de passer a la suivante (FR4, FR26)
**Et** zero trace residuelle dans Firebase

**Etant donne** que la purge est terminee
**Quand** la Cloud Function retourne le succes
**Alors** l'utilisateur est deconnecte et redirige vers l'ecran de login
**Et** un message confirme la suppression

**Etant donne** que la suppression echoue en cours de route
**Quand** une erreur survient sur une des collections
**Alors** la Cloud Function log l'erreur et retente la suppression
**Et** l'utilisateur est informe que la suppression est en cours de traitement

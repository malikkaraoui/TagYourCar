---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-02b-vision
  - step-02c-executive-summary
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
  - step-12-complete
classification:
  projectType: mobile_app
  domain: communautaire_automobile
  complexity: medium
  projectContext: greenfield
---

# Product Requirements Document — TagYourCar

**Auteur :** Malik Karaoui
**Date :** 2026-03-20

## Résumé Exécutif

TagYourCar est une application iOS communautaire et gratuite qui résout un problème universel : **l'impossibilité de prévenir le propriétaire d'un véhicule d'un problème visible** (phares allumés, vitre ouverte, mal garé). La plaque d'immatriculation sert d'identifiant universel — pas de réseau social, pas de messagerie privée, juste un outil d'alerte direct entre automobilistes inconnus.

L'app cible **tous les automobilistes** sans distinction. Le modèle de conversion repose sur l'évidence du besoin : une seule alerte reçue (batterie sauvée, vol évité) transforme un utilisateur passif en ambassadeur actif. La gratuité et la simplicité suppriment toute friction d'adoption.

TagYourCar s'inscrit dans un écosystème aux côtés d'OkazCar (analyse de confiance véhicules d'occasion). À terme, la donnée collectée (habitudes, zones, véhicules) alimente des SaaS B2B et ouvre des partenariats stratégiques — notamment les assureurs, pour qui chaque sinistre évité représente une économie directe.

### Ce qui rend TagYourCar spécial

- **Aucun concurrent** : en 15+ ans, personne n'a adressé ce besoin pourtant universel en France
- **Conversion quasi-instantanée** : une seule alerte reçue suffit à fidéliser l'utilisateur
- **Cheval de Troie stratégique** : app gratuite en surface, machine à collecter de la donnée humaine à haute valeur en profondeur
- **Synergie écosystème** : la plaque comme pivot entre TagYourCar (entraide) et OkazCar (marché VO), créant un effet de réseau autour du véhicule
- **Partenaires naturels** : les assureurs (GMF, AXA...) ont un intérêt direct — chaque sinistre prévenu = argent économisé

## Classification du projet

| Critère | Valeur |
| ------- | ------ |
| **Type** | Application mobile iOS (Swift natif, SwiftUI, MVVM) |
| **Domaine** | Communautaire automobile / mobilité |
| **Complexité** | Moyenne (données plaques, push notifications, modération) |
| **Contexte** | Greenfield |
| **Backend** | Firebase (Firestore, Auth, Cloud Functions, APNs) |

## Critères de Succès

### Succès Utilisateur

- Notification push en **temps réel** quand quelqu'un signale un problème sur son véhicule
- Signalement en **moins de 30 secondes** (saisie plaque → sélection problème → envoi)
- App **silencieuse par défaut** — elle ne sonne que quand ça compte. Pas de spam, pas de gamification artificielle
- Modèle anti-traditionnel : l'utilisateur **oublie l'app** jusqu'au moment où elle lui sauve la mise

### Succès Business

- **10 000 utilisateurs** dans les 3 premiers mois post-lancement
- Rétention mesurée par les plaques enregistrées actives (pas par l'usage quotidien — app dormante par design)
- Croissance organique via le bouche-à-oreille (chaque alerte reçue = ambassadeur potentiel)

### Succès Technique

- Notification push délivrée en **< 5 secondes** après signalement
- Disponibilité **99.5%+** (SLA Firebase)
- Zéro fuite de données personnelles (plaques = donnée sensible)

### Résultats Mesurables

| Métrique | Cible 3 mois | Cible 12 mois |
| -------- | ------------ | ------------- |
| Utilisateurs inscrits | 10 000 | 50 000+ |
| Plaques enregistrées | 15 000+ | 75 000+ |
| Alertes envoyées/jour | 100+ | 1 000+ |
| Temps de livraison notif | < 5s | < 3s |

## Parcours Utilisateur

### Parcours 1 — Sophie, la signaleuse (happy path)

Sophie, 34 ans, sort du supermarché. Elle remarque une Clio garée à côté avec les phares allumés. Elle ouvre TagYourCar, tape la plaque, sélectionne "Phares allumés", envoie. **15 secondes.** Elle repart tranquille.

**Moment clé :** La simplicité — pas de message à écrire, juste plaque + problème + envoyer.

### Parcours 2 — Marc, le propriétaire sauvé (le moment bingo)

Marc, 42 ans, est au bureau. Son téléphone vibre : "Quelqu'un a signalé un problème sur votre véhicule AB-123-CD : Vitre passager ouverte." Il pleut. Marc descend en courant au parking, ferme sa vitre. Intérieur sauvé. Il parle de l'app à 3 collègues le jour même.

**Moment clé :** La notification qui change tout. L'app dormante depuis des semaines vient de prouver sa valeur en une seconde.

### Parcours 3 — Sophie signale une plaque non enregistrée (edge case)

Sophie tape une plaque. L'app répond : "Cette plaque n'est pas encore enregistrée sur TagYourCar. Laissez un petit mot sur le pare-brise pour que ce propriétaire ait le réflexe TagYourCar la prochaine fois !" Aucun signalement sauvegardé — zéro donnée orpheline en base.

**Moment clé :** L'app transforme un échec en opportunité de croissance organique — chaque mot sur un pare-brise est un tract gratuit.

### Parcours 4 — Léa reçoit son kit de bienvenue

Léa s'inscrit et enregistre sa première plaque. Pour recevoir son kit, elle fournit son adresse postale. Quelques jours plus tard, elle reçoit :

- **1 autocollant** carré bords arrondis (logo TagYourCar + hashtag) — à coller sur sa propre voiture
- **1 carte** à glisser dans le joint de vitre conducteur d'un véhicule tagué non inscrit (on ne dégrade rien)

Chaque voiture équipée d'un autocollant = panneau publicitaire ambulant. Chaque carte déposée = tract de conversion.

**Données collectées au passage :** nom, prénom, email, plaque(s), adresse postale, type de smartphone — le tout opt-in et consenti.

### Synthèse des capacités révélées par les parcours

| Parcours | Capacités requises |
| -------- | ------------------ |
| Sophie signale | Saisie plaque, sélection problème, envoi signalement |
| Marc reçoit | Notification push temps réel, affichage détail signalement |
| Plaque inconnue | Vérification plaque en base, message encouragement pare-brise |
| Kit bienvenue | Collecte adresse postale, envoi postal (manuel au début) |
| Admin MVP | Console Firebase directe, pas de dashboard custom |

## Exigences Domaine

### RGPD & Données Personnelles

- Les plaques d'immatriculation sont des **données personnelles** au sens du RGPD (identification indirecte via le SIV)
- **Hashage systématique** des données sensibles en base (plaques, adresses postales) — même en cas de compromission, les données brutes sont inexploitables
- Consentement explicite à l'inscription (CGU + politique de confidentialité)
- Droit à la suppression de compte et de toutes les données associées
- Pas de conservation de signalements orphelins (plaque non enregistrée = aucune trace en base)

### Sécurité & Anti-abus

- Firebase Security Rules strictes (accès limité au propriétaire authentifié)
- Hashage des plaques côté serveur (Cloud Function) avant stockage Firestore
- Aucune donnée personnelle en clair stockée en base
- Données en transit chiffrées via TLS (Firebase par défaut)
- Rate limiting sur les signalements par utilisateur
- Détection de patterns abusifs (signalements répétés sur une même plaque)
- Possibilité de bloquer un signaleur abusif

### App Store Compliance

- Suppression de compte obligatoire (Apple requirement)
- Consentement notifications push explicite
- Pas de contenu utilisateur visible publiquement (pas de messagerie, pas de commentaires)

## Innovation & Paysage Concurrentiel

### Tentatives existantes (toutes échouées ou moribondes)

Plusieurs apps ont tenté le concept "contacter un conducteur via sa plaque" : Plext, CarConnect, CarAlert, CaRegi, WheelBees, Zilp, Burnt Out. Constat : sites morts, apps non mises à jour, zéro traction.

**Causes d'échec :**

- **Mauvais angle** : messagerie/appel entre inconnus → personne ne veut être appelé par un inconnu via sa plaque
- **Trop ouvert** : chat libre = porte ouverte au spam et harcèlement
- **Pas de vision business** : devs isolés sans stratégie de croissance
- **Pas de marché local** : aucune app française sur ce créneau

### Différenciation TagYourCar

- **Pas de messagerie, pas d'appel** — signalement prédéfini uniquement. Impossible de harceler avec un menu déroulant
- **Marché français vierge** — zéro concurrent local
- **Simplicité radicale** — 15 secondes, pas de conversation, pas de profil social
- **Vision business structurée** — écosystème OkazCar, collecte data opt-in, partenariats assureurs, SaaS B2B
- **Growth physique-digital** — kit autocollant + carte pare-brise, chaque utilisateur = agent de conversion IRL

### Validation

- Le concept a été tenté plusieurs fois → le besoin existe, l'exécution était mauvaise
- TagYourCar corrige les erreurs : pas de chat, pas d'appel, gratuit, simple, français
- Métrique clé : taux "1ère notif reçue → en parle à quelqu'un"

## Exigences Spécifiques Mobile iOS

### Architecture technique

- **Plateforme** : iOS natif uniquement (Swift, SwiftUI, MVVM)
- **Backend** : Firebase (Firestore, Auth, Cloud Functions, Cloud Messaging)
- **Notifications** : APNs via Firebase Cloud Messaging — coeur du produit
- **Mode hors-ligne** : non requis

### Permissions appareil (stratégie lazy)

Permissions demandées **uniquement quand la fonction qui en a besoin est activée** — jamais au premier lancement.

| Permission | Quand demandée | Usage |
| ---------- | -------------- | ----- |
| Notifications push | Enregistrement de la première plaque | Alertes de signalement |
| Caméra | Post-MVP : activation du scan OCR | Reconnaissance automatique de plaque |
| Localisation | Post-MVP : activation zone/stats | Stats par zone + anti-usurpation |

### Saisie de plaque

- **MVP** : saisie manuelle au clavier avec validation du format français (AA-123-AA)
- **Post-MVP** : scan OCR via caméra (détection automatique)

### Géolocalisation (Post-MVP)

- Statistiques par zone géographique
- **Anti-usurpation** : vérification de cohérence entre lieu du signalement et position habituelle du véhicule
- Donnée à haute valeur pour les futurs SaaS B2B

### Conformité App Store

- iOS 16+ minimum (~95% du parc)
- Suppression de compte intégrée
- Pas de contenu utilisateur public → catégorie simple en App Review
- Pas de paiement in-app en MVP

## Scoping & Développement Phasé

### Stratégie MVP

**Approche :** MVP de validation — le strict minimum pour prouver que le concept convertit.

**Ressources :** Dev solo (Malik) + Claude. Firebase gère l'infra.

### Phase 1 — MVP

**Parcours supportés :** Sophie signale → Marc reçoit → Plaque inconnue (message pare-brise)

| Fonctionnalité | Détail |
| -------------- | ------ |
| Authentification | Firebase Auth (email + Apple Sign-In) |
| Gestion de plaques | Ajouter jusqu'à 5 plaques, vérification de propriété |
| Signalement | Saisie plaque manuelle + sélection problème prédéfini |
| Notification push | Alerte temps réel via FCM/APNs |
| Plaque inconnue | Message "laissez un mot sur le pare-brise" |
| Suppression compte | Conformité RGPD + App Store |
| Sécurité | Hashage plaques, Firebase Security Rules |

### Phase 2 — Croissance

| Fonctionnalité | Détail |
| -------------- | ------ |
| Scan OCR plaque | Caméra pour détecter automatiquement la plaque |
| Géolocalisation | Stats par zone + anti-usurpation |
| Kit de bienvenue | Collecte adresse postale, envoi autocollant + carte |
| Historique | Signalements reçus/envoyés |
| Stats communautaires | Nombre de signalements par zone |
| Gamification légère | Badges, compteur d'entraide |

### Phase 3 — Expansion

| Fonctionnalité | Détail |
| -------------- | ------ |
| Synergie OkazCar | Passerelle entre les deux apps |
| SaaS B2B | Parkings, assureurs, flottes |
| Partenariats assureurs | GMF, AXA — sinistres évités |
| Exploitation data | Données anonymisées à valeur commerciale |
| Espace pub | Publicité contextuelle |

### Analyse des risques

| Type | Risque | Mitigation |
| ---- | ------ | ---------- |
| Marché | Masse critique insuffisante | Lancement ciblé 1 ville + kit physique |
| Marché | Concurrence soudaine | First mover France + données + effet réseau |
| Technique | Latence notifications | Firebase SLA garanti |
| Ressources | Dev solo | Firebase élimine la complexité backend, Claude accélère le dev |
| Abus | Spam/harcèlement | Signalements prédéfinis uniquement + rate limiting |

## Exigences Fonctionnelles

### Gestion de compte

- **FR1** : L'utilisateur peut créer un compte via email ou Apple Sign-In
- **FR2** : L'utilisateur peut se connecter à son compte
- **FR3** : L'utilisateur peut se déconnecter
- **FR4** : L'utilisateur peut supprimer définitivement son compte et toutes ses données associées
- **FR5** : L'utilisateur peut consulter et modifier ses informations de profil

### Gestion de plaques

- **FR6** : L'utilisateur peut enregistrer une plaque d'immatriculation sur son compte (max 5)
- **FR7** : L'utilisateur peut supprimer une plaque de son compte
- **FR8** : Le système vérifie que l'utilisateur est le propriétaire de la plaque avant enregistrement
- **FR9** : Le système valide le format de la plaque française (AA-123-AA)
- **FR10** : Le système hashe les plaques avant stockage en base

### Signalement

- **FR11** : L'utilisateur peut saisir manuellement une plaque pour signaler un problème
- **FR12** : L'utilisateur peut sélectionner un type de problème prédéfini contextuel par zone (avant : phares allumés, capot ouvert, trappe de charge ouverte, pneu à plat, autre / milieu : vitre ouverte, portière mal fermée, toit ouvrant ouvert, autre / arrière : feux allumés, trappe à essence ouverte, coffre ouvert, pneu à plat, autre)
- **FR13** : L'utilisateur peut envoyer un signalement en moins de 30 secondes
- **FR14** : Le système vérifie si la plaque signalée est enregistrée dans la base
- **FR15** : Si la plaque est enregistrée, le système déclenche une notification au propriétaire
- **FR16** : Si la plaque n'est pas enregistrée, le système affiche un message invitant à laisser un mot sur le pare-brise
- **FR17** : Le système ne conserve aucune donnée quand la plaque signalée n'est pas enregistrée

### Notifications

- **FR18** : Le propriétaire reçoit une notification push en temps réel quand un problème est signalé sur son véhicule
- **FR19** : La notification contient le type de problème et l'identifiant partiel de la plaque concernée
- **FR20** : Le système demande la permission de notifications push uniquement à l'enregistrement de la première plaque

### Anti-abus

- **FR21** : Le système applique un rate limiting sur les signalements par utilisateur
- **FR22** : Le système détecte les patterns abusifs (signalements répétés sur une même plaque par le même utilisateur)
- **FR23** : Le système peut bloquer un signaleur identifié comme abusif

### Consentement & RGPD

- **FR24** : L'utilisateur doit accepter les CGU et la politique de confidentialité à l'inscription
- **FR25** : L'utilisateur peut consulter les CGU et la politique de confidentialité à tout moment
- **FR26** : La suppression de compte entraîne la suppression de toutes les données associées (plaques, profil)

## Exigences Non-Fonctionnelles

### Performance

- **NFR1** : Notification push délivrée en **< 5 secondes** après signalement
- **NFR2** : Écran de signalement chargé en **< 1 seconde**
- **NFR3** : Vérification de plaque en base en **< 500ms**
- **NFR4** : Flux complet de signalement réalisable en **< 30 secondes**

### Scalabilité

- **NFR5** : Support de **10 000 utilisateurs** à 3 mois et **50 000+** à 12 mois sans dégradation
- **NFR6** : Firebase auto-scale gère les pics sans provisionnement manuel
- **NFR7** : Architecture extensible (OCR, géolocalisation) sans refonte

### Fiabilité

- **NFR8** : Disponibilité **99.5%+** (SLA Firebase)
- **NFR9** : Aucune perte de signalement — retry automatique en cas d'échec de notification

### Accessibilité

- **NFR10** : Standards iOS d'accessibilité respectés (VoiceOver, Dynamic Type)
- **NFR11** : Contraste et taille de texte conformes aux guidelines Apple HIG

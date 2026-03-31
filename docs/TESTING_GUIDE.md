# Guide de Test - TagYourCar

## 🎯 Corrections apportées

### ✅ P0 - Critique (Résolu)
1. **Double configuration Firebase** ❌ → Supprimé de `TagYourCarApp.swift`, gardé uniquement dans `AppDelegate`
2. **Gestion d'erreur Firebase** ❌ → Ajout de `TagYourCarError.firebaseNotConfigured`
3. **Logs améliorés** ❌ → Passage de `warning` à `error` pour les cas critiques

### ✅ P1 - Important (Résolu)
4. **Mapping d'erreurs Firebase** ❌ → Ajout de 8+ codes d'erreur supplémentaires avec ID de référence
5. **Haptic feedback** ❌ → Ajouté sur succès/erreur pour ajout et suppression de plaques
6. **Gestion du clavier** ❌ → `.scrollDismissesKeyboard(.interactively)` sur LoginView et SignUpView
7. **Accessibilité** ❌ → Labels, hints et values ajoutés sur tous les contrôles interactifs

### ✅ Améliorations supplémentaires
8. **Limite Firestore** ❌ → `.limit(to: 10)` ajouté sur la requête
9. **Messages de chargement** ❌ → "Chargement de vos plaques..." au lieu d'un simple spinner
10. **HealthCheck** ❌ → Nouveau système de vérification au démarrage

---

## 📱 Plan de test sur Simulateur

### 1. Test de démarrage
- [ ] Vérifier les logs dans la Console Xcode
- [ ] Rechercher "✅ Firebase est correctement configuré"
- [ ] Pas d'erreurs critiques au lancement

### 2. Test d'authentification

#### Email/Password
- [ ] Créer un nouveau compte
- [ ] Valider les champs en temps réel (email invalide = bordure rouge)
- [ ] Tester mot de passe < 6 caractères
- [ ] Vérifier que la case CGU doit être cochée
- [ ] Se déconnecter et se reconnecter

#### Providers sociaux (Simulateur)
- [ ] Apple Sign In → Devrait fonctionner sur simulateur iOS 17+
- [ ] Google Sign In → Peut échouer sur simulateur (normal)
- [ ] GitHub → Peut échouer sur simulateur (normal)

**Note** : Les providers sociaux fonctionnent mieux sur device réel

### 3. Test des plaques

#### Ajout
- [ ] Ajouter une première plaque → Permission notifications demandée
- [ ] Vérifier le haptic feedback (si device)
- [ ] Ajouter jusqu'à 5 plaques
- [ ] Vérifier que le bouton "+" disparaît à 5 plaques
- [ ] Tenter d'ajouter une plaque avec format invalide

#### Suppression
- [ ] Swiper vers la gauche sur une plaque
- [ ] Confirmer la suppression
- [ ] Vérifier le haptic feedback (si device)
- [ ] Vérifier que le compteur se met à jour

### 4. Test de l'UI

#### Clavier
- [ ] Ouvrir LoginView, taper dans le champ email
- [ ] Scroller → Le clavier doit se fermer automatiquement
- [ ] Idem sur SignUpView

#### États de chargement
- [ ] Connexion lente → Voir le spinner
- [ ] PlateListView au premier chargement → "Chargement de vos plaques..."

#### Erreurs
- [ ] Tenter de se connecter avec mauvais mot de passe
- [ ] Vérifier le message d'erreur clair
- [ ] Vérifier que l'erreur a un ID de référence

### 5. Test d'accessibilité

#### VoiceOver (iOS)
- [ ] Activer VoiceOver : Settings > Accessibility > VoiceOver
- [ ] Naviguer dans LoginView
- [ ] Vérifier que tous les boutons ont des labels
- [ ] Vérifier la case à cocher CGU ("Cochée" / "Non cochée")

#### Dynamic Type
- [ ] Settings > Accessibility > Display & Text Size > Larger Text
- [ ] Augmenter la taille du texte
- [ ] Vérifier que l'UI s'adapte

---

## 📱 Plan de test sur iPhone 12 Pro

### Pré-requis
1. **Certificat de développement** configuré dans Xcode
2. **Bundle ID** unique (ex: `com.votrecompte.tagyourcar`)
3. **Signing & Capabilities** bien configuré
4. **GoogleService-Info.plist** présent dans le projet
5. **iOS 17+** sur l'iPhone 12 Pro

### Configuration device
```bash
# Dans Xcode
1. Connecter l'iPhone 12 Pro via USB
2. Sélectionner le device dans la barre d'outils
3. Product > Destination > Votre iPhone
4. Cmd+R pour Build & Run
```

### Tests spécifiques au device

#### 1. Haptic Feedback ⭐
- [ ] Ajouter une plaque → Vibration de succès
- [ ] Supprimer une plaque → Vibration de succès
- [ ] Échec d'ajout → Vibration d'erreur

#### 2. Notifications
- [ ] Ajouter première plaque
- [ ] Accepter les notifications
- [ ] Aller dans Settings > Notifications > TagYourCar
- [ ] Vérifier que les permissions sont activées

#### 3. Authentification sociale (device uniquement)

##### Apple Sign In
- [ ] Se connecter avec Apple ID
- [ ] Choisir "Partager mon email" ou "Masquer mon email"
- [ ] Vérifier que le compte est créé

##### Google Sign In
- [ ] Se connecter avec Google
- [ ] Autoriser l'app
- [ ] Vérifier la connexion

##### GitHub Sign In
- [ ] Se connecter avec GitHub
- [ ] Autoriser via Safari
- [ ] Vérifier la redirection vers l'app

#### 4. Performance
- [ ] Mesurer le temps de lancement
- [ ] Vérifier la fluidité du scroll
- [ ] Tester avec connexion lente (Settings > Developer > Network Link Conditioner)

#### 5. Rotation d'écran
- [ ] Tester en mode portrait
- [ ] Tester en mode paysage (si supporté)
- [ ] Vérifier que l'UI s'adapte

#### 6. Interruptions
- [ ] Recevoir un appel pendant l'utilisation
- [ ] Revenir à l'app → État préservé
- [ ] Mettre l'app en background pendant une connexion
- [ ] Revenir → Gérer la reconnexion

---

## 🐛 Checklist de débogage

Si quelque chose ne marche pas :

### Firebase ne se connecte pas
```
❌ Firebase non configure
```
**Solution** :
1. Vérifier que `GoogleService-Info.plist` est dans le projet
2. Vérifier qu'il est dans la target "TagYourCar"
3. Project Navigator > GoogleService-Info.plist > Target Membership ✅

### Authentification échoue
```
❌ Sign in failed: ...
```
**Solution** :
1. Vérifier la Console Firebase > Authentication
2. Vérifier que les méthodes sont activées (Email, Apple, Google, GitHub)
3. Pour Apple : Vérifier les Signing & Capabilities > Sign in with Apple
4. Pour Google : Vérifier le CLIENT_ID dans `GoogleService-Info.plist`

### Plaques ne s'ajoutent pas
```
❌ Ajout de plaque impossible sans Firebase Functions
```
**Solution** :
1. Vérifier que les Cloud Functions sont déployées
2. Tester avec `curl` ou Postman
3. Vérifier les logs Firebase Functions

### Haptic feedback ne marche pas
**Solution** :
- Le haptic ne fonctionne PAS sur simulateur
- Tester obligatoirement sur device réel

---

## 📊 Métriques de succès

### Performance
- [ ] Lancement < 2 secondes
- [ ] Connexion < 1 seconde (réseau normal)
- [ ] Chargement des plaques < 500ms

### Stabilité
- [ ] Pas de crash pendant 30 min d'utilisation
- [ ] Pas de memory leak (Instruments > Leaks)
- [ ] Pas de freeze UI

### UX
- [ ] Tous les boutons réagissent au tap
- [ ] Tous les messages d'erreur sont clairs
- [ ] Navigation fluide entre les écrans

---

## 🚀 Prochaines étapes (après validation)

1. **Tests automatisés** : Ajouter UI Tests avec XCTest
2. **Analytics** : Intégrer Firebase Analytics
3. **Crashlytics** : Intégrer Firebase Crashlytics
4. **TestFlight** : Déployer en beta pour tests externes
5. **App Store** : Préparer la soumission

---

## 📝 Notes importantes

### Limites connues
- Plaques limitées à 5 par utilisateur (business logic)
- Pas de pagination sur la liste (max 10 de Firestore, business = 5)
- Haptic feedback uniquement sur device

### À tester en conditions réelles
- Connexion 4G lente
- Mode avion → Mode online
- Notifications push (nécessite APNs configuré)
- Plusieurs utilisateurs en simultané

---

## ✅ Validation finale

Avant de considérer l'app prête :

- [ ] Tous les tests simulateur passent
- [ ] Tous les tests device passent
- [ ] Accessibilité validée
- [ ] Performance acceptable
- [ ] Aucun crash critique
- [ ] Firebase correctement configuré
- [ ] Tous les providers d'auth fonctionnent

---

**Bonne chance pour vos tests ! 🎉**

Si vous rencontrez des problèmes, vérifiez d'abord les logs dans Xcode Console (Cmd+Shift+Y).

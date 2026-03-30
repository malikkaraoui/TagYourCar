# Story 1.2: Inscription & Connexion Email + CGU

Status: review

## Story

En tant qu'utilisateur,
Je veux creer un compte par email et me connecter,
Afin d'avoir un compte securise pour utiliser TagYourCar.

## Acceptance Criteria

1. **Etant donne** que l'utilisateur n'a pas de compte **Quand** il ouvre l'app pour la premiere fois **Alors** l'ecran de login s'affiche avec les options d'authentification et il peut s'inscrire par email avec mot de passe
2. **Etant donne** l'inscription par email **Quand** l'utilisateur remplit ses informations **Alors** il doit accepter les CGU et la politique de confidentialite avant de finaliser (FR24) et un document user est cree dans Firestore (uid, email, displayName, createdAt)
3. **Etant donne** un compte existant **Quand** l'utilisateur saisit son email et mot de passe **Alors** il est connecte et redirige vers l'ecran d'accueil (FR2)
4. **Etant donne** que l'utilisateur saisit un email invalide ou un mot de passe trop court **Quand** il tente de s'inscrire ou de se connecter **Alors** un message d'erreur explicite s'affiche sous le champ concerne et le bouton de validation reste desactive tant que le format est invalide
5. **Etant donne** que l'utilisateur saisit un mot de passe incorrect **Quand** il tente de se connecter **Alors** un message d'erreur s'affiche : "Email ou mot de passe incorrect" sans indication sur lequel des deux est faux
6. **Etant donne** une erreur reseau **Quand** la requete Firebase echoue **Alors** un banner non-bloquant s'affiche avec un message humain
7. **Etant donne** que l'utilisateur est connecte **Quand** il choisit de se deconnecter **Alors** sa session est fermee et il revient a l'ecran de login (FR3)

## Tasks / Subtasks

- [ ] Task 1 : AuthService — wrapper Firebase Auth (AC: #1, #2, #3, #7)
  - [ ] Creer AuthService.swift dans Services/
  - [ ] Methodes : signUp(email, password, displayName), signIn(email, password), signOut()
  - [ ] Gestion du currentUser via @Published
  - [ ] Creation document Firestore users a l'inscription (uid, email, displayName, createdAt)
  - [ ] Listener onAuthStateChanged pour persistence de session

- [ ] Task 2 : AuthViewModel (AC: #1, #4, #5, #6)
  - [ ] Creer AuthViewModel.swift dans ViewModels/
  - [ ] @MainActor, ViewState, validation email/password en live
  - [ ] Gestion des erreurs Firebase → messages humains en francais
  - [ ] Erreur login : "Email ou mot de passe incorrect" (pas de distinction)

- [ ] Task 3 : LoginView — ecran de connexion (AC: #1, #3, #4, #5)
  - [ ] Creer LoginView.swift dans Views/Auth/
  - [ ] Champs email + mot de passe avec validation live
  - [ ] Bouton connexion desactive si format invalide
  - [ ] Lien "Pas encore de compte ? S'inscrire"
  - [ ] Messages d'erreur sous les champs

- [ ] Task 4 : SignUpView — ecran d'inscription + CGU (AC: #1, #2, #4)
  - [ ] Creer SignUpView.swift dans Views/Auth/
  - [ ] Champs : prenom, nom, email, mot de passe
  - [ ] Checkbox CGU obligatoire avec liens vers CGU et politique de confidentialite (FR24)
  - [ ] Bouton inscription desactive tant que CGU non acceptees ou format invalide

- [ ] Task 5 : ContentView — auth guard navigation (AC: #1, #3, #7)
  - [ ] Modifier ContentView pour router vers LoginView ou ecran principal selon l'etat auth
  - [ ] Injection AuthService via @EnvironmentObject

- [ ] Task 6 : Tests unitaires (AC: tous)
  - [ ] Tests AuthViewModel : validation email, validation password, etats erreur
  - [ ] Verifier que les messages d'erreur sont en francais et humains

## Dev Notes

### Architecture
- AuthService : @Published currentUser, async/await, os.Logger
- AuthViewModel : @MainActor, ViewState enum, pas de booleens isLoading
- Views pures : zero logique metier dans les Views
- Navigation : NavigationStack depuis ContentView
- Firestore users collection : uid, email, displayName, createdAt (champs definis dans architecture.md)

### Regles
- Pas de print() → os.Logger
- Erreurs typees TagYourCarError
- @EnvironmentObject pour DI des Services
- Codable models avec @DocumentID

### Design tokens a utiliser
- Theme.Colors.accentPrimary pour boutons primaires
- Theme.Colors.bgPrimary pour fond
- Theme.Colors.error pour messages erreur
- Theme.Typography.body pour champs
- Theme.Spacing.md pour padding standard
- Theme.Radius.md pour coins boutons

### Story 1.1 learnings
- Firebase init conditionnelle (check plist avant configure)
- nonisolated(unsafe) pour Regex static en strict concurrency
- XcodeGen pour generer le projet

## Dev Agent Record

### Agent Model Used
### Debug Log References
### Completion Notes List
### File List

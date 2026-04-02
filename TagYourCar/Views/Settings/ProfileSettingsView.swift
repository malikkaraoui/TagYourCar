import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSaving = false
    @State private var showSaveConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                profileSection
                legalSection
                appInfoSection
                actionsSection
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
        }
        .background(Theme.Colors.bgPrimary.ignoresSafeArea())
        .navigationTitle("Profil & Paramètres")
        .onAppear {
            loadCurrentProfile()
        }
        .alert("Modifications enregistrées", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
        .alert("Supprimer votre compte ?", isPresented: $showDeleteConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("Cette action est irréversible. Toutes vos données seront supprimées définitivement (plaques, signalements, profil).")
        }
    }

    // MARK: - Profil

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("PROFIL")
                .font(Theme.Typography.captionSmall)
                .foregroundStyle(Theme.Colors.textSecondary)
                .padding(.leading, Theme.Spacing.xs)

            VStack(spacing: 0) {
                // Prenom
                settingsTextField(placeholder: "Prénom", text: $firstName)

                settingsDivider

                // Nom
                settingsTextField(placeholder: "Nom", text: $lastName)

                // Email (lecture seule)
                if let email = authService.currentUser?.email, !email.isEmpty {
                    settingsDivider

                    HStack {
                        Text("Email")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Spacer()
                        Text(email)
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.textPlaceholder)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.md)
                }

                settingsDivider

                // Bouton enregistrer
                Button {
                    Task { await saveProfile() }
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text("Enregistrer les modifications")
                            .font(Theme.Typography.bodyMedium)
                            .foregroundStyle(canSave && !isSaving ? Theme.Colors.accentInteractive : Theme.Colors.textPlaceholder)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                }
                .disabled(!canSave || isSaving)
            }
            .background(Theme.Colors.bgCard)
            .cornerRadius(Theme.Radius.lg)
            .cardShadow()
        }
    }

    // MARK: - Informations legales

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("INFORMATIONS LÉGALES")
                .font(Theme.Typography.captionSmall)
                .foregroundStyle(Theme.Colors.textSecondary)
                .padding(.leading, Theme.Spacing.xs)

            VStack(spacing: 0) {
                settingsLink(
                    title: "Politique de confidentialité",
                    url: "https://tagyourcar.com/confidentialite",
                    isExternal: true
                )

                settingsDivider

                settingsLink(
                    title: "Conditions générales d'utilisation",
                    url: "https://tagyourcar.com/cgu",
                    isExternal: true
                )

                settingsDivider

                settingsLink(
                    title: "Site web TagYourCar",
                    url: "https://tagyourcar.com",
                    isExternal: true
                )
            }
            .background(Theme.Colors.bgCard)
            .cornerRadius(Theme.Radius.lg)
            .cardShadow()
        }
    }

    // MARK: - Info app

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("APPLICATION")
                .font(Theme.Typography.captionSmall)
                .foregroundStyle(Theme.Colors.textSecondary)
                .padding(.leading, Theme.Spacing.xs)

            HStack {
                Text("Version")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Text(appVersion)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.bgCard)
            .cornerRadius(Theme.Radius.lg)
            .cardShadow()
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Deconnexion
            Button {
                try? authService.signOut()
            } label: {
                Text("Se déconnecter")
                    .font(Theme.Typography.bodyMedium)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Theme.Colors.error)
                    .background(Theme.Colors.bgCard)
                    .cornerRadius(Theme.Radius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.lg)
                            .stroke(Theme.Colors.error.opacity(0.3), lineWidth: 1)
                    )
            }
            .cardShadow()

            // Suppression
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text("Supprimer mon compte")
                        .font(Theme.Typography.bodyMedium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(Theme.Colors.textOnAccent)
                .background(Theme.Colors.error)
                .cornerRadius(Theme.Radius.lg)
            }
            .disabled(isDeleting)
            .accessibilityLabel("Supprimer définitivement votre compte")
            .accessibilityHint("Cette action est irréversible")

            if let deleteError {
                Text(deleteError)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.error)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Composants reutilisables

    private var settingsDivider: some View {
        Divider()
            .overlay(Theme.Colors.bgSeparator)
    }

    private func settingsTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(Theme.Typography.body)
            .foregroundStyle(Theme.Colors.textPrimary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
            .textContentType(placeholder == "Prénom" ? .givenName : .familyName)
    }

    private func settingsLink(title: String, url: String, isExternal: Bool) -> some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Image(systemName: isExternal ? "arrow.up.right" : "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.Colors.textPlaceholder)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
        }
    }

    // MARK: - Helpers

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        hasChanges
    }

    private var hasChanges: Bool {
        let currentName = authService.currentUser?.displayName ?? ""
        let newName = "\(firstName) \(lastName)"
        return newName != currentName
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func loadCurrentProfile() {
        guard let displayName = authService.currentUser?.displayName else { return }
        let parts = displayName.split(separator: " ", maxSplits: 1)
        firstName = parts.first.map(String.init) ?? ""
        lastName = parts.count > 1 ? String(parts[1]) : ""
    }

    private func deleteAccount() async {
        isDeleting = true
        deleteError = nil
        do {
            try await authService.deleteAccount()
        } catch {
            deleteError = "La suppression est en cours de traitement. Vos données seront supprimées sous peu."
        }
        isDeleting = false
    }

    private func saveProfile() async {
        isSaving = true
        do {
            try await authService.updateProfile(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces)
            )
            showSaveConfirmation = true
        } catch {
            // Erreur geree silencieusement
        }
        isSaving = false
    }
}

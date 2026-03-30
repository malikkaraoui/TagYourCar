import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSaving = false
    @State private var showSaveConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            // Profile Section
            Section("Profil") {
                TextField("Prenom", text: $firstName)
                    .textContentType(.givenName)

                TextField("Nom", text: $lastName)
                    .textContentType(.familyName)

                if let email = authService.currentUser?.email, !email.isEmpty {
                    HStack {
                        Text("Email")
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Spacer()
                        Text(email)
                            .foregroundStyle(Theme.Colors.textPlaceholder)
                    }
                }

                Button {
                    Task { await saveProfile() }
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text("Enregistrer les modifications")
                    }
                }
                .disabled(!canSave || isSaving)
            }

            // Settings Section
            Section("Informations legales") {
                Link(destination: URL(string: "https://tagyourcar.com/confidentialite")!) {
                    HStack {
                        Text("Politique de confidentialite")
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Theme.Colors.textPlaceholder)
                    }
                }

                Link(destination: URL(string: "https://tagyourcar.com/cgu")!) {
                    HStack {
                        Text("Conditions generales d'utilisation")
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Theme.Colors.textPlaceholder)
                    }
                }

                Link(destination: URL(string: "https://tagyourcar.com")!) {
                    HStack {
                        Text("Site web TagYourCar")
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(Theme.Colors.textPlaceholder)
                    }
                }
            }

            Section("Application") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }

            // Actions Section
            Section {
                Button("Se deconnecter") {
                    try? authService.signOut()
                }
                .foregroundStyle(Theme.Colors.error)
            }
        }
        .navigationTitle("Profil & Parametres")
        .onAppear {
            loadCurrentProfile()
        }
        .alert("Modifications enregistrees", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
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

    private func saveProfile() async {
        isSaving = true
        do {
            try await authService.updateProfile(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces)
            )
            showSaveConfirmation = true
        } catch {
            // Error handled silently — could add error display
        }
        isSaving = false
    }
}

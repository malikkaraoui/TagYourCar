import SwiftUI

struct PlateListView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: PlateViewModel
    @State private var plateToDelete: Plate?
    @State private var showDeleteConfirmation = false

    init(plateService: PlateService) {
        _viewModel = StateObject(wrappedValue: PlateViewModel(plateService: plateService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.plates.isEmpty && viewModel.state == .loaded {
                    emptyState
                } else if viewModel.state == .loading && viewModel.plates.isEmpty {
                    VStack(spacing: Theme.Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Chargement de vos plaques...")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                } else {
                    plateList
                }
            }
            .navigationTitle("Mes plaques")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ProfileSettingsView()
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundStyle(Theme.Colors.accentInteractive)
                    }
                    .accessibilityLabel("Profil et paramètres")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.hasReachedLimit {
                        Button {
                            viewModel.showAddPlate = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(Theme.Colors.accentInteractive)
                        }
                        .accessibilityLabel("Ajouter une plaque")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddPlate) {
                AddPlateView(viewModel: viewModel, uid: authService.currentUser?.uid ?? "")
            }
            .task {
                if let uid = authService.currentUser?.uid {
                    await viewModel.loadPlates(for: uid)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "car.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.accentMuted)

            Text("Aucune plaque enregistree")
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Colors.textPrimary)

            Text("Ajoutez votre premiere plaque pour recevoir des notifications quand quelqu'un signale un probleme sur votre vehicule.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            Button {
                viewModel.showAddPlate = true
            } label: {
                Text("Ajouter votre premiere plaque")
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.accentInteractive)
                    .foregroundStyle(Theme.Colors.textOnAccent)
                    .cornerRadius(Theme.Radius.md)
            }
            .padding(.horizontal, Theme.Spacing.xl)
        }
    }

    private var plateList: some View {
        List {
            Section {
                ForEach(viewModel.plates) { plate in
                    PlateCard(plate: plate)
                        .listRowInsets(EdgeInsets(top: Theme.Spacing.xs, leading: Theme.Spacing.md, bottom: Theme.Spacing.xs, trailing: Theme.Spacing.md))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                plateToDelete = plate
                                showDeleteConfirmation = true
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                }
            } footer: {
                Text("\(viewModel.plates.count)/\(PlateViewModel.maxPlates) plaques")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .listStyle(.plain)
        .alert("Supprimer cette plaque ?", isPresented: $showDeleteConfirmation) {
            Button("Annuler", role: .cancel) {
                plateToDelete = nil
            }
            Button("Supprimer", role: .destructive) {
                if let plate = plateToDelete, let uid = authService.currentUser?.uid {
                    Task {
                        await viewModel.deletePlate(plate.id, for: uid)
                        plateToDelete = nil
                    }
                }
            }
        } message: {
            Text("Cette action est irreversible. Vous ne recevrez plus de notifications pour ce vehicule.")
        }
    }
}

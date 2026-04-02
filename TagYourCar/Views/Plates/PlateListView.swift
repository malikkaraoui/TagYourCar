import SwiftUI

struct PlateListView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: PlateViewModel
    @State private var plateToDelete: Plate?
    @State private var showDeleteConfirmation = false
    let isTabActive: Bool

    init(plateService: PlateService, isTabActive: Bool) {
        self.isTabActive = isTabActive
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
            .task(id: isTabActive) {
                guard isTabActive,
                      !viewModel.hasLoadedInitialPlates,
                      let uid = authService.currentUser?.uid else { return }

                await viewModel.loadPlates(for: uid)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "car.fill")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(Theme.Colors.accentInteractive)
                .frame(width: 96, height: 96)
                .background(Theme.Colors.accentInteractive.opacity(0.1))
                .clipShape(Circle())

            VStack(spacing: Theme.Spacing.sm) {
                Text("Aucune plaque enregistrée")
                    .font(Theme.Typography.h2)
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("Ajoutez votre première plaque pour recevoir des notifications quand quelqu'un signale un problème sur votre véhicule.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.Spacing.xl)

            Button {
                viewModel.showAddPlate = true
            } label: {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Ajouter une plaque")
                        .font(Theme.Typography.bodyMedium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Theme.Colors.accentInteractive)
                .foregroundStyle(Theme.Colors.textOnAccent)
                .cornerRadius(Theme.Radius.lg)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .accentGlow()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.bgPrimary)
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
                            .tint(Theme.Colors.error)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                guard let uid = authService.currentUser?.uid else { return }
                                Task {
                                    await viewModel.toggleFavorite(plate.id, for: uid)
                                }
                            } label: {
                                Label(
                                    plate.isFavorite ? "Retirer" : "Favoris",
                                    systemImage: plate.isFavorite ? "star.slash.fill" : "star.fill"
                                )
                            }
                            .tint(Theme.Colors.accentInteractive)
                        }
                }
            } footer: {
                Text("\(viewModel.plates.count)/\(PlateViewModel.maxPlates) plaques")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.bgPrimary)
        .refreshable {
            if let uid = authService.currentUser?.uid {
                await viewModel.loadPlates(for: uid)
            }
        }
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
            Text("Cette action est irréversible. Vous ne recevrez plus de notifications pour ce véhicule.")
        }
    }
}

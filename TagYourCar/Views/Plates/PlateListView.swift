import SwiftUI

struct PlateListView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: PlateViewModel

    init(plateService: PlateService) {
        _viewModel = StateObject(wrappedValue: PlateViewModel(plateService: plateService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.plates.isEmpty && viewModel.state == .loaded {
                    emptyState
                } else if viewModel.state == .loading && viewModel.plates.isEmpty {
                    ProgressView()
                } else {
                    plateList
                }
            }
            .navigationTitle("Mes plaques")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.hasReachedLimit {
                        Button {
                            viewModel.showAddPlate = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(Theme.Colors.accentInteractive)
                        }
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
                }
            } footer: {
                Text("\(viewModel.plates.count)/\(PlateViewModel.maxPlates) plaques")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .listStyle(.plain)
    }
}

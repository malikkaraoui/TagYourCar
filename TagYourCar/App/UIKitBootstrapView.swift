import SwiftUI
import UIKit

struct UIKitBootstrapView: UIViewControllerRepresentable {
    let notificationHandler: NotificationHandler

    func makeUIViewController(context: Context) -> UIKitBootstrapViewController {
        UIKitBootstrapViewController(notificationHandler: notificationHandler)
    }

    func updateUIViewController(_ uiViewController: UIKitBootstrapViewController, context: Context) {
        uiViewController.update(notificationHandler: notificationHandler)
    }
}

@MainActor
final class UIKitBootstrapViewController: UIViewController {
    private let minimumBrandingDuration: TimeInterval = 2.0
    private var bootstrapTask: Task<Void, Never>?
    private var hasStartedBootstrap = false
    private var authService: AuthService?
    private var notificationHandler: NotificationHandler
    private var hostedContentController: UIViewController?

    private let brandingContainer = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(notificationHandler: NotificationHandler) {
        self.notificationHandler = notificationHandler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        bootstrapTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBootstrapView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasStartedBootstrap else { return }
        hasStartedBootstrap = true

        bootstrapTask = Task { [weak self] in
            await self?.bootstrapIfNeeded()
        }
    }

    func update(notificationHandler: NotificationHandler) {
        self.notificationHandler = notificationHandler
    }

    private func configureBootstrapView() {
        view.backgroundColor = UIColor(named: "BgPrimary") ?? UIColor.systemBackground

        brandingContainer.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "TagYourCar"
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor(named: "TextPrimary") ?? UIColor.label

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Signalez. Protégez. Communauté."
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor(named: "TextSecondary") ?? UIColor.secondaryLabel
        subtitleLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16

        brandingContainer.addSubview(stack)
        view.addSubview(brandingContainer)

        NSLayoutConstraint.activate([
            brandingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            brandingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            brandingContainer.topAnchor.constraint(equalTo: view.topAnchor),
            brandingContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.centerXAnchor.constraint(equalTo: brandingContainer.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: brandingContainer.centerYAnchor, constant: -34),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: brandingContainer.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: brandingContainer.trailingAnchor, constant: -24)
        ])
    }

    private func bootstrapIfNeeded() async {
        let bootstrapStartedAt = Date()

        await Task.yield()

        FirebaseBootstrap.configureIfNeeded()

        let service = AuthService()
        service.activateIfNeeded()
        authService = service

        let elapsed = Date().timeIntervalSince(bootstrapStartedAt)
        let remaining = max(0, minimumBrandingDuration - elapsed)
        if remaining > 0 {
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
        }

        guard !Task.isCancelled else { return }
        installSwiftUIRoot(using: service)
    }

    private func installSwiftUIRoot(using authService: AuthService) {
        guard hostedContentController == nil else { return }

        let rootView = ContentView(notificationHandler: notificationHandler)
            .environmentObject(authService)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        addChild(hostingController)
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.view.alpha = 0
        hostingController.didMove(toParent: self)
        hostedContentController = hostingController

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            hostingController.view.alpha = 1
            self.brandingContainer.alpha = 0
        } completion: { _ in
            self.brandingContainer.removeFromSuperview()
        }
    }
}
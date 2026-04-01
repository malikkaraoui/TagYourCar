import SwiftUI

enum Theme {

    // MARK: - Colors

    enum Colors {
        // Accent
        static let accentPrimary = Color("AccentPrimary")
        static let accentInteractive = Color("AccentInteractive")
        static let accentSubtle = Color("AccentSubtle")
        static let accentMuted = Color("AccentMuted")

        // Background
        static let bgPrimary = Color("BgPrimary")
        static let bgCard = Color("BgCard")
        static let bgSecondary = Color("BgSecondary")
        static let bgSeparator = Color("BgSeparator")

        // Semantic
        static let success = Color("SemanticSuccess")
        static let error = Color("SemanticError")
        static let warning = Color("SemanticWarning")

        // Text
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let textOnAccent = Color("TextOnAccent")
        static let textPlaceholder = Color("TextPlaceholder")
    }

    // MARK: - Typography (SF Pro — tight tracking pour les titres, aere pour le body)

    enum Typography {
        static let display = Font.system(size: 34, weight: .black, design: .rounded)
        static let h1 = Font.system(size: 28, weight: .bold)
        static let h2 = Font.system(size: 22, weight: .bold)
        static let h3 = Font.system(size: 20, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let bodyMedium = Font.system(size: 17, weight: .medium)
        static let bodySmall = Font.system(size: 15, weight: .regular)
        static let caption = Font.system(size: 13, weight: .medium)
        static let captionSmall = Font.system(size: 11, weight: .semibold)
        static let plate = Font.system(size: 28, weight: .bold, design: .monospaced)
    }

    // MARK: - Spacing (8pt grid)

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows (teintees slate pour la profondeur)

    enum Shadows {
        static func card() -> some View {
            Color.clear
                .shadow(color: Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.06), radius: 8, x: 0, y: 4)
        }

        static func modal() -> some View {
            Color.clear
                .shadow(color: Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.15), radius: 16, x: 0, y: 8)
        }
    }

    // MARK: - Animation

    enum Animation {
        static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.25)
    }
}

// MARK: - View Modifiers

extension View {
    func cardShadow() -> some View {
        self
            .shadow(color: Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.04), radius: 2, x: 0, y: 1)
            .shadow(color: Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.06), radius: 8, x: 0, y: 4)
    }

    func modalShadow() -> some View {
        self
            .shadow(color: Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.08), radius: 4, x: 0, y: 2)
            .shadow(color: Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.15), radius: 16, x: 0, y: 8)
    }

    func accentGlow() -> some View {
        self.shadow(color: Color("AccentInteractive").opacity(0.3), radius: 12, x: 0, y: 4)
    }
}

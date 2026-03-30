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

    // MARK: - Typography

    enum Typography {
        static let display = Font.system(size: 34, weight: .bold)
        static let h1 = Font.system(size: 28, weight: .semibold)
        static let h2 = Font.system(size: 22, weight: .semibold)
        static let h3 = Font.system(size: 20, weight: .medium)
        static let body = Font.system(size: 17, weight: .regular)
        static let bodySmall = Font.system(size: 15, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
        static let plate = Font.system(size: 24, weight: .medium, design: .monospaced)
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

    // MARK: - Shadows

    enum Shadows {
        static func card() -> some View {
            Color.clear
                .shadow(color: Color(red: 45/255, green: 27/255, blue: 78/255).opacity(0.08), radius: 4, x: 0, y: 2)
        }

        static func modal() -> some View {
            Color.clear
                .shadow(color: Color(red: 45/255, green: 27/255, blue: 78/255).opacity(0.12), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - View Modifiers

extension View {
    func cardShadow() -> some View {
        self.shadow(color: Color(red: 45/255, green: 27/255, blue: 78/255).opacity(0.08), radius: 4, x: 0, y: 2)
    }

    func modalShadow() -> some View {
        self.shadow(color: Color(red: 45/255, green: 27/255, blue: 78/255).opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

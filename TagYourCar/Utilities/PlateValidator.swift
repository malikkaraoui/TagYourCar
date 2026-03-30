import Foundation

enum PlateValidator {
    private static nonisolated(unsafe) let plateRegex = /^[A-Z]{2}-[0-9]{3}-[A-Z]{2}$/

    static func isValid(_ plate: String) -> Bool {
        plate.wholeMatch(of: plateRegex) != nil
    }

    static func format(_ input: String) -> String {
        let cleaned = input.uppercased().filter { $0.isLetter || $0.isNumber }
        var result = ""
        for (index, char) in cleaned.enumerated() {
            if index == 2 || index == 5 {
                result += "-"
            }
            result += String(char)
        }
        return String(result.prefix(9))
    }
}

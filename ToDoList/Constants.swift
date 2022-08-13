import UIKit

struct Constants {

    struct Colors {
        
        struct Support {
            static let separator = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            static let overlay = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.06)
            static let navBarBlur = UIColor.init(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)
        }
        
        struct Label {
            static let primary = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            static let secondary = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
            static let tertiary = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            static let disable = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15)
        }
        
        struct Color {
            static let red = UIColor.init(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
            static let green = UIColor.init(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
            static let blue = UIColor.init(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
            static let gray = UIColor.init(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
            static let lightGray = UIColor.init(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.0)
            static let white = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        struct Back {
            static let iOSPrimary = UIColor.init(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
            static let primary = UIColor.init(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
            static let secondaryElevated = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    struct Fonts {
        static let largeTitle = UIFont.systemFont(ofSize: 38, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17)
        static let subhead = UIFont.systemFont(ofSize: 15)
        static let footnote = UIFont.systemFont(ofSize: 13)
    }
    
    struct Images {
        static let exclamationmark = UIImage(systemName: "exclamationmark.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?.withTintColor(.red, renderingMode: .alwaysOriginal)
        static let calendar = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?.withTintColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), renderingMode: .alwaysOriginal)
        static let circleGray = UIImage(systemName: "circle")?.withTintColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), renderingMode: .alwaysOriginal)
        static let circleGreen = UIImage(systemName: "checkmark.circle.green")?.withTintColor(UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0), renderingMode: .alwaysOriginal)
        static let circleRed = UIImage(systemName: "circle")?.withTintColor(UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0), renderingMode: .alwaysOriginal)
        static let chevron = UIImage(systemName: "chevron.right")?.withTintColor(Constants.Colors.Color.gray)
        static let info = UIImage(systemName: "info.circle.fill")?.withTintColor(Constants.Colors.Color.white)
        static let arrowDown = UIImage(systemName: "arrow.down")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        static let plusCircleFill = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44, weight: .bold))?.withTintColor(Constants.Colors.Color.blue)
    }

}

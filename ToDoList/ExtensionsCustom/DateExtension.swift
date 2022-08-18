import Foundation

extension Date {
    func inString(withYear: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM\(withYear ? " yyyy" : "")"
        let text = dateFormatter.string(from: self)
        return text
    }
}

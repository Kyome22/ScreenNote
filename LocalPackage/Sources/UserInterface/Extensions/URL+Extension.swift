import Foundation

extension URL {
    static var localizedPrivacyPolicy: URL {
        URL.privacyPolicy.appending(queryItems: [
            URLQueryItem(name: "lang", value: String(localized: "lang", bundle: .module)),
        ])
    }
}

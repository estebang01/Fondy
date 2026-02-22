import Foundation

/// Centralizes construction of Logo.dev URLs and key handling.
///
/// Configure keys via Info.plist entries:
/// - LogoDevPublicKey (String)
/// - LogoDevPrivateKey (String) [optional if not required]
///
/// Or set environment variables for previews/tests:
/// - LOGODEV_PUBLIC_KEY
/// - LOGODEV_PRIVATE_KEY
enum LogoDev {
    /// Base host for the image service. You can change to enterprise host if needed.
    private static let base = URL(string: "https://img.logo.dev")!

    /// Returns the configured public key from Info.plist or environment.
    static var publicKey: String? {
        if let key = ProcessInfo.processInfo.environment["LOGODEV_PUBLIC_KEY"], !key.isEmpty {
            return key
        }
        if let key = Bundle.main.object(forInfoDictionaryKey: "LogoDevPublicKey") as? String, !key.isEmpty {
            return key
        }
        return nil
    }

    /// Returns the configured private key from Info.plist or environment (if used).
    static var privateKey: String? {
        if let key = ProcessInfo.processInfo.environment["LOGODEV_PRIVATE_KEY"], !key.isEmpty {
            return key
        }
        if let key = Bundle.main.object(forInfoDictionaryKey: "LogoDevPrivateKey") as? String, !key.isEmpty {
            return key
        }
        return nil
    }

    /// Builds a Logo.dev URL with an optional size parameter and attaches the public key if available.
    /// Example: https://img.logo.dev/apple.com?size=64&api_key=PUBLIC_KEY
    static func url(for domain: String, size: Int? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = LogoDev.base.scheme
        components.host = LogoDev.base.host
        components.path = "/\(domain)"

        var queryItems: [URLQueryItem] = []
        if let size, size > 0 {
            queryItems.append(URLQueryItem(name: "size", value: String(size)))
        }
        if let key = publicKey {
            queryItems.append(URLQueryItem(name: "api_key", value: key))
        }
        // If your plan requires signing requests with a private key, you could add a signature item here.
        // For most image endpoints, the public key alone is sufficient.

        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }
}

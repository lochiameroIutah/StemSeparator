import Foundation

enum LicenseManager {
    private static let productID = "P1qGA4tbPFt_k9zxW5YGvg=="

    private static let udKey = "activatedLicenseKey"

    static var isActivated: Bool { storedKey != nil }

    static var storedKey: String? {
        UserDefaults.standard.string(forKey: udKey)
    }

    /// Valida la chiave con le API Gumroad. Ritorna true se valida.
    static func activate(key: String) async throws -> Bool {
        guard let url = URL(string: "https://api.gumroad.com/v2/licenses/verify") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Encoding corretto per form-urlencoded: codifica = + / ecc.
        let formChars = CharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        let encodedKey = key.trimmingCharacters(in: .whitespaces)
            .addingPercentEncoding(withAllowedCharacters: formChars) ?? key

        let encodedID = productID.addingPercentEncoding(withAllowedCharacters: formChars) ?? productID
        let body = "product_id=\(encodedID)&license_key=\(encodedKey)&increment_uses_count=false"
        request.httpBody = body.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)

        // Debug: stampa risposta raw in console
        if let raw = String(data: data, encoding: .utf8) {
            print("[LicenseManager] API response: \(raw)")
        }

        let response = try JSONDecoder().decode(GumroadResponse.self, from: data)

        if response.success {
            UserDefaults.standard.set(key.trimmingCharacters(in: .whitespaces), forKey: udKey)
        }
        return response.success
    }

    static func deactivate() {
        UserDefaults.standard.removeObject(forKey: udKey)
    }
}

private struct GumroadResponse: Decodable {
    let success: Bool
    let message: String?
}

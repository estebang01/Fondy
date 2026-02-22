import SwiftUI

/// Renders a company logo using Logo.dev when a domain is provided,
/// otherwise falls back to an SF Symbol inside a circular background.
struct CompanyLogoView: View {
    let domain: String?
    let systemName: String
    let symbolColor: Color
    let background: Color
    var size: CGFloat = Spacing.iconSize

    private var logoURL: URL? {
        guard let domain, !domain.isEmpty else { return nil }
        return URL(string: "https://img.logo.dev/\(domain)?size=64")
    }

    var body: some View {
        ZStack {
            if let url = logoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                            .background(background, in: Circle())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.62, height: size * 0.62)
                            .frame(width: size, height: size)
                            .background(background, in: Circle())
                    case .failure:
                        fallbackSymbol
                    @unknown default:
                        fallbackSymbol
                    }
                }
            } else {
                fallbackSymbol
            }
        }
        .accessibilityHidden(true)
    }

    private var fallbackSymbol: some View {
        Image(systemName: systemName)
            .font(.system(size: min(20, size * 0.38), weight: .medium))
            .foregroundStyle(symbolColor)
            .frame(width: size, height: size)
            .background(background, in: Circle())
    }
}

#Preview("CompanyLogoView") {
    VStack(spacing: 16) {
        CompanyLogoView(domain: "apple.com", systemName: "apple.logo", symbolColor: .white, background: .black, size: 56)
        CompanyLogoView(domain: nil, systemName: "bolt.car.fill", symbolColor: .white, background: .red, size: 56)
    }
    .padding()
}

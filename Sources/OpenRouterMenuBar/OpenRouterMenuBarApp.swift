import SwiftUI

@main
struct OpenRouterMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var credits = CreditsService()

    var body: some Scene {
        MenuBarExtra {
            ContentView(credits: credits)
        } label: {
            Image(nsImage: MenuBarIcon.image(balance: credits.remaining.map { String(format: "$%.2f", $0) }))
        }
        .menuBarExtraStyle(.window)
    }
}

enum MenuBarIcon {
    private static let iconSize = CGSize(width: 18, height: 18)

    private static let baseIcon: NSImage = {
        guard let url = Bundle.module.url(forResource: "MenuBarIcon", withExtension: "pdf"),
              let image = NSImage(contentsOf: url) else {
            return NSImage(systemSymbolName: "creditcard", accessibilityDescription: "OpenRouter credits")!
        }
        image.isTemplate = true
        image.accessibilityDescription = "OpenRouter credits"
        return image
    }()

    static func image(balance: String? = nil) -> NSImage {
        guard let balance else { return baseIcon }

        let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.labelColor]
        let attrStr = NSAttributedString(string: balance, attributes: attrs)
        let textSize = attrStr.size()

        let spacing: CGFloat = 3
        let totalWidth = iconSize.width + spacing + ceil(textSize.width)

        let combined = NSImage(size: CGSize(width: totalWidth, height: iconSize.height), flipped: false) { _ in
            MenuBarIcon.baseIcon.draw(in: CGRect(origin: .zero, size: MenuBarIcon.iconSize))
            attrStr.draw(at: CGPoint(x: MenuBarIcon.iconSize.width + spacing,
                                     y: (MenuBarIcon.iconSize.height - textSize.height) / 2 - 1))
            return true
        }
        combined.isTemplate = true
        combined.accessibilityDescription = "OpenRouter credits: \(balance)"
        return combined
    }
}

/// Hides the Dock icon so this behaves as a menu-bar-only utility even when
/// run as a plain SPM executable without LSUIElement in an Info.plist.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

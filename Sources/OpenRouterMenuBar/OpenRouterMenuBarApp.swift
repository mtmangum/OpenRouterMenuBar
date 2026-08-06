import SwiftUI
import AppKit

@main
struct OpenRouterMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var credits = CreditsService()

    var body: some Scene {
        MenuBarExtra {
            ContentView(credits: credits)
                .onAppear { credits.startPolling() }
        } label: {
            Image(nsImage: MenuBarIcon.image(balance: credits.remaining.map { String(format: "$%.2f", $0) }))
        }
        .menuBarExtraStyle(.window)
    }
}

/// Vector "OR" monogram used as the status bar glyph, rendered as a template
/// image so macOS auto-tints it for the light/dark menu bar.
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
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
        let attrStr = NSAttributedString(string: balance, attributes: attrs)
        let textSize = attrStr.size()

        let spacing: CGFloat = 3
        let totalWidth = iconSize.width + spacing + ceil(textSize.width)
        let height = iconSize.height

        let combined = NSImage(size: CGSize(width: totalWidth, height: height), flipped: false) { _ in
            MenuBarIcon.baseIcon.draw(in: CGRect(origin: .zero, size: MenuBarIcon.iconSize))
            attrStr.draw(at: CGPoint(x: MenuBarIcon.iconSize.width + spacing,
                                     y: (height - textSize.height) / 2 - 1))
            return true
        }
        combined.isTemplate = true
        combined.accessibilityDescription = "OpenRouter credits: \(balance)"
        return combined
    }
}

/// Hides the Dock icon / app switcher entry so this behaves like a proper
/// menu-bar-only utility, even when run as a plain SPM executable without
/// a bundled Info.plist (LSUIElement).
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

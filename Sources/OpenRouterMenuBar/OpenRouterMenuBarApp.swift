import SwiftUI
import AppKit

@main
struct OpenRouterMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var credits = CreditsService()

    var body: some Scene {
        MenuBarExtra {
            ContentView(credits: credits)
                .onAppear {
                    credits.startPolling()
                }
        } label: {
            Image(nsImage: MenuBarIcon.image)
        }
        .menuBarExtraStyle(.window)
    }
}

/// Vector "OR" monogram used as the status bar glyph, rendered as a template
/// image so macOS auto-tints it for the light/dark menu bar.
enum MenuBarIcon {
    static let image: NSImage = {
        guard let url = Bundle.module.url(forResource: "MenuBarIcon", withExtension: "pdf"),
              let image = NSImage(contentsOf: url) else {
            return NSImage(systemSymbolName: "creditcard", accessibilityDescription: "OpenRouter credits")!
        }
        image.isTemplate = true
        image.accessibilityDescription = "OpenRouter credits"
        return image
    }()
}

/// Hides the Dock icon / app switcher entry so this behaves like a proper
/// menu-bar-only utility, even when run as a plain SPM executable without
/// a bundled Info.plist (LSUIElement).
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

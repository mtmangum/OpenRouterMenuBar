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
            Image(systemName: "creditcard")
        }
        .menuBarExtraStyle(.window)
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

import Foundation
import ServiceManagement

/// Wraps SMAppService registration of the main app as a login item.
/// Only meaningful when running from the built .app bundle; under
/// `swift run` there is no bundle to register, so this reports unavailable.
@MainActor
enum LaunchAtLogin {
    static var isAvailable: Bool {
        Bundle.main.bundleIdentifier != nil
    }

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}

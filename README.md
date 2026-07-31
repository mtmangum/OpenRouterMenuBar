# OpenRouter Menu Bar

A tiny native macOS menu bar app that shows your OpenRouter credit balance and usage.

## What it does
- Adds a credit-card icon to your menu bar.
- Click it to see remaining balance, total used, and total credits.
- Polls `https://openrouter.ai/api/v1/credits` every 5 minutes automatically, plus a manual refresh button.
- Stores your API key in the macOS Keychain (never written to disk in plaintext).

## Requirements
- macOS 13 (Ventura) or later.
- Xcode Command Line Tools (for the `swift` compiler). If you don't have them:
  ```
  xcode-select --install
  ```

## Quick test run (no bundling)
From inside the `OpenRouterMenuBar` folder:
```
swift run
```
This launches the app directly. You'll be prompted for your API key the first time
(find yours at https://openrouter.ai/settings/keys — use a key with the `credits` scope,
i.e. any standard API key works).

Note: run this way, macOS may briefly show a Dock icon before the app hides itself.
For a clean menu-bar-only experience, build the `.app` bundle instead (below).

## Building a proper .app
```
chmod +x build_app.sh
./build_app.sh
```
This produces `OpenRouterMenuBar.app` in the project folder. Drag it into
`/Applications`, then double-click to launch. Since it's not signed/notarized,
the first launch needs a right-click → Open (macOS Gatekeeper will otherwise block it).

To have it launch automatically at login: System Settings → General → Login Items →
add OpenRouterMenuBar.

## Changing the poll interval
In `Sources/OpenRouterMenuBar/OpenRouterMenuBarApp.swift`, the call
`credits.startPolling()` defaults to every 300 seconds. Pass a different
`interval:` value (in seconds) to change it.

## Files
- `KeychainHelper.swift` — secure storage for the API key.
- `CreditsService.swift` — fetches and decodes the OpenRouter credits endpoint.
- `ContentView.swift` — the dropdown UI (balance, usage bar, key entry).
- `OpenRouterMenuBarApp.swift` — app entry point (MenuBarExtra).
- `build_app.sh` — packages a release build into a distributable `.app`.
- `Resources/MenuBarIcon.pdf` — vector "OR" monogram shown in the menu bar.

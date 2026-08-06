# OpenRouter Menu Bar

A tiny native macOS menu bar app that shows your OpenRouter credit balance and usage.

## What it does
- Shows your remaining balance next to the "OR" icon in the menu bar.
- Click the icon to see remaining balance, total used, total credits, and a usage bar.
- Balance is color-coded in the popover: green (>$10), orange ($2–$10), red (<$2).
- Polls `https://openrouter.ai/api/v1/credits` every 30 seconds automatically, plus a manual refresh button.
- Stores your API key in the macOS Keychain (never written to disk in plaintext).
- Optionally launches at login via the in-app toggle.

## Requirements
- macOS 14 (Sonoma) or later.
- Xcode Command Line Tools (for the `swift` compiler). If you don't have them:
  ```
  xcode-select --install
  ```

## Build & install
```
chmod +x deploy.sh
./deploy.sh
```
This builds a release `.app`, installs it to `~/Applications`, ad-hoc signs it, and launches it. No admin password required.

On first run you'll be prompted for your OpenRouter API key — find yours at
https://openrouter.ai/settings/keys. When the macOS Keychain prompt appears,
click **Always Allow** so you aren't asked again on future launches.

## Updating
After making code changes, just run `./deploy.sh` again. It quits the running instance, rebuilds, reinstalls, and relaunches.

## Changing the poll interval
In `Sources/OpenRouterMenuBar/CreditsService.swift`, `startPolling()` defaults to every 30 seconds. Pass a different `interval:` value (in seconds) to change it.

## Files
- `KeychainHelper.swift` — secure storage for the API key.
- `CreditsService.swift` — fetches and decodes the OpenRouter credits endpoint.
- `ContentView.swift` — the popover UI (balance, usage bar, key entry).
- `OpenRouterMenuBarApp.swift` — app entry point and menu bar label rendering.
- `build_app.sh` — packages a release build into a distributable `.app`.
- `deploy.sh` — build + install + sign + launch in one step.
- `Resources/MenuBarIcon.pdf` — vector "OR" monogram shown in the menu bar.

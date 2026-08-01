# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [1.0.0] - 2026-08-01
### Added
- Small countdown ring next to the "Updated" timestamp showing time remaining until the next automatic poll.

### Changed
- Replaced the system "creditcard" SF Symbol with a custom "OR" monogram menu bar icon, bundled as a vector template image (`Resources/MenuBarIcon.pdf`) that auto-tints for light/dark menu bars.
- Default polling interval lowered from 5 minutes to 30 seconds.
- Manual refresh now also resets the polling timer/countdown, instead of just fetching once.
- Modernized `CreditsService` from Combine's `ObservableObject` to the `@Observable` macro; polling now runs on a single structured-concurrency task instead of a `Timer`.
- Minimum macOS version raised from 13 (Ventura) to 14 (Sonoma), required by `@Observable`.
- Currency values are formatted with `FormatStyle` instead of building a `NumberFormatter` on every render.
- Saving a new API key now resets the poll countdown in addition to fetching immediately.

### Fixed
- `build_app.sh` now copies the SwiftPM resource bundle into the `.app`; the bundled app previously crashed at launch when loading the menu bar icon.

## [0.1.0] - 2026-07-31
### Added
- Menu bar app showing OpenRouter credit balance and usage.
- Automatic polling of the OpenRouter credits API every 5 minutes, plus manual refresh.
- API key entry with secure storage in the macOS Keychain.
- `build_app.sh` script to package a distributable `.app` bundle.

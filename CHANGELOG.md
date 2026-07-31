# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]
### Changed
- Replaced the system "creditcard" SF Symbol with a custom "OR" monogram menu bar icon, bundled as a vector template image (`Resources/MenuBarIcon.pdf`) that auto-tints for light/dark menu bars.
- Default polling interval lowered from 5 minutes to 30 seconds.

## [0.1.0] - 2026-07-31
### Added
- Menu bar app showing OpenRouter credit balance and usage.
- Automatic polling of the OpenRouter credits API every 5 minutes, plus manual refresh.
- API key entry with secure storage in the macOS Keychain.
- `build_app.sh` script to package a distributable `.app` bundle.

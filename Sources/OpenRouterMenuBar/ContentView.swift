import SwiftUI

struct ContentView: View {
    var credits: CreditsService
    @State private var apiKeyInput: String = ""
    @State private var showingKeyEntry: Bool = KeychainHelper.load() == nil
    @State private var launchAtLogin: Bool = LaunchAtLogin.isEnabled

    private var trimmedKeyInput: String {
        apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showingKeyEntry {
                keyEntryView
            } else {
                balanceView
            }
        }
        .padding(16)
        .frame(width: 280)
    }

    private var balanceView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("OpenRouter")
                    .font(.headline)
                Spacer()
                Button {
                    credits.refreshNow()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .disabled(credits.isLoading)
            }

            Divider()

            if let remaining = credits.remaining {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatted(remaining))
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundStyle(remaining < 2 ? Color.red : remaining <= 10 ? Color.orange : Color.green)
                }

                if let total = credits.totalCredits, let used = credits.totalUsage {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Used: \(formatted(used))")
                            Spacer()
                            Text("Total: \(formatted(total))")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        ProgressView(value: total > 0 ? min(used / total, 1) : 0)
                    }
                }
            } else if credits.isLoading {
                ProgressView()
            } else if let error = credits.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let updated = credits.lastUpdated {
                HStack(spacing: 5) {
                    Text("Updated \(updated.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let nextPollDate = credits.nextPollDate {
                        PollCountdownRing(nextPollDate: nextPollDate, interval: credits.pollInterval)
                    }
                }
            }

            Divider()

            Toggle("Launch at login", isOn: $launchAtLogin)
                .toggleStyle(.checkbox)
                .font(.caption)
                .onChange(of: launchAtLogin) { _, enabled in
                    do {
                        try LaunchAtLogin.setEnabled(enabled)
                    } catch {
                        launchAtLogin = LaunchAtLogin.isEnabled
                    }
                }

            HStack {
                Button("Change API Key") {
                    apiKeyInput = ""
                    showingKeyEntry = true
                }
                .buttonStyle(.plain)
                .font(.caption)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
        }
    }

    private var keyEntryView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Enter your OpenRouter API key")
                .font(.headline)
            Text("Stored securely in the macOS Keychain. Find yours at openrouter.ai/settings/keys.")
                .font(.caption)
                .foregroundStyle(.secondary)

            SecureField("sk-or-...", text: $apiKeyInput)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("Save") {
                    let trimmed = trimmedKeyInput
                    guard !trimmed.isEmpty else { return }
                    KeychainHelper.save(apiKey: trimmed)
                    showingKeyEntry = false
                    credits.refreshNow()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(trimmedKeyInput.isEmpty)
            }
        }
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.currency(code: "USD"))
    }
}

/// A small ring that depletes clockwise as the next automatic poll approaches,
/// then resets to full once that poll fires.
private struct PollCountdownRing: View {
    let nextPollDate: Date
    let interval: TimeInterval

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let remaining = max(0, nextPollDate.timeIntervalSince(context.date))
            let fraction = interval > 0 ? remaining / interval : 0

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(Color.secondary, style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 9, height: 9)
                .accessibilityLabel("Next update in \(Int(remaining)) seconds")
        }
    }
}

import SwiftUI

struct ContentView: View {
    @ObservedObject var credits: CreditsService
    @State private var apiKeyInput: String = ""
    @State private var showingKeyEntry: Bool = KeychainHelper.load() == nil

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
                    Task { await credits.refresh() }
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
                Text("Updated \(updated.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

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
                    let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    KeychainHelper.save(apiKey: trimmed)
                    showingKeyEntry = false
                    Task { await credits.refresh() }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

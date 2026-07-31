import Foundation
import Combine

struct CreditsResponse: Decodable {
    struct Data: Decodable {
        let total_credits: Double
        let total_usage: Double
    }
    let data: Data
}

enum CreditsError: LocalizedError {
    case noAPIKey
    case badStatus(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .noAPIKey: return "No API key set"
        case .badStatus(let code): return "OpenRouter returned status \(code)"
        case .decoding: return "Couldn't parse OpenRouter's response"
        }
    }
}

@MainActor
final class CreditsService: ObservableObject {
    @Published var totalCredits: Double?
    @Published var totalUsage: Double?
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var timer: Timer?

    var remaining: Double? {
        guard let total = totalCredits, let used = totalUsage else { return nil }
        return total - used
    }

    /// Poll every 5 minutes by default. Change `interval` if you want tighter/looser polling.
    func startPolling(interval: TimeInterval = 300) {
        stopPolling()
        Task { await refresh() }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.refresh() }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() async {
        guard let apiKey = KeychainHelper.load(), !apiKey.isEmpty else {
            errorMessage = CreditsError.noAPIKey.localizedDescription
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            var request = URLRequest(url: URL(string: "https://openrouter.ai/api/v1/credits")!)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw CreditsError.badStatus(code)
            }

            let decoded = try JSONDecoder().decode(CreditsResponse.self, from: data)
            self.totalCredits = decoded.data.total_credits
            self.totalUsage = decoded.data.total_usage
            self.lastUpdated = Date()
            self.errorMessage = nil
        } catch let error as CreditsError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Network error: \(error.localizedDescription)"
        }
    }
}

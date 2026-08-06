import Foundation
import Observation

struct CreditsResponse: Decodable {
    struct Credits: Decodable {
        let totalCredits: Double
        let totalUsage: Double
    }
    let data: Credits
}

enum CreditsError: LocalizedError {
    case noAPIKey
    case badStatus(Int)

    var errorDescription: String? {
        switch self {
        case .noAPIKey: return "No API key set"
        case .badStatus(let code): return "OpenRouter returned status \(code)"
        }
    }
}

@MainActor
@Observable
final class CreditsService {
    private(set) var totalCredits: Double?
    private(set) var totalUsage: Double?
    private(set) var lastUpdated: Date?
    private(set) var errorMessage: String?
    private(set) var isLoading = false
    private(set) var pollInterval: TimeInterval = 30
    private(set) var nextPollDate: Date?

    private var pollTask: Task<Void, Never>?

    init() {
        startPolling()
    }

    var remaining: Double? {
        guard let total = totalCredits, let used = totalUsage else { return nil }
        return total - used
    }

    /// Poll every 30 seconds by default. Change `interval` if you want tighter/looser polling.
    func startPolling(interval: TimeInterval = 30) {
        stopPolling()
        pollInterval = interval
        pollTask = Task {
            while !Task.isCancelled {
                let nextPoll = Date().addingTimeInterval(interval)
                nextPollDate = nextPoll
                await refresh()
                try? await Task.sleep(for: .seconds(max(0, nextPoll.timeIntervalSinceNow)))
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }

    /// Fetches immediately and restarts the poll countdown.
    func refreshNow() {
        startPolling(interval: pollInterval)
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

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(CreditsResponse.self, from: data)
            totalCredits = decoded.data.totalCredits
            totalUsage = decoded.data.totalUsage
            lastUpdated = Date()
            errorMessage = nil
        } catch let error as CreditsError {
            errorMessage = error.localizedDescription
        } catch is DecodingError {
            errorMessage = "Couldn't parse OpenRouter's response"
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
    }
}

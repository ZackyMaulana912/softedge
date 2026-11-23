import Foundation

/// Ends a pause when its time comes. The continuous clock keeps counting
/// while the Mac sleeps, so a pause that ran out during sleep ends on wake.
@MainActor
final class PauseTimer {
    private let settings: AppSettings
    private var task: Task<Void, Never>?

    init(settings: AppSettings) {
        self.settings = settings
    }

    func start() {
        observeChanges { [weak self] in
            guard let self else { return }
            self.schedule(until: self.settings.pausedUntil)
        }
    }

    private func schedule(until date: Date?) {
        task?.cancel()
        guard let date else { return }
        task = Task { @MainActor [weak self] in
            let wait = max(0, date.timeIntervalSinceNow)
            try? await Task.sleep(for: .seconds(wait), clock: .continuous)
            guard !Task.isCancelled else { return }
            self?.settings.resume()
        }
    }
}

import Foundation

/// The pause lengths the settings offer, and how a pause end is shown.
enum PauseSchedule {
    static let morningHour = 6

    static func oneHour(from now: Date = .now) -> Date {
        now.addingTimeInterval(60 * 60)
    }

    /// The next 06:00, so a pause started late at night ends the next morning.
    static func nextMorning(from now: Date = .now) -> Date {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: morningHour, minute: 0, second: 0, of: now) ?? now
        return today > now ? today : calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }

    /// "14.30" for later today, "besok 06.00" for another day.
    static func label(for date: Date, now: Date = .now) -> String {
        let time = date.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened, locale: Locale(identifier: "id_ID"))
        )
        return Calendar.current.isDate(date, inSameDayAs: now) ? time : "besok \(time)"
    }
}

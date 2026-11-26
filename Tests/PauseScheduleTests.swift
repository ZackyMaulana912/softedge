import Foundation
import Testing

struct PauseScheduleTests {
    private let calendar = Calendar.current

    /// A fixed day, so the tests do not depend on when they run.
    private func date(day: Int = 10, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour, minute: minute))!
    }

    @Test func oneHourIsSixtyMinutesLater() {
        let now = date(hour: 9, minute: 15)
        #expect(PauseSchedule.oneHour(from: now) == date(hour: 10, minute: 15))
    }

    @Test func lateAtNightEndsNextMorning() {
        #expect(PauseSchedule.nextMorning(from: date(hour: 23)) == date(day: 11, hour: 6))
    }

    @Test func afterMidnightEndsThisMorning() {
        #expect(PauseSchedule.nextMorning(from: date(hour: 2)) == date(hour: 6))
    }

    @Test func exactlySixEndsTomorrow() {
        #expect(PauseSchedule.nextMorning(from: date(hour: 6)) == date(day: 11, hour: 6))
    }

    @Test func labelForLaterToday() {
        let label = PauseSchedule.label(for: date(hour: 14, minute: 30), now: date(hour: 9))
        #expect(label == "14.30")
    }

    @Test func labelForTomorrow() {
        let label = PauseSchedule.label(for: date(day: 11, hour: 6), now: date(hour: 23))
        #expect(label == "besok 06.00")
    }
}

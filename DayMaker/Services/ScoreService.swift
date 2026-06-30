// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import Foundation
import Combine

final class ScoreService: ObservableObject {
    static let shared = ScoreService()
    private var cancellables = Set<AnyCancellable>()

    @Published var todayScore: Int = 0
    @Published var breakdown: ScoreBreakdown = ScoreBreakdown()

    private init() {
        NotificationCenter.default.publisher(for: .scoreNeedsUpdate)
            .sink { [weak self] _ in self?.recalculate() }
            .store(in: &cancellables)
    }

    func recalculate() {
        let profileService = ProfileService.shared
        let streak = StreakService.shared
        var b = ScoreBreakdown()

        b.moodChecked    = profileService.todayMood != nil      // 20 pts
        b.streakActive   = streak.currentStreak > 0             // 20 pts
        b.journalWritten = profileService.todaysCompliments.contains { $0.journalNote != nil } // 20 pts

        let readCount = profileService.todaysCompliments.filter { $0.isRead && !$0.isSoulLetter }.count
        b.complimentsRead = min(readCount, 4)                   // 10 pts each → 40 pts max

        breakdown = b
        todayScore = b.total
    }
}

struct ScoreBreakdown {
    var moodChecked: Bool    = false   // 20
    var streakActive: Bool   = false   // 20
    var journalWritten: Bool = false   // 20
    var complimentsRead: Int = 0       // 10 each

    var total: Int {
        (moodChecked    ? 20 : 0) +
        (streakActive   ? 20 : 0) +
        (journalWritten ? 20 : 0) +
        (complimentsRead * 10)
    }

    var maxScore: Int { 100 }
    var progress: Double { Double(total) / Double(maxScore) }
}

extension Notification.Name {
    static let scoreNeedsUpdate = Notification.Name("daymaker_score_needs_update")
}

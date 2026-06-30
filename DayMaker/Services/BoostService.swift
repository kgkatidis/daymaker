// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import Foundation

final class BoostService: ObservableObject {
    static let shared = BoostService()

    @Published var boostsUsedToday: Int = 0
    let maxPerDay = 3

    private let countKey = "daymaker_boost_count"
    private let dateKey  = "daymaker_boost_date"

    private init() { load() }

    var canBoost: Bool { boostsUsedToday < maxPerDay }
    var remaining: Int { maxPerDay - boostsUsedToday }

    func useBoost() {
        boostsUsedToday += 1
        UserDefaults.standard.set(boostsUsedToday, forKey: countKey)
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }

    private func load() {
        guard let date = UserDefaults.standard.object(forKey: dateKey) as? Date,
              Calendar.current.isDateInToday(date) else {
            boostsUsedToday = 0
            return
        }
        boostsUsedToday = UserDefaults.standard.integer(forKey: countKey)
    }

    func reset() {
        boostsUsedToday = 0
        UserDefaults.standard.removeObject(forKey: countKey)
        UserDefaults.standard.removeObject(forKey: dateKey)
    }
}

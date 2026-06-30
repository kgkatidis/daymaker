// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var age: String = ""
    var profession: String = ""
    var proudestAchievement: String = ""
    var passionsAndHobbies: String = ""
    var personalityTrait: String = ""
    var goalsNextYear: String = ""
    var frequentCompliments: String = ""
    var recentChallenge: String = ""
    var whatMakesUnique: String = ""
    var physicalFeatureLove: String = ""
    var morningRoutine: String = ""
    var relationshipStatus: String = ""
    var lifePhilosophy: String = ""
    var createdAt: Date = Date()
    var isOnboardingComplete: Bool = false
}

extension UserProfile {
    var summaryForAI: String {
        """
        Name: \(name)
        Age: \(age)
        Profession: \(profession)
        Proudest achievement: \(proudestAchievement)
        Passions & hobbies: \(passionsAndHobbies)
        Personality trait they love: \(personalityTrait)
        Goals for next year: \(goalsNextYear)
        What people often compliment them on: \(frequentCompliments)
        Recent challenge overcome: \(recentChallenge)
        What makes them unique: \(whatMakesUnique)
        Physical feature they love: \(physicalFeatureLove)
        Morning routine: \(morningRoutine)
        Relationship status: \(relationshipStatus)
        Life philosophy: \(lifePhilosophy)
        """
    }
}

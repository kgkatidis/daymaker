// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import Foundation

enum ComplimentSlot: Int, Codable, CaseIterable {
    case morning = 0
    case midMorning = 1
    case afternoon = 2
    case evening = 3

    var displayName: String {
        switch self {
        case .morning: return "Πρωινό"
        case .midMorning: return "Μεσημέρι"
        case .afternoon: return "Απόγευμα"
        case .evening: return "Βράδυ"
        }
    }

    var hour: Int {
        switch self {
        case .morning: return 8
        case .midMorning: return 11
        case .afternoon: return 15
        case .evening: return 20
        }
    }

    var emoji: String {
        switch self {
        case .morning: return "🌅"
        case .midMorning: return "☀️"
        case .afternoon: return "🌤"
        case .evening: return "🌙"
        }
    }

    var systemPromptContext: String {
        switch self {
        case .morning:
            return "It's early morning. The person is starting their day. Give them an energizing, warm compliment that sets a positive tone for the day ahead."
        case .midMorning:
            return "It's mid-morning. The person is in the flow of their day. Give them a genuine, motivating compliment that keeps their energy and confidence high."
        case .afternoon:
            return "It's afternoon. The person might be feeling the midday dip. Give them a heartfelt, uplifting compliment that reminds them of their inner strength."
        case .evening:
            return "It's evening. The person is wrapping up their day. Give them a warm, reflective compliment that celebrates who they are and honors the day they lived."
        }
    }
}

enum MoodState: Int, Codable, CaseIterable {
    case rough = 0
    case meh = 1
    case okay = 2
    case good = 3
    case amazing = 4

    var emoji: String {
        switch self {
        case .rough: return "😔"
        case .meh: return "😐"
        case .okay: return "🙂"
        case .good: return "😊"
        case .amazing: return "🤩"
        }
    }

    var label: String {
        switch self {
        case .rough: return "Δύσκολα"
        case .meh: return "Έτσι κι έτσι"
        case .okay: return "Καλά"
        case .good: return "Πολύ καλά"
        case .amazing: return "Τέλεια!"
        }
    }

    var promptContext: String {
        switch self {
        case .rough:
            return "IMPORTANT: This person is having a rough day. They feel down. Give them extra warmth, validation, and remind them gently that hard days don't define them."
        case .meh:
            return "This person is feeling neutral today. Lift their spirits with something that reminds them of their quiet strength."
        case .okay:
            return "This person is doing okay. Give them a compliment that adds a spark of joy to an already decent day."
        case .good:
            return "This person is in a good mood. Match their energy with something celebratory and affirming."
        case .amazing:
            return "This person is feeling amazing today! Celebrate alongside them with an enthusiastic, joyful compliment."
        }
    }
}

struct Compliment: Codable, Identifiable {
    let id: UUID
    let text: String
    let slot: ComplimentSlot
    let date: Date
    var isRead: Bool
    var mood: MoodState?
    var journalNote: String?
    var isSoulLetter: Bool
    var isMonthlyLetter: Bool
    var isFavorite: Bool

    init(text: String, slot: ComplimentSlot, date: Date = Date(), mood: MoodState? = nil, isSoulLetter: Bool = false, isMonthlyLetter: Bool = false) {
        self.id = UUID()
        self.text = text
        self.slot = slot
        self.date = date
        self.isRead = false
        self.mood = mood
        self.journalNote = nil
        self.isSoulLetter = isSoulLetter
        self.isMonthlyLetter = isMonthlyLetter
        self.isFavorite = false
    }
}

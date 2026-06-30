// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct DayMakerGradient: View {
    let slot: ComplimentSlot?

    private var colors: [Color] {
        switch slot {
        case .morning:
            return [Color(hex: "FF6B6B"), Color(hex: "FFE66D")]
        case .midMorning:
            return [Color(hex: "4FACFE"), Color(hex: "00F2FE")]
        case .afternoon:
            return [Color(hex: "43E97B"), Color(hex: "38F9D7")]
        case .evening:
            return [Color(hex: "667EEA"), Color(hex: "764BA2")]
        case nil:
            return [Color(hex: "667EEA"), Color(hex: "764BA2")]
        }
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct TypewriterText: View {
    let fullText: String
    var font: Font = .body
    var color: Color = .primary
    var lineSpacing: CGFloat = 4
    var delay: Double = 0

    @State private var displayed = ""
    @State private var started = false

    var body: some View {
        Text(displayed)
            .font(font)
            .foregroundColor(color)
            .lineSpacing(lineSpacing)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
                guard !started else { return }
                started = true
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    animateText()
                }
            }
    }

    private func animateText() {
        displayed = ""
        let chars = Array(fullText)
        for (i, char) in chars.enumerated() {
            let interval = delay + Double(i) * 0.018
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                displayed.append(char)
            }
        }
    }
}

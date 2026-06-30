// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let delay: Double
}

struct ParticleBackground: View {
    private let particles: [Particle] = (0..<18).map { i in
        Particle(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 2...5),
            opacity: Double.random(in: 0.06...0.18),
            duration: Double.random(in: 6...14),
            delay: Double.random(in: 0...8)
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    FloatingParticle(
                        size: p.size,
                        opacity: p.opacity,
                        duration: p.duration,
                        delay: p.delay
                    )
                    .position(
                        x: p.x * geo.size.width,
                        y: p.y * geo.size.height
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct FloatingParticle: View {
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let delay: Double

    @State private var offsetY: CGFloat = 0
    @State private var currentOpacity: Double = 0

    var body: some View {
        Circle()
            .fill(Color.purple)
            .frame(width: size, height: size)
            .opacity(currentOpacity)
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offsetY = -30
                    currentOpacity = opacity
                }
            }
    }
}

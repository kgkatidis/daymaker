// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct ShareCardView: View {
    let compliment: Compliment
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Text("Κοινοποίηση")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    shareCard
                        .padding(.horizontal, 20)

                    Text("Πάτα και κράτα την κάρτα για αποθήκευση,\nή κοινοποίησέ την παρακάτω.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    ShareLink(
                        item: compliment.text,
                        subject: Text("DayMaker"),
                        message: Text("— DayMaker by Konstantinos Gkatidis")
                    ) {
                        Label("Κοινοποίηση", systemImage: "square.and.arrow.up")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.purple)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Κλείσιμο") { dismiss() }
                }
            }
        }
    }

    private var shareCard: some View {
        ZStack {
            DayMakerGradient(slot: compliment.isSoulLetter ? nil : compliment.slot)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    if compliment.isSoulLetter {
                        Label("Soul Letter", systemImage: "envelope.open.fill")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    } else {
                        Text("\(compliment.slot.emoji) \(compliment.slot.displayName)")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    }
                    Spacer()
                }

                Text(compliment.text)
                    .font(.body)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(5)

                Spacer(minLength: 8)

                HStack {
                    Spacer()
                    Text("☀️ DayMaker")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(minHeight: 220)
    }
}

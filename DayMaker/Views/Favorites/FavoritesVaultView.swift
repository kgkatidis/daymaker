// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct FavoritesVaultView: View {
    @EnvironmentObject var profileService: ProfileService
    @Environment(\.dismiss) var dismiss

    private var favorites: [Compliment] {
        profileService.compliments.filter { $0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                if favorites.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            headerCard
                            ForEach(favorites) { compliment in
                                ComplimentCard(compliment: compliment, compact: false)
                                    .environmentObject(profileService)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Vault ❤️")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Κλείσιμο") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(favorites.count) αγαπημένα")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var headerCard: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Text("❤️")
                    .font(.system(size: 36))
                Text("Τα αγαπημένα σου")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Τα μηνύματα που αγγίξανε κάτι βαθύ")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(height: 110)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Text("❤️")
                .font(.system(size: 64))
                .opacity(0.4)
            Text("Κανένα αγαπημένο ακόμα")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Πάτα παρατεταμένα σε οποιοδήποτε\nμήνυμα για να το αποθηκεύσεις εδώ.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

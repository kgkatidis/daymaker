// Copyright © 2026 Konstantinos Gkatidis. All rights reserved.

import SwiftUI

struct ComplimentHistoryView: View {
    @EnvironmentObject var profileService: ProfileService
    @Environment(\.dismiss) var dismiss
    @State private var selectedFilter: ComplimentSlot? = nil

    private var filtered: [Compliment] {
        guard let f = selectedFilter else { return profileService.compliments }
        return profileService.compliments.filter { $0.slot == f }
    }

    private var grouped: [(String, [Compliment])] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: filtered) { compliment -> String in
            if cal.isDateInToday(compliment.date) { return "Σήμερα" }
            if cal.isDateInYesterday(compliment.date) { return "Χθες" }
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "el_GR")
            fmt.dateStyle = .long
            return fmt.string(from: compliment.date)
        }
        return groups.sorted { a, b in
            if a.key == "Σήμερα" { return true }
            if b.key == "Σήμερα" { return false }
            if a.key == "Χθες" { return true }
            if b.key == "Χθες" { return false }
            return a.key > b.key
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                if filtered.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(grouped, id: \.0) { group, compliments in
                            Section(header: Text(group).font(.headline)) {
                                ForEach(compliments) { compliment in
                                    ComplimentCard(compliment: compliment, compact: true)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Ιστορικό")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Κλείσιμο") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(profileService.compliments.count) μηνύματα")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "Όλα", slot: nil)
                ForEach(ComplimentSlot.allCases, id: \.rawValue) { slot in
                    filterChip(label: "\(slot.emoji) \(slot.displayName)", slot: slot)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func filterChip(label: String, slot: ComplimentSlot?) -> some View {
        let selected = selectedFilter == slot
        return Button(action: { selectedFilter = slot }) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color.purple : Color(UIColor.secondarySystemBackground))
                .foregroundColor(selected ? .white : .primary)
                .cornerRadius(20)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.4))
            Text("Δεν υπάρχουν μηνύματα ακόμα")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Τα μηνύματά σου θα εμφανίζονται εδώ καθώς η μέρα προχωράει.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}

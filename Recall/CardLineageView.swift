import SwiftUI

struct CardLineageView: View {
    let card: StudyCard
    let lineage: CardLineage
    let reviewHistory: [ReviewResult]

    private var events: [LineageEvent] {
        var items: [LineageEvent] = [
            LineageEvent(title: "Original source", subtitle: lineage.sourceName, date: lineage.createdDate, icon: "book.closed.fill", tint: .blue),
            LineageEvent(title: "Created card", subtitle: lineage.createdFrom.label, date: lineage.createdDate, icon: "rectangle.stack.fill", tint: .purple)
        ]

        items += lineage.revisionHistory.map {
            LineageEvent(title: "Edited revision", subtitle: $0.changeSummary, date: $0.date, icon: "pencil", tint: .orange)
        }

        items += reviewHistory
            .filter { $0.cardID == card.id }
            .prefix(3)
            .map {
                LineageEvent(
                    title: $0.missReason == nil ? "Reviewed" : "Missed in practice",
                    subtitle: $0.reflectionReason.isEmpty ? $0.rating.rawValue : $0.reflectionReason,
                    date: $0.reviewedAt,
                    icon: $0.missReason == nil ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                    tint: $0.missReason == nil ? .green : .red
                )
            }

        if !lineage.revisionHistory.isEmpty {
            items.append(LineageEvent(title: "Updated explanation", subtitle: lineage.revisionHistory.last?.newBack ?? card.back, date: lineage.revisionHistory.last?.date ?? card.lastReviewedDate, icon: "text.bubble.fill", tint: .cyan))
        }

        return items.sorted { $0.date < $1.date }
    }

    var body: some View {
        DashboardCard(title: "Card Lineage", systemImage: "timeline.selection") {
            VStack(alignment: .leading, spacing: 12) {
                lineageSummary

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(events) { event in
                        lineageRow(event)
                    }
                }
            }
        }
    }

    private var lineageSummary: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Created from: \(lineage.createdFrom.label)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
            Text("Source: \(lineage.sourceName)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Revisions: \(lineage.revisionHistory.count) • Last edited \(DateFormatters.shortDate.string(from: lastEditedDate))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Related concepts: \(card.concepts.map(\.name).joined(separator: ", "))")
                .font(.caption)
                .foregroundStyle(.purple)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
    }

    private var lastEditedDate: Date {
        lineage.revisionHistory.last?.date ?? lineage.createdDate
    }

    private func lineageRow(_ event: LineageEvent) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(event.tint.opacity(0.22))
                    Image(systemName: event.icon)
                        .font(.caption)
                        .foregroundStyle(event.tint)
                }
                .frame(width: 30, height: 30)

                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1, height: 32)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(DateFormatters.shortDate.string(from: event.date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(event.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(.top, 2)
        }
    }
}

private struct LineageEvent: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let date: Date
    let icon: String
    let tint: Color
}

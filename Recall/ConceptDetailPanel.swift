import SwiftUI

struct ConceptDetailPanel: View {
    @ObservedObject var viewModel: AppViewModel
    let concept: ConceptNode
    @State private var expandedSections: Set<InspectorSection> = []

    private var linkedCards: [StudyCard] {
        viewModel.studyCards.filter { card in
            card.linkedConceptIDs.contains(concept.id) || card.concepts.contains { $0.name == concept.name }
        }
    }

    private var linkedDecks: [StudyDeck] {
        viewModel.studyDecks.filter { deck in
            deck.linkedConcepts.contains { $0.name == concept.name } || linkedCards.contains { $0.deckName == deck.name }
        }
    }

    private var relatedConcepts: [ConceptNode] {
        viewModel.relatedConcepts(for: concept)
    }

    private var commonConfusions: [ConceptNode] {
        let confusedIDs = viewModel.conceptEdges.compactMap { edge -> UUID? in
            guard edge.relationshipType == .confusedWith else { return nil }
            if edge.fromConceptID == concept.id { return edge.toConceptID }
            if edge.toConceptID == concept.id { return edge.fromConceptID }
            return nil
        }
        return viewModel.graphConcepts.filter { confusedIDs.contains($0.id) }
    }

    private var sourceNames: [String] {
        let cardSources = linkedCards.map(\.sourceReferenceText)
        let deckSources = linkedDecks.flatMap { $0.sources.map(\.title) }
        return Array(Set(cardSources + deckSources)).sorted()
    }

    private var relatedHistory: [ReviewResult] {
        let cardIDs = Set(linkedCards.map(\.id))
        return viewModel.reviewHistory.filter { cardIDs.contains($0.cardID) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(18)

            Divider()
                .overlay(Color.white.opacity(0.1))

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    inspectorSection(.overview) {
                        overviewContent
                    }

                    inspectorSection(.connections) {
                        connectionsContent
                    }

                    inspectorSection(.sources) {
                        compactRows(sourceNames, fallback: "No sources linked")
                    }

                    inspectorSection(.history) {
                        historyContent
                    }

                    inspectorSection(.actions) {
                        actionButtons
                    }
                }
                .padding(14)
            }
        }
        .background(Color.black.opacity(0.24))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inspector")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(concept.name)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(concept.section)
                .font(.caption.weight(.bold))
                .foregroundStyle(.purple)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(concept.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                metric(title: "Mastery", value: "\(Int(concept.mastery * 100))%", icon: "target", tint: concept.mastery < 0.65 ? .orange : .green)
                metric(title: "Weak", value: "\(concept.weakCount)", icon: "exclamationmark.triangle.fill", tint: .orange)
                metric(title: "Cards", value: "\(max(linkedCards.count, concept.linkedCardIDs.count))", icon: "rectangle.stack.fill", tint: .blue)
                metric(title: "Decks", value: "\(linkedDecks.count)", icon: "books.vertical.fill", tint: .purple)
            }
        }
    }

    private var connectionsContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            compactRows(relatedConcepts.prefix(5).map(\.name), fallback: "No related concepts")
            compactRows(commonConfusions.map { "Confused with \($0.name)" }, fallback: "No confusion edges")
        }
    }

    private var historyContent: some View {
        VStack(spacing: 7) {
            if relatedHistory.isEmpty {
                compactRow("No review history linked yet", isMuted: true)
            } else {
                ForEach(relatedHistory.prefix(4)) { result in
                    compactRow("\(DateFormatters.shortDate.string(from: result.reviewedAt)) • \(result.rating.rawValue) • \(result.reflectionReason.isEmpty ? result.section : result.reflectionReason)")
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            actionButton("Review linked cards", icon: "rectangle.stack.fill") {
                viewModel.selectedScreen = .review
            }
            actionButton("Practice application", icon: "checklist.checked") {
                viewModel.selectedScreen = .practice
            }
            actionButton("View lineage", icon: "timeline.selection") {
                viewModel.selectedScreen = .library
            }
        }
    }

    private func inspectorSection<Content: View>(_ section: InspectorSection, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.16)) {
                    if expandedSections.contains(section) {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack {
                    Label(section.rawValue, systemImage: section.systemImage)
                        .font(.caption.weight(.bold))
                    Spacer()
                    Image(systemName: expandedSections.contains(section) ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.white)
                .padding(12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expandedSections.contains(section) {
                VStack(alignment: .leading, spacing: 10) {
                    content()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func metric(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.18)))
    }

    private func compactRows(_ rows: [String], fallback: String) -> some View {
        VStack(spacing: 7) {
            if rows.isEmpty {
                compactRow(fallback, isMuted: true)
            } else {
                ForEach(rows, id: \.self) { row in
                    compactRow(row)
                }
            }
        }
    }

    private func compactRow(_ text: String, isMuted: Bool = false) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(isMuted ? Color.secondary : Color.white)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.18)))
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.18)))
        }
        .buttonStyle(.plain)
    }
}

private enum InspectorSection: String, CaseIterable, Hashable {
    case overview = "Overview"
    case connections = "Connections"
    case sources = "Sources"
    case history = "History"
    case actions = "Actions"

    var systemImage: String {
        switch self {
        case .overview:
            return "info.circle.fill"
        case .connections:
            return "point.3.connected.trianglepath.dotted"
        case .sources:
            return "book.closed.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .actions:
            return "bolt.fill"
        }
    }
}

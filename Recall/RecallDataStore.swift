import Foundation
import SwiftUI

struct RecallSeedRuntimeData {
    let folders: [StudyFolder]
    let decks: [StudyDeck]
    let cards: [StudyCard]
    let concepts: [ConceptNode]
    let edges: [ConceptEdge]
    let lineages: [CardLineage]
    let sources: [ResourceSource]
    let stats: ReviewStats
}

final class RecallDataStore {
    static let shared = RecallDataStore()

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let sourceID = UUID(uuidString: "A77EDE32-6C4D-4F36-9ED8-100B9076BC40")!
    private(set) var cachedConcepts: [ConceptNode] = []

    private var seedDataURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Recall", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("MCATSeedData.json")
    }

    private init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadRuntimeData() -> RecallSeedRuntimeData {
        let dataset = loadOrCreateSeedDataset()
        return runtimeData(from: dataset)
    }

    func cachedConcept(named name: String) -> ConceptNode? {
        cachedConcepts.first { $0.name == name }
    }

    func isPDFSeedData(_ persisted: PersistentAppData) -> Bool {
        persisted.cards.contains { card in
            card.source.title == "MCAT Review Sheets.pdf" || card.createdFrom == CardLineageSource.pdfImport.rawValue
        }
    }

    private func loadOrCreateSeedDataset() -> RecallSeedDataset {
        if let data = try? Data(contentsOf: seedDataURL),
           let dataset = try? decoder.decode(RecallSeedDataset.self, from: data),
           !dataset.cards.isEmpty {
            return dataset
        }

        let generated = MCATSeedGenerator().generate()
        if let encoded = try? encoder.encode(generated) {
            try? encoded.write(to: seedDataURL, options: .atomic)
        }
        return generated
    }

    private func runtimeData(from dataset: RecallSeedDataset) -> RecallSeedRuntimeData {
        let source = ResourceSource(id: sourceID, title: dataset.sourceName, type: .pdfImport)
        let cardsByConcept = Dictionary(grouping: dataset.cards.flatMap { card in
            card.conceptIDs.map { (conceptID: $0, cardID: card.id) }
        }, by: \.conceptID)

        let linkedConceptIDs = linkedIDsByConcept(from: dataset.edges)
        let concepts = dataset.concepts.map { seed in
            ConceptNode(
                id: seed.id,
                name: seed.name,
                section: seed.section,
                description: seed.description,
                mastery: seed.mastery,
                weakCount: seed.weakCount,
                linkedConceptIDs: linkedConceptIDs[seed.id] ?? [],
                linkedCardIDs: cardsByConcept[seed.id]?.map(\.cardID) ?? [],
                sourceIDs: [source.id],
                lastReviewed: Calendar.current.date(byAdding: .day, value: -max(1, seed.weakCount / 2), to: Date()) ?? Date(),
                recommendedAction: seed.weakCount >= 7 ? .practiceQuestions : .reviewConceptCards
            )
        }

        cachedConcepts = concepts
        let conceptByID = Dictionary(uniqueKeysWithValues: concepts.map { ($0.id, $0) })
        let cards = dataset.cards.map { seed in
            let linkedConcepts = seed.conceptIDs.compactMap { conceptByID[$0] }
            return StudyCard(
                id: seed.id,
                deckID: seed.deckID,
                deckName: seed.deckName,
                section: seed.section,
                front: seed.front,
                back: seed.back,
                cardType: seed.cardType,
                difficulty: seed.difficulty,
                dueDate: Date(),
                lastReviewedDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                reviewIntervalDays: 0,
                stability: seed.difficulty == .hard ? 1.8 : 2.5,
                fsrsDifficulty: seed.difficulty == .hard ? 6.2 : 5.0,
                retrievability: 0.72,
                reviewCount: 0,
                easeFactor: seed.difficulty == .hard ? 2.1 : 2.35,
                retentionScore: seed.difficulty == .hard ? 0.58 : 0.68,
                confidenceRating: seed.difficulty == .hard ? 2 : 3,
                missReason: nil,
                tags: seed.tags,
                concepts: linkedConcepts,
                source: source,
                sourcePage: seed.sourcePage,
                sourceSectionTitle: seed.sourceSectionTitle,
                createdFrom: .pdfImport,
                linkedConceptIDs: seed.conceptIDs,
                linkedFullLengthExamNumber: nil
            )
        }

        let cardsByDeck = Dictionary(grouping: cards, by: \.deckName)
        let conceptsByDeck = Dictionary(grouping: concepts, by: \.section)
        let decks = dataset.sections.map { section in
            let deckCards = cardsByDeck[section.deckName] ?? []
            let deckConcepts = conceptsByDeck[section.deckName] ?? []
            let mastery = deckCards.isEmpty ? 0 : deckCards.map(\.retentionScore).reduce(0, +) / Double(deckCards.count)
            return StudyDeck(
                id: section.id,
                folderName: folderName(for: section.deckName),
                name: section.deckName,
                description: "\(section.name) cards generated from \(dataset.sourceName), pages \(section.pageStart)-\(section.pageEnd).",
                cardCount: deckCards.count,
                dueToday: deckCards.count,
                mastery: mastery,
                tags: ["mcat", "pdf-import", section.name.lowercased().replacingOccurrences(of: " ", with: "-")],
                linkedConcepts: deckConcepts,
                sources: [source],
                lastStudied: "Seeded",
                accentColor: accentColor(for: section.deckName)
            )
        }

        let folders = [
            StudyFolder(name: "Chem/Phys", systemImage: "atom", accentColor: .blue),
            StudyFolder(name: "Bio/Biochem", systemImage: "cross.case.fill", accentColor: .green),
            StudyFolder(name: "Psych/Soc", systemImage: "person.3.fill", accentColor: .purple),
            StudyFolder(name: "Appendix", systemImage: "doc.text.fill", accentColor: .orange)
        ]

        let edges = dataset.edges.map {
            ConceptEdge(id: $0.id, fromConceptID: $0.fromConceptID, toConceptID: $0.toConceptID, relationshipType: $0.relationshipType, strength: $0.strength)
        }

        let lineages = cards.map {
            CardLineage(
                cardID: $0.id,
                createdFrom: .pdfImport,
                sourceName: $0.sourceReferenceText,
                parentQuestionID: nil,
                parentCardID: nil,
                createdDate: dataset.generatedAt,
                revisionHistory: []
            )
        }

        let stats = ReviewStats(
            cardsDueToday: cards.count,
            completedToday: 0,
            retentionPercentage: cards.isEmpty ? 0 : Int((cards.map(\.retentionScore).reduce(0, +) / Double(cards.count)) * 100),
            streakDays: 0,
            totalCards: cards.count,
            masteredConcepts: concepts.filter { $0.mastery >= 0.75 }.count
        )

        return RecallSeedRuntimeData(
            folders: folders,
            decks: decks,
            cards: cards,
            concepts: concepts,
            edges: edges,
            lineages: lineages,
            sources: [source],
            stats: stats
        )
    }

    private func linkedIDsByConcept(from edges: [SeedConceptEdge]) -> [UUID: [UUID]] {
        var result: [UUID: Set<UUID>] = [:]
        for edge in edges {
            result[edge.fromConceptID, default: []].insert(edge.toConceptID)
            result[edge.toConceptID, default: []].insert(edge.fromConceptID)
        }
        return result.mapValues { Array($0) }
    }

    private func folderName(for deckName: String) -> String {
        switch deckName {
        case "General Chemistry", "Organic Chemistry", "Physics":
            return "Chem/Phys"
        case "Biology", "Biochemistry":
            return "Bio/Biochem"
        case "Psychology / Sociology":
            return "Psych/Soc"
        default:
            return "Appendix"
        }
    }

    private func accentColor(for deckName: String) -> Color {
        switch deckName {
        case "General Chemistry":
            return .blue
        case "Organic Chemistry":
            return .pink
        case "Biology":
            return .green
        case "Biochemistry":
            return .mint
        case "Psychology / Sociology":
            return .purple
        case "Physics":
            return .cyan
        default:
            return .orange
        }
    }
}

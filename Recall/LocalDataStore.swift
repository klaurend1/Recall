import Foundation
import SwiftUI

struct PersistentAppData: Codable {
    var folders: [PersistentFolder]
    var decks: [PersistentDeck]
    var cards: [PersistentCard]
    var reviewHistory: [PersistentReviewResult]
    var practiceResults: [PersistentPracticeResult]
    var stats: PersistentReviewStats?
}

struct PersistentDeckPackage: Codable {
    var deck: PersistentDeck
    var cards: [PersistentCard]
}

final class LocalDataStore {
    static let shared = LocalDataStore()

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private var appDataURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Recall", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("recall-data.json")
    }

    private var deckExportURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RecallSelectedDeckExport.json")
    }

    private init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
    }

    func load() -> PersistentAppData? {
        guard let data = try? Data(contentsOf: appDataURL) else { return nil }
        return try? decoder.decode(PersistentAppData.self, from: data)
    }

    func save(folders: [StudyFolder], decks: [StudyDeck], cards: [StudyCard], reviewHistory: [ReviewResult], practiceResults: [PracticeResult], stats: ReviewStats) {
        let data = PersistentAppData(
            folders: folders.map(PersistentFolder.init),
            decks: decks.map(PersistentDeck.init),
            cards: cards.map(PersistentCard.init),
            reviewHistory: reviewHistory.map(PersistentReviewResult.init),
            practiceResults: practiceResults.map(PersistentPracticeResult.init),
            stats: PersistentReviewStats(stats)
        )

        guard let encoded = try? encoder.encode(data) else { return }
        try? encoded.write(to: appDataURL, options: .atomic)
    }

    func exportDeck(_ deck: StudyDeck, cards: [StudyCard]) -> URL? {
        let package = PersistentDeckPackage(deck: PersistentDeck(deck), cards: cards.map(PersistentCard.init))
        guard let encoded = try? encoder.encode(package) else { return nil }
        do {
            try encoded.write(to: deckExportURL, options: .atomic)
            return deckExportURL
        } catch {
            return nil
        }
    }

    func importDeckPackage() -> (deck: StudyDeck, cards: [StudyCard])? {
        guard let data = try? Data(contentsOf: deckExportURL),
              let package = try? decoder.decode(PersistentDeckPackage.self, from: data) else {
            return nil
        }
        return (package.deck.model, package.cards.map(\.model))
    }
}

struct PersistentReviewStats: Codable {
    var cardsDueToday: Int
    var completedToday: Int
    var retentionPercentage: Int
    var streakDays: Int
    var totalCards: Int
    var masteredConcepts: Int

    init(_ stats: ReviewStats) {
        cardsDueToday = stats.cardsDueToday
        completedToday = stats.completedToday
        retentionPercentage = stats.retentionPercentage
        streakDays = stats.streakDays
        totalCards = stats.totalCards
        masteredConcepts = stats.masteredConcepts
    }

    var model: ReviewStats {
        ReviewStats(cardsDueToday: cardsDueToday, completedToday: completedToday, retentionPercentage: retentionPercentage, streakDays: streakDays, totalCards: totalCards, masteredConcepts: masteredConcepts)
    }
}

struct PersistentFolder: Codable {
    var id: UUID
    var name: String
    var systemImage: String
    var colorName: String

    init(_ folder: StudyFolder) {
        id = folder.id
        name = folder.name
        systemImage = folder.systemImage
        colorName = ColorToken.name(for: folder.accentColor)
    }

    var model: StudyFolder {
        StudyFolder(id: id, name: name, systemImage: systemImage, accentColor: ColorToken.color(named: colorName))
    }
}

struct PersistentDeck: Codable {
    var id: UUID
    var folderName: String
    var name: String
    var description: String
    var cardCount: Int
    var dueToday: Int
    var mastery: Double
    var tags: [String]
    var linkedConceptNames: [String]
    var sources: [PersistentSource]
    var lastStudied: String
    var colorName: String

    init(_ deck: StudyDeck) {
        id = deck.id
        folderName = deck.folderName
        name = deck.name
        description = deck.description
        cardCount = deck.cardCount
        dueToday = deck.dueToday
        mastery = deck.mastery
        tags = deck.tags
        linkedConceptNames = deck.linkedConcepts.map(\.name)
        sources = deck.sources.map(PersistentSource.init)
        lastStudied = deck.lastStudied
        colorName = ColorToken.name(for: deck.accentColor)
    }

    var model: StudyDeck {
        StudyDeck(id: id, folderName: folderName, name: name, description: description, cardCount: cardCount, dueToday: dueToday, mastery: mastery, tags: tags, linkedConcepts: linkedConceptNames.compactMap { ConceptLookup.concept(named: $0) }, sources: sources.map(\.model), lastStudied: lastStudied, accentColor: ColorToken.color(named: colorName))
    }
}

struct PersistentCard: Codable {
    var id: UUID
    var deckID: UUID?
    var deckName: String
    var section: String
    var front: String
    var back: String
    var cardType: String?
    var difficulty: String
    var dueDate: Date
    var lastReviewedDate: Date
    var reviewIntervalDays: Int
    var stability: Double
    var fsrsDifficulty: Double
    var retrievability: Double
    var reviewCount: Int
    var easeFactor: Double
    var retentionScore: Double
    var confidenceRating: Int
    var missReason: String?
    var tags: [String]
    var conceptNames: [String]
    var source: PersistentSource
    var sourcePage: Int?
    var sourceSectionTitle: String?
    var createdFrom: String?
    var linkedFullLengthExamNumber: Int?

    init(_ card: StudyCard) {
        id = card.id
        deckID = card.deckID
        deckName = card.deckName
        section = card.section
        front = card.front
        back = card.back
        cardType = card.cardType.rawValue
        difficulty = card.difficulty.rawValue
        dueDate = card.dueDate
        lastReviewedDate = card.lastReviewedDate
        reviewIntervalDays = card.reviewIntervalDays
        stability = card.stability
        fsrsDifficulty = card.fsrsDifficulty
        retrievability = card.retrievability
        reviewCount = card.reviewCount
        easeFactor = card.easeFactor
        retentionScore = card.retentionScore
        confidenceRating = card.confidenceRating
        missReason = card.missReason?.rawValue
        tags = card.tags
        conceptNames = card.concepts.map(\.name)
        source = PersistentSource(card.source)
        sourcePage = card.sourcePage
        sourceSectionTitle = card.sourceSectionTitle
        createdFrom = card.createdFrom.rawValue
        linkedFullLengthExamNumber = card.linkedFullLengthExamNumber
    }

    var model: StudyCard {
        let concepts = conceptNames.compactMap { ConceptLookup.concept(named: $0) }
        let linkedIDs = concepts.isEmpty ? [] : concepts.map(\.id)
        return StudyCard(id: id, deckID: deckID, deckName: deckName, section: section, front: front, back: back, cardType: cardType.flatMap(StudyCardType.init(rawValue:)) ?? .basic, difficulty: CardDifficulty(rawValue: difficulty) ?? .medium, dueDate: dueDate, lastReviewedDate: lastReviewedDate, reviewIntervalDays: reviewIntervalDays, stability: stability, fsrsDifficulty: fsrsDifficulty, retrievability: retrievability, reviewCount: reviewCount, easeFactor: easeFactor, retentionScore: retentionScore, confidenceRating: confidenceRating, missReason: missReason.flatMap(MissReason.init(rawValue:)), tags: tags, concepts: concepts, source: source.model, sourcePage: sourcePage, sourceSectionTitle: sourceSectionTitle, createdFrom: createdFrom.flatMap(CardLineageSource.init(rawValue:)) ?? .userCreated, linkedConceptIDs: linkedIDs, linkedFullLengthExamNumber: linkedFullLengthExamNumber)
    }
}

struct PersistentSource: Codable {
    var id: UUID
    var title: String
    var type: String

    init(_ source: ResourceSource) {
        id = source.id
        title = source.title
        type = source.type.rawValue
    }

    var model: ResourceSource {
        ResourceSource(id: id, title: title, type: ResourceSourceType(rawValue: type) ?? .userCreated)
    }
}

struct PersistentReviewResult: Codable {
    var id: UUID
    var cardID: UUID
    var deckName: String
    var section: String
    var rating: String
    var missReason: String?
    var confidence: Int
    var reviewedAt: Date
    var previousDueDate: Date?
    var nextDueDate: Date
    var intervalDays: Int
    var reflectionReason: String?
    var linkedFullLengthExamNumber: Int?

    init(_ result: ReviewResult) {
        id = result.id
        cardID = result.cardID
        deckName = result.deckName
        section = result.section
        rating = result.rating.rawValue
        missReason = result.missReason?.rawValue
        confidence = result.confidence
        reviewedAt = result.reviewedAt
        previousDueDate = result.previousDueDate
        nextDueDate = result.nextDueDate
        intervalDays = result.intervalDays
        reflectionReason = result.reflectionReason
        linkedFullLengthExamNumber = result.linkedFullLengthExamNumber
    }

    var model: ReviewResult {
        ReviewResult(id: id, cardID: cardID, deckName: deckName, section: section, rating: ReviewRating(rawValue: rating) ?? .good, missReason: missReason.flatMap(MissReason.init(rawValue:)), confidence: confidence, reviewedAt: reviewedAt, previousDueDate: previousDueDate ?? reviewedAt, nextDueDate: nextDueDate, intervalDays: intervalDays, reflectionReason: reflectionReason ?? missReason ?? "", linkedFullLengthExamNumber: linkedFullLengthExamNumber)
    }
}

struct PersistentPracticeResult: Codable {
    var id: UUID
    var questionID: UUID
    var section: String
    var selectedAnswerIndex: Int
    var correctAnswerIndex: Int
    var missReason: String?
    var confidence: Int
    var followUpSuggestion: String
    var completedAt: Date

    init(_ result: PracticeResult) {
        id = result.id
        questionID = result.questionID
        section = result.section
        selectedAnswerIndex = result.selectedAnswerIndex
        correctAnswerIndex = result.correctAnswerIndex
        missReason = result.missReason?.rawValue
        confidence = result.confidence
        followUpSuggestion = result.followUpSuggestion
        completedAt = result.completedAt
    }

    var model: PracticeResult {
        PracticeResult(id: id, questionID: questionID, section: section, selectedAnswerIndex: selectedAnswerIndex, correctAnswerIndex: correctAnswerIndex, missReason: missReason.flatMap(MissReason.init(rawValue:)), confidence: confidence, followUpSuggestion: followUpSuggestion, completedAt: completedAt)
    }
}

enum ConceptLookup {
    static func concept(named name: String) -> ConceptNode? {
        RecallDataStore.shared.cachedConcept(named: name) ?? MockData.graphConceptNodes.first { $0.name == name }
    }
}

enum ColorToken {
    static func name(for color: Color) -> String {
        switch color {
        case .purple: return "purple"
        case .indigo: return "indigo"
        case .blue: return "blue"
        case .cyan: return "cyan"
        case .mint: return "mint"
        case .pink: return "pink"
        case .orange: return "orange"
        case .red: return "red"
        default: return "purple"
        }
    }

    static func color(named name: String) -> Color {
        switch name {
        case "purple": return .purple
        case "indigo": return .indigo
        case "blue": return .blue
        case "cyan": return .cyan
        case "mint": return .mint
        case "pink": return .pink
        case "orange": return .orange
        case "red": return .red
        default: return .purple
        }
    }
}

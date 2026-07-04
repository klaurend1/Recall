import Foundation
import SwiftUI
import Combine

enum AppScreen: String, CaseIterable, Identifiable {
    case home = "Home"
    case review = "Review"
    case practice = "Practice"
    case library = "Library"
    case graph = "Graph"
    case analytics = "Analytics"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .home:
            return "square.grid.2x2.fill"
        case .review:
            return "rectangle.stack.fill"
        case .practice:
            return "list.clipboard.fill"
        case .library:
            return "books.vertical.fill"
        case .graph:
            return "point.3.connected.trianglepath.dotted"
        case .analytics:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

struct Deck: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let cardCount: Int
    let dueToday: Int
    let mastery: Double
    let accentColor: Color
    let concepts: [Concept]
}

struct Card: Identifiable, Hashable {
    let id = UUID()
    let deckName: String
    var front: String
    var back: String
    let relatedConcepts: [Concept]
    let difficulty: String
}

struct Concept: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let summary: String
    let mastery: Double
}

struct StudyFolder: Identifiable, Hashable {
    var id: UUID = UUID()
    let name: String
    let systemImage: String
    let accentColor: Color
}

struct ConceptNode: Identifiable, Hashable {
    var id: UUID = UUID()
    let name: String
    let section: String
    let description: String
    let mastery: Double
    let weakCount: Int
    let linkedConceptIDs: [UUID]
    let linkedCardIDs: [UUID]
    let sourceIDs: [UUID]
    let lastReviewed: Date
    let recommendedAction: RecommendedAction

    var summary: String { description }
    var missedCards: Int { weakCount }

    init(
        id: UUID = UUID(),
        name: String,
        section: String,
        summary: String,
        mastery: Double,
        missedCards: Int,
        lastReviewed: Date,
        recommendedAction: RecommendedAction,
        linkedConceptIDs: [UUID] = [],
        linkedCardIDs: [UUID] = [],
        sourceIDs: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.section = section
        self.description = summary
        self.mastery = mastery
        self.weakCount = missedCards
        self.linkedConceptIDs = linkedConceptIDs
        self.linkedCardIDs = linkedCardIDs
        self.sourceIDs = sourceIDs
        self.lastReviewed = lastReviewed
        self.recommendedAction = recommendedAction
    }

    init(
        id: UUID = UUID(),
        name: String,
        section: String,
        description: String,
        mastery: Double,
        weakCount: Int,
        linkedConceptIDs: [UUID] = [],
        linkedCardIDs: [UUID] = [],
        sourceIDs: [UUID] = [],
        lastReviewed: Date,
        recommendedAction: RecommendedAction
    ) {
        self.id = id
        self.name = name
        self.section = section
        self.description = description
        self.mastery = mastery
        self.weakCount = weakCount
        self.linkedConceptIDs = linkedConceptIDs
        self.linkedCardIDs = linkedCardIDs
        self.sourceIDs = sourceIDs
        self.lastReviewed = lastReviewed
        self.recommendedAction = recommendedAction
    }
}

enum ConceptRelationshipType: String, CaseIterable, Identifiable, Hashable, Codable {
    case prerequisite = "prerequisite"
    case related = "related"
    case confusedWith = "confusedWith"
    case testedTogether = "testedTogether"
    case applicationOf = "applicationOf"
    case activates = "activates"
    case produces = "produces"
    case triggers = "triggers"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .confusedWith:
            return "confused with"
        case .testedTogether:
            return "tested together"
        case .applicationOf:
            return "application of"
        default:
            return rawValue
        }
    }
}

struct ConceptEdge: Identifiable, Hashable {
    var id: UUID = UUID()
    let fromConceptID: UUID
    let toConceptID: UUID
    let relationshipType: ConceptRelationshipType
    let strength: Double
}

enum CardLineageSource: String, CaseIterable, Identifiable, Hashable {
    case userCreated = "userCreated"
    case pdfImport = "pdfImport"
    case missedPracticeQuestion = "missedPracticeQuestion"
    case fullLengthReview = "fullLengthReview"
    case textbookImport = "textbookImport"
    case communityDataset = "communityDataset"
    case companyDataset = "companyDataset"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .userCreated:
            return "User created"
        case .pdfImport:
            return "PDF import"
        case .missedPracticeQuestion:
            return "Missed practice question"
        case .fullLengthReview:
            return "Full-length review"
        case .textbookImport:
            return "Textbook import"
        case .communityDataset:
            return "Community dataset"
        case .companyDataset:
            return "Company dataset"
        }
    }
}

struct CardRevision: Identifiable, Hashable {
    var id: UUID = UUID()
    let date: Date
    let changeSummary: String
    let previousFront: String
    let previousBack: String
    let newFront: String
    let newBack: String
}

struct CardLineage: Identifiable, Hashable {
    var id: UUID = UUID()
    let cardID: UUID
    let createdFrom: CardLineageSource
    let sourceName: String
    let parentQuestionID: UUID?
    let parentCardID: UUID?
    let createdDate: Date
    let revisionHistory: [CardRevision]
}

enum SemanticSearchResultType: String, CaseIterable, Identifiable, Hashable {
    case card
    case concept
    case deck
    case source

    var id: String { rawValue }
}

struct SemanticSearchResult: Identifiable, Hashable {
    var id: UUID = UUID()
    let type: SemanticSearchResultType
    let title: String
    let subtitle: String
    let relevanceScore: Double
    let matchedTerms: [String]
    let relatedConcepts: [String]
}

enum RecommendedAction: String, CaseIterable, Identifiable {
    case reviewConceptCards = "Review concept cards"
    case practiceQuestions = "Do 10 practice questions"
    case rewatchContent = "Rewatch content"
    case addFullLengthCards = "Add cards from missed full-length"
    case restMaintain = "Rest / maintain"

    var id: String { rawValue }
}

enum ResourceSourceType: String, CaseIterable, Identifiable {
    case kaplan = "Kaplan"
    case pdfImport = "PDF Import"
    case practice = "UWorld-style Practice"
    case aamcFullLength = "AAMC Full-Length"
    case jackWestin = "Jack Westin"
    case userCreated = "User Created"
    case communityDataset = "Community Dataset"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .kaplan:
            return "Kaplan"
        case .pdfImport:
            return "PDF"
        case .practice:
            return "Practice"
        case .aamcFullLength:
            return "AAMC FL"
        case .jackWestin:
            return "Jack Westin"
        case .userCreated:
            return "User"
        case .communityDataset:
            return "Community"
        }
    }

    var systemImage: String {
        switch self {
        case .kaplan:
            return "book.closed.fill"
        case .pdfImport:
            return "doc.richtext.fill"
        case .practice:
            return "checklist.checked"
        case .aamcFullLength:
            return "doc.text.magnifyingglass"
        case .jackWestin:
            return "text.book.closed.fill"
        case .userCreated:
            return "person.crop.circle.fill"
        case .communityDataset:
            return "person.3.fill"
        }
    }
}

struct ResourceSource: Identifiable, Hashable {
    var id: UUID = UUID()
    let title: String
    let type: ResourceSourceType
}

struct SourceReference: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let sourceName: String
    let page: Int
    let sectionTitle: String
    let conceptName: String
}

enum CardDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }
}

enum StudyCardType: String, CaseIterable, Identifiable, Hashable, Codable {
    case basic = "Basic"
    case cloze = "Cloze"
    case application = "Application"
    case misconception = "Misconception"

    var id: String { rawValue }
}

enum MissReason: String, CaseIterable, Identifiable {
    case didNotKnowContent = "Did not know content"
    case forgotContent = "Forgot content"
    case confusedConcepts = "Confused concepts"
    case misreadQuestion = "Misread question"
    case carelessMistake = "Careless mistake"
    case timingIssue = "Timing issue"

    var id: String { rawValue }
}

enum CorrectReflection: String, CaseIterable, Identifiable {
    case understood = "Understood"
    case shaky = "Got it, but shaky"
    case morePractice = "Want more practice"

    var id: String { rawValue }
}

struct StudyCard: Identifiable, Hashable {
    var id: UUID = UUID()
    var deckID: UUID? = nil
    let deckName: String
    let section: String
    var front: String
    var back: String
    var cardType: StudyCardType = .basic
    let difficulty: CardDifficulty
    var dueDate: Date
    var lastReviewedDate: Date
    var reviewIntervalDays: Int
    var stability: Double = 2.5
    var fsrsDifficulty: Double = 5.0
    var retrievability: Double = 0.9
    var reviewCount: Int = 0
    var easeFactor: Double
    var retentionScore: Double
    var confidenceRating: Int
    var missReason: MissReason?
    var tags: [String]
    let concepts: [ConceptNode]
    let source: ResourceSource
    var sourcePage: Int? = nil
    var sourceSectionTitle: String? = nil
    var createdFrom: CardLineageSource = .userCreated
    let linkedConceptIDs: [UUID]
    let linkedFullLengthExamNumber: Int?

    var sourceReferenceText: String {
        if let sourcePage {
            return "\(source.title), p. \(sourcePage)"
        }
        return source.title
    }
}

struct StudyDeck: Identifiable, Hashable {
    var id: UUID = UUID()
    let folderName: String
    let name: String
    let description: String
    let cardCount: Int
    let dueToday: Int
    let mastery: Double
    let tags: [String]
    let linkedConcepts: [ConceptNode]
    let sources: [ResourceSource]
    let lastStudied: String
    let accentColor: Color

    var primarySourceType: ResourceSourceType {
        sources.first?.type ?? .userCreated
    }

    var hasWeakConcepts: Bool {
        linkedConcepts.contains { $0.mastery < 0.7 }
    }
}

enum LibraryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case dueToday = "Due Today"
    case weakConcepts = "Weak Concepts"
    case textbookSources = "PDF Sources"
    case community = "Community"
    case company = "AAMC FL"

    var id: String { rawValue }
}

enum ConceptSectionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case bioBiochem = "Bio/Biochem"
    case chemPhys = "Chem/Phys"
    case psychSoc = "Psych/Soc"
    case cars = "CARS"

    var id: String { rawValue }

    func matches(_ concept: ConceptNode) -> Bool {
        switch self {
        case .all:
            return true
        case .bioBiochem:
            return concept.section == "Biology" || concept.section == "Biochemistry" || concept.section == "Bio/Biochem"
        case .chemPhys:
            return concept.section == "General Chemistry" || concept.section == "Organic Chemistry" || concept.section == "Physics" || concept.section == "Chem/Phys"
        case .psychSoc:
            return concept.section == "Psychology / Sociology" || concept.section == "Psych/Soc"
        case .cars:
            return concept.section == "CARS"
        }
    }
}

struct ReviewStats {
    let cardsDueToday: Int
    let completedToday: Int
    let retentionPercentage: Int
    let streakDays: Int
    let totalCards: Int
    let masteredConcepts: Int

    var dailyProgress: Double {
        guard cardsDueToday > 0 else { return 0 }
        return Double(completedToday) / Double(cardsDueToday)
    }
}

struct ReviewResult: Identifiable, Hashable {
    var id: UUID = UUID()
    let cardID: UUID
    let deckName: String
    let section: String
    let rating: ReviewRating
    let missReason: MissReason?
    let confidence: Int
    let reviewedAt: Date
    var previousDueDate: Date = Date()
    let nextDueDate: Date
    let intervalDays: Int
    var reflectionReason: String = ""
    let linkedFullLengthExamNumber: Int?
}

struct PracticeQuestion: Identifiable, Hashable {
    var id: UUID = UUID()
    let section: String
    let passage: String
    let stem: String
    let answerChoices: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let testedConcepts: [ConceptNode]
    let sourceLabel: String
    let applicationSkill: String
}

struct PracticeResult: Identifiable, Hashable {
    var id: UUID = UUID()
    let questionID: UUID
    let section: String
    let selectedAnswerIndex: Int
    let correctAnswerIndex: Int
    let missReason: MissReason?
    let confidence: Int
    let followUpSuggestion: String
    let completedAt: Date

    var isCorrect: Bool {
        selectedAnswerIndex == correctAnswerIndex
    }
}

final class AppViewModel: ObservableObject {
    private enum LayoutDefaults {
        static let appNavigationVisible = "Recall.layout.appNavigationVisible"
        static let contextPanelVisible = "Recall.layout.contextPanelVisible"
        static let rightInspectorVisible = "Recall.layout.rightInspectorVisible"
    }

    @Published var selectedScreen: AppScreen = .home
    @Published var selectedDeck: Deck = MockData.decks[0]
    @Published var currentCardIndex: Int = 0
    @Published var isShowingAnswer: Bool = false
    @Published var isShowingReflection: Bool = false
    @Published var pendingRating: ReviewRating?
    @Published var selectedMissReason: MissReason = .forgotContent
    @Published var selectedCorrectReflection: CorrectReflection = .understood
    @Published var selectedConfidence: Int = 3
    @Published var isReviewFocusMode: Bool = false
    @Published var isGraphFocusMode: Bool = false
    @Published var isPracticeFocusMode: Bool = false
    @Published var isAppNavigationVisible: Bool {
        didSet { UserDefaults.standard.set(isAppNavigationVisible, forKey: LayoutDefaults.appNavigationVisible) }
    }
    @Published var isContextPanelVisible: Bool {
        didSet { UserDefaults.standard.set(isContextPanelVisible, forKey: LayoutDefaults.contextPanelVisible) }
    }
    @Published var isRightInspectorVisible: Bool {
        didSet { UserDefaults.standard.set(isRightInspectorVisible, forKey: LayoutDefaults.rightInspectorVisible) }
    }
    @Published var stats: ReviewStats = MockData.reviewStats
    @Published var selectedStudyFolder: StudyFolder? = MockData.studyFolders.first
    @Published var selectedLibraryFilter: LibraryFilter = .all
    @Published var librarySearchText: String = ""
    @Published var selectedStudyDeck: StudyDeck? = MockData.studyDecks.first
    @Published var studyFolders: [StudyFolder] = MockData.studyFolders
    @Published var studyDecks: [StudyDeck] = MockData.studyDecks
    @Published var studyCards: [StudyCard] = MockData.studyCards
    @Published var reviewHistory: [ReviewResult] = MockData.reviewHistory
    @Published var currentPracticeIndex: Int = 0
    @Published var selectedPracticeSection: String = "Biology/Biochemistry"
    @Published var selectedPracticeAnswerIndex: Int?
    @Published var isShowingPracticeResult: Bool = false
    @Published var practiceMissReason: MissReason = .confusedConcepts
    @Published var practiceConfidence: Int = 3
    @Published var practiceResults: [PracticeResult] = MockData.practiceResults
    @Published var graphSearchText: String = ""
    @Published var selectedGraphSection: ConceptSectionFilter = .all
    @Published var selectedGraphConcept: ConceptNode = MockData.graphConceptNodes.first ?? MockData.conceptNodes[0]
    @Published var semanticSearchText: String = ""
    @Published var isFocusingWeakGraphConcepts: Bool = false
    @Published var isShowingOnlyTestedTogetherEdges: Bool = false
    @Published var resourceSources: [ResourceSource] = MockData.sources
    @Published var graphConcepts: [ConceptNode] = MockData.graphConceptNodes
    @Published var conceptEdges: [ConceptEdge] = MockData.conceptEdges
    @Published var cardLineages: [CardLineage] = MockData.cardLineages

    let cards: [Card] = MockData.cards
    let practiceQuestions: [PracticeQuestion] = MockData.practiceQuestions
    let practiceSections = ["Biology/Biochemistry", "Chemistry/Physics", "Psychology/Sociology", "CARS"]

    var decks: [Deck] {
        studyDecks.map {
            Deck(name: $0.name, description: $0.description, cardCount: $0.cardCount, dueToday: dueCount(forDeckNamed: $0.name), mastery: $0.mastery, accentColor: $0.accentColor, concepts: [])
        }
    }

    init() {
        isAppNavigationVisible = UserDefaults.standard.object(forKey: LayoutDefaults.appNavigationVisible) as? Bool ?? true
        isContextPanelVisible = UserDefaults.standard.object(forKey: LayoutDefaults.contextPanelVisible) as? Bool ?? true
        isRightInspectorVisible = UserDefaults.standard.object(forKey: LayoutDefaults.rightInspectorVisible) as? Bool ?? true

        let seedData = RecallDataStore.shared.loadRuntimeData()
        resourceSources = seedData.sources
        graphConcepts = seedData.concepts
        conceptEdges = seedData.edges
        cardLineages = seedData.lineages
        studyFolders = seedData.folders
        studyDecks = seedData.decks
        studyCards = seedData.cards
        stats = seedData.stats

        var loadedPersistedStats = false

        if let persisted = LocalDataStore.shared.load(), RecallDataStore.shared.isPDFSeedData(persisted) {
            studyFolders = persisted.folders.map(\.model)
            studyDecks = persisted.decks.map(\.model)
            studyCards = persisted.cards.map(\.model)
            reviewHistory = persisted.reviewHistory.map(\.model)
            practiceResults = persisted.practiceResults.map(\.model)
            if let persistedStats = persisted.stats?.model {
                stats = persistedStats
                loadedPersistedStats = true
            }
        } else {
            persist()
        }

        selectedStudyFolder = studyFolders.first
        selectedStudyDeck = studyDecks.first
        selectedDeck = decks.first ?? MockData.decks[0]
        selectedGraphConcept = graphConcepts.first ?? selectedGraphConcept
        if !loadedPersistedStats {
            stats = recalculatedStats()
        }
    }

    var currentStudyCard: StudyCard {
        dueStudyCards.isEmpty ? studyCards[currentCardIndex % studyCards.count] : dueStudyCards[currentCardIndex % dueStudyCards.count]
    }

    var currentCard: Card {
        cards[currentCardIndex % cards.count]
    }

    var dueStudyCards: [StudyCard] {
        studyCards.filter { Calendar.current.startOfDay(for: $0.dueDate) <= Calendar.current.startOfDay(for: Date()) }
    }

    var filteredPracticeQuestions: [PracticeQuestion] {
        practiceQuestions.filter { $0.section == selectedPracticeSection }
    }

    var currentPracticeQuestion: PracticeQuestion {
        let questions = filteredPracticeQuestions.isEmpty ? practiceQuestions : filteredPracticeQuestions
        return questions[currentPracticeIndex % questions.count]
    }

    var practiceProgressText: String {
        let count = max(filteredPracticeQuestions.count, 1)
        return "Question \((currentPracticeIndex % count) + 1) of \(count)"
    }

    var currentPracticeFollowUpSuggestion: String {
        followUpSuggestion(for: practiceMissReason)
    }

    var practiceAccuracyBySection: [(section: String, accuracy: Double, completed: Int)] {
        practiceSections.map { section in
            let results = practiceResults.filter { $0.section == section }
            let correct = results.filter(\.isCorrect).count
            let accuracy = results.isEmpty ? 0 : Double(correct) / Double(results.count)
            return (section, accuracy, results.count)
        }
    }

    var contentVsApplication: (content: Double, application: Double) {
        let content = Double(overallRetention) / 100
        let applicationResults = practiceResults
        let correct = applicationResults.filter(\.isCorrect).count
        let application = applicationResults.isEmpty ? 0 : Double(correct) / Double(applicationResults.count)
        return (content, application)
    }

    var applicationWeaknesses: [String] {
        practiceAccuracyBySection
            .sorted { $0.accuracy < $1.accuracy }
            .prefix(3)
            .map { $0.section }
    }

    var missedQuestionPatterns: [(reason: MissReason, count: Int)] {
        let grouped = Dictionary(grouping: practiceResults.compactMap(\.missReason), by: { $0 })
        return MissReason.allCases.map { ($0, grouped[$0]?.count ?? 0) }
    }

    var reviewProgressText: String {
        let count = max(dueStudyCards.count, 1)
        return "Card \((currentCardIndex % count) + 1) of \(count)"
    }

    var reviewProgress: Double {
        let count = max(dueStudyCards.count, 1)
        return Double((currentCardIndex % count) + 1) / Double(count)
    }

    var filteredStudyDecks: [StudyDeck] {
        guard let selectedStudyFolder else { return [] }

        return studyDecks.filter { deck in
            let matchesFolder = deck.folderName == selectedStudyFolder.name
            let matchesSearch = librarySearchText.isEmpty || deck.name.localizedCaseInsensitiveContains(librarySearchText) || deck.description.localizedCaseInsensitiveContains(librarySearchText) || deck.tags.contains { $0.localizedCaseInsensitiveContains(librarySearchText) }
            let matchesFilter: Bool

            switch selectedLibraryFilter {
            case .all:
                matchesFilter = true
            case .dueToday:
                matchesFilter = deck.dueToday > 0
            case .weakConcepts:
                matchesFilter = deck.hasWeakConcepts
            case .textbookSources:
                matchesFilter = deck.sources.contains { $0.type == .pdfImport || $0.type == .kaplan }
            case .community:
                matchesFilter = deck.sources.contains { $0.type == .communityDataset }
            case .company:
                matchesFilter = deck.sources.contains { $0.type == .aamcFullLength }
            }

            return matchesFolder && matchesSearch && matchesFilter
        }
    }

    var overallRetention: Int {
        guard !studyCards.isEmpty else { return 0 }
        let average = studyCards.map(\.retentionScore).reduce(0, +) / Double(studyCards.count)
        return Int(average * 100)
    }

    var confidenceAverage: Double {
        guard !studyCards.isEmpty else { return 0 }
        return Double(studyCards.map(\.confidenceRating).reduce(0, +)) / Double(studyCards.count)
    }

    var weakestSection: String {
        sectionRetention.sorted { $0.value < $1.value }.first?.key ?? "Biology"
    }

    var recommendedFocus: String {
        weakestConcepts.first?.name ?? "Maintain today’s due cards"
    }

    var weakestConcepts: [ConceptNode] {
        graphConcepts.sorted {
            if $0.mastery == $1.mastery {
                return $0.missedCards > $1.missedCards
            }
            return $0.mastery < $1.mastery
        }
    }

    var sectionRetention: [String: Double] {
        Dictionary(grouping: studyCards, by: \.section).mapValues { cards in
            cards.map(\.retentionScore).reduce(0, +) / Double(cards.count)
        }
    }

    var missReasonBreakdown: [(reason: MissReason, count: Int)] {
        let runtime = reviewHistory.compactMap(\.missReason)
        let stored = studyCards.compactMap(\.missReason)
        let grouped = Dictionary(grouping: runtime + stored, by: { $0 })
        return MissReason.allCases.map { ($0, grouped[$0]?.count ?? 0) }
    }

    var tomorrowForecast: Int {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return cardsDue(on: tomorrow)
    }

    var nextSevenDaysForecast: Int {
        (1...7).reduce(0) { total, offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
            return total + cardsDue(on: date)
        }
    }

    var fullLengthReviewCards: [StudyCard] {
        studyCards.filter { $0.linkedFullLengthExamNumber != nil }
    }

    var filteredGraphConcepts: [ConceptNode] {
        graphConcepts.filter { concept in
            let matchesSection = selectedGraphSection.matches(concept)
            let matchesSearch = graphSearchText.isEmpty || concept.name.localizedCaseInsensitiveContains(graphSearchText) || concept.description.localizedCaseInsensitiveContains(graphSearchText)
            let matchesWeakFocus = !isFocusingWeakGraphConcepts || concept.mastery < 0.7 || concept.weakCount > 0
            return matchesSection && matchesSearch && matchesWeakFocus
        }
    }

    var relatedGraphConcepts: [ConceptNode] {
        relatedConcepts(for: selectedGraphConcept, onlyTestedTogether: isShowingOnlyTestedTogetherEdges)
    }

    var semanticSearchResults: [SemanticSearchResult] {
        semanticSearchResults(for: semanticSearchText)
    }

    func selectDeck(_ deck: Deck) {
        selectedDeck = deck
        selectedScreen = .review
        currentCardIndex = 0
        isShowingAnswer = false
        isShowingReflection = false
    }

    func selectStudyFolder(_ folder: StudyFolder) {
        selectedStudyFolder = folder
        selectedStudyDeck = filteredStudyDecks.first ?? studyDecks.first { $0.folderName == folder.name }
    }

    func selectLibraryFilter(_ filter: LibraryFilter) {
        selectedLibraryFilter = filter
        selectedStudyDeck = filteredStudyDecks.first
    }

    func selectGraphConcept(_ concept: ConceptNode) {
        selectedGraphConcept = concept
        selectedScreen = .graph
    }

    func relatedConcepts(for concept: ConceptNode, onlyTestedTogether: Bool = false) -> [ConceptNode] {
        let linkedIDs = Set(conceptEdges.compactMap { edge -> UUID? in
            if onlyTestedTogether && edge.relationshipType != .testedTogether { return nil }
            if edge.fromConceptID == concept.id { return edge.toConceptID }
            if edge.toConceptID == concept.id { return edge.fromConceptID }
            return nil
        })
        return graphConcepts.filter { linkedIDs.contains($0.id) }
    }

    func edges(for concept: ConceptNode, onlyTestedTogether: Bool = false) -> [ConceptEdge] {
        conceptEdges.filter { edge in
            let isLinked = edge.fromConceptID == concept.id || edge.toConceptID == concept.id
            let matchesType = !onlyTestedTogether || edge.relationshipType == .testedTogether
            return isLinked && matchesType
        }
    }

    func lineage(for card: StudyCard) -> CardLineage {
        cardLineages.first { $0.cardID == card.id } ?? CardLineage(
            cardID: card.id,
            createdFrom: card.createdFrom,
            sourceName: card.sourceReferenceText,
            parentQuestionID: nil,
            parentCardID: nil,
            createdDate: card.lastReviewedDate,
            revisionHistory: []
        )
    }

    func semanticSearchResults(for query: String) -> [SemanticSearchResult] {
        let terms = query
            .lowercased()
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }

        guard !terms.isEmpty else {
            return MockData.featuredSemanticSearchResults
        }

        var results: [SemanticSearchResult] = []

        for concept in graphConcepts {
            let text = [concept.name, concept.description, concept.section].joined(separator: " ").lowercased()
            let matched = terms.filter { text.contains($0) }
            if !matched.isEmpty {
                let exactBoost = terms.contains(concept.name.lowercased()) ? 0.35 : 0
                results.append(SemanticSearchResult(
                    type: .concept,
                    title: concept.name,
                    subtitle: concept.description,
                    relevanceScore: min(1.0, 0.58 + exactBoost + Double(matched.count) * 0.08),
                    matchedTerms: matched,
                    relatedConcepts: relatedConcepts(for: concept).map(\.name)
                ))
            }
        }

        for card in studyCards {
            let conceptNames = card.concepts.map(\.name)
            let text = ([card.front, card.back, card.deckName, card.section] + card.tags + conceptNames).joined(separator: " ").lowercased()
            let matched = terms.filter { text.contains($0) }
            if !matched.isEmpty {
                results.append(SemanticSearchResult(
                    type: .card,
                    title: card.front,
                    subtitle: "\(card.deckName) card",
                    relevanceScore: min(1.0, 0.48 + Double(matched.count) * 0.1),
                    matchedTerms: matched,
                    relatedConcepts: conceptNames
                ))
            }
        }

        for deck in studyDecks {
            let conceptNames = deck.linkedConcepts.map(\.name)
            let text = ([deck.name, deck.description] + deck.tags + conceptNames).joined(separator: " ").lowercased()
            let matched = terms.filter { text.contains($0) }
            if !matched.isEmpty {
                results.append(SemanticSearchResult(
                    type: .deck,
                    title: deck.name,
                    subtitle: "\(deck.cardCount) cards, \(deck.linkedConcepts.count) concepts",
                    relevanceScore: min(1.0, 0.42 + Double(matched.count) * 0.09),
                    matchedTerms: matched,
                    relatedConcepts: conceptNames
                ))
            }
        }

        for source in resourceSources {
            let sourceCards = studyCards.filter { $0.source.title == source.title || $0.source.id == source.id }
            let sourceConceptNames = sourceCards.flatMap { $0.concepts.map(\.name) }
            let sourceCardText = sourceCards.flatMap { [$0.front, $0.back, $0.deckName] + $0.tags + $0.concepts.map(\.name) }
            let text = ([source.title, source.type.rawValue] + sourceCardText).joined(separator: " ").lowercased()
            let matched = terms.filter { text.contains($0) }
            if !matched.isEmpty {
                let relatedConcepts = graphConcepts.filter { concept in
                    sourceConceptNames.contains(concept.name) || studyCards.contains { $0.source.id == source.id && $0.linkedConceptIDs.contains(concept.id) }
                }
                results.append(SemanticSearchResult(
                    type: .source,
                    title: source.title,
                    subtitle: source.type.rawValue,
                    relevanceScore: min(1.0, 0.44 + Double(matched.count) * 0.1),
                    matchedTerms: matched,
                    relatedConcepts: relatedConcepts.map(\.name)
                ))
            }
        }

        return results.sorted { $0.relevanceScore > $1.relevanceScore }
    }

    func showAnswer() {
        guard !isShowingAnswer && !isShowingReflection else { return }
        isShowingAnswer = true
    }

    func toggleReviewFocusMode() {
        isReviewFocusMode.toggle()
    }

    func toggleAppNavigation() {
        isAppNavigationVisible.toggle()
    }

    func toggleContextPanel() {
        isContextPanelVisible.toggle()
    }

    func toggleRightInspector() {
        isRightInspectorVisible.toggle()
    }

    func toggleFocusMode() {
        switch selectedScreen {
        case .review:
            isReviewFocusMode.toggle()
        case .practice:
            isPracticeFocusMode.toggle()
        case .graph:
            isGraphFocusMode.toggle()
        default:
            isAppNavigationVisible.toggle()
        }
    }

    var isCurrentScreenFocused: Bool {
        switch selectedScreen {
        case .review:
            return isReviewFocusMode
        case .practice:
            return isPracticeFocusMode
        case .graph:
            return isGraphFocusMode
        default:
            return false
        }
    }

    func rateCurrentCard(_ rating: ReviewRating) {
        guard isShowingAnswer && !isShowingReflection else { return }
        pendingRating = rating
        selectedMissReason = rating == .again || rating == .hard ? .forgotContent : .carelessMistake
        selectedCorrectReflection = rating == .easy ? .understood : .shaky
        selectedConfidence = rating.defaultConfidence
        isShowingReflection = true
    }

    func selectPracticeSection(_ section: String) {
        selectedPracticeSection = section
        currentPracticeIndex = 0
        selectedPracticeAnswerIndex = nil
        isShowingPracticeResult = false
        practiceMissReason = .confusedConcepts
        practiceConfidence = 3
    }

    func selectPracticeAnswer(_ index: Int) {
        selectedPracticeAnswerIndex = index
        isShowingPracticeResult = true
        practiceMissReason = index == currentPracticeQuestion.correctAnswerIndex ? .carelessMistake : .confusedConcepts
        practiceConfidence = index == currentPracticeQuestion.correctAnswerIndex ? 4 : 2
    }

    func savePracticeReflectionAndAdvance() {
        guard let selectedPracticeAnswerIndex else { return }
        let question = currentPracticeQuestion
        let missReason = selectedPracticeAnswerIndex == question.correctAnswerIndex ? nil : practiceMissReason
        let suggestion = followUpSuggestion(for: practiceMissReason)

        practiceResults.insert(
            PracticeResult(
                questionID: question.id,
                section: question.section,
                selectedAnswerIndex: selectedPracticeAnswerIndex,
                correctAnswerIndex: question.correctAnswerIndex,
                missReason: missReason,
                confidence: practiceConfidence,
                followUpSuggestion: suggestion,
                completedAt: Date()
            ),
            at: 0
        )

        let count = max(filteredPracticeQuestions.count, 1)
        currentPracticeIndex = (currentPracticeIndex + 1) % count
        self.selectedPracticeAnswerIndex = nil
        isShowingPracticeResult = false
        practiceMissReason = .confusedConcepts
        practiceConfidence = 3
        persist()
    }

    func followUpSuggestion(for reason: MissReason) -> String {
        switch reason {
        case .didNotKnowContent:
            return "Suggest a content recall card before another application question."
        case .forgotContent:
            return "Schedule a spaced review for the tested concept."
        case .confusedConcepts:
            return "Generate a concept comparison question to separate the two ideas."
        case .misreadQuestion:
            return "Assign a CARS-style reasoning drill focused on wording and scope."
        case .carelessMistake:
            return "Add a timing/checklist reminder before the next mini-set."
        case .timingIssue:
            return "Suggest a timed mini-set with 3 related questions."
        }
    }

    func saveReflectionAndAdvance() {
        guard let pendingRating else { return }

        let card = currentStudyCard
        let schedule = fsrsLiteSchedule(for: card, rating: pendingRating)
        let previousDueDate = card.dueDate
        let interval = schedule.intervalDays
        let nextDueDate = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
        let adjustedEase = max(1.3, card.easeFactor + pendingRating.easeAdjustment)
        let adjustedRetention = max(0.0, min(1.0, card.retentionScore + pendingRating.retentionAdjustment))
        let missReason = pendingRating == .again || pendingRating == .hard ? selectedMissReason : nil
        let reflectionReason = missReason?.rawValue ?? selectedCorrectReflection.rawValue

        if let index = studyCards.firstIndex(where: { $0.id == card.id }) {
            studyCards[index].dueDate = nextDueDate
            studyCards[index].lastReviewedDate = Date()
            studyCards[index].reviewIntervalDays = interval
            studyCards[index].stability = schedule.stability
            studyCards[index].fsrsDifficulty = schedule.difficulty
            studyCards[index].retrievability = schedule.retrievability
            studyCards[index].reviewCount += 1
            studyCards[index].easeFactor = adjustedEase
            studyCards[index].retentionScore = adjustedRetention
            studyCards[index].confidenceRating = selectedConfidence
            studyCards[index].missReason = missReason
        }

        reviewHistory.insert(
            ReviewResult(
                cardID: card.id,
                deckName: card.deckName,
                section: card.section,
                rating: pendingRating,
                missReason: missReason,
                confidence: selectedConfidence,
                reviewedAt: Date(),
                previousDueDate: previousDueDate,
                nextDueDate: nextDueDate,
                intervalDays: interval,
                reflectionReason: reflectionReason,
                linkedFullLengthExamNumber: card.linkedFullLengthExamNumber
            ),
            at: 0
        )

        let completed = min(stats.completedToday + 1, stats.cardsDueToday)
        stats = ReviewStats(
            cardsDueToday: stats.cardsDueToday,
            completedToday: completed,
            retentionPercentage: overallRetention,
            streakDays: stats.streakDays,
            totalCards: stats.totalCards,
            masteredConcepts: stats.masteredConcepts
        )

        currentCardIndex = (currentCardIndex + 1) % max(dueStudyCards.count, 1)
        isShowingAnswer = false
        isShowingReflection = false
        self.pendingRating = nil
        stats = recalculatedStats()
        persist()
    }

    func addCard(deckName: String, section: String, front: String, back: String, tags: [String]) {
        let concepts = graphConcepts.filter { $0.section == section }.prefix(1)
        let source = resourceSources.first { $0.type == .userCreated } ?? ResourceSource(title: "User Created", type: .userCreated)
        let card = StudyCard(
            deckName: deckName,
            section: section,
            front: front,
            back: back,
            cardType: .basic,
            difficulty: .medium,
            dueDate: Date(),
            lastReviewedDate: Date(),
            reviewIntervalDays: 0,
            stability: 2.5,
            fsrsDifficulty: 5.0,
            retrievability: 0.9,
            reviewCount: 0,
            easeFactor: 2.3,
            retentionScore: 0.5,
            confidenceRating: 3,
            missReason: nil,
            tags: tags,
            concepts: Array(concepts),
            source: source,
            sourcePage: nil,
            sourceSectionTitle: nil,
            createdFrom: .userCreated,
            linkedConceptIDs: concepts.map(\.id),
            linkedFullLengthExamNumber: nil
        )
        studyCards.insert(card, at: 0)
        refreshDeckCounts()
        persist()
    }

    func updateCard(_ card: StudyCard, front: String, back: String, tags: [String]) {
        guard let index = studyCards.firstIndex(where: { $0.id == card.id }) else { return }
        studyCards[index].front = front
        studyCards[index].back = back
        studyCards[index].tags = tags
        persist()
    }

    func deleteCard(_ card: StudyCard) {
        studyCards.removeAll { $0.id == card.id }
        refreshDeckCounts()
        persist()
    }

    func exportSelectedDeckToJSON() -> String {
        guard let selectedStudyDeck else { return "Select a deck to export" }
        let cards = studyCards.filter { $0.deckName == selectedStudyDeck.name }
        return LocalDataStore.shared.exportDeck(selectedStudyDeck, cards: cards)?.path ?? "Export failed"
    }

    func importDeckFromJSON() -> String {
        guard let package = LocalDataStore.shared.importDeckPackage() else {
            return "No selected deck export found in Documents"
        }

        studyDecks.removeAll { $0.id == package.deck.id || $0.name == package.deck.name }
        studyDecks.insert(package.deck, at: 0)
        studyCards.removeAll { $0.deckName == package.deck.name }
        studyCards.insert(contentsOf: package.cards, at: 0)
        selectedStudyDeck = package.deck
        selectedDeck = decks.first ?? selectedDeck
        refreshDeckCounts()
        persist()
        return "Imported \(package.deck.name) with \(package.cards.count) cards"
    }

    private func persist() {
        LocalDataStore.shared.save(
            folders: studyFolders,
            decks: studyDecks,
            cards: studyCards,
            reviewHistory: reviewHistory,
            practiceResults: practiceResults,
            stats: stats
        )
    }

    private func fsrsLiteSchedule(for card: StudyCard, rating: ReviewRating) -> (stability: Double, difficulty: Double, retrievability: Double, intervalDays: Int) {
        let nextDifficulty = min(10, max(1, card.fsrsDifficulty + rating.fsrsDifficultyAdjustment))
        let nextStability = max(0.1, card.stability * rating.stabilityMultiplier)
        let nextRetrievability = min(0.99, max(0.1, card.retrievability + rating.retrievabilityAdjustment))
        let interval: Int

        switch rating {
        case .again:
            interval = 0
        case .hard:
            interval = max(1, Int(nextStability.rounded(.down)))
        case .good:
            interval = max(2, Int((nextStability * 1.8).rounded()))
        case .easy:
            interval = max(4, Int((nextStability * 2.8).rounded()))
        }

        return (nextStability, nextDifficulty, nextRetrievability, interval)
    }

    private func refreshDeckCounts() {
        studyDecks = studyDecks.map { deck in
            let cards = studyCards.filter { $0.deckName == deck.name }
            let due = cards.filter { Calendar.current.startOfDay(for: $0.dueDate) <= Calendar.current.startOfDay(for: Date()) }.count
            let mastery = cards.isEmpty ? deck.mastery : cards.map(\.retentionScore).reduce(0, +) / Double(cards.count)
            return StudyDeck(id: deck.id, folderName: deck.folderName, name: deck.name, description: deck.description, cardCount: cards.count, dueToday: due, mastery: mastery, tags: deck.tags, linkedConcepts: deck.linkedConcepts, sources: deck.sources, lastStudied: deck.lastStudied, accentColor: deck.accentColor)
        }
    }

    private func recalculatedStats() -> ReviewStats {
        ReviewStats(
            cardsDueToday: dueStudyCards.count,
            completedToday: reviewHistory.filter { Calendar.current.isDateInToday($0.reviewedAt) }.count,
            retentionPercentage: overallRetention,
            streakDays: stats.streakDays,
            totalCards: studyCards.count,
            masteredConcepts: graphConcepts.filter { $0.mastery >= 0.75 }.count
        )
    }

    private func dueCount(forDeckNamed name: String) -> Int {
        studyCards.filter { $0.deckName == name && Calendar.current.startOfDay(for: $0.dueDate) <= Calendar.current.startOfDay(for: Date()) }.count
    }

    private func cardsDue(on date: Date) -> Int {
        let target = Calendar.current.startOfDay(for: date)
        return studyCards.filter { Calendar.current.startOfDay(for: $0.dueDate) == target }.count
    }
}

enum ReviewRating: String, CaseIterable, Identifiable {
    case again = "Again"
    case hard = "Hard"
    case good = "Good"
    case easy = "Easy"

    var id: String { rawValue }

    var tint: Color {
        switch self {
        case .again:
            return .red
        case .hard:
            return .orange
        case .good:
            return .blue
        case .easy:
            return .green
        }
    }

    var intervalDays: Int {
        switch self {
        case .again:
            return 0
        case .hard:
            return 1
        case .good:
            return 3
        case .easy:
            return 7
        }
    }

    var stabilityMultiplier: Double {
        switch self {
        case .again:
            return 0.35
        case .hard:
            return 0.85
        case .good:
            return 1.65
        case .easy:
            return 2.35
        }
    }

    var fsrsDifficultyAdjustment: Double {
        switch self {
        case .again:
            return 0.8
        case .hard:
            return 0.35
        case .good:
            return -0.05
        case .easy:
            return -0.25
        }
    }

    var retrievabilityAdjustment: Double {
        switch self {
        case .again:
            return -0.35
        case .hard:
            return -0.12
        case .good:
            return 0.05
        case .easy:
            return 0.12
        }
    }

    var easeAdjustment: Double {
        switch self {
        case .again:
            return -0.2
        case .hard:
            return -0.08
        case .good:
            return 0
        case .easy:
            return 0.12
        }
    }

    var retentionAdjustment: Double {
        switch self {
        case .again:
            return -0.08
        case .hard:
            return -0.03
        case .good:
            return 0.02
        case .easy:
            return 0.04
        }
    }

    var defaultConfidence: Int {
        switch self {
        case .again:
            return 1
        case .hard:
            return 2
        case .good:
            return 4
        case .easy:
            return 5
        }
    }
}

enum DateFormatters {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

import SwiftUI

enum MockData {
    private static let today = Date()

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: today) ?? today
    }

    private static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: today) ?? today
    }

    static let sources = [
        ResourceSource(title: "Kaplan Biology Review", type: .kaplan),
        ResourceSource(title: "Kaplan Biochemistry Review", type: .kaplan),
        ResourceSource(title: "UWorld-style Practice Set", type: .practice),
        ResourceSource(title: "AAMC Full-Length 3", type: .aamcFullLength),
        ResourceSource(title: "Jack Westin CARS Passage", type: .jackWestin),
        ResourceSource(title: "User Missed Question Notes", type: .userCreated),
        ResourceSource(title: "MCAT Community Dataset", type: .communityDataset)
    ]

    static let conceptNodes = [
        ConceptNode(name: "Cell Signaling", section: "Biology", summary: "Receptors, second messengers, and pathway regulation.", mastery: 0.68, missedCards: 7, lastReviewed: daysAgo(1), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Endocrine System", section: "Biology", summary: "Hormones, feedback loops, and target tissue responses.", mastery: 0.74, missedCards: 4, lastReviewed: daysAgo(3), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Nervous System", section: "Biology", summary: "Neurons, action potentials, synapses, and sensory systems.", mastery: 0.71, missedCards: 5, lastReviewed: daysAgo(2), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Genetics", section: "Biology", summary: "Inheritance, gene expression, and molecular genetics.", mastery: 0.79, missedCards: 3, lastReviewed: daysAgo(5), recommendedAction: .restMaintain),
        ConceptNode(name: "Metabolism", section: "Biology", summary: "Energy pathways and regulation across tissues.", mastery: 0.65, missedCards: 8, lastReviewed: daysAgo(1), recommendedAction: .rewatchContent),
        ConceptNode(name: "Enzyme Kinetics", section: "Biochemistry", summary: "Michaelis-Menten behavior, inhibition, and catalytic efficiency.", mastery: 0.62, missedCards: 9, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Amino Acids", section: "Biochemistry", summary: "Side chains, polarity, charge, and one-letter codes.", mastery: 0.76, missedCards: 4, lastReviewed: daysAgo(2), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Protein Structure", section: "Biochemistry", summary: "Primary through quaternary structure and stabilizing forces.", mastery: 0.72, missedCards: 5, lastReviewed: daysAgo(4), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Glycolysis", section: "Biochemistry", summary: "Rate-limiting steps, net yield, and regulatory enzymes.", mastery: 0.67, missedCards: 6, lastReviewed: daysAgo(2), recommendedAction: .rewatchContent),
        ConceptNode(name: "Citric Acid Cycle", section: "Biochemistry", summary: "Inputs, outputs, irreversible steps, and regulation.", mastery: 0.70, missedCards: 5, lastReviewed: daysAgo(5), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Acids and Bases", section: "General Chemistry", summary: "pH, buffers, titrations, and Henderson-Hasselbalch.", mastery: 0.64, missedCards: 8, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Thermodynamics", section: "General Chemistry", summary: "Enthalpy, entropy, Gibbs free energy, and spontaneity.", mastery: 0.73, missedCards: 4, lastReviewed: daysAgo(6), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Equilibrium", section: "General Chemistry", summary: "Le Chatelier, equilibrium constants, and reaction quotients.", mastery: 0.69, missedCards: 6, lastReviewed: daysAgo(3), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Electrochemistry", section: "General Chemistry", summary: "Galvanic cells, reduction potentials, and Nernst equation.", mastery: 0.66, missedCards: 7, lastReviewed: daysAgo(2), recommendedAction: .rewatchContent),
        ConceptNode(name: "Functional Groups", section: "Organic Chemistry", summary: "Identification, properties, and reactivity patterns.", mastery: 0.78, missedCards: 3, lastReviewed: daysAgo(4), recommendedAction: .restMaintain),
        ConceptNode(name: "Stereochemistry", section: "Organic Chemistry", summary: "Chirality, R/S, enantiomers, and diastereomers.", mastery: 0.63, missedCards: 8, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Carbonyl Chemistry", section: "Organic Chemistry", summary: "Nucleophilic addition, derivatives, and reaction conditions.", mastery: 0.67, missedCards: 6, lastReviewed: daysAgo(2), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Substitution / Elimination", section: "Organic Chemistry", summary: "SN1/SN2/E1/E2 mechanisms and competition.", mastery: 0.61, missedCards: 10, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Fluids", section: "Physics", summary: "Pressure, buoyancy, continuity, and Bernoulli behavior.", mastery: 0.58, missedCards: 11, lastReviewed: daysAgo(1), recommendedAction: .rewatchContent),
        ConceptNode(name: "Circuits", section: "Physics", summary: "Voltage, current, resistance, capacitors, and power.", mastery: 0.70, missedCards: 5, lastReviewed: daysAgo(3), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Optics", section: "Physics", summary: "Lenses, mirrors, refraction, and image formation.", mastery: 0.72, missedCards: 4, lastReviewed: daysAgo(5), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Work and Energy", section: "Physics", summary: "Mechanical energy, conservation, and work-energy theorem.", mastery: 0.75, missedCards: 3, lastReviewed: daysAgo(4), recommendedAction: .restMaintain),
        ConceptNode(name: "Learning and Memory", section: "Psychology / Sociology", summary: "Conditioning, reinforcement, memory systems, and recall.", mastery: 0.77, missedCards: 4, lastReviewed: daysAgo(2), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Social Stratification", section: "Psychology / Sociology", summary: "Class, mobility, inequality, and social structure.", mastery: 0.69, missedCards: 5, lastReviewed: daysAgo(3), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Research Methods", section: "Psychology / Sociology", summary: "Study design, validity, reliability, and interpretation.", mastery: 0.73, missedCards: 4, lastReviewed: daysAgo(5), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Identity", section: "Psychology / Sociology", summary: "Self-concept, social identity, and development.", mastery: 0.81, missedCards: 2, lastReviewed: daysAgo(7), recommendedAction: .restMaintain),
        ConceptNode(name: "Main Idea", section: "CARS", summary: "Central thesis, passage structure, and global purpose.", mastery: 0.62, missedCards: 9, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Author Tone", section: "CARS", summary: "Attitude, stance, and rhetorical posture.", mastery: 0.71, missedCards: 4, lastReviewed: daysAgo(2), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Inference", section: "CARS", summary: "Supported conclusions beyond explicitly stated claims.", mastery: 0.65, missedCards: 8, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Passage Mapping", section: "CARS", summary: "Paragraph roles, argument flow, and evidence location.", mastery: 0.68, missedCards: 6, lastReviewed: daysAgo(3), recommendedAction: .practiceQuestions)
    ]

    private static let graphOnlyConceptNodes = [
        ConceptNode(name: "GPCR", section: "Biology", description: "G protein-coupled receptors that activate second messenger pathways.", mastery: 0.66, weakCount: 5, lastReviewed: daysAgo(1), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Phospholipase C", section: "Biology", description: "Membrane enzyme that cleaves PIP2 into DAG and IP3.", mastery: 0.61, weakCount: 6, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions),
        ConceptNode(name: "IP3", section: "Biology", description: "Second messenger that opens ER calcium channels after PLC activation.", mastery: 0.58, weakCount: 8, lastReviewed: daysAgo(1), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Calcium Signaling", section: "Biology", description: "Intracellular calcium changes that alter enzyme activity, secretion, or contraction.", mastery: 0.63, weakCount: 7, lastReviewed: daysAgo(2), recommendedAction: .practiceQuestions),
        ConceptNode(name: "Signal Transduction", section: "Biology", description: "Conversion of receptor activation into intracellular response.", mastery: 0.69, weakCount: 4, lastReviewed: daysAgo(2), recommendedAction: .reviewConceptCards),
        ConceptNode(name: "Michaelis-Menten", section: "Biochemistry", description: "Model connecting substrate concentration, Vmax, and Km.", mastery: 0.60, weakCount: 7, lastReviewed: daysAgo(1), recommendedAction: .practiceQuestions)
    ]

    static let graphConceptNodes = conceptNodes + graphOnlyConceptNodes

    static let conceptEdges: [ConceptEdge] = {
        func concept(_ name: String) -> ConceptNode {
            graphConceptNodes.first { $0.name == name } ?? graphConceptNodes[0]
        }

        return [
            ConceptEdge(fromConceptID: concept("GPCR").id, toConceptID: concept("Phospholipase C").id, relationshipType: .activates, strength: 0.92),
            ConceptEdge(fromConceptID: concept("Phospholipase C").id, toConceptID: concept("IP3").id, relationshipType: .produces, strength: 0.95),
            ConceptEdge(fromConceptID: concept("IP3").id, toConceptID: concept("Calcium Signaling").id, relationshipType: .triggers, strength: 0.88),
            ConceptEdge(fromConceptID: concept("Cell Signaling").id, toConceptID: concept("Endocrine System").id, relationshipType: .testedTogether, strength: 0.78),
            ConceptEdge(fromConceptID: concept("Cell Signaling").id, toConceptID: concept("Signal Transduction").id, relationshipType: .related, strength: 0.86),
            ConceptEdge(fromConceptID: concept("Cell Signaling").id, toConceptID: concept("GPCR").id, relationshipType: .applicationOf, strength: 0.81),
            ConceptEdge(fromConceptID: concept("Enzyme Kinetics").id, toConceptID: concept("Michaelis-Menten").id, relationshipType: .applicationOf, strength: 0.9),
            ConceptEdge(fromConceptID: concept("Acids and Bases").id, toConceptID: concept("Equilibrium").id, relationshipType: .confusedWith, strength: 0.62),
            ConceptEdge(fromConceptID: concept("Fluids").id, toConceptID: concept("Work and Energy").id, relationshipType: .testedTogether, strength: 0.55),
            ConceptEdge(fromConceptID: concept("Main Idea").id, toConceptID: concept("Inference").id, relationshipType: .prerequisite, strength: 0.67)
        ]
    }()

    static let concepts = conceptNodes.prefix(5).map {
        Concept(name: $0.name, summary: $0.summary, mastery: $0.mastery)
    }

    static let studyFolders = [
        StudyFolder(name: "MCAT", systemImage: "cross.case.fill", accentColor: .purple)
    ]

    static let studyDecks = [
        StudyDeck(folderName: "MCAT", name: "Biology", description: "Cell signaling, organ systems, genetics, and metabolism.", cardCount: 640, dueToday: 32, mastery: 0.70, tags: ["Bio/Biochem", "Content", "High Yield"], linkedConcepts: Array(conceptNodes[0...4]), sources: [sources[0], sources[2]], lastStudied: "Today", accentColor: .purple),
        StudyDeck(folderName: "MCAT", name: "Biochemistry", description: "Amino acids, enzymes, proteins, glycolysis, and TCA cycle.", cardCount: 520, dueToday: 28, mastery: 0.68, tags: ["Bio/Biochem", "Pathways", "Enzymes"], linkedConcepts: Array(conceptNodes[5...9]), sources: [sources[1], sources[2]], lastStudied: "Today", accentColor: .indigo),
        StudyDeck(folderName: "MCAT", name: "General Chemistry", description: "Acids and bases, equilibrium, thermodynamics, and electrochemistry.", cardCount: 430, dueToday: 24, mastery: 0.67, tags: ["Chem/Phys", "Equations", "Practice"], linkedConcepts: Array(conceptNodes[10...13]), sources: [sources[0], sources[2]], lastStudied: "Yesterday", accentColor: .blue),
        StudyDeck(folderName: "MCAT", name: "Organic Chemistry", description: "Functional groups, stereochemistry, carbonyls, and mechanisms.", cardCount: 360, dueToday: 19, mastery: 0.66, tags: ["Chem/Phys", "Mechanisms", "Reactions"], linkedConcepts: Array(conceptNodes[14...17]), sources: [sources[0], sources[6]], lastStudied: "2 days ago", accentColor: .cyan),
        StudyDeck(folderName: "MCAT", name: "Physics", description: "Fluids, circuits, optics, work, energy, and MCAT math shortcuts.", cardCount: 390, dueToday: 26, mastery: 0.64, tags: ["Chem/Phys", "Equations", "Weak"], linkedConcepts: Array(conceptNodes[18...21]), sources: [sources[0], sources[2]], lastStudied: "Today", accentColor: .mint),
        StudyDeck(folderName: "MCAT", name: "Psychology / Sociology", description: "Learning, memory, identity, stratification, and research methods.", cardCount: 500, dueToday: 21, mastery: 0.74, tags: ["Psych/Soc", "Terms", "Recall"], linkedConcepts: Array(conceptNodes[22...25]), sources: [sources[0], sources[6]], lastStudied: "Yesterday", accentColor: .pink),
        StudyDeck(folderName: "MCAT", name: "CARS", description: "Main idea, tone, inference, passage mapping, and timing errors.", cardCount: 300, dueToday: 18, mastery: 0.66, tags: ["CARS", "Passages", "Timing"], linkedConcepts: Array(conceptNodes[26...29]), sources: [sources[4], sources[5]], lastStudied: "Today", accentColor: .orange),
        StudyDeck(folderName: "MCAT", name: "Full-Length Review", description: "Cards created from missed AAMC full-length questions and post-exam review.", cardCount: 180, dueToday: 15, mastery: 0.61, tags: ["AAMC", "FL Review", "Mistakes"], linkedConcepts: [conceptNodes[5], conceptNodes[10], conceptNodes[18], conceptNodes[26]], sources: [sources[3], sources[5]], lastStudied: "Today", accentColor: .red)
    ]

    static let decks = studyDecks.map {
        Deck(name: $0.name, description: $0.description, cardCount: $0.cardCount, dueToday: $0.dueToday, mastery: $0.mastery, accentColor: $0.accentColor, concepts: [])
    }

    static let cards = [
        Card(deckName: "Biology", front: "What is the role of IP3 in phospholipase C signaling?", back: "IP3 diffuses through the cytosol and binds ER receptors, causing Ca2+ release.", relatedConcepts: [Concept(name: "Cell Signaling", summary: "Second messenger signaling.", mastery: 0.68)], difficulty: "Medium")
    ]

    static let studyCards = [
        StudyCard(deckName: "Biology", section: "Biology", front: "What is the role of IP3 in phospholipase C signaling?", back: "IP3 diffuses through the cytosol and binds receptors on the endoplasmic reticulum, causing Ca2+ release.", difficulty: .medium, dueDate: today, lastReviewedDate: daysAgo(2), reviewIntervalDays: 1, easeFactor: 2.3, retentionScore: 0.72, confidenceRating: 3, missReason: .forgotContent, tags: ["Cell Signaling", "Second Messenger"], concepts: [conceptNodes[0]], source: sources[0], linkedConceptIDs: [conceptNodes[0].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "Biology", section: "Biology", front: "How does negative feedback regulate endocrine hormone levels?", back: "A downstream response inhibits earlier hormone release, stabilizing the system around a set point.", difficulty: .easy, dueDate: today, lastReviewedDate: daysAgo(3), reviewIntervalDays: 3, easeFactor: 2.5, retentionScore: 0.80, confidenceRating: 4, missReason: nil, tags: ["Endocrine", "Feedback"], concepts: [conceptNodes[1]], source: sources[2], linkedConceptIDs: [conceptNodes[1].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "Biochemistry", section: "Biochemistry", front: "What does Km represent in Michaelis-Menten kinetics?", back: "Km is the substrate concentration at which the reaction rate is half of Vmax; lower Km usually means higher substrate affinity.", difficulty: .hard, dueDate: today, lastReviewedDate: daysAgo(1), reviewIntervalDays: 0, easeFactor: 2.0, retentionScore: 0.58, confidenceRating: 2, missReason: .confusedConcepts, tags: ["Enzymes", "Kinetics"], concepts: [conceptNodes[5]], source: sources[1], linkedConceptIDs: [conceptNodes[5].id], linkedFullLengthExamNumber: 3),
        StudyCard(deckName: "Biochemistry", section: "Biochemistry", front: "Which glycolysis enzyme catalyzes the committed step?", back: "Phosphofructokinase-1 catalyzes the committed and rate-limiting step of glycolysis.", difficulty: .medium, dueDate: today, lastReviewedDate: daysAgo(2), reviewIntervalDays: 1, easeFactor: 2.2, retentionScore: 0.66, confidenceRating: 3, missReason: .forgotContent, tags: ["Glycolysis", "Pathways"], concepts: [conceptNodes[8]], source: sources[2], linkedConceptIDs: [conceptNodes[8].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "General Chemistry", section: "General Chemistry", front: "When is the Henderson-Hasselbalch equation most useful?", back: "It is useful for estimating pH in buffer systems when weak acid and conjugate base concentrations are known.", difficulty: .medium, dueDate: today, lastReviewedDate: daysAgo(1), reviewIntervalDays: 1, easeFactor: 2.25, retentionScore: 0.63, confidenceRating: 2, missReason: .didNotKnowContent, tags: ["Acids/Bases", "Buffers"], concepts: [conceptNodes[10]], source: sources[0], linkedConceptIDs: [conceptNodes[10].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "General Chemistry", section: "General Chemistry", front: "What does a negative Gibbs free energy indicate?", back: "A negative delta G indicates a thermodynamically spontaneous process under the given conditions.", difficulty: .easy, dueDate: daysFromNow(1), lastReviewedDate: daysAgo(4), reviewIntervalDays: 3, easeFactor: 2.45, retentionScore: 0.76, confidenceRating: 4, missReason: nil, tags: ["Thermodynamics"], concepts: [conceptNodes[11]], source: sources[2], linkedConceptIDs: [conceptNodes[11].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "Organic Chemistry", section: "Organic Chemistry", front: "What favors an SN2 reaction mechanism?", back: "A strong nucleophile, polar aprotic solvent, and less hindered substrate favor backside attack in SN2 reactions.", difficulty: .hard, dueDate: today, lastReviewedDate: daysAgo(1), reviewIntervalDays: 0, easeFactor: 1.95, retentionScore: 0.57, confidenceRating: 2, missReason: .confusedConcepts, tags: ["SN2", "Mechanisms"], concepts: [conceptNodes[17]], source: sources[6], linkedConceptIDs: [conceptNodes[17].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "Physics", section: "Physics", front: "How does velocity change when fluid moves through a narrower tube?", back: "For an incompressible fluid, continuity requires velocity to increase when cross-sectional area decreases.", difficulty: .hard, dueDate: today, lastReviewedDate: daysAgo(1), reviewIntervalDays: 0, easeFactor: 1.9, retentionScore: 0.54, confidenceRating: 2, missReason: .timingIssue, tags: ["Fluids", "Continuity"], concepts: [conceptNodes[18]], source: sources[3], linkedConceptIDs: [conceptNodes[18].id], linkedFullLengthExamNumber: 3),
        StudyCard(deckName: "Physics", section: "Physics", front: "What happens to total resistance when resistors are added in parallel?", back: "Total resistance decreases because additional paths increase total conductance.", difficulty: .medium, dueDate: daysFromNow(3), lastReviewedDate: daysAgo(2), reviewIntervalDays: 3, easeFactor: 2.35, retentionScore: 0.72, confidenceRating: 4, missReason: nil, tags: ["Circuits"], concepts: [conceptNodes[19]], source: sources[0], linkedConceptIDs: [conceptNodes[19].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "Psychology / Sociology", section: "Psychology / Sociology", front: "How does negative reinforcement differ from punishment?", back: "Negative reinforcement removes an aversive stimulus to increase behavior; punishment decreases behavior.", difficulty: .medium, dueDate: today, lastReviewedDate: daysAgo(2), reviewIntervalDays: 1, easeFactor: 2.3, retentionScore: 0.78, confidenceRating: 4, missReason: nil, tags: ["Learning", "Behavior"], concepts: [conceptNodes[22]], source: sources[6], linkedConceptIDs: [conceptNodes[22].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "CARS", section: "CARS", front: "What is the safest way to identify the main idea of a CARS passage?", back: "Track the author's central claim across paragraphs and choose the answer that covers the passage globally without being too narrow.", difficulty: .hard, dueDate: today, lastReviewedDate: daysAgo(1), reviewIntervalDays: 0, easeFactor: 2.0, retentionScore: 0.60, confidenceRating: 2, missReason: .misreadQuestion, tags: ["Main Idea", "CARS"], concepts: [conceptNodes[26]], source: sources[4], linkedConceptIDs: [conceptNodes[26].id], linkedFullLengthExamNumber: nil),
        StudyCard(deckName: "Full-Length Review", section: "Full-Length Review", front: "FL3 Q42: You missed a buffer question because you chose the strong acid approach. What should you identify first?", back: "First identify whether the passage gives a weak acid/conjugate base pair, then use buffer logic before attempting strong acid calculations.", difficulty: .hard, dueDate: today, lastReviewedDate: daysAgo(1), reviewIntervalDays: 0, easeFactor: 1.85, retentionScore: 0.52, confidenceRating: 1, missReason: .carelessMistake, tags: ["FL3", "Buffers", "Review"], concepts: [conceptNodes[10]], source: sources[3], linkedConceptIDs: [conceptNodes[10].id], linkedFullLengthExamNumber: 3)
    ]

    static let practiceQuestions = [
        PracticeQuestion(
            section: "Biology/Biochemistry",
            passage: "A researcher applies a hormone to cultured endocrine cells and observes a rapid increase in cytosolic Ca2+ without a change in cAMP. The response is blocked by inhibiting phospholipase C.",
            stem: "Which intracellular messenger most directly explains the Ca2+ increase?",
            answerChoices: ["A. cAMP activating protein kinase A", "B. IP3 opening ER calcium channels", "C. NADH donating electrons to complex I", "D. ATP synthase increasing proton flow"],
            correctAnswerIndex: 1,
            explanation: "Phospholipase C cleaves PIP2 into DAG and IP3. IP3 binds receptors on the endoplasmic reticulum and releases Ca2+ into the cytosol.",
            testedConcepts: [conceptNodes[0]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Map pathway evidence to the correct second messenger."
        ),
        PracticeQuestion(
            section: "Biology/Biochemistry",
            passage: "An enzyme variant shows the same Vmax as the wild type but requires a higher substrate concentration to reach half-maximal velocity.",
            stem: "Which change best describes the variant?",
            answerChoices: ["A. Lower Km and higher affinity", "B. Higher Km and lower affinity", "C. Lower Vmax and lower affinity", "D. Higher Vmax and unchanged affinity"],
            correctAnswerIndex: 1,
            explanation: "Km is the substrate concentration at half Vmax. A higher Km means more substrate is required, which usually indicates lower substrate affinity.",
            testedConcepts: [conceptNodes[5]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Interpret enzyme kinetics from experimental changes."
        ),
        PracticeQuestion(
            section: "Chemistry/Physics",
            passage: "A student prepares a buffer by mixing a weak acid with its conjugate base. The concentrations of acid and conjugate base are equal after dilution.",
            stem: "What is the pH of the buffer relative to the acid pKa?",
            answerChoices: ["A. pH = pKa", "B. pH = 2 x pKa", "C. pH is always 7", "D. pH is lower than pKa by 1 unit"],
            correctAnswerIndex: 0,
            explanation: "The Henderson-Hasselbalch equation gives pH = pKa + log([A-]/[HA]). Equal concentrations make the log term zero.",
            testedConcepts: [conceptNodes[10]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Apply a formula only after recognizing buffer structure."
        ),
        PracticeQuestion(
            section: "Chemistry/Physics",
            passage: "Blood flows through a vessel segment that narrows to half its original cross-sectional area. Assume incompressible flow and no branching.",
            stem: "How does fluid velocity change in the narrowed segment?",
            answerChoices: ["A. It decreases by half", "B. It remains unchanged", "C. It doubles", "D. It quadruples"],
            correctAnswerIndex: 2,
            explanation: "Continuity requires A1v1 = A2v2. If area is halved, velocity doubles.",
            testedConcepts: [conceptNodes[18]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Translate a physical scenario into the continuity equation."
        ),
        PracticeQuestion(
            section: "Psychology/Sociology",
            passage: "A child cleans their room more often after parents stop nagging whenever the room is clean.",
            stem: "Which learning process is demonstrated?",
            answerChoices: ["A. Positive reinforcement", "B. Negative reinforcement", "C. Positive punishment", "D. Observational learning"],
            correctAnswerIndex: 1,
            explanation: "Negative reinforcement increases a behavior by removing an aversive stimulus, here the nagging.",
            testedConcepts: [conceptNodes[22]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Classify behavior change using stimulus removal/addition logic."
        ),
        PracticeQuestion(
            section: "Psychology/Sociology",
            passage: "A study comparing income groups finds that access to preventative care differs by neighborhood and insurance status.",
            stem: "Which concept is most directly illustrated?",
            answerChoices: ["A. Social stratification", "B. Role strain", "C. Group polarization", "D. Fundamental attribution error"],
            correctAnswerIndex: 0,
            explanation: "Unequal access to resources by class and social position reflects social stratification.",
            testedConcepts: [conceptNodes[23]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Connect passage evidence to sociological structure."
        ),
        PracticeQuestion(
            section: "CARS",
            passage: "The author describes a museum renovation as technically impressive but culturally timid, arguing that preservation should not prevent institutions from taking interpretive risks.",
            stem: "Which choice best captures the author’s attitude?",
            answerChoices: ["A. Unqualified admiration", "B. Cautious criticism", "C. Complete indifference", "D. Hostile dismissal"],
            correctAnswerIndex: 1,
            explanation: "The author acknowledges technical strengths but criticizes the museum’s lack of interpretive risk, making the tone cautiously critical.",
            testedConcepts: [conceptNodes[27]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Infer tone from mixed evaluative language."
        ),
        PracticeQuestion(
            section: "CARS",
            passage: "A passage argues that public debates often reward memorable phrasing over careful reasoning, which can obscure the strongest version of an opponent’s argument.",
            stem: "The main idea is best described as:",
            answerChoices: ["A. Rhetoric can distort serious argument", "B. Public debate is always useless", "C. Memorable phrasing improves reasoning", "D. Opponents rarely understand their own views"],
            correctAnswerIndex: 0,
            explanation: "The passage focuses on how style can overshadow careful reasoning, without claiming debate is always useless.",
            testedConcepts: [conceptNodes[26]],
            sourceLabel: "AAMC-style mock",
            applicationSkill: "Choose a global claim without overextending it."
        )
    ]

    static let practiceResults = [
        PracticeResult(questionID: practiceQuestions[0].id, section: "Biology/Biochemistry", selectedAnswerIndex: 0, correctAnswerIndex: 1, missReason: .confusedConcepts, confidence: 2, followUpSuggestion: "Generate a concept comparison question to separate the two ideas.", completedAt: daysAgo(1)),
        PracticeResult(questionID: practiceQuestions[3].id, section: "Chemistry/Physics", selectedAnswerIndex: 1, correctAnswerIndex: 2, missReason: .timingIssue, confidence: 2, followUpSuggestion: "Suggest a timed mini-set with 3 related questions.", completedAt: daysAgo(1)),
        PracticeResult(questionID: practiceQuestions[4].id, section: "Psychology/Sociology", selectedAnswerIndex: 1, correctAnswerIndex: 1, missReason: nil, confidence: 4, followUpSuggestion: "Add a timing/checklist reminder before the next mini-set.", completedAt: daysAgo(2)),
        PracticeResult(questionID: practiceQuestions[6].id, section: "CARS", selectedAnswerIndex: 3, correctAnswerIndex: 1, missReason: .misreadQuestion, confidence: 2, followUpSuggestion: "Assign a CARS-style reasoning drill focused on wording and scope.", completedAt: daysAgo(2))
    ]

    static let reviewHistory = [
        ReviewResult(cardID: studyCards[2].id, deckName: "Biochemistry", section: "Biochemistry", rating: .again, missReason: .confusedConcepts, confidence: 2, reviewedAt: daysAgo(1), nextDueDate: today, intervalDays: 0, linkedFullLengthExamNumber: 3),
        ReviewResult(cardID: studyCards[7].id, deckName: "Physics", section: "Physics", rating: .hard, missReason: .timingIssue, confidence: 2, reviewedAt: daysAgo(1), nextDueDate: today, intervalDays: 1, linkedFullLengthExamNumber: 3),
        ReviewResult(cardID: studyCards[10].id, deckName: "CARS", section: "CARS", rating: .hard, missReason: .misreadQuestion, confidence: 2, reviewedAt: daysAgo(2), nextDueDate: today, intervalDays: 1, linkedFullLengthExamNumber: nil)
    ]

    static let cardLineages = [
        CardLineage(
            cardID: studyCards[0].id,
            createdFrom: .textbookImport,
            sourceName: "Kaplan Biology Review",
            parentQuestionID: practiceQuestions[0].id,
            parentCardID: nil,
            createdDate: daysAgo(12),
            revisionHistory: [
                CardRevision(
                    date: daysAgo(8),
                    changeSummary: "Added PLC and ER calcium channel detail.",
                    previousFront: "What does IP3 do?",
                    previousBack: "IP3 releases calcium.",
                    newFront: studyCards[0].front,
                    newBack: studyCards[0].back
                ),
                CardRevision(
                    date: daysAgo(2),
                    changeSummary: "Updated explanation after missed practice question.",
                    previousFront: studyCards[0].front,
                    previousBack: "IP3 binds ER receptors.",
                    newFront: studyCards[0].front,
                    newBack: studyCards[0].back
                )
            ]
        ),
        CardLineage(
            cardID: studyCards[2].id,
            createdFrom: .fullLengthReview,
            sourceName: "AAMC Full-Length 3",
            parentQuestionID: practiceQuestions[1].id,
            parentCardID: nil,
            createdDate: daysAgo(9),
            revisionHistory: [
                CardRevision(
                    date: daysAgo(4),
                    changeSummary: "Changed wording to emphasize half Vmax.",
                    previousFront: "Define Km.",
                    previousBack: "Km relates to affinity.",
                    newFront: studyCards[2].front,
                    newBack: studyCards[2].back
                )
            ]
        )
    ]

    static let featuredSemanticSearchResults = [
        SemanticSearchResult(type: .concept, title: "IP3", subtitle: "Second messenger in PLC signaling", relevanceScore: 0.98, matchedTerms: ["ip3"], relatedConcepts: ["Calcium Signaling", "Phospholipase C"]),
        SemanticSearchResult(type: .card, title: "Role of IP3 in PLC signaling", subtitle: "Biology card", relevanceScore: 0.93, matchedTerms: ["ip3", "plc"], relatedConcepts: ["Cell Signaling", "Calcium Signaling"]),
        SemanticSearchResult(type: .concept, title: "Enzyme Kinetics", subtitle: "Km, Vmax, inhibition, and catalytic efficiency", relevanceScore: 0.9, matchedTerms: ["enzyme"], relatedConcepts: ["Michaelis-Menten"]),
        SemanticSearchResult(type: .deck, title: "Biochemistry", subtitle: "520 cards, enzymes and pathways", relevanceScore: 0.82, matchedTerms: ["enzyme"], relatedConcepts: ["Enzyme Kinetics", "Michaelis-Menten"]),
        SemanticSearchResult(type: .source, title: "Kaplan Biology Review", subtitle: "Textbook source", relevanceScore: 0.78, matchedTerms: ["ip3"], relatedConcepts: ["Cell Signaling"])
    ]

    static let reviewStats = ReviewStats(
        cardsDueToday: 59,
        completedToday: 18,
        retentionPercentage: 68,
        streakDays: 21,
        totalCards: 2930,
        masteredConcepts: 11
    )
}

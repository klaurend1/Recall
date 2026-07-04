import Foundation

struct RecallSeedDataset: Codable {
    var version: Int
    var sourceName: String
    var sourceRevision: String
    var generatedAt: Date
    var sections: [SeedSection]
    var concepts: [SeedConcept]
    var cards: [SeedCard]
    var edges: [SeedConceptEdge]
}

struct SeedSection: Codable, Hashable {
    var id: UUID = UUID()
    let name: String
    let deckName: String
    let pageStart: Int
    let pageEnd: Int
}

struct SeedConcept: Codable, Hashable {
    var id: UUID = UUID()
    let name: String
    let section: String
    let sourcePage: Int
    let sourceSectionTitle: String
    let description: String
    let mastery: Double
    let weakCount: Int
    let tags: [String]
}

struct SeedCard: Codable, Hashable {
    var id: UUID = UUID()
    let deckID: UUID
    let deckName: String
    let section: String
    let front: String
    let back: String
    let cardType: StudyCardType
    let difficulty: CardDifficulty
    let conceptIDs: [UUID]
    let sourcePage: Int
    let sourceSectionTitle: String
    let tags: [String]
}

final class MCATSeedGenerator {
    private let sourceName = "MCAT Review Sheets.pdf"
    private let sourceRevision = "Revised 2019"

    func generate() -> RecallSeedDataset {
        let sections = makeSections()
        let sectionDeckIDs = Dictionary(uniqueKeysWithValues: sections.map { ($0.deckName, $0.id) })
        let blueprints = makeConceptBlueprints()
        let concepts = blueprints.map(\.concept)
        let graphBuilder = ConceptGraphBuilder()
        let edges = graphBuilder.buildEdges(concepts: concepts)
        let cards = blueprints.flatMap { blueprint in
            makeCards(for: blueprint, deckID: sectionDeckIDs[blueprint.concept.section] ?? sections[0].id)
        }

        return RecallSeedDataset(
            version: 1,
            sourceName: sourceName,
            sourceRevision: sourceRevision,
            generatedAt: Date(),
            sections: sections,
            concepts: concepts,
            cards: cards,
            edges: edges
        )
    }

    private func makeSections() -> [SeedSection] {
        [
            SeedSection(name: "General Chemistry", deckName: "General Chemistry", pageStart: 1, pageEnd: 12),
            SeedSection(name: "Organic Chemistry", deckName: "Organic Chemistry", pageStart: 13, pageEnd: 24),
            SeedSection(name: "Biology", deckName: "Biology", pageStart: 25, pageEnd: 36),
            SeedSection(name: "Biochemistry", deckName: "Biochemistry", pageStart: 37, pageEnd: 48),
            SeedSection(name: "Psychology / Sociology", deckName: "Psychology / Sociology", pageStart: 49, pageEnd: 60),
            SeedSection(name: "Physics", deckName: "Physics", pageStart: 61, pageEnd: 72),
            SeedSection(name: "Appendix", deckName: "Appendix", pageStart: 73, pageEnd: 89)
        ]
    }

    private func makeCards(for blueprint: ConceptBlueprint, deckID: UUID) -> [SeedCard] {
        let concept = blueprint.concept
        let sharedTags = blueprint.concept.tags + ["pdf-import", "mcat-review-sheets"]
        let basic = SeedCard(
            deckID: deckID,
            deckName: concept.section,
            section: concept.section,
            front: "What should you recall about \(concept.name)?",
            back: concept.description,
            cardType: .basic,
            difficulty: blueprint.difficulty,
            conceptIDs: [concept.id],
            sourcePage: concept.sourcePage,
            sourceSectionTitle: concept.sourceSectionTitle,
            tags: sharedTags
        )

        let cloze = SeedCard(
            deckID: deckID,
            deckName: concept.section,
            section: concept.section,
            front: blueprint.clozePrompt,
            back: blueprint.clozeAnswer,
            cardType: .cloze,
            difficulty: blueprint.difficulty,
            conceptIDs: [concept.id],
            sourcePage: concept.sourcePage,
            sourceSectionTitle: concept.sourceSectionTitle,
            tags: sharedTags + ["cloze"]
        )

        let application = SeedCard(
            deckID: deckID,
            deckName: concept.section,
            section: concept.section,
            front: blueprint.applicationPrompt,
            back: blueprint.applicationAnswer,
            cardType: .application,
            difficulty: blueprint.difficulty == .easy ? .medium : blueprint.difficulty,
            conceptIDs: [concept.id],
            sourcePage: concept.sourcePage,
            sourceSectionTitle: concept.sourceSectionTitle,
            tags: sharedTags + ["application"]
        )

        let misconception = SeedCard(
            deckID: deckID,
            deckName: concept.section,
            section: concept.section,
            front: "What misconception should you avoid for \(concept.name)?",
            back: blueprint.misconception,
            cardType: .misconception,
            difficulty: .medium,
            conceptIDs: [concept.id],
            sourcePage: concept.sourcePage,
            sourceSectionTitle: concept.sourceSectionTitle,
            tags: sharedTags + ["misconception"]
        )

        return [basic, cloze, application, misconception]
    }

    private func makeConceptBlueprints() -> [ConceptBlueprint] {
        [
            bp("Atomic Structure", "General Chemistry", 1, "General Chemistry 1: Atomic Structure", "Quantum numbers describe electron shells, subshells, orbitals, and spin; unpaired electrons make atoms paramagnetic.", "Atomic structure uses principal, azimuthal, magnetic, and spin quantum numbers to label electrons.", "Paramagnetism requires at least one unpaired electron; diamagnetism means all electrons are paired.", "Given an electron configuration, apply Hund's rule before deciding whether it is attracted to a magnetic field.", "Do not call every filled subshell paramagnetic; attraction requires unpaired electrons.", .medium, ["general-chemistry", "electrons"]),
            bp("Periodic Trends", "General Chemistry", 2, "General Chemistry 2: The Periodic Table", "Effective nuclear charge, ionization energy, electron affinity, electronegativity, and atomic radius explain periodic behavior.", "Across a period, Zeff generally increases while atomic size decreases.", "Cations are smaller than neutral atoms, while anions are larger.", "Rank atoms by electronegativity by moving generally up and right, with fluorine as the common maximum.", "Noble gases are exceptions for electron affinity and most electronegativity comparisons.", .easy, ["general-chemistry", "periodic-table"]),
            bp("Bonding and Molecular Geometry", "General Chemistry", 3, "General Chemistry 3: Bonding and Chemical Interactions", "Bond order, electronegativity difference, intermolecular forces, and VSEPR geometry predict molecular properties.", "VSEPR treats bonding and lone electron groups around a central atom to predict geometry.", "A tetrahedral electron geometry with two lone pairs gives a bent molecular shape.", "Use the number of electron groups to choose hybridization before assigning molecular shape.", "Do not treat electronic geometry and molecular geometry as interchangeable when lone pairs are present.", .medium, ["general-chemistry", "bonding"]),
            bp("Chemical Kinetics", "General Chemistry", 5, "General Chemistry 5: Chemical Kinetics", "Reaction order controls rate law form, integrated rate law shape, half-life behavior, and rate constant units.", "First-order reactions have a half-life of ln(2)/k.", "At high substrate concentration, Michaelis-Menten reactions approximate zero-order behavior.", "Use graph shape or half-life behavior to distinguish zeroth, first, and second order kinetics.", "Rate laws come from experimental data or elementary slow steps, not from overall stoichiometry by default.", .hard, ["general-chemistry", "kinetics"]),
            bp("Equilibrium", "General Chemistry", 6, "General Chemistry 6: Equilibrium", "Keq, Q, delta G, and Le Chatelier's principle describe direction and response of reversible reactions.", "If Q is less than Keq, the reaction proceeds forward and delta G is negative.", "Pure solids and liquids are excluded from equilibrium expressions.", "Predict the shift after adding product by choosing the direction that relieves the stress.", "Catalysts do not change Keq; they only help the system reach equilibrium faster.", .medium, ["general-chemistry", "equilibrium"]),
            bp("Thermodynamics", "General Chemistry", 7, "General Chemistry 7: Thermochemistry", "Enthalpy, entropy, temperature, and Gibbs free energy determine spontaneity and heat flow.", "Delta G equals delta H minus T delta S.", "A negative delta G indicates a spontaneous process under the stated conditions.", "Use signs of delta H and delta S to decide whether spontaneity depends on high or low temperature.", "Spontaneous does not mean fast; kinetics and thermodynamics answer different questions.", .medium, ["general-chemistry", "thermodynamics"]),
            bp("Acids and Bases", "General Chemistry", 10, "General Chemistry 10: Acids and Bases", "Arrhenius, Bronsted-Lowry, and Lewis definitions, pH, buffers, titrations, and Henderson-Hasselbalch are linked.", "At the half-equivalence point, pH equals pKa for a weak acid titration.", "Buffers have maximum capacity within about one pH unit of the pKa.", "Use normality when titration equivalents depend on multiple ionizable protons.", "The endpoint is not always the equivalence point; indicator choice matters.", .hard, ["general-chemistry", "acid-base"]),
            bp("Electrochemistry", "General Chemistry", 12, "General Chemistry 12: Electrochemistry", "Oxidation occurs at the anode, reduction at the cathode, and cell potential connects to free energy.", "Galvanic cells are spontaneous, with negative delta G and positive cell potential.", "Electrons flow from anode to cathode.", "Identify the oxidized species first, then assign anode/cathode and calculate Ecell.", "Anode and cathode signs switch between galvanic and electrolytic cells, but oxidation and reduction locations do not.", .hard, ["general-chemistry", "electrochemistry"]),
            bp("Isomers", "Organic Chemistry", 14, "Organic Chemistry 2: Isomers", "Structural isomers differ in connectivity, while stereoisomers share connectivity but differ in 3D arrangement.", "Enantiomers are nonsuperimposable mirror images.", "Diastereomers are stereoisomers that are not mirror images.", "Use Cahn-Ingold-Prelog priorities to assign R/S stereochemistry.", "D/L notation is relative configuration and does not directly tell you + or - optical rotation.", .medium, ["organic-chemistry", "stereochemistry"]),
            bp("SN1/SN2/E1/E2", "Organic Chemistry", 16, "Organic Chemistry 4: Analyzing Organic Reactions", "Substrate substitution, nucleophile/base strength, sterics, and solvent determine substitution or elimination pathways.", "SN2 is concerted and proceeds with backside attack and inversion.", "Tertiary substrates favor SN1/E1 in polar protic solvent unless strong base pushes E2.", "Choose the mechanism by combining substrate class with nucleophile/base and solvent.", "Strong bulky base with a primary substrate can favor E2 rather than SN2.", .hard, ["organic-chemistry", "mechanisms"]),
            bp("Alcohol Oxidation", "Organic Chemistry", 17, "Organic Chemistry 5: Alcohols", "Primary alcohols can stop at aldehydes with PCC or oxidize to carboxylic acids with stronger oxidants; secondary alcohols become ketones.", "PCC oxidizes primary alcohols to aldehydes.", "Secondary alcohols oxidize to ketones with common oxidizing agents.", "Pick PCC when a question asks for aldehyde synthesis from a primary alcohol.", "Do not use NaBH4 as an oxidizing agent; it reduces carbonyls.", .medium, ["organic-chemistry", "redox"]),
            bp("Carbonyl Chemistry", "Organic Chemistry", 18, "Organic Chemistry 6: Aldehydes and Ketones I", "Aldehydes and ketones undergo nucleophilic addition because the carbonyl carbon is electrophilic.", "Hydride reagents reduce aldehydes to primary alcohols and ketones to secondary alcohols.", "Water addition to a carbonyl forms a geminal diol.", "Track the nucleophile attacking the carbonyl carbon and the pi electrons moving to oxygen.", "Do not expect aldehydes and ketones to eject a leaving group during simple nucleophilic addition.", .hard, ["organic-chemistry", "carbonyls"]),
            bp("Carboxylic Acid Derivatives", "Organic Chemistry", 21, "Organic Chemistry 9: Carboxylic Acid Derivatives", "Acid chlorides, anhydrides, esters, amides, and carboxylates differ in acyl-substitution reactivity.", "Reactivity decreases from acid chloride to anhydride to ester to amide to carboxylate.", "Amides hydrolyze only under strongly acidic or basic conditions.", "Rank derivatives by leaving group stability and carbonyl electrophilicity.", "Steric hindrance is not the only determinant; induction and resonance matter.", .hard, ["organic-chemistry", "derivatives"]),
            bp("Spectroscopy", "Organic Chemistry", 23, "Organic Chemistry 11: Spectroscopy", "IR, UV, NMR, and mass spectrometry reveal functional groups, conjugation, proton environments, and molecular mass.", "A sharp C=O IR stretch appears near 1750 cm-1.", "NMR integration is proportional to the number of protons under a peak.", "Use M+1 relative abundance to estimate carbon count from mass spectrometry.", "Downfield means left on an NMR spectrum and usually more deshielded.", .medium, ["organic-chemistry", "lab"]),
            bp("Separations and Purifications", "Organic Chemistry", 24, "Organic Chemistry 12: Separations and Purifications", "Extraction, filtration, recrystallization, distillation, and chromatography separate compounds by solubility, boiling point, size, charge, or affinity.", "In TLC with polar silica, nonpolar compounds have higher Rf values.", "Size-exclusion chromatography elutes larger molecules first.", "Choose vacuum distillation for high-boiling liquids to prevent degradation.", "A wash is the reverse of extraction: it removes impurities while retaining the compound of interest.", .medium, ["organic-chemistry", "lab"]),
            bp("The Cell", "Biology", 25, "Biology 1: The Cell", "Eukaryotic and prokaryotic structures, organelles, cytoskeleton, bacteria, viruses, and cell cycle regulation are core cell biology.", "Rough ER accepts mRNA and makes proteins; smooth ER detoxifies and makes lipids.", "Gram-positive bacteria stain purple and have thick peptidoglycan.", "Match organelle functions to protein trafficking or degradation pathways.", "Plasmids are not the same as the main bacterial chromosome, though episomes can integrate.", .medium, ["biology", "cell"]),
            bp("Cardiovascular System", "Biology", 31, "Biology 7: Cardiovascular System", "Blood flow, valve order, electrical conduction, vasculature, pressure, blood types, and fluid balance govern circulation.", "Cardiac output equals heart rate times stroke volume.", "Blood flows SA node to AV node to Bundle of His to Purkinje fibers.", "Trace deoxygenated blood from right atrium to lungs before returning to the left heart.", "Pulmonary arteries carry deoxygenated blood; pulmonary veins carry oxygenated blood.", .medium, ["biology", "cardio"]),
            bp("Nervous System", "Biology", 28, "Biology 4: Nervous System", "Neurons, action potentials, glial cells, reflex arcs, and autonomic divisions explain rapid signaling.", "Depolarization is driven by sodium influx; repolarization is driven by potassium efflux.", "Schwann cells myelinate the PNS, while oligodendrocytes myelinate the CNS.", "Separate afferent sensory input from efferent motor output in a reflex arc.", "White matter refers to myelinated axons, not cell bodies.", .medium, ["biology", "neuro"]),
            bp("Endocrine System", "Biology", 29, "Biology 5: Endocrine System", "Peptide, steroid, and amino-acid derivative hormones use different receptors and feedback systems.", "Peptide hormones are polar and usually use extracellular receptors like GPCRs.", "Steroid hormones pass through membranes and bind intracellular receptors.", "Classify hormones by chemical type before predicting receptor location.", "Epinephrine is amino-acid derived but commonly signals through GPCRs.", .hard, ["biology", "endocrine"]),
            bp("Immune System", "Biology", 32, "Biology 8: Immune System", "Innate defenses are nonspecific; adaptive immunity uses B cells, T cells, antibodies, and memory.", "MHC I presents endogenous antigen to CD8 T cells.", "MHC II presents exogenous antigen to CD4 helper T cells.", "Differentiate humoral immunity from cell-mediated immunity by the main cell and target.", "Natural killer cells attack cells low on MHC, including virally infected cells.", .hard, ["biology", "immune"]),
            bp("Genetics and Evolution", "Biology", 36, "Biology 12: Genetics and Evolution", "Mendelian inheritance, mutations, Hardy-Weinberg, experiments, and evolutionary mechanisms explain genetic patterns.", "Hardy-Weinberg uses p + q = 1 and p squared + 2pq + q squared = 1.", "Frameshift mutations alter the downstream reading frame.", "Use recombination frequency to infer distance between linked genes.", "Independent assortment does not apply cleanly to tightly linked genes.", .medium, ["biology", "genetics"]),
            bp("Amino Acids", "Biochemistry", 37, "Biochemistry 1: Amino Acids, Peptides, and Proteins", "Amino acids are amphoteric, form zwitterions, and vary by side-chain polarity, charge, and stereochemistry.", "All chiral eukaryotic amino acids are L, and all except cysteine are S.", "The isoelectric point is the pH at which net charge is zero.", "Use acidic/basic side-chain pKa values to choose the two pKa values that bracket the neutral form.", "Glycine is achiral; cysteine is the stereochemical exception.", .hard, ["biochemistry", "amino-acids"]),
            bp("Protein Structure", "Biochemistry", 37, "Biochemistry 1: Amino Acids, Peptides, and Proteins", "Protein primary through quaternary structures are stabilized by peptide bonds, hydrogen bonds, hydrophobic effects, ionic interactions, and disulfides.", "Denaturation disrupts higher-order structure but not primary sequence.", "Disulfide bonds form when cysteine residues oxidize to cystine.", "Predict whether a denaturing condition breaks covalent or noncovalent interactions.", "Peptide bonds have partial double-bond character and restricted rotation.", .medium, ["biochemistry", "proteins"]),
            bp("Enzyme Kinetics", "Biochemistry", 38, "Biochemistry 2: Enzymes", "Enzymes lower activation energy and change reaction rate without changing delta G or equilibrium.", "Enzymes catalyze forward and reverse reactions and are reusable.", "Km is the substrate concentration at half Vmax.", "Interpret a Michaelis-Menten curve by identifying saturation and half-maximal velocity.", "A catalyst does not make an unfavorable equilibrium favorable.", .hard, ["biochemistry", "enzymes"]),
            bp("Michaelis-Menten", "Biochemistry", 38, "Biochemistry 2: Enzymes", "Michaelis-Menten kinetics relate reaction velocity to substrate concentration, Vmax, and Km for saturable enzymes.", "The Michaelis-Menten curve is hyperbolic.", "Low substrate concentration approximates first-order behavior; high substrate concentration approximates zero-order behavior.", "Estimate Km by finding the substrate concentration at one-half Vmax.", "Do not read Vmax at the steep early part of the curve; saturation defines it.", .hard, ["biochemistry", "enzymes"]),
            bp("Km", "Biochemistry", 38, "Biochemistry 2: Enzymes", "Km is substrate concentration at half Vmax and inversely reflects enzyme-substrate affinity in simple Michaelis-Menten settings.", "Higher Km means lower apparent substrate affinity.", "Competitive inhibition increases apparent Km while Vmax is unchanged.", "Compare two enzymes by asking which reaches half Vmax at lower substrate concentration.", "Km is a concentration, not a reaction rate.", .hard, ["biochemistry", "enzymes"]),
            bp("Vmax", "Biochemistry", 38, "Biochemistry 2: Enzymes", "Vmax is the maximum reaction rate when enzyme active sites are saturated with substrate.", "Noncompetitive inhibition decreases Vmax while Km is unchanged for pure noncompetitive inhibition.", "Adding enzyme can increase Vmax.", "Use the plateau of a saturation curve to identify Vmax.", "Adding more substrate cannot overcome pure noncompetitive inhibition.", .hard, ["biochemistry", "enzymes"]),
            bp("Competitive Inhibition", "Biochemistry", 82, "Appendix J: Enzyme Inhibition", "Competitive inhibitors bind the active site, can be overcome by substrate, increase Km, and leave Vmax unchanged.", "Competitive inhibition increases Km and does not change Vmax.", "Lineweaver-Burk competitive plots intersect at the y-axis.", "If extra substrate restores velocity, suspect competitive inhibition.", "Competitive inhibition does not lower Vmax in the classic MCAT model.", .hard, ["biochemistry", "enzyme-inhibition"]),
            bp("Uncompetitive Inhibition", "Biochemistry", 82, "Appendix J: Enzyme Inhibition", "Uncompetitive inhibitors bind only the enzyme-substrate complex, lowering both Km and Vmax.", "Uncompetitive inhibition decreases both Km and Vmax.", "Lineweaver-Burk uncompetitive plots are parallel to the uninhibited line.", "Identify uncompetitive inhibition when inhibitor binds only after substrate is bound.", "Do not confuse uncompetitive with noncompetitive; Km changes in uncompetitive inhibition.", .hard, ["biochemistry", "enzyme-inhibition"]),
            bp("Noncompetitive Inhibition", "Biochemistry", 82, "Appendix J: Enzyme Inhibition", "Pure noncompetitive inhibitors bind enzyme and enzyme-substrate complex equally, decreasing Vmax without changing Km.", "Noncompetitive inhibition decreases Vmax and leaves Km unchanged.", "Lineweaver-Burk noncompetitive plots intersect at the x-axis.", "If substrate cannot overcome inhibition and affinity is unchanged, choose noncompetitive inhibition.", "Allosteric binding does not automatically mean Km changes in the pure noncompetitive case.", .hard, ["biochemistry", "enzyme-inhibition"]),
            bp("Lineweaver-Burk", "Biochemistry", 82, "Appendix J: Enzyme Inhibition", "Lineweaver-Burk plots use double reciprocals to linearize enzyme kinetics and reveal inhibition patterns.", "The y-intercept is 1/Vmax and the x-intercept is -1/Km.", "Competitive inhibition changes slope and x-intercept but not y-intercept.", "Use intercept movement to distinguish competitive, uncompetitive, and noncompetitive inhibition.", "The negative x-axis is theoretical, but it is still used for extrapolation.", .hard, ["biochemistry", "enzyme-inhibition"]),
            bp("Glycolysis", "Biochemistry", 84, "Appendix L: Glycolysis", "Glycolysis occurs in the cytoplasm, converts glucose to two pyruvates, and nets two ATP and two NADH.", "Phosphofructokinase is the committed step of glycolysis.", "Pyruvate kinase is inactive when phosphorylated.", "Calculate net ATP by subtracting two invested ATP from four produced ATP.", "Do not count four ATP as net yield; glycolysis nets two ATP per glucose.", .hard, ["biochemistry", "metabolism"]),
            bp("Pyruvate Kinase", "Biochemistry", 84, "Appendix L: Glycolysis", "Pyruvate kinase converts PEP to pyruvate, producing ATP and completing glycolysis.", "Pyruvate kinase is regulated by covalent modification and is inactive when phosphorylated.", "High alanine inhibits pyruvate kinase.", "Connect PEP's high energy to enol-to-keto tautomerization after phosphate transfer.", "Pyruvate kinase is not the committed step; PFK is.", .hard, ["biochemistry", "metabolism"]),
            bp("Citric Acid Cycle", "Biochemistry", 86, "Appendix N: Citric Acid Cycle", "The citric acid cycle oxidizes acetyl-CoA in the mitochondrial matrix, producing NADH, FADH2, ATP/GTP, and CO2.", "One acetyl-CoA produces three NADH, one FADH2, one ATP or GTP, and two CO2.", "Isocitrate dehydrogenase is the rate-limiting enzyme.", "Double the per-turn yield when calculating output per glucose.", "The cycle does not directly consume oxygen; oxidative phosphorylation does.", .hard, ["biochemistry", "metabolism"]),
            bp("Oxidative Phosphorylation", "Biochemistry", 87, "Appendix O: Oxidative Phosphorylation", "The electron transport chain and chemiosmosis convert NADH and FADH2 energy into ATP using oxygen as terminal electron acceptor.", "Each NADH yields about 2.5 ATP and each FADH2 yields about 1.5 ATP.", "One glucose can produce about 32 ATP in the review sheet convention.", "Track which reduced cofactors enter the ETC to estimate ATP yield.", "FADH2 yields less ATP because it enters downstream of Complex I.", .hard, ["biochemistry", "metabolism"]),
            bp("GPCR", "Biochemistry", 39, "Biochemistry 3: Nonenzymatic Protein Function and Protein Analysis", "G protein-coupled receptors activate membrane-bound G proteins and second messenger cascades after ligand binding.", "GPCR signaling uses a first messenger ligand to initiate a second messenger response.", "Phosphodiesterase deactivates cAMP and GTP hydrolyzes back to GDP.", "Classify epinephrine signaling as a ligand-driven GPCR pathway.", "Do not place steroid hormone receptors on the cell surface by default.", .medium, ["biochemistry", "signaling"]),
            bp("IP3", "Biochemistry", 39, "Biochemistry 3: Nonenzymatic Protein Function and Protein Analysis", "IP3 is a second messenger generated from PIP2 cleavage and triggers calcium release from intracellular stores.", "Phospholipase C cleaves PIP2 into DAG and IP3.", "IP3 opens ER calcium channels.", "Trace GPCR to G protein to PLC to IP3 to calcium release.", "IP3 is not the same messenger as cAMP.", .medium, ["biochemistry", "signaling"]),
            bp("Calcium Signaling", "Biochemistry", 39, "Biochemistry 3: Nonenzymatic Protein Function and Protein Analysis", "Intracellular calcium acts as a second messenger that can alter enzyme activity, secretion, contraction, or transcriptional responses.", "Calcium often binds calmodulin or calcium-sensitive proteins to change activity.", "IP3-mediated ER calcium release can amplify receptor signals.", "Predict calcium-dependent effects after IP3 generation in a signaling pathway.", "Extracellular calcium concentration is not the same as a calcium second messenger spike.", .medium, ["biochemistry", "signaling"]),
            bp("Learning and Memory", "Psychology / Sociology", 51, "Behavioral Sciences 3: Learning and Memory", "Learning includes habituation, classical conditioning, operant conditioning, and observational learning; memory includes encoding, storage, and retrieval.", "Operant conditioning changes behavior through reinforcement and punishment.", "Recognition is usually stronger than recall.", "Distinguish positive reinforcement from negative reinforcement by whether something is added or removed.", "Negative reinforcement is not punishment; it increases behavior by removing an aversive stimulus.", .medium, ["psych-soc", "learning"]),
            bp("Cognition", "Psychology / Sociology", 52, "Behavioral Sciences 4: Cognition, Consciousness, and Language", "Cognition covers information processing, problem solving, biases, language, consciousness, and sleep.", "Piaget's formal operational stage begins around age 11 and supports abstract reasoning.", "Broca's area supports speech production, while Wernicke's area supports language comprehension.", "Use aphasia symptoms to localize language deficits.", "Conduction aphasia is impaired repetition, not fluent nonsense speech.", .medium, ["psych-soc", "cognition"]),
            bp("Stress", "Psychology / Sociology", 53, "Behavioral Sciences 5: Motivation, Emotion, and Stress", "Stress involves appraisal, stressors, sympathetic activation, endocrine responses, and general adaptation syndrome.", "General adaptation syndrome progresses through alarm, resistance, and exhaustion.", "ACTH release leads to increased cortisol during stress.", "Separate primary appraisal from secondary appraisal in stress questions.", "Eustress can be positive stress; stress is not always distress.", .medium, ["psych-soc", "stress"]),
            bp("Social Stratification", "Psychology / Sociology", 60, "Behavioral Sciences 12: Social Stratification", "Social stratification ranks people into hierarchies by class, status, power, privilege, and inequality.", "Relative poverty depends on comparison to a larger population, while absolute poverty means lacking basic necessities.", "Social reproduction passes inequality from one generation to the next.", "Identify whether an example describes social mobility, social capital, or social exclusion.", "Meritocracy is an idealized system and does not erase structural inequality.", .medium, ["psych-soc", "sociology"]),
            bp("Research Design", "Psychology / Sociology", 71, "Physics and Math 11: Reasoning About the Design and Execution of Research", "Research design evaluates hypotheses using variables, controls, validity, bias, and ethical constraints.", "Internal validity asks whether the independent variable caused the observed dependent-variable change.", "External validity asks whether findings generalize to the target population.", "Choose cohort, cross-sectional, or case-control based on how exposure and outcome are measured.", "Correlation in observational human-subject research does not automatically prove causality.", .hard, ["psych-soc", "research"]),
            bp("Kinematics and Dynamics", "Physics", 61, "Physics and Math 1: Kinematics and Dynamics", "Vectors, Newton's laws, acceleration, forces, torque, linear motion, projectiles, inclined planes, and circular motion describe mechanics.", "Newton's second law is Fnet equals mass times acceleration.", "Projectile horizontal velocity is constant when air resistance is negligible.", "Resolve inclined-plane forces with mg sin theta parallel and mg cos theta perpendicular.", "Centripetal force points inward, while instantaneous velocity is tangential.", .hard, ["physics", "mechanics"]),
            bp("Work and Energy", "Physics", 62, "Physics and Math 2: Work and Energy", "Work transfers energy; kinetic, potential, and mechanical energy relationships predict motion and power.", "The work-energy theorem says net work equals change in kinetic energy.", "Conservative forces are path independent and include gravity and electrostatics.", "Use W equals Fd cos theta when force and displacement are not aligned.", "Power is rate of work or energy transfer, not total work.", .medium, ["physics", "energy"]),
            bp("Fluids", "Physics", 64, "Physics and Math 4: Fluids", "Fluid statics and dynamics use pressure, density, buoyancy, continuity, viscosity, Poiseuille flow, and Bernoulli's equation.", "Continuity says flow rate equals area times velocity.", "Bernoulli predicts lower static pressure where fluid speed is higher in a constriction.", "Use Archimedes' principle to compare buoyant force with weight.", "Flow speed and pressure do not both increase through a narrowed ideal tube.", .hard, ["physics", "fluids"]),
            bp("Circuits", "Physics", 66, "Physics and Math 6: Circuits", "Current, voltage, resistance, Ohm's law, Kirchhoff's laws, capacitors, and meters explain circuit behavior.", "Resistors in series add directly; resistors in parallel add by reciprocals.", "Capacitors in parallel add directly; capacitors in series add by reciprocals.", "Choose whether elements share current or voltage before combining them.", "A voltmeter is placed in parallel, while an ammeter is placed in series.", .hard, ["physics", "electricity"]),
            bp("Waves and Sound", "Physics", 67, "Physics and Math 7: Waves and Sound", "Wave speed, wavelength, frequency, interference, resonance, sound propagation, Doppler shifts, and harmonics describe oscillations.", "Wave speed equals frequency times wavelength.", "Sound is longitudinal and cannot travel through vacuum.", "Use source and detector motion direction to choose Doppler signs.", "Pitch is perception of frequency, not amplitude.", .medium, ["physics", "waves"]),
            bp("Optics", "Physics", 68, "Physics and Math 8: Light and Optics", "Reflection, refraction, Snell's law, mirrors, lenses, total internal reflection, diffraction, and polarization govern light behavior.", "Snell's law is n1 sin theta1 equals n2 sin theta2.", "Total internal reflection requires travel from higher to lower refractive index at a large incident angle.", "Use sign and object location to decide real versus virtual images.", "Index of refraction is not wavelength; it is c divided by speed in medium.", .hard, ["physics", "optics"]),
            bp("Statistics", "Psychology / Sociology", 72, "Physics and Math 12: Data-Based and Statistical Reasoning", "Central tendency, distributions, probability, hypothesis testing, p-values, confidence intervals, and graph interpretation support data reasoning.", "A p-value is compared with alpha to decide whether to reject the null hypothesis.", "A wider confidence interval is associated with a higher confidence level.", "Use skew direction based on the tail of the distribution.", "Statistical significance does not guarantee clinical significance.", .medium, ["research", "statistics"])
        ]
    }

    private func bp(
        _ name: String,
        _ section: String,
        _ page: Int,
        _ title: String,
        _ description: String,
        _ clozePrompt: String,
        _ clozeAnswer: String,
        _ applicationPrompt: String,
        _ misconception: String,
        _ difficulty: CardDifficulty,
        _ tags: [String]
    ) -> ConceptBlueprint {
        ConceptBlueprint(
            concept: SeedConcept(
                name: name,
                section: section,
                sourcePage: page,
                sourceSectionTitle: title,
                description: description,
                mastery: masteryValue(for: name),
                weakCount: weakCount(for: difficulty),
                tags: tags
            ),
            clozePrompt: clozePrompt,
            clozeAnswer: clozeAnswer,
            applicationPrompt: applicationPrompt,
            applicationAnswer: description,
            misconception: misconception,
            difficulty: difficulty
        )
    }

    private func masteryValue(for name: String) -> Double {
        let values = name.unicodeScalars.map { Int($0.value) }.reduce(0, +)
        return 0.56 + Double(values % 24) / 100.0
    }

    private func weakCount(for difficulty: CardDifficulty) -> Int {
        switch difficulty {
        case .easy:
            return 2
        case .medium:
            return 4
        case .hard:
            return 7
        }
    }
}

private struct ConceptBlueprint {
    let concept: SeedConcept
    let clozePrompt: String
    let clozeAnswer: String
    let applicationPrompt: String
    let applicationAnswer: String
    let misconception: String
    let difficulty: CardDifficulty
}

import Foundation

struct SeedConceptEdge: Codable, Hashable {
    var id: UUID = UUID()
    let fromConceptID: UUID
    let toConceptID: UUID
    let relationshipType: ConceptRelationshipType
    let strength: Double
}

final class ConceptGraphBuilder {
    func buildEdges(concepts: [SeedConcept]) -> [SeedConceptEdge] {
        let byName = Dictionary(uniqueKeysWithValues: concepts.map { ($0.name, $0.id) })

        func edge(_ from: String, _ to: String, _ type: ConceptRelationshipType, _ strength: Double) -> SeedConceptEdge? {
            guard let fromID = byName[from], let toID = byName[to] else { return nil }
            return SeedConceptEdge(fromConceptID: fromID, toConceptID: toID, relationshipType: type, strength: strength)
        }

        return [
            edge("Chemical Kinetics", "Enzyme Kinetics", .applicationOf, 0.82),
            edge("Enzyme Kinetics", "Michaelis-Menten", .applicationOf, 0.94),
            edge("Michaelis-Menten", "Km", .related, 0.91),
            edge("Michaelis-Menten", "Vmax", .related, 0.91),
            edge("Km", "Competitive Inhibition", .confusedWith, 0.86),
            edge("Vmax", "Noncompetitive Inhibition", .confusedWith, 0.86),
            edge("Uncompetitive Inhibition", "Lineweaver-Burk", .testedTogether, 0.88),
            edge("Competitive Inhibition", "Lineweaver-Burk", .testedTogether, 0.84),
            edge("Acids and Bases", "Equilibrium", .prerequisite, 0.78),
            edge("Electrochemistry", "Thermodynamics", .testedTogether, 0.78),
            edge("SN1/SN2/E1/E2", "Isomers", .testedTogether, 0.74),
            edge("Alcohol Oxidation", "Carbonyl Chemistry", .produces, 0.86),
            edge("Carbonyl Chemistry", "Carboxylic Acid Derivatives", .related, 0.81),
            edge("The Cell", "Immune System", .related, 0.72),
            edge("Nervous System", "Endocrine System", .testedTogether, 0.76),
            edge("Endocrine System", "GPCR", .applicationOf, 0.84),
            edge("GPCR", "IP3", .produces, 0.88),
            edge("IP3", "Calcium Signaling", .triggers, 0.91),
            edge("Glycolysis", "Pyruvate Kinase", .related, 0.86),
            edge("Glycolysis", "Citric Acid Cycle", .prerequisite, 0.77),
            edge("Citric Acid Cycle", "Oxidative Phosphorylation", .prerequisite, 0.82),
            edge("Amino Acids", "Protein Structure", .prerequisite, 0.8),
            edge("Learning and Memory", "Cognition", .testedTogether, 0.78),
            edge("Research Design", "Statistics", .testedTogether, 0.88),
            edge("Kinematics and Dynamics", "Work and Energy", .prerequisite, 0.82),
            edge("Fluids", "Cardiovascular System", .applicationOf, 0.76),
            edge("Circuits", "Electrochemistry", .confusedWith, 0.7),
            edge("Optics", "Waves and Sound", .testedTogether, 0.78)
        ].compactMap { $0 }
    }
}

import Foundation

struct PDFExtractedSection: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let sourceName: String
    let title: String
    let sectionName: String
    let page: Int
    let body: String
}

final class PDFImportService {
    static let shared = PDFImportService()

    private init() {}

    func sections(from extractedText: String, sourceName: String) -> [PDFExtractedSection] {
        let lines = extractedText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var sections: [PDFExtractedSection] = []
        var currentTitle: String?
        var currentPage = 1
        var currentLines: [String] = []

        for line in lines where !line.isEmpty {
            if let heading = parseHeading(line) {
                if let currentTitle {
                    sections.append(
                        PDFExtractedSection(
                            sourceName: sourceName,
                            title: currentTitle,
                            sectionName: sectionName(for: currentTitle),
                            page: currentPage,
                            body: currentLines.joined(separator: "\n")
                        )
                    )
                }
                currentTitle = heading.title
                currentPage = heading.page
                currentLines = []
            } else {
                currentLines.append(line)
            }
        }

        if let currentTitle {
            sections.append(
                PDFExtractedSection(
                    sourceName: sourceName,
                    title: currentTitle,
                    sectionName: sectionName(for: currentTitle),
                    page: currentPage,
                    body: currentLines.joined(separator: "\n")
                )
            )
        }

        return sections
    }

    func importPDF(at url: URL) -> [PDFExtractedSection] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return []
    }

    private func parseHeading(_ line: String) -> (title: String, page: Int)? {
        let prefixes = [
            "General Chemistry",
            "Organic Chemistry",
            "Biology",
            "Biochemistry",
            "Behavioral Sciences",
            "Physics and Math",
            "Appendix"
        ]

        guard prefixes.contains(where: { line.hasPrefix($0) }) else { return nil }
        let page = Int(line.split(separator: " ").last ?? "") ?? 1
        return (line, page)
    }

    private func sectionName(for title: String) -> String {
        if title.hasPrefix("General Chemistry") { return "General Chemistry" }
        if title.hasPrefix("Organic Chemistry") { return "Organic Chemistry" }
        if title.hasPrefix("Biology") { return "Biology" }
        if title.hasPrefix("Biochemistry") { return "Biochemistry" }
        if title.hasPrefix("Behavioral Sciences") { return "Psychology / Sociology" }
        if title.hasPrefix("Physics and Math") { return "Physics" }
        if title.hasPrefix("Appendix") { return "Appendix" }
        return "MCAT"
    }
}

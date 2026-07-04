import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: AppViewModel

    private let sectionGroups = [
        MCATSectionGroup(name: "Bio/Biochem", sections: ["Biology", "Biochemistry"], tint: .purple),
        MCATSectionGroup(name: "Chem/Phys", sections: ["General Chemistry", "Organic Chemistry", "Physics"], tint: .blue),
        MCATSectionGroup(name: "Psych/Soc", sections: ["Psychology / Sociology"], tint: .cyan),
        MCATSectionGroup(name: "CARS", sections: ["CARS"], tint: .orange)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                topMetrics
                applicationOverview
                recommendedFocusPanel
                sectionMasteryCards
                commandGrid
                applicationPanels
                weakestConceptsPanel
                conceptClustersAtRiskPanel
                forecastPanel
            }
            .padding(28)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("MCAT Command Center")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Retention, workload, weak concepts, and full-length review signals in one place.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("Next 7 days")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(nextSevenDayForecast.reduce(0) { $0 + $1.count }) cards")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.055)))
        }
    }

    private var topMetrics: some View {
        HStack(spacing: 16) {
            MetricTile(title: "Overall Retention", value: "\(viewModel.overallRetention)%", caption: "MCAT scheduled cards", tint: .blue)
            MetricTile(title: "Due Today", value: "\(viewModel.dueStudyCards.count)", caption: "Active recall queue", tint: .purple)
            MetricTile(title: "Completed Today", value: "\(viewModel.stats.completedToday)", caption: "Runtime session", tint: .cyan)
            MetricTile(title: "Confidence", value: String(format: "%.1f", viewModel.confidenceAverage), caption: "Average / 5", tint: .orange)
        }
    }

    private var applicationOverview: some View {
        HStack(alignment: .top, spacing: 16) {
            DashboardCard(title: "Content vs Application", systemImage: "arrow.left.arrow.right") {
                VStack(spacing: 14) {
                    comparisonBar(title: "Content Retention", value: viewModel.contentVsApplication.content, tint: .blue)
                    comparisonBar(title: "Application Accuracy", value: viewModel.contentVsApplication.application, tint: .orange)
                }
            }

            DashboardCard(title: "Application Weakness", systemImage: "exclamationmark.triangle.fill") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.applicationWeaknesses, id: \.self) { section in
                        HStack {
                            Text(section)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("needs reps")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.orange)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                    }
                }
            }
        }
    }

    private var applicationPanels: some View {
        HStack(alignment: .top, spacing: 16) {
            DashboardCard(title: "Practice Accuracy by Section", systemImage: "scope") {
                VStack(spacing: 12) {
                    ForEach(viewModel.practiceAccuracyBySection, id: \.section) { item in
                        comparisonBar(title: item.section, value: item.accuracy, tint: item.accuracy < 0.7 ? .orange : .green, caption: "\(item.completed) completed")
                    }
                }
            }

            DashboardCard(title: "Missed Question Patterns", systemImage: "list.bullet.clipboard.fill") {
                VStack(spacing: 10) {
                    ForEach(viewModel.missedQuestionPatterns, id: \.reason) { pattern in
                        HStack {
                            Text(pattern.reason.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(pattern.count)")
                                .font(.headline)
                                .foregroundStyle(pattern.count > 0 ? .orange : .secondary)
                        }
                        .padding(11)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                    }
                }
            }
        }
    }

    private var recommendedFocusPanel: some View {
        let concept = viewModel.weakestConcepts.first
        let source = concept?.section ?? viewModel.weakestSection
        let action = concept?.recommendedAction.rawValue ?? "Clear due cards"

        return DashboardCard(title: "Recommended Focus Today", systemImage: "target") {
            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(concept?.name ?? viewModel.recommendedFocus)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Prioritize \(source), then clear the due cards tied to missed questions and low-confidence reviews.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)

                    HStack(spacing: 8) {
                        focusPill(action, tint: .purple)
                        focusPill("\(concept?.missedCards ?? 0) missed", tint: .orange)
                        focusPill("\(Int((concept?.mastery ?? 0) * 100))% mastery", tint: .blue)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Workload")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.dueStudyCards.count)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("cards due today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var sectionMasteryCards: some View {
        HStack(spacing: 16) {
            ForEach(sectionGroups) { group in
                sectionCard(group)
            }
        }
    }

    private var commandGrid: some View {
        HStack(alignment: .top, spacing: 16) {
            missReasonPanel
            fullLengthPanel
        }
    }

    private var missReasonPanel: some View {
        DashboardCard(title: "Miss Reason Breakdown", systemImage: "questionmark.bubble.fill") {
            VStack(spacing: 12) {
                ForEach(viewModel.missReasonBreakdown, id: \.reason) { item in
                    missReasonBar(reason: item.reason, count: item.count)
                }
            }
        }
    }

    private var fullLengthPanel: some View {
        DashboardCard(title: "Full-Length Connection", systemImage: "doc.text.magnifyingglass") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .lastTextBaseline) {
                    Text("\(viewModel.fullLengthReviewCards.count)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("AAMC-linked cards")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.fullLengthReviewCards.prefix(4)) { card in
                    HStack(spacing: 10) {
                        Text("FL\(card.linkedFullLengthExamNumber ?? 0)")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.red.opacity(0.28)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.concepts.first?.name ?? card.deckName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(card.missReason?.rawValue ?? "Review source error")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                }
            }
        }
    }

    private var weakestConceptsPanel: some View {
        DashboardCard(title: "Weakest Concepts: Top 5", systemImage: "brain.head.profile") {
            VStack(spacing: 12) {
                ForEach(Array(viewModel.weakestConcepts.prefix(5).enumerated()), id: \.element.id) { index, concept in
                    weakestConceptRow(rank: index + 1, concept: concept)
                }
            }
        }
    }

    private var forecastPanel: some View {
        DashboardCard(title: "Next 7 Days Forecast", systemImage: "calendar") {
            HStack(spacing: 12) {
                ForEach(nextSevenDayForecast) { day in
                    forecastCard(day)
                }
            }
        }
    }

    private var conceptClustersAtRiskPanel: some View {
        DashboardCard(title: "Concept Clusters at Risk", systemImage: "point.3.connected.trianglepath.dotted") {
            VStack(spacing: 12) {
                ForEach(conceptClustersAtRisk.prefix(4), id: \.concept.id) { cluster in
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(cluster.concept.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(cluster.linkedWeakConcepts.map(\.name).joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(cluster.linkedWeakConcepts.count + 1)")
                                .font(.title3.bold())
                                .foregroundStyle(.orange)
                            Text("weak nodes")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            viewModel.selectGraphConcept(cluster.concept)
                        } label: {
                            Image(systemName: "arrow.up.right")
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.2)))
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                }
            }
        }
    }

    private func comparisonBar(title: String, value: Double, tint: Color, caption: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(tint)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.07))
                    Capsule()
                        .fill(tint.opacity(0.75))
                        .frame(width: proxy.size.width * max(0, min(value, 1)))
                }
            }
            .frame(height: 9)

            if let caption {
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
    }

    private func sectionCard(_ group: MCATSectionGroup) -> some View {
        let mastery = masteryForGroup(group)
        let due = dueCardsForGroup(group)
        let weak = weakConceptsForGroup(group)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Text("\(Int(mastery * 100))%")
                    .font(.headline)
                    .foregroundStyle(group.tint)
            }

            ProgressView(value: mastery)
                .tint(mastery < 0.68 ? .orange : group.tint)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(due)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text("due")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(weak)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text("weak")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(group.tint.opacity(0.12))
                .stroke(group.tint.opacity(0.28), lineWidth: 1)
        )
    }

    private func missReasonBar(reason: MissReason, count: Int) -> some View {
        let maxCount = max(viewModel.missReasonBreakdown.map(\.count).max() ?? 1, 1)
        let fraction = Double(count) / Double(maxCount)

        return VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(reason.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(count)")
                    .font(.caption.bold())
                    .foregroundStyle(count > 0 ? .orange : .secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.07))
                    Capsule()
                        .fill(LinearGradient(colors: [.orange, .purple], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(proxy.size.width * fraction, count > 0 ? 8 : 0))
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
    }

    private func weakestConceptRow(rank: Int, concept: ConceptNode) -> some View {
        HStack(spacing: 14) {
            Text("#\(rank)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .leading)

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(concept.name)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(Int(concept.mastery * 100))%")
                        .font(.subheadline.bold())
                        .foregroundStyle(concept.mastery < 0.68 ? .orange : .green)
                }

                ProgressView(value: concept.mastery)
                    .tint(concept.mastery < 0.68 ? .orange : .purple)

                HStack(spacing: 12) {
                    Text(concept.section)
                    Text("\(concept.missedCards) missed")
                    Text(concept.recommendedAction.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
    }

    private func forecastCard(_ day: ForecastDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(day.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("\(day.count)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(day.caption)
                .font(.caption2)
                .foregroundStyle(day.count > 0 ? .purple : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.052))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func focusPill(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
            .background(Capsule().fill(tint.opacity(0.2)))
    }

    private func masteryForGroup(_ group: MCATSectionGroup) -> Double {
        let cards = viewModel.studyCards.filter { group.sections.contains($0.section) }
        guard !cards.isEmpty else { return 0 }
        return cards.map(\.retentionScore).reduce(0, +) / Double(cards.count)
    }

    private func dueCardsForGroup(_ group: MCATSectionGroup) -> Int {
        viewModel.dueStudyCards.filter { group.sections.contains($0.section) }.count
    }

    private func weakConceptsForGroup(_ group: MCATSectionGroup) -> Int {
        viewModel.weakestConcepts.filter { group.sections.contains($0.section) && $0.mastery < 0.7 }.count
    }

    private var nextSevenDayForecast: [ForecastDay] {
        (1...7).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
            let count = cardsDue(on: date)
            return ForecastDay(
                label: shortWeekday(for: date),
                count: count,
                caption: offset == 1 ? "tomorrow" : "scheduled"
            )
        }
    }

    private func cardsDue(on date: Date) -> Int {
        let target = Calendar.current.startOfDay(for: date)
        return viewModel.studyCards.filter { Calendar.current.startOfDay(for: $0.dueDate) == target }.count
    }

    private func shortWeekday(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var conceptClustersAtRisk: [(concept: ConceptNode, linkedWeakConcepts: [ConceptNode])] {
        viewModel.graphConcepts
            .map { concept in
                let linkedWeak = viewModel.relatedConcepts(for: concept).filter { $0.mastery < 0.7 }
                return (concept, linkedWeak)
            }
            .filter { $0.concept.mastery < 0.7 && !$0.linkedWeakConcepts.isEmpty }
            .sorted {
                if $0.linkedWeakConcepts.count == $1.linkedWeakConcepts.count {
                    return $0.concept.mastery < $1.concept.mastery
                }
                return $0.linkedWeakConcepts.count > $1.linkedWeakConcepts.count
            }
    }
}

private struct MCATSectionGroup: Identifiable {
    let id = UUID()
    let name: String
    let sections: [String]
    let tint: Color
}

private struct ForecastDay: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
    let caption: String
}

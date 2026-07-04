import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                metrics
                focusCard
                weakConceptNetworkCard
                deckSection
            }
            .padding(28)
        }
        .background(Color.clear)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("MCAT Review")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Today’s queue is tuned for active recall, weak concepts, and full-length mistakes.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.selectedScreen = .review
            } label: {
                Label("Start Review", systemImage: "play.fill")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
    }

    private var metrics: some View {
        HStack(spacing: 16) {
            MetricTile(title: "Due Today", value: "\(viewModel.dueStudyCards.count)", caption: "MCAT cards ready", tint: .purple)
            MetricTile(title: "Retention", value: "\(viewModel.overallRetention)%", caption: "Across MCAT cards", tint: .blue)
            MetricTile(title: "Weakest Section", value: viewModel.weakestSection, caption: "Needs attention", tint: .orange)
        }
    }

    private var focusCard: some View {
        DashboardCard(title: "Recommended Focus", systemImage: "target") {
            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.recommendedFocus)
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Start with the weakest concept, then clear due cards from the same MCAT section.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Tomorrow")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.tomorrowForecast) due")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Next 7 days: \(viewModel.nextSevenDaysForecast)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var deckSection: some View {
        DashboardCard(title: "MCAT Decks", systemImage: "rectangle.stack.fill") {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.decks) { deck in
                    Button {
                        viewModel.selectDeck(deck)
                    } label: {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Circle()
                                    .fill(deck.accentColor)
                                    .frame(width: 10, height: 10)

                                Text(deck.name)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)

                                Spacer()
                            }

                            Text(deck.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)

                            ProgressView(value: deck.mastery)
                                .tint(deck.accentColor)

                            HStack {
                                Text("\(deck.dueToday) due")
                                Spacer()
                                Text("\(Int(deck.mastery * 100))% mastery")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.055))
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var weakConceptNetworkCard: some View {
        DashboardCard(title: "Weak Concept Network", systemImage: "point.3.connected.trianglepath.dotted") {
            HStack(alignment: .top, spacing: 14) {
                ForEach(Array(viewModel.weakestConcepts.prefix(3).enumerated()), id: \.element.id) { index, concept in
                    Button {
                        viewModel.selectGraphConcept(concept)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(viewModel.relatedConcepts(for: concept).count) links")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.purple)
                            }

                            Text(concept.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text("\(concept.section) • \(concept.weakCount) weak cards")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ProgressView(value: concept.mastery)
                                .tint(concept.mastery < 0.65 ? .orange : .purple)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

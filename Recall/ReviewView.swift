import SwiftUI

struct ReviewView: View {
    @ObservedObject var viewModel: AppViewModel

    private var card: StudyCard {
        viewModel.currentStudyCard
    }

    private var cardMaxWidth: CGFloat {
        viewModel.isReviewFocusMode ? 920 : 780
    }

    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    reviewHeader
                    reviewCard
                    relatedConcepts
                    CardLineageView(card: card, lineage: viewModel.lineage(for: card), reviewHistory: viewModel.reviewHistory)
                }
                .padding(viewModel.isReviewFocusMode ? 40 : 28)
                .frame(maxWidth: .infinity, alignment: viewModel.isReviewFocusMode ? .center : .leading)
            }

            if !viewModel.isReviewFocusMode && viewModel.isRightInspectorVisible {
                AnalyticsPanel(viewModel: viewModel)
                    .frame(width: 300)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isReviewFocusMode)
    }

    private var reviewHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(card.deckName) • \(card.section)")
                        .font(.caption)
                        .foregroundStyle(.purple)
                        .fontWeight(.semibold)

                    Text(viewModel.isReviewFocusMode ? "Focus Review" : "MCAT Active Recall")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 10) {
                    Text(viewModel.reviewProgressText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleReviewFocusMode()
                            }
                        } label: {
                            Label(viewModel.isReviewFocusMode ? "Exit Focus Mode" : "Focus Mode", systemImage: viewModel.isReviewFocusMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.isReviewFocusMode ? Color.white.opacity(0.08) : Color.purple.opacity(0.22))
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .keyboardShortcut("f", modifiers: [])
                    }
                }
            }

            ProgressView(value: viewModel.reviewProgress)
                .tint(.purple)
        }
        .frame(maxWidth: cardMaxWidth)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var reviewCard: some View {
        VStack(spacing: 24) {
            VStack(spacing: 14) {
                Text(card.front)
                    .font(.system(size: viewModel.isReviewFocusMode ? 30 : 27, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                HStack(spacing: 8) {
                    capsule(card.cardType.rawValue)
                    capsule("Difficulty: \(card.difficulty.rawValue)")
                    capsule("Ease: \(String(format: "%.2f", card.easeFactor))")
                    capsule("Interval: \(card.reviewIntervalDays)d")
                }

                Text(card.sourceReferenceText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Divider()
                .overlay(Color.white.opacity(0.12))

            if viewModel.isShowingReflection {
                reflectionPanel
            } else if viewModel.isShowingAnswer {
                Text(card.back)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                ratingButtons
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showAnswer()
                    }
                } label: {
                    Label("Show Answer", systemImage: "eye.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .frame(maxWidth: 220)
                .keyboardShortcut(.space, modifiers: [])
            }
        }
        .frame(maxWidth: cardMaxWidth)
        .frame(minHeight: viewModel.isReviewFocusMode ? 500 : 430)
        .padding(viewModel.isReviewFocusMode ? 40 : 34)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.07))
                .stroke(
                    LinearGradient(colors: [.purple.opacity(0.8), .blue.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var ratingButtons: some View {
        VStack(spacing: 10) {
            Text("Grade recall quality")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(ReviewRating.allCases) { rating in
                    ratingButton(rating)
                }
            }
        }
    }

    private func ratingButton(_ rating: ReviewRating) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.rateCurrentCard(rating)
            }
        } label: {
            VStack(spacing: 4) {
                Text(rating.rawValue)
                    .fontWeight(.semibold)
                Text(nextDueLabel(for: rating))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.72))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(rating.tint.opacity(0.28))
                .stroke(rating.tint.opacity(0.65), lineWidth: 1)
        )
        .keyboardShortcut(rating.shortcutKey, modifiers: [])
    }

    private var reflectionPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Quick Reflection")
                .font(.title3.bold())
                .foregroundStyle(.white)

            reflectionChoices

            VStack(alignment: .leading, spacing: 10) {
                Text("Confidence")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        confidenceButton(value)
                    }
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.saveReflectionAndAdvance()
                }
            } label: {
                Label("Save Reflection & Next Card", systemImage: "arrow.right.circle.fill")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var reflectionChoices: some View {
        if viewModel.pendingRating == .good || viewModel.pendingRating == .easy {
            VStack(alignment: .leading, spacing: 10) {
                Text("How solid did that feel?")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(CorrectReflection.allCases) { reflection in
                        correctReflectionButton(reflection)
                    }
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Why did you miss this?")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                    ForEach(MissReason.allCases) { reason in
                        missReasonButton(reason)
                    }
                }
            }
        }
    }

    private func missReasonButton(_ reason: MissReason) -> some View {
        let isSelected = viewModel.selectedMissReason == reason

        return Button {
            viewModel.selectedMissReason = reason
        } label: {
            Text(reason.rawValue)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.purple.opacity(0.28) : Color.white.opacity(0.055))
                        .stroke(isSelected ? Color.purple.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func correctReflectionButton(_ reflection: CorrectReflection) -> some View {
        let isSelected = viewModel.selectedCorrectReflection == reflection

        return Button {
            viewModel.selectedCorrectReflection = reflection
        } label: {
            Text(reflection.rawValue)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.green.opacity(0.22) : Color.white.opacity(0.055))
                        .stroke(isSelected ? Color.green.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func confidenceButton(_ value: Int) -> some View {
        let isSelected = viewModel.selectedConfidence == value

        return Button {
            viewModel.selectedConfidence = value
        } label: {
            Text("\(value)")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 38)
                .contentShape(Rectangle())
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.28) : Color.white.opacity(0.055))
                        .stroke(isSelected ? Color.blue.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 48)
    }

    private var relatedConcepts: some View {
        DashboardCard(title: "Related MCAT Concepts", systemImage: "point.3.connected.trianglepath.dotted") {
            VStack(spacing: 12) {
                ForEach(card.concepts) { concept in
                    HStack(spacing: 14) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(concept.mastery < 0.7 ? .orange : .purple)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(concept.name)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("\(concept.section) • \(concept.recommendedAction.rawValue)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {
                            viewModel.selectGraphConcept(concept)
                        } label: {
                            Label("Open in Graph", systemImage: "point.3.connected.trianglepath.dotted")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.2)))

                        Text("\(Int(concept.mastery * 100))%")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
        }
        .frame(maxWidth: cardMaxWidth)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func capsule(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.white.opacity(0.08)))
    }

    private func nextDueLabel(for rating: ReviewRating) -> String {
        switch rating {
        case .again:
            return "today"
        case .hard:
            return "tomorrow"
        case .good:
            return "3 days"
        case .easy:
            return "7 days"
        }
    }
}

struct AnalyticsPanel: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Session")
                .font(.title2.bold())
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                Text("Daily Progress")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ProgressView(value: viewModel.stats.dailyProgress)
                    .tint(.purple)

                Text("\(viewModel.stats.completedToday) / \(viewModel.stats.cardsDueToday) complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .overlay(Color.white.opacity(0.12))

            panelMetric(title: "Retention", value: "\(viewModel.overallRetention)%", icon: "target")
            panelMetric(title: "Due Today", value: "\(viewModel.dueStudyCards.count)", icon: "tray.full.fill")
            panelMetric(title: "Confidence", value: String(format: "%.1f / 5", viewModel.confidenceAverage), icon: "gauge.with.dots.needle.50percent")
            panelMetric(title: "Weakest", value: viewModel.weakestSection, icon: "exclamationmark.triangle.fill")

            Spacer()
        }
        .padding(22)
        .background(Color.black.opacity(0.22))
    }

    private func panelMetric(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.055))
        )
    }
}

private extension ReviewRating {
    var shortcutKey: KeyEquivalent {
        switch self {
        case .again:
            return "1"
        case .hard:
            return "2"
        case .good:
            return "3"
        case .easy:
            return "4"
        }
    }
}

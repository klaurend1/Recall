import SwiftUI

struct PracticeView: View {
    @ObservedObject var viewModel: AppViewModel

    private var question: PracticeQuestion {
        viewModel.currentPracticeQuestion
    }

    private var confusedWithConcepts: [ConceptNode] {
        let testedIDs = Set(question.testedConcepts.map(\.id))
        let confusedIDs = viewModel.conceptEdges.compactMap { edge -> UUID? in
            guard edge.relationshipType == .confusedWith else { return nil }
            if testedIDs.contains(edge.fromConceptID) { return edge.toConceptID }
            if testedIDs.contains(edge.toConceptID) { return edge.fromConceptID }
            return nil
        }
        return viewModel.graphConcepts.filter { confusedIDs.contains($0.id) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    sectionTabs
                    questionCard
                }
                .padding(28)
            }

            if !viewModel.isPracticeFocusMode && viewModel.isRightInspectorVisible {
                practiceSidePanel
                    .frame(width: 310)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isPracticeFocusMode)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isRightInspectorVisible)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Application Practice")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("AAMC-style mock questions for students who know content but need application reps.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(viewModel.practiceProgressText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
        }
    }

    private var sectionTabs: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.practiceSections, id: \.self) { section in
                let isSelected = viewModel.selectedPracticeSection == section

                Button {
                    viewModel.selectPracticeSection(section)
                } label: {
                    Text(section)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .frame(minHeight: 34)
                        .contentShape(Rectangle())
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.purple.opacity(0.28) : Color.white.opacity(0.055))
                                .stroke(isSelected ? Color.purple.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                sourceBadge
                Spacer()
                Text(question.applicationSkill)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Passage / Context")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.purple)
                Text(question.passage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }

            Divider().overlay(Color.white.opacity(0.12))

            Text(question.stem)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .lineSpacing(3)

            VStack(spacing: 10) {
                ForEach(Array(question.answerChoices.enumerated()), id: \.offset) { index, choice in
                    answerChoice(index: index, choice: choice)
                }
            }

            if viewModel.isShowingPracticeResult {
                resultPanel
            }
        }
        .padding(24)
        .frame(maxWidth: 840, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.065))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var sourceBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.text.magnifyingglass")
            Text(question.sourceLabel)
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.blue.opacity(0.22)))
    }

    private func answerChoice(index: Int, choice: String) -> some View {
        let isSelected = viewModel.selectedPracticeAnswerIndex == index
        let isCorrect = index == question.correctAnswerIndex
        let shouldShowCorrect = viewModel.isShowingPracticeResult && isCorrect
        let shouldShowIncorrect = viewModel.isShowingPracticeResult && isSelected && !isCorrect
        let tint: Color = shouldShowCorrect ? .green : (shouldShowIncorrect ? .red : (isSelected ? .purple : .white))

        return Button {
            if !viewModel.isShowingPracticeResult {
                viewModel.selectPracticeAnswer(index)
            }
        } label: {
            HStack(spacing: 12) {
                Text(String(UnicodeScalar(65 + index) ?? "A"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(tint.opacity(0.24)))

                Text(choice)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                Spacer()

                if shouldShowCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if shouldShowIncorrect {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tint.opacity(isSelected || shouldShowCorrect ? 0.16 : 0.055))
                    .stroke(tint.opacity(isSelected || shouldShowCorrect ? 0.55 : 0.09), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var resultPanel: some View {
        let isCorrect = viewModel.selectedPracticeAnswerIndex == question.correctAnswerIndex

        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label(isCorrect ? "Correct" : "Incorrect", systemImage: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(isCorrect ? .green : .red)
                Spacer()
            }

            Text(question.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            conceptResultPanel

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

            VStack(alignment: .leading, spacing: 6) {
                Text("Follow-up suggestion")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(viewModel.currentPracticeFollowUpSuggestion)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineSpacing(3)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.14)))

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.savePracticeReflectionAndAdvance()
                }
            } label: {
                Label("Save Reflection & Next Question", systemImage: "arrow.right.circle.fill")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)

            Button {
                viewModel.selectedScreen = .library
            } label: {
                Label("Create linked card", systemImage: "plus.rectangle.on.rectangle")
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.07)))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.18))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var practiceSidePanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Practice Signals")
                .font(.title2.bold())
                .foregroundStyle(.white)

            sideMetric(title: "Completed", value: "\(viewModel.practiceResults.count)", icon: "checklist.checked")
            sideMetric(title: "Current Section", value: viewModel.selectedPracticeSection, icon: "square.grid.2x2.fill")
            sideMetric(title: "Tested Concepts", value: question.testedConcepts.map(\.name).joined(separator: ", "), icon: "brain.head.profile")

            DashboardCard(title: "Why This Exists", systemImage: "bolt.fill") {
                Text("This layer targets application errors: the student may know the content but still miss questions because of setup, wording, timing, or concept transfer.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(22)
        .background(Color.black.opacity(0.22))
    }

    private var conceptResultPanel: some View {
        HStack(alignment: .top, spacing: 12) {
            conceptColumn(title: "Tested Concepts", concepts: question.testedConcepts, tint: .purple)
            conceptColumn(title: "Confused With", concepts: confusedWithConcepts, tint: .orange)
        }
    }

    private func conceptColumn(title: String, concepts: [ConceptNode], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if concepts.isEmpty {
                Text("No linked concepts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
            } else {
                ForEach(concepts) { concept in
                    Button {
                        viewModel.selectGraphConcept(concept)
                    } label: {
                        Text(concept.name)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .background(RoundedRectangle(cornerRadius: 8).fill(tint.opacity(0.18)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func missReasonButton(_ reason: MissReason) -> some View {
        let isSelected = viewModel.practiceMissReason == reason

        return Button {
            viewModel.practiceMissReason = reason
        } label: {
            Text(reason.rawValue)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
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

    private func confidenceButton(_ value: Int) -> some View {
        let isSelected = viewModel.practiceConfidence == value

        return Button {
            viewModel.practiceConfidence = value
        } label: {
            Text("\(value)")
                .font(.headline)
                .frame(width: 42, height: 36)
                .contentShape(Rectangle())
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.28) : Color.white.opacity(0.055))
                        .stroke(isSelected ? Color.blue.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func sideMetric(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.055)))
    }
}

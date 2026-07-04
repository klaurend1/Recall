import SwiftUI

struct CommandPaletteView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    private var actionResults: [PaletteAction] {
        let actions = [
            PaletteAction(title: "Open Graph", subtitle: "Go to the knowledge graph", systemImage: "point.3.connected.trianglepath.dotted") {
                viewModel.selectedScreen = .graph
            },
            PaletteAction(title: "Start Review", subtitle: "Open the active recall queue", systemImage: "rectangle.stack.fill") {
                viewModel.selectedScreen = .review
            },
            PaletteAction(title: "Start Practice", subtitle: "Open application practice", systemImage: "checklist.checked") {
                viewModel.selectedScreen = .practice
            },
            PaletteAction(title: "Open Library", subtitle: "Browse decks, cards, tags, and sources", systemImage: "books.vertical.fill") {
                viewModel.selectedScreen = .library
            },
            PaletteAction(title: "Jump to Weak Concepts", subtitle: "Open graph with weak concept focus", systemImage: "exclamationmark.triangle.fill") {
                viewModel.isFocusingWeakGraphConcepts = true
                if let concept = viewModel.weakestConcepts.first {
                    viewModel.selectedGraphConcept = concept
                }
                viewModel.selectedScreen = .graph
            }
        ]

        guard !query.isEmpty else { return actions }
        let needle = query.lowercased()
        return actions.filter {
            $0.title.lowercased().contains(needle) || $0.subtitle.lowercased().contains(needle)
        }
    }

    private var searchResults: [SemanticSearchResult] {
        viewModel.semanticSearchResults(for: query)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.52)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(alignment: .leading, spacing: 12) {
                searchField

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if !actionResults.isEmpty {
                            resultSection(title: "Actions") {
                                ForEach(actionResults) { action in
                                    actionRow(action)
                                }
                            }
                        }

                        if !searchResults.isEmpty {
                            resultSection(title: "Search") {
                                ForEach(searchResults.prefix(8)) { result in
                                    searchRow(result)
                                }
                            }
                        }

                        if actionResults.isEmpty && searchResults.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
            .padding(14)
            .frame(width: 620, height: 520, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.07, green: 0.075, blue: 0.105))
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    .shadow(color: .black.opacity(0.35), radius: 28, x: 0, y: 18)
            )
            .padding(.top, 74)
        }
        .onAppear {
            isSearchFocused = true
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "command")
                .foregroundStyle(.purple)

            TextField("Search Recall or run an action", text: $query)
                .textFieldStyle(.plain)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .focused($isSearchFocused)

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.07))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func resultSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 2)
            content()
        }
    }

    private func actionRow(_ action: PaletteAction) -> some View {
        Button {
            action.perform()
            isPresented = false
        } label: {
            HStack(spacing: 12) {
                Image(systemName: action.systemImage)
                    .foregroundStyle(.purple)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text(action.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(action.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
        }
        .buttonStyle(.plain)
    }

    private func searchRow(_ result: SemanticSearchResult) -> some View {
        Button {
            open(result)
            isPresented = false
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon(for: result.type))
                    .foregroundStyle(tint(for: result.type))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(result.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(result.type.rawValue.capitalized)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(tint(for: result.type))
                    }

                    Text(result.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(12)
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No results")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Try graph, review, IP3, enzyme, Kaplan, or weak concepts.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.04)))
    }

    private func open(_ result: SemanticSearchResult) {
        switch result.type {
        case .card:
            viewModel.selectedScreen = .review
        case .concept:
            if let concept = viewModel.graphConcepts.first(where: { $0.name == result.title }) {
                viewModel.selectedGraphConcept = concept
            }
            viewModel.selectedScreen = .graph
        case .deck:
            if let deck = viewModel.studyDecks.first(where: { $0.name == result.title }) {
                viewModel.selectedStudyDeck = deck
            }
            viewModel.selectedScreen = .library
        case .source:
            viewModel.selectedScreen = .library
        }
    }

    private func icon(for type: SemanticSearchResultType) -> String {
        switch type {
        case .card:
            return "rectangle.stack.fill"
        case .concept:
            return "brain.head.profile"
        case .deck:
            return "books.vertical.fill"
        case .source:
            return "book.closed.fill"
        }
    }

    private func tint(for type: SemanticSearchResultType) -> Color {
        switch type {
        case .card:
            return .blue
        case .concept:
            return .purple
        case .deck:
            return .orange
        case .source:
            return .green
        }
    }
}

private struct PaletteAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let perform: () -> Void
}

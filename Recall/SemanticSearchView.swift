import SwiftUI

struct SemanticSearchView: View {
    @ObservedObject var viewModel: AppViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        DashboardCard(title: "Semantic Search Mock", systemImage: "magnifyingglass.circle.fill") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search cards, concepts, decks, or sources", text: $viewModel.semanticSearchText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .focused($isSearchFocused)

                    Button {
                        isSearchFocused = true
                    } label: {
                        Text("⌘K")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.24)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.07)))

                if viewModel.semanticSearchResults.isEmpty {
                    emptySearchState
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 230), spacing: 10)], spacing: 10) {
                        ForEach(viewModel.semanticSearchResults.prefix(4)) { result in
                            searchResultCard(result)
                        }
                    }
                }
            }
        }
    }

    private func searchResultCard(_ result: SemanticSearchResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon(for: result.type))
                    .foregroundStyle(tint(for: result.type))
                    .frame(width: 18)

                Text(result.type.rawValue.capitalized)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint(for: result.type))

                Spacer()

                Text("\(Int(result.relevanceScore * 100))")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }

            Text(result.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(result.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if !result.relatedConcepts.isEmpty {
                Text(result.relatedConcepts.prefix(2).joined(separator: ", "))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.purple)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var emptySearchState: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text("No search results")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("Try IP3, enzyme, Km, Biology, or Kaplan.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.045))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
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

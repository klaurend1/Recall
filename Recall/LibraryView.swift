import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var hoveredDeckID: UUID?
    @State private var editingCard: StudyCard?
    @State private var cardFront = ""
    @State private var cardBack = ""
    @State private var cardTags = ""
    @State private var importExportMessage = ""
    @State private var isShowingDetails = true

    private func deckColumns(for width: CGFloat) -> [GridItem] {
        let minimum = width < 620 ? 220.0 : 250.0
        return [GridItem(.adaptive(minimum: minimum), spacing: 14)]
    }

    private var selectedDeckForPreview: StudyDeck? {
        guard let selectedDeck = viewModel.selectedStudyDeck else { return nil }
        return viewModel.filteredStudyDecks.contains(selectedDeck) ? selectedDeck : nil
    }

    var body: some View {
        GeometryReader { proxy in
            let detailsWidth = min(320.0, max(280.0, proxy.size.width * 0.28))
            let shouldShowContext = viewModel.isContextPanelVisible && !viewModel.isCurrentScreenFocused
            let shouldShowDetails = isShowingDetails && viewModel.isRightInspectorVisible && !viewModel.isCurrentScreenFocused && proxy.size.width >= 980
            let contextWidth = shouldShowContext ? 230.0 : 0
            let gridWidth = max(260.0, proxy.size.width - contextWidth - (shouldShowDetails ? detailsWidth : 0) - 72)

            VStack(alignment: .leading, spacing: 14) {
                header

                if !importExportMessage.isEmpty {
                    Text(importExportMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                }

                HStack(alignment: .top, spacing: 14) {
                    if shouldShowContext {
                        folderColumn
                            .frame(width: 230)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }

                    mainDeckArea(width: gridWidth)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if shouldShowDetails {
                        deckPreviewPanel
                            .frame(width: detailsWidth)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .padding(proxy.size.width < 1180 ? 18 : 28)
            .animation(.easeInOut(duration: 0.18), value: isShowingDetails)
            .animation(.easeInOut(duration: 0.18), value: viewModel.isContextPanelVisible)
            .animation(.easeInOut(duration: 0.18), value: viewModel.isRightInspectorVisible)
        }
    }

    private var header: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Library")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Folders, concepts, tags, and sources in one study filing system.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    isShowingDetails.toggle()
                } label: {
                    Label(isShowingDetails ? "Hide Details" : "Show Details", systemImage: isShowingDetails ? "sidebar.right" : "sidebar.right.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))

                Button {
                    importExportMessage = "Exported to \(viewModel.exportSelectedDeckToJSON())"
                } label: {
                    Label("Export Deck", systemImage: "square.and.arrow.up")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))

                Button {
                    importExportMessage = viewModel.importDeckFromJSON()
                } label: {
                    Label("Import Deck", systemImage: "square.and.arrow.down")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search decks, tags, or descriptions", text: $viewModel.librarySearchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(width: 360)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.075))
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }

    private var folderColumn: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Folders")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(viewModel.studyFolders.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.white.opacity(0.07)))
            }

            if viewModel.studyFolders.isEmpty {
                compactEmptyState(icon: "folder", title: "No folders", message: "Create a folder to start filing decks.")
            } else {
                VStack(spacing: 7) {
                    ForEach(viewModel.studyFolders) { folder in
                        folderRow(folder)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.055))
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    private func folderRow(_ folder: StudyFolder) -> some View {
        let isSelected = viewModel.selectedStudyFolder == folder

        return Button {
            viewModel.selectStudyFolder(folder)
        } label: {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(folder.accentColor.opacity(isSelected ? 0.26 : 0.14))

                    Image(systemName: folder.systemImage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(folder.accentColor)
                }
                .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    Text("\(deckCount(for: folder)) decks")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(folder.accentColor)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .foregroundStyle(isSelected ? .white : .secondary)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? folder.accentColor.opacity(0.2) : Color.white.opacity(0.035))
                    .stroke(isSelected ? folder.accentColor.opacity(0.55) : Color.white.opacity(0.055), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func mainDeckArea(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            filterChips

            if viewModel.selectedStudyFolder == nil {
                largeEmptyState(icon: "folder.fill.badge.questionmark", title: "Select a folder", message: "Choose a folder to browse its decks, concepts, and sources.")
            } else if viewModel.filteredStudyDecks.isEmpty {
                largeEmptyState(icon: "tray", title: "No decks match this view", message: "Try another filter or search term.")
            } else {
                ScrollView {
                    LazyVGrid(columns: deckColumns(for: width), spacing: 14) {
                        ForEach(viewModel.filteredStudyDecks) { deck in
                            deckCard(deck)
                        }
                    }
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
                }
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LibraryFilter.allCases) { filter in
                    let isSelected = viewModel.selectedLibraryFilter == filter

                    Button {
                        viewModel.selectLibraryFilter(filter)
                    } label: {
                        Text(filter.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minHeight: 32)
                            .contentShape(Rectangle())
                            .foregroundStyle(isSelected ? .white : .secondary)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.purple.opacity(0.28) : Color.white.opacity(0.06))
                                    .stroke(isSelected ? Color.purple.opacity(0.6) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func deckCard(_ deck: StudyDeck) -> some View {
        let isSelected = selectedDeckForPreview == deck
        let isHovered = hoveredDeckID == deck.id

        return Button {
            viewModel.selectedStudyDeck = deck
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(deck.accentColor.opacity(0.2))

                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(deck.accentColor)
                    }
                    .frame(width: 38, height: 38)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(deck.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(deck.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    sourceBadge(deck.primarySourceType, tint: deck.accentColor)
                    Spacer()
                    Text("\(Int(deck.mastery * 100))% mastery")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(deck.accentColor)
                }

                ProgressView(value: deck.mastery)
                    .tint(deck.accentColor)

                HStack(spacing: 8) {
                    miniMetric(value: "\(deck.cardCount)", label: "cards")
                    miniMetric(value: "\(deck.dueToday)", label: "due")
                    miniMetric(value: "\(deck.linkedConcepts.count)", label: "concepts")
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 164, alignment: .topLeading)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(cardFill(isSelected: isSelected, isHovered: isHovered))
                    .stroke(cardStroke(deck: deck, isSelected: isSelected, isHovered: isHovered), lineWidth: isSelected ? 1.5 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(deck.accentColor)
                        .padding(12)
                }
            }
            .shadow(color: isHovered ? deck.accentColor.opacity(0.18) : .clear, radius: 12, x: 0, y: 8)
            .scaleEffect(isHovered ? 1.012 : 1)
            .animation(.easeOut(duration: 0.16), value: isHovered)
            .animation(.easeOut(duration: 0.16), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            hoveredDeckID = isHovering ? deck.id : nil
        }
    }

    @ViewBuilder
    private var deckPreviewPanel: some View {
        if let deck = selectedDeckForPreview {
            ScrollView {
                selectedDeckPanel(deck)
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "sidebar.right")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Text("No deck selected")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Select a deck card to inspect tags, concepts, sources, due cards, and progress.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.2))
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    private func selectedDeckPanel(_ deck: StudyDeck) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    sourceBadge(deck.primarySourceType, tint: deck.accentColor)
                    Spacer()
                    Text(deck.folderName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(deck.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(deck.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }

            Divider()
                .overlay(Color.white.opacity(0.12))

            VStack(spacing: 10) {
                previewMetric(title: "Cards Due", value: "\(deck.dueToday)", icon: "clock.fill", tint: deck.accentColor)
                previewMetric(title: "Mastery", value: "\(Int(deck.mastery * 100))%", icon: "target", tint: deck.accentColor)
                previewMetric(title: "Last Studied", value: deck.lastStudied, icon: "calendar", tint: deck.accentColor)
            }

            detailSection(title: "Tags") {
                wrappingPills(deck.tags, tint: .purple)
            }

            detailSection(title: "Linked Concepts") {
                VStack(spacing: 8) {
                    ForEach(deck.linkedConcepts) { concept in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(concept.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)

                                ProgressView(value: concept.mastery)
                                    .tint(concept.mastery < 0.7 ? .orange : deck.accentColor)
                            }

                            Text("\(Int(concept.mastery * 100))%")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                }
            }

            detailSection(title: "Sources") {
                VStack(spacing: 8) {
                    ForEach(deck.sources) { source in
                        HStack(spacing: 10) {
                            Image(systemName: source.type.systemImage)
                                .foregroundStyle(deck.accentColor)
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(source.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)

                                Text(source.type.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                }
            }

            conceptGraphPreview(for: deck)

            cardManagementSection(for: deck)

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.24))
                .stroke(deck.accentColor.opacity(0.28), lineWidth: 1)
        )
    }

    private func cardManagementSection(for deck: StudyDeck) -> some View {
        let cards = viewModel.studyCards.filter { $0.deckName == deck.name }

        return detailSection(title: "Cards") {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Front", text: $cardFront)
                    .textFieldStyle(.plain)
                    .padding(9)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.055)))
                    .foregroundStyle(.white)

                TextField("Back", text: $cardBack)
                    .textFieldStyle(.plain)
                    .padding(9)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.055)))
                    .foregroundStyle(.white)

                TextField("Tags, comma separated", text: $cardTags)
                    .textFieldStyle(.plain)
                    .padding(9)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.055)))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Button {
                        saveCardForm(for: deck)
                    } label: {
                        Label(editingCard == nil ? "Add Card" : "Save Card", systemImage: editingCard == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.24)))
                    .disabled(cardFront.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardBack.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button {
                        resetCardForm()
                    } label: {
                        Text("Clear")
                            .font(.caption.weight(.semibold))
                            .frame(width: 58)
                            .padding(.vertical, 9)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.055)))
                }

                ForEach(cards.prefix(4)) { card in
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(card.front)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text("Due \(DateFormatters.shortDate.string(from: card.dueDate)) • \(card.reviewCount) reviews")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(card.sourceReferenceText)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.purple)
                                .lineLimit(1)
                        }

                        Spacer()

                        Button {
                            beginEditing(card)
                        } label: {
                            Image(systemName: "pencil")
                                .frame(width: 26, height: 26)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)

                        Button {
                            viewModel.deleteCard(card)
                            if editingCard?.id == card.id { resetCardForm() }
                        } label: {
                            Image(systemName: "trash")
                                .frame(width: 26, height: 26)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.red)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                }
            }
        }
    }

    private func conceptGraphPreview(for deck: StudyDeck) -> some View {
        detailSection(title: "Concept Graph Preview") {
            VStack(alignment: .leading, spacing: 10) {
                let weakConcepts = deck.linkedConcepts.filter { $0.mastery < 0.7 }

                HStack(spacing: 8) {
                    ForEach(deck.linkedConcepts.prefix(4)) { concept in
                        Button {
                            viewModel.selectGraphConcept(concept)
                        } label: {
                            VStack(spacing: 5) {
                                Circle()
                                    .fill(concept.mastery < 0.7 ? Color.orange.opacity(0.75) : deck.accentColor.opacity(0.75))
                                    .frame(width: 14, height: 14)
                                Text(concept.name)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 62)
                            .contentShape(Rectangle())
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("\(weakConcepts.count) weak concept nodes connected to this deck")
                    .font(.caption)
                    .foregroundStyle(weakConcepts.isEmpty ? Color.secondary : Color.orange)
            }
        }
    }

    private func beginEditing(_ card: StudyCard) {
        editingCard = card
        cardFront = card.front
        cardBack = card.back
        cardTags = card.tags.joined(separator: ", ")
    }

    private func saveCardForm(for deck: StudyDeck) {
        let tags = cardTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if let editingCard {
            viewModel.updateCard(editingCard, front: cardFront, back: cardBack, tags: tags)
        } else {
            viewModel.addCard(deckName: deck.name, section: deck.name, front: cardFront, back: cardBack, tags: tags)
        }

        resetCardForm()
    }

    private func resetCardForm() {
        editingCard = nil
        cardFront = ""
        cardBack = ""
        cardTags = ""
    }

    private func largeEmptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.04))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func compactEmptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
            Text(message)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.04))
        )
    }

    private func detailSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
        }
    }

    private func previewMetric(title: String, value: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 20)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func sourceBadge(_ sourceType: ResourceSourceType, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: sourceType.systemImage)
            Text(sourceType.shortName)
        }
        .font(.caption2.weight(.bold))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .foregroundStyle(tint)
        .background(
            Capsule()
                .fill(tint.opacity(0.16))
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
    }

    private func pillRow(_ tags: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                tagPill(tag, tint: .white)
            }
        }
    }

    private func wrappingPills(_ tags: [String], tint: Color) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 78), spacing: 6)], alignment: .leading, spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                tagPill(tag, tint: tint)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func tagPill(_ tag: String, tint: Color) -> some View {
        let usesNeutralStyle = tint == .white

        return Text(tag)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(usesNeutralStyle ? Color.secondary : Color.white)
            .background(
                Capsule()
                    .fill(usesNeutralStyle ? Color.white.opacity(0.07) : tint.opacity(0.18))
            )
    }

    private func miniMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.18))
        )
    }

    private func cardFill(isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected { return Color.white.opacity(0.105) }
        if isHovered { return Color.white.opacity(0.078) }
        return Color.white.opacity(0.052)
    }

    private func cardStroke(deck: StudyDeck, isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected { return deck.accentColor.opacity(0.78) }
        if isHovered { return deck.accentColor.opacity(0.34) }
        return Color.white.opacity(0.085)
    }

    private func deckCount(for folder: StudyFolder) -> Int {
        viewModel.studyDecks.filter { $0.folderName == folder.name }.count
    }
}

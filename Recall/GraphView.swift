import SwiftUI

struct GraphView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        HStack(spacing: 0) {
            if viewModel.isContextPanelVisible && !viewModel.isGraphFocusMode {
                conceptDrawer
                    .frame(width: 260)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            graphWorkspace

            if viewModel.isRightInspectorVisible && !viewModel.isGraphFocusMode {
                ConceptDetailPanel(viewModel: viewModel, concept: viewModel.selectedGraphConcept)
                    .frame(width: 310)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isContextPanelVisible)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isRightInspectorVisible)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isGraphFocusMode)
    }

    private var graphWorkspace: some View {
        ZStack(alignment: .topLeading) {
            GraphCanvasView(
                selectedConcept: viewModel.selectedGraphConcept,
                relatedConcepts: viewModel.relatedGraphConcepts,
                edges: viewModel.edges(for: viewModel.selectedGraphConcept, onlyTestedTogether: viewModel.isShowingOnlyTestedTogetherEdges),
                isFilteringTestedTogether: viewModel.isShowingOnlyTestedTogetherEdges,
                onSelect: viewModel.selectGraphConcept
            )

            floatingToolbar
                .padding(18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.08))
    }

    private var floatingToolbar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    viewModel.toggleContextPanel()
                } label: {
                    Image(systemName: "sidebar.leading")
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.isContextPanelVisible ? .white : .secondary)

                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Find concepts in graph", text: $viewModel.graphSearchText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .frame(width: 280)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.46))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

                Button {
                    if let first = viewModel.filteredGraphConcepts.first {
                        viewModel.selectedGraphConcept = first
                    }
                } label: {
                    Label("Center", systemImage: "scope")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08)))

                Button {
                    viewModel.toggleRightInspector()
                } label: {
                    Image(systemName: "sidebar.right")
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.isRightInspectorVisible ? .white : .secondary)
            }

            HStack(spacing: 8) {
                ForEach(ConceptSectionFilter.allCases) { filter in
                    sectionFilterButton(filter)
                }

                Divider()
                    .frame(height: 22)
                    .overlay(Color.white.opacity(0.12))

                filterToggle(
                    title: "Weak",
                    icon: "exclamationmark.triangle.fill",
                    isOn: $viewModel.isFocusingWeakGraphConcepts,
                    tint: .orange
                )

                filterToggle(
                    title: "Tested together",
                    icon: "link",
                    isOn: $viewModel.isShowingOnlyTestedTogetherEdges,
                    tint: .blue
                )
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.36))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var conceptDrawer: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Concepts")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Spacer()

                Text("\(viewModel.filteredGraphConcepts.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.07)))
            }

            ScrollView {
                VStack(spacing: 8) {
                    if viewModel.filteredGraphConcepts.isEmpty {
                        emptyConceptList
                    } else {
                        ForEach(viewModel.filteredGraphConcepts) { concept in
                            conceptRow(concept)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color.black.opacity(0.24))
    }

    private var emptyConceptList: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("No concepts match")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)

            Text("Clear search or widen filters.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.045)))
    }

    private func conceptRow(_ concept: ConceptNode) -> some View {
        let isSelected = viewModel.selectedGraphConcept.id == concept.id

        return Button {
            viewModel.selectedGraphConcept = concept
        } label: {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(concept.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Text("\(Int(concept.mastery * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(concept.mastery < 0.65 ? .orange : .green)
                }

                Text("\(concept.section) • \(concept.weakCount) weak")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ProgressView(value: concept.mastery)
                    .tint(concept.mastery < 0.65 ? .orange : .purple)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.purple.opacity(0.22) : Color.white.opacity(0.045))
                    .stroke(isSelected ? Color.purple.opacity(0.55) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionFilterButton(_ filter: ConceptSectionFilter) -> some View {
        let isSelected = viewModel.selectedGraphSection == filter

        return Button {
            viewModel.selectedGraphSection = filter
            if let first = viewModel.filteredGraphConcepts.first {
                viewModel.selectedGraphConcept = first
            }
        } label: {
            Text(filter.rawValue)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
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

    private func filterToggle(title: String, icon: String, isOn: Binding<Bool>, tint: Color) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            if let first = viewModel.filteredGraphConcepts.first, !viewModel.filteredGraphConcepts.contains(where: { $0.id == viewModel.selectedGraphConcept.id }) {
                viewModel.selectedGraphConcept = first
            }
        } label: {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .contentShape(Rectangle())
                .foregroundStyle(isOn.wrappedValue ? Color.white : Color.secondary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isOn.wrappedValue ? tint.opacity(0.22) : Color.white.opacity(0.055))
                        .stroke(isOn.wrappedValue ? tint.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct GraphCanvasView: View {
    let selectedConcept: ConceptNode
    let relatedConcepts: [ConceptNode]
    let edges: [ConceptEdge]
    let isFilteringTestedTogether: Bool
    let onSelect: (ConceptNode) -> Void

    @State private var hoveredConceptID: UUID?
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private var visibleRelatedConcepts: [ConceptNode] {
        Array(relatedConcepts.prefix(8))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                ZStack {
                    gridBackground

                    graphContent
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(panGesture)
                        .gesture(zoomGesture)
                        .animation(.easeOut(duration: 0.16), value: scale)
                }
                .frame(width: max(1400, proxy.size.width * 1.4), height: max(900, proxy.size.height * 1.35))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            zoomControls
                .padding(18)
        }
    }

    private var graphContent: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let positions = nodePositions(in: proxy.size, center: center)

            ZStack {
                Canvas { context, _ in
                    for (_, point) in positions {
                        var path = Path()
                        path.move(to: center)
                        path.addLine(to: point)
                        context.stroke(path, with: .color(.purple.opacity(0.42)), lineWidth: 3)
                    }
                }

                if visibleRelatedConcepts.isEmpty {
                    mapEmptyState
                        .position(CGPoint(x: center.x, y: center.y + 166))
                } else {
                    ForEach(Array(visibleRelatedConcepts.enumerated()), id: \.element.id) { index, concept in
                        if let position = positions[index] {
                            relatedNode(concept)
                                .position(position)
                        }
                    }
                }

                centralNode
                    .position(center)

                ForEach(Array(visibleRelatedConcepts.enumerated()), id: \.element.id) { index, concept in
                    if let position = positions[index],
                       let edge = edgeConnecting(concept) {
                        edgeLabel(edge.relationshipType.label)
                            .position(midpoint(center, position))
                    }
                }
            }
        }
    }

    private var centralNode: some View {
        VStack(spacing: 9) {
            Text(selectedConcept.name)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("\(selectedConcept.section) • \(Int(selectedConcept.mastery * 100))%")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.purple)
        }
        .padding(24)
        .frame(width: 230)
        .frame(minHeight: 136)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.34))
                .stroke(Color.purple.opacity(0.98), lineWidth: 2.5)
        )
        .shadow(color: .purple.opacity(0.55), radius: 24, x: 0, y: 0)
    }

    private func relatedNode(_ concept: ConceptNode) -> some View {
        let isHovered = hoveredConceptID == concept.id

        return Button {
            onSelect(concept)
        } label: {
            VStack(spacing: 7) {
                Text(concept.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text("\(concept.weakCount) weak cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(width: 198)
            .frame(minHeight: 108)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.white.opacity(0.12) : Color.black.opacity(0.34))
                    .stroke(concept.mastery < 0.65 ? Color.orange.opacity(0.82) : Color.blue.opacity(0.58), lineWidth: isHovered ? 2 : 1.2)
            )
            .shadow(color: isHovered ? Color.purple.opacity(0.28) : Color.clear, radius: 16, x: 0, y: 8)
            .scaleEffect(isHovered ? 1.045 : 1)
            .animation(.easeOut(duration: 0.14), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            hoveredConceptID = isHovering ? concept.id : nil
        }
    }

    private func edgeLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.78))
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
    }

    private var mapEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: isFilteringTestedTogether ? "link.badge.plus" : "point.3.connected.trianglepath.dotted")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(isFilteringTestedTogether ? "No tested-together links" : "No related nodes")
                .font(.headline)
                .foregroundStyle(.white)
            Text(isFilteringTestedTogether ? "Turn off the relationship filter to see adjacent concepts." : "Select another concept or clear filters.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(width: 280)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.3)))
    }

    private var gridBackground: some View {
        Canvas { context, size in
            let spacing: CGFloat = 48
            var path = Path()

            stride(from: CGFloat(0), through: size.width, by: spacing).forEach { x in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }

            stride(from: CGFloat(0), through: size.height, by: spacing).forEach { y in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }

            context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 1)
        }
    }

    private var zoomControls: some View {
        HStack(spacing: 6) {
            Button {
                scale = max(0.65, scale - 0.12)
                lastScale = scale
            } label: {
                Image(systemName: "minus")
                    .frame(width: 30, height: 30)
            }

            Text("\(Int(scale * 100))%")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 48)

            Button {
                scale = min(1.5, scale + 0.12)
                lastScale = scale
            } label: {
                Image(systemName: "plus")
                    .frame(width: 30, height: 30)
            }

            Button {
                scale = 1
                lastScale = 1
                offset = .zero
                lastOffset = .zero
            } label: {
                Image(systemName: "scope")
                    .frame(width: 30, height: 30)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.42))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(1.5, max(0.65, lastScale * value))
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    private func nodePositions(in size: CGSize, center: CGPoint) -> [Int: CGPoint] {
        let radius = min(size.width, size.height) * 0.34
        return Dictionary(uniqueKeysWithValues: visibleRelatedConcepts.indices.map { index in
            let angle = (Double(index) / Double(max(visibleRelatedConcepts.count, 1))) * Double.pi * 2 - Double.pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            return (index, point)
        })
    }

    private func edgeConnecting(_ concept: ConceptNode) -> ConceptEdge? {
        edges.first { edge in
            edge.fromConceptID == concept.id || edge.toConceptID == concept.id
        }
    }

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}

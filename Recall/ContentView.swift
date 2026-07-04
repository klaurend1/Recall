import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var isCommandPalettePresented = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                if viewModel.isAppNavigationVisible && !viewModel.isCurrentScreenFocused {
                    SidebarView(selectedScreen: $viewModel.selectedScreen)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }

                mainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isAppNavigationVisible)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isCurrentScreenFocused)

            panelControls
                .padding(.top, 14)
                .padding(.trailing, 16)

            if isCommandPalettePresented {
                CommandPaletteView(viewModel: viewModel, isPresented: $isCommandPalettePresented)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(10)
            }
        }
        .background(appBackground)
        .preferredColorScheme(.dark)
        .frame(minWidth: 1100, minHeight: 720)
        .animation(.easeInOut(duration: 0.16), value: isCommandPalettePresented)
        .background(shortcutCommands)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.selectedScreen {
        case .home:
            HomeView(viewModel: viewModel)
        case .review:
            ReviewView(viewModel: viewModel)
        case .practice:
            PracticeView(viewModel: viewModel)
        case .library:
            LibraryView(viewModel: viewModel)
        case .graph:
            GraphView(viewModel: viewModel)
        case .analytics:
            AnalyticsView(viewModel: viewModel)
        }
    }

    private var appBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.055, blue: 0.085),
                Color(red: 0.025, green: 0.03, blue: 0.05),
                Color(red: 0.07, green: 0.04, blue: 0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var panelControls: some View {
        HStack(spacing: 6) {
            iconButton(
                systemImage: viewModel.isAppNavigationVisible ? "sidebar.left" : "sidebar.left",
                isActive: viewModel.isAppNavigationVisible,
                action: viewModel.toggleAppNavigation
            )

            iconButton(
                systemImage: "sidebar.leading",
                isActive: viewModel.isContextPanelVisible,
                action: viewModel.toggleContextPanel
            )

            iconButton(
                systemImage: "sidebar.right",
                isActive: viewModel.isRightInspectorVisible,
                action: viewModel.toggleRightInspector
            )

            iconButton(
                systemImage: viewModel.isCurrentScreenFocused ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
                isActive: viewModel.isCurrentScreenFocused,
                action: viewModel.toggleFocusMode
            )
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.34))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func iconButton(systemImage: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isActive ? Color.white : Color.secondary)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isActive ? Color.white.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    private var shortcutCommands: some View {
        VStack {
            Button("") { viewModel.toggleAppNavigation() }
                .keyboardShortcut("\\", modifiers: .command)
            Button("") { viewModel.toggleContextPanel() }
                .keyboardShortcut("\\", modifiers: [.command, .option])
            Button("") { viewModel.toggleRightInspector() }
                .keyboardShortcut("]", modifiers: .command)
            Button("") { viewModel.toggleFocusMode() }
                .keyboardShortcut("f", modifiers: [])
            Button("") { isCommandPalettePresented = true }
                .keyboardShortcut("k", modifiers: .command)
        }
        .frame(width: 0, height: 0)
        .opacity(0)
    }
}

#Preview {
    ContentView()
}

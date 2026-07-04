import SwiftUI

struct SidebarView: View {
    @Binding var selectedScreen: AppScreen

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recall")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Concept-first review")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.top, 20)

            VStack(spacing: 6) {
                ForEach(AppScreen.allCases) { screen in
                    Button {
                        selectedScreen = screen
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: screen.systemImage)
                                .frame(width: 22)

                            Text(screen.rawValue)
                                .fontWeight(.medium)

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .foregroundStyle(selectedScreen == screen ? .white : .secondary)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedScreen == screen ? Color.purple.opacity(0.35) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text("Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ProgressView(value: 0.54)
                    .tint(.purple)

                Text("32 of 59 reviews complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.06))
            )
            .padding(14)
        }
        .frame(width: 230)
        .background(Color.black.opacity(0.32))
    }
}

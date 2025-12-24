//
//  FloatingActionMenu.swift
//  ExpenseMate
//
//  Created by Alex Senu
//

import SwiftUI

struct FloatingActionMenu: View {
    enum Placement {
        case floatingBottomTrailing
        case dockedCenter
    }

    struct Action: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let tint: Color
        let handler: () -> Void
    }

    @Binding var isExpanded: Bool

    let mainSystemImage: String
    let mainTint: Color
    let actions: [Action]

    var placement: Placement = .floatingBottomTrailing

    /// When true, the title pill uses Material and primary text.
    /// When false, it uses a solid pill and white text.
    var materialPills: Bool = true

    /// Use false for docked mode when the parent draws the full-screen dim.
    var showsDimmingBackground: Bool = true

    var body: some View {
        ZStack(alignment: alignment) {
            if isExpanded, showsDimmingBackground {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring()) { isExpanded = false } }
            }

            content
        }
    }

    private var alignment: Alignment {
        switch placement {
        case .floatingBottomTrailing: return .bottomTrailing
        case .dockedCenter: return .bottom
        }
    }

    @ViewBuilder
    private var content: some View {
        switch placement {
        case .floatingBottomTrailing:
            floatingContent
        case .dockedCenter:
            dockedContent
        }
    }

    // MARK: - Floating (bottom-trailing)

    private var floatingContent: some View {
        VStack(alignment: .trailing, spacing: 12) {
            if isExpanded {
                ForEach(actions) { action in
                    actionRow(action)
                }
            }

            mainButton(size: 64)
        }
        .padding(.trailing, 18)
        .padding(.bottom, 18)
    }

    // MARK: - Docked (center of bottom bar)

    private var dockedContent: some View {
        ZStack(alignment: .bottom) {
            if isExpanded {
                VStack(spacing: 14) {
                    ForEach(actions) { action in
                        actionRow(action)
                    }
                }
                .padding(.bottom, 76) // lift actions above main
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            mainButton(size: 72)
        }
    }

    // MARK: - Pieces

    private func mainButton(size: CGFloat) -> some View {
        Button {
            withAnimation(.spring()) { isExpanded.toggle() }
        } label: {
            Image(systemName: mainSystemImage)
                .font(.system(size: 22, weight: .bold))
                .frame(width: size, height: size)
                .background(mainTint, in: Circle())
                .foregroundColor(.white) // <- safe
                .shadow(radius: 10, y: 5)
        }
        .accessibilityLabel(isExpanded ? "Close actions" : "Open actions")
    }

    private func actionRow(_ action: Action) -> some View {
        Button {
            withAnimation(.spring()) { isExpanded = false }
            action.handler()
        } label: {
            HStack(spacing: 12) {
                Text(action.title)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(pillStyle, in: Capsule())
                    .foregroundStyle(materialPills ? AnyShapeStyle(Color.primary) : AnyShapeStyle(Color.white))

                Image(systemName: action.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 56, height: 56)
                    .background(action.tint, in: Circle())
                    .foregroundColor(.white) // <- safe
                    .shadow(radius: 6, y: 3)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Styles

    private var pillStyle: AnyShapeStyle {
        materialPills
        ? AnyShapeStyle(.ultraThinMaterial)
        : AnyShapeStyle(Color.black.opacity(0.35))
    }
}

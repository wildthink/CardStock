//
//  BentoLayout.swift
//  CardStock
//
//  Created by Jason Jobe on 3/27/25.
//


import SwiftUI

public struct BentoBox<Content: View>: View {
    @Environment(\.bentoBoxAxis) var axis
    @ViewBuilder var content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        BentoLayout(axis: axis) {
            content()
                .environment(\.bentoBoxAxis, axis.opposite)
        }
    }
}

extension ContainerValues {
    @Entry var layoutWeight: Double = 1
}

extension View {
    @ViewBuilder
    public func layoutWeight(_ value: Double) -> some View {
        containerValue(\.layoutWeight, value)
    }
}

public extension Axis {
    var opposite: Axis {
        switch self {
            case .horizontal: return .vertical
            case .vertical: return .horizontal
        }
    }
}

public struct BentoLayout: Layout {
    public var axis: Axis = .horizontal

    public init(axis: Axis) {
        self.axis = axis
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let totalWeight = subviews.reduce(into: 0) { $0 += $1.containerValues.layoutWeight }
        let availableSize = axis == .horizontal ? proposal.width ?? 0 : proposal.height ?? 0

        var currentOffset: CGFloat = 0
        for subview in subviews {
            let childSize = (subview.containerValues.layoutWeight / totalWeight) * availableSize
            if axis == .horizontal {
                currentOffset += childSize
            } else {
                currentOffset += childSize
            }
        }

        return if axis == .horizontal {
            CGSize(width: currentOffset, height: proposal.height ?? 0)
        } else {
            CGSize(width: proposal.width ?? 0, height: currentOffset)
        }
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }

        let totalWeight = subviews.reduce(0) { $0 + $1.containerValues.layoutWeight }
        let availableSize = axis == .horizontal ? bounds.width : bounds.height

        var currentOffset: CGFloat = 0
        for subview in subviews {
            let childSize = (subview.containerValues.layoutWeight / totalWeight) * availableSize
            let childFrame: CGRect
            if axis == .horizontal {
                childFrame = CGRect(x: bounds.minX + currentOffset, y: bounds.minY, width: childSize, height: bounds.height)
            } else {
                childFrame = CGRect(x: bounds.minX, y: bounds.minY + currentOffset, width: bounds.width, height: childSize)
            }
            subview.place(at: childFrame.origin, proposal: ProposedViewSize(width: childFrame.width, height: childFrame.height))
            currentOffset += childSize
        }
    }
}

extension EnvironmentValues {
    @Entry var bentoBoxAxis: Axis = .horizontal
}

extension View {
    func bentoBox(axis: Axis) -> some View {
        environment(\.bentoBoxAxis, axis)
    }
}

#Preview ("Vertical") {
    ZStack {
        BentoBox {
            Color.blue.layoutWeight(2)
            Color.yellow.layoutWeight(1)
            BentoBox {
                Color.red
                Color.cyan.layoutWeight(3)
            }
        }
        .bentoBox(axis: .vertical)
    }
    .frame(width: 300, height: 300)
}

#Preview ("Horizontal") {
    @Previewable @State var toggle: Bool = true
    
    VStack {
        BentoBox {
            Color.blue.layoutWeight(2)
            Color.yellow.layoutWeight(1)
            BentoBox {
                Color.red
                Color.cyan.layoutWeight(3)
            }
        }
        .bentoBox(axis: toggle ? .horizontal : .vertical)
        .animation(.default, value: toggle)
        Divider()
        Toggle("Horizontal", isOn: $toggle)
    }
    .frame(width: 300, height: 300)
    .padding()
}

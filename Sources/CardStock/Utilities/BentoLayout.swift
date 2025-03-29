//
//  BentoLayout.swift
//  CardStock
//
//  Created by Jason Jobe on 3/27/25.
//


import SwiftUI

extension ContainerValues {
    @Entry var layoutWeight: Double = 1
}

extension View {
    @ViewBuilder
    public func layoutWeight(_ value: Double) -> some View {
        containerValue(\.layoutWeight, value)
    }
}

struct BentoLayout: Layout {
    var axis: Axis = .horizontal

    enum Axis {
        case horizontal
        case vertical
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let totalWeight = subviews.reduce(into: 0) { $0 + $1.containerValues.layoutWeight }
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

        if axis == .horizontal {
            return CGSize(width: currentOffset, height: proposal.height ?? 0)
        } else {
            return CGSize(width: proposal.width ?? 0, height: currentOffset)
        }
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
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

//struct BentoBox<Content: View>: View {
//    var layoutWeight: CGFloat = 1
//    var content: () -> Content
//
//    var body: some View {
//        content()
//            .layoutPriority(layoutWeight)
//    }
//}

//#Preview {
//    ZStack {
//        BentoLayout {
//            Color.blue.layoutWeight(1)
//            Color.yellow.layoutWeight(1)
//        }
//    }
//    .frame(width: 300, height: 300)
//}

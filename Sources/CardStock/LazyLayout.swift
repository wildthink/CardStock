//
//  LazyLayout.swift
//  CardStock
//
//  Created by Jason Jobe on 1/31/25.
//


//

import SwiftUI

protocol LazyLayout: Layout {
    var moreSubviewsAvailable: Bool { get set }
}

struct MasonryLayout: LazyLayout {
    var numberOfColumns = 2
    var moreSubviewsAvailable: Bool = false

    func rects(proposed: ProposedViewSize, subviews: Subviews) -> ([CGRect], minColumnY: CGFloat) {
        var columnYs = Array(repeating: CGFloat(0), count: numberOfColumns)
        var columnWidth = proposed.width.map { $0 / .init(numberOfColumns) } ?? 10

        return (subviews.map { subview in
            let currentColumnIdx = columnYs.indices.sorted(by: { columnYs[$0] < columnYs[$1] }).first!
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))
            let origin = CGPoint(x: columnWidth * .init(currentColumnIdx), y: columnYs[currentColumnIdx])
            columnYs[currentColumnIdx] += size.height
            return CGRect(origin: origin, size: size)
        }, columnYs.min() ?? 0)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var (frames, minY) = rects(proposed: proposal, subviews: subviews)
        var size = frames.reduce(CGRect.null, { $0.union($1) }).size
        if moreSubviewsAvailable {
            size.height = minY
        }
        return size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let (frames, _) = rects(proposed: proposal, subviews: subviews)
        let childProposal = ProposedViewSize(width: proposal.width.map { $0 / .init(numberOfColumns) } ?? 10, height: nil)
        for (s, r) in zip(subviews, frames) {
            s.place(at: r.origin + bounds.origin, proposal: childProposal)
        }
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

struct LazyVStackLayout: Layout {
    var spacing: CGFloat?

    func spacings(for subviews: Subviews) -> [CGFloat] {
        subviews.indices.dropLast().map { idx in
            spacing ?? subviews[idx].spacing.distance(to: subviews[idx+1].spacing, along: .vertical)
        }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {

        var result: CGSize = .zero
        let spaces = spacings(for: subviews)

        for s in subviews {
            let size = s.sizeThatFits(.init(width: proposal.width, height: nil))
            result.height += size.height
            result.width = max(result.width, size.width)
        }

        result.height += spaces.reduce(0, +)

        return result
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentY: CGFloat = 0
        let spaces = spacings(for: subviews)
        for (offset, s) in subviews.enumerated() {
            var point = bounds.origin
            point.y += currentY
            let prop = ProposedViewSize(width: proposal.width, height: nil)
            let size = s.sizeThatFits(prop)
            s.place(at: point, proposal: prop)
            currentY += size.height
            if offset < subviews.count - 1 {
                currentY += spaces[offset]
            }
        }
    }
}

//struct LazyVContainer<Content: View, L: LazyLayout>: View {
//    let layout: L
//
//    @ViewBuilder var content: Content
//    @State var numberOfSubviewsVisible = 1
//    @State var maxY: CGFloat = 0
//    @State var currentHeight: CGFloat = 0
//
//    func theLayout(numberOfSubviews: Int) -> L {
//        var copy = layout
//        copy.moreSubviewsAvailable = numberOfSubviewsVisible < numberOfSubviews
//        return copy
//    }
//
//    var body: some View {
//        Group(subviews: content) { coll in
//            let l = theLayout(numberOfSubviews: coll.count)
//            l {
//                coll.prefix(numberOfSubviewsVisible)
//            }
//
//            .onGeometryChange(for: CGFloat.self) { proxy in
//                proxy.bounds(of: .scrollView)!.maxY
//            } action: { newValue in
//                maxY = newValue
//            }
//            .onGeometryChange(for: CGFloat.self, of: { maxY - $0.size.height }, action: { newValue in
//                if newValue > 0 && numberOfSubviewsVisible < coll.count {
//                    numberOfSubviewsVisible += 1
//                    print(numberOfSubviewsVisible)
//                }
//            })
//            .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) { newValue in
//                currentHeight = newValue
//            }
//            .frame(minHeight: currentHeight / .init(numberOfSubviewsVisible) * .init(coll.count), alignment: .top)
//        }
//    }
//}

struct ContentView: View {
    var body: some View {
        ScrollView {
//            LazyVContainer(layout: MasonryLayout()) {
            MasonryLayout {
//                Image(systemName: "globe")
                ForEach(0..<50) { ix in
                    VStack {
                        Text("item \(ix)")
                            .onAppear { print("onAppear", ix) }
                    }
                    .frame(height: 30 * .init((1 + ix % 5)))
                    .border(Color.red)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

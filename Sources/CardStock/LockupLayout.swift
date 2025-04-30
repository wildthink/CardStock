//
//  LockupLayout.swift
//  CardStock
//
//  Created by Jason Jobe on 4/22/25.
//

import SwiftUI

extension CGSize {
    var aspectRatio: CGFloat {
        width / height
    }
}

extension EnvironmentValues {
    @Entry var lockupSizing: PresentationSizing = .automatic
}

struct LockupLayout: Layout {
//    @Environment(\.lockupSizing) var sizing
    var visualStyle: VisualStyle
    var ratio: CGFloat?
    var contentMode: ContentMode
    var enabled: Bool = true

    func childProposal(proposal: ProposedViewSize, child: Subviews.Element) -> ProposedViewSize {
        guard enabled else {
            return proposal
        }
        let aspectRatio = ratio ?? child.sizeThatFits(.unspecified).aspectRatio
        switch (proposal.width, proposal.height) {
        case (nil, nil): 
            return proposal
        case (let width?, nil): 
            return .init(width: width, height: width/aspectRatio)
        case (nil, let height?): 
            return .init(width: height*aspectRatio, height: height)
        case (let width?, let height?):
//            let combine: (CGFloat, CGFloat) -> CGFloat = contentMode == .fit ? min : max
            func combine(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
                contentMode == .fit ? min(a, b) : max(a, b)
            }
            let width = combine(width, height * aspectRatio)
            return .init(width: width, height: width/aspectRatio)
        }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 1)
        let s = subviews[0]
        return s.sizeThatFits(childProposal(proposal: proposal, child: s))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let s = subviews[0]
        s.place(at: bounds.origin, proposal: childProposal(proposal: proposal, child: s))
    }
}

struct LockupSizer: ViewModifier {
    @Environment(\.lockupSizing) var lockupSizing
    @Environment(\.visualStyle) var visualStyle
    
    func body(content: Content) -> some View {
        LockupLayout(visualStyle: visualStyle, ratio: nil, contentMode: .fit, enabled: true) {
            content
        }
    }
}

extension View {
    @ViewBuilder
//    func lockupLayout(visualStyle: VisualStyle, _ ratio: CGFloat? = nil, contentMode: ContentMode, enabled: Bool = true) -> some View {
    func lockupLayout(visualStyle: VisualStyle) -> some View {
        modifier(LockupSizer())
            .environment(\.visualStyle, visualStyle)
//        LockupLayout(visualStyle: visualStyle, ratio: ratio, contentMode: contentMode, enabled: enabled) {
//            self
//        }
    }
}

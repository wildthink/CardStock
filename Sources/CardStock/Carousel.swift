//
//  Carousel.swift
//  CardStock
//
//  Created by Jason Jobe on 2/24/25.
//
import SwiftUI

public struct Carousel<Catalog, Element, Cell: View>: View
where Catalog: RandomAccessCollection<Element>,
      Element: Identifiable & Hashable & Sendable
{
    var items: Catalog
    var spacing: CGFloat?
    @ViewBuilder var cell: (Catalog.Element) -> Cell
    @Binding var scrollPosition: ScrollPosition
    var showsIndicators: Bool
    
    public init(
        scrollPosition: Binding<ScrollPosition>,
        spacing: CGFloat? = nil,
        showsIndicators: Bool = false,
        items: Catalog,
        cell: @escaping (Element) -> Cell
    ) {
        self.items = items
        self.cell = cell
        self.showsIndicators = showsIndicators
        self._scrollPosition = scrollPosition
    }
    
    let rows = [GridItem(.fixed(30)), GridItem(.fixed(30))]

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: showsIndicators) {
            LazyHGrid(rows: [GridItem(.flexible(minimum:120, maximum: 300))]) {
//            LazyHStack(spacing: spacing) {
                ForEach(items) {
                    cell($0)
                        .id($0)
                        .containerRelativeFrame(.horizontal)
                         .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.6)
                                .opacity(phase.isIdentity ? 1.0 : 0.7)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition($scrollPosition, anchor: .center)
    }
}

struct Carousel_ii<Content: View>: View {
//    @Binding var scrollPosition: ScrollPosition
    @ViewBuilder var content: Content
    var showsIndicators: Bool
  
    init(showsIndicators: Bool = false, content: () -> Content) {
        self.content = content()
        self.showsIndicators = showsIndicators
    }

//    init(scrollPosition: Binding<ScrollPosition>, showsIndicators: Bool = false, content: () -> Content) {
//        self._scrollPosition = scrollPosition
//        self.content = content()
//        self.showsIndicators = showsIndicators
//    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: showsIndicators) {
            LazyHStack {
                ForEach(subviews: content) { subview in
                    subview
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
//        .scrollPosition($scrollPosition, anchor: .center)
//        .contentMargins(16)
    }
}

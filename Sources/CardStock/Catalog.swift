//
//  Catalog.swift
//  ShowcasePackage
//
//  Created by Jason Jobe on 3/14/25.
//

import SwiftUI

public struct Catalog<T: Identifiable>: RandomAccessCollection {
    public typealias Index = Int
    public typealias Element = T
    
    public var name: String
    private var items: [T]
    
    public init(_ name: String? = nil, _ items: [T]) {
        self.name = name ?? String(describing: T.self)
        self.items = items
    }
    
    public var startIndex: Int { items.startIndex }
    public var endIndex: Int { items.endIndex }
    
    public subscript(position: Int) -> T {
        items[position]
    }
}

extension Catalog: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T...) {
        self = .init(nil, elements)
    }
}

extension View {
    public func frame(proposed: ProposedViewSize) -> some View {
        self.frame(width: proposed.width, height: proposed.height)
    }
}

// MARK: Previews
// For @StateOrBinding
//import Engine
//import Turbocharger
//import InterfaceViews

public struct LockupOptions: OptionSet, Sendable, ExpressibleByIntegerLiteral {
    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let showHeadline:LockupOptions = 0
    public static let showControls:LockupOptions = 1
    public static let showCount:LockupOptions = 2
    public static let showsIndicators:LockupOptions = 3
}

extension OptionSet where Self: ExpressibleByIntegerLiteral, RawValue: FixedWidthInteger {
    public init(integerLiteral value: RawValue) {
        self = Self.init(rawValue: value)
    }
}

public struct LockupViewStyle {
//    public var defaultStyle: VisualStyle = .page
    public var showHeadline: Bool = true
    public var showControls: Bool = true
    public var showCount: Bool = true
    public var showsIndicators: Bool = false
}

extension EnvironmentValues {
    @Entry var presentationAspect: PresentationAspect =  .hero
}

public extension View {
    func lockupStyle(configuration: CatalogViewConfiguration) -> some View {
        environment(\.catalogConfiguration, configuration)
    }
}

struct LockupTile: View {
//    @Environment(\.presentationAspect) var lockupStyle
    var id: Int
//    var lockupStyle: PresentationAspect
    
    init(id: Int) {
        self.id = id
//        self.lockupStyle = .hero
    }
    
//    init(id: Int, lockupStyle: PresentationAspect = .hero) {
//        self.id = id
//        self.lockupStyle = lockupStyle
//    }
    
    var body: some View {
        ZStack {
            BentoBox {
                Color.blue.layoutWeight(2)
                Color.orange.layoutWeight(1)
                BentoBox {
                    Color.red
                    Color.cyan //.layoutWeight()
                }
            }

//            Color.orange.opacity(0.8)
//            AdaptiveLockupView(model: .portrait, presentationAspect: lockupStyle)
            Text("Tile \(id)")
                .font(.headline)
        }
//        .aspectRatio(5/3, contentMode: .fit)
        .cornerRadius(8)
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

//public enum LockupStyle: CaseIterable, Hashable {
//    case tableRow, tile, poster, hero, portrait, landscape
//}

public enum VisualStyle: CaseIterable, Hashable {
    case page, table, carousel, grid
}

public extension VisualStyle {
    var symbolName: String {
        switch self {
        case .page:
            return "text.page"
        case .table:
            return "square.fill.text.grid.1x2"
        case .carousel:
            return "rectangle.stack"
        case .grid:
            return "rectangle.grid.3x2"
        }
    }
}

extension EnvironmentValues {
    @Entry var catalogConfiguration: CatalogViewConfiguration =  .init()
}

public extension View {
    func catalog(configuration: CatalogViewConfiguration) -> some View {
        environment(\.catalogConfiguration, configuration)
    }
}

extension CatalogView {
    public typealias Configuration = CatalogViewConfiguration
}

public struct CatalogViewConfiguration {
    public var defaultStyle: VisualStyle = .page
    public var showHeadline: Bool = true
    public var showControls: Bool = true
    public var showCount: Bool = true
    public var showsIndicators: Bool = false
    
    public init(
        defaultStyle: VisualStyle = .carousel,
        showHeadline: Bool = true,
        showControls: Bool = true,
        showCount: Bool = true,
        showsIndicators: Bool = false
    ) {
        self.defaultStyle = defaultStyle
        self.showHeadline = showHeadline
        self.showControls = showControls
        self.showCount = showCount
        self.showsIndicators = showsIndicators
    }
}
//}

public struct CatalogView<Item: Identifiable, Tile: View>: View
where Item.ID: Sendable
{
    @Environment(\.catalogConfiguration) var configuration
    var catalog: Catalog<Item>
    @ViewBuilder var tile: (Item) -> Tile
    
    @State var visualStyle: VisualStyle = .page
    @State var scrollViewSize: CGSize = .zero
    @State var scrollPosition: ScrollPosition
    var showsIndicators: Bool { configuration.showsIndicators }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if configuration.showHeadline {
                headline
            }
            GeometryReader { gp in
                ScrollView(axis, showsIndicators: false) {
                    layout {
                        ForEach(catalog) { item in
                            tile(item)
                                .frame(proposed: proposedSize(in: gp))
                                .border(.green)
                                .id(item.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition($scrollPosition, anchor: .topLeading)
            }
            .onGeometryChange(for: CGSize.self, of: \.size) {
                self.scrollViewSize = $0
            }
            .animation(.easeInOut(duration: 1), value: visualStyle)
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    public init(
        catalog: Catalog<Item>,
        visualStyle: VisualStyle = .carousel,
        scrollPosition: ScrollPosition? = nil,
        @ViewBuilder tile: @escaping (Item) -> Tile
    ) {
        self.catalog = catalog
        self.visualStyle = visualStyle
        self.scrollPosition = scrollPosition ?? ScrollPosition(idType: Item.ID.self)
        //        self.showsIndicators = showsIndicators
        self.tile = tile
    }
    
    var axis: Axis.Set {
        switch visualStyle {
        case .page, .carousel: .horizontal
        case .table, .grid:   .vertical
        }
    }
    
    func proposedSize(in gp: GeometryProxy) -> ProposedViewSize {
        let (wd, ht) = (gp.size.width, gp.size.height)
        return switch visualStyle {
        case .page: ProposedViewSize(width: wd, height: ht)
        case .table: ProposedViewSize(width: wd, height: ht/4)
        case .carousel: ProposedViewSize(width: wd/3, height: ht/2)
        case .grid:ProposedViewSize(width: 80, height: 80)
        }
    }
    
    @ViewBuilder
    var headline: some View {
        HStack {
            Text(catalog.name)
                .font(.headline)
            Spacer().frame(minWidth: 10)
            if configuration.showCount {
                Text("\(catalog.count) items")
                    .font(.caption)
            }
            //            if let id = scrollPosition.viewID {
            //                Text("\(String(describing: id))")
            //            }
            if configuration.showControls {
                controls
                    .labelStyle(.iconOnly)
                    .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    var controls: some View {
        Picker("", selection: $visualStyle) {
            ForEach(VisualStyle.allCases, id: \.self) { style in
                Label(String(describing: style), systemImage: style.symbolName)
            }
        }
    }
    
//    @LayoutBuilder
    var layout: AnyLayout {
        let l: any Layout = switch visualStyle {
        case .page:
            HStackLayout()
        case .grid:
            FlowLayout(spacing: 4)
//            FlowStackLayout(alignment: .center, spacing: 4)
        case .table:
            VStackLayout()
        case .carousel:
            HStackLayout()
        }
        return AnyLayout(l)
    }
}

#Preview {
    CatalogView(catalog: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], tile: LockupTile.init)
        .padding()
        .frame(width: 340, height: 400)
        .border(.red)
        .padding()
}

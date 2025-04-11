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
        get { items[position] }
        _modify {
            yield &items[position]
        }
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
    public var spacing: ProposedViewSize = .unspecified
    
    public init(
        defaultStyle: VisualStyle = .carousel,
        showHeadline: Bool = true,
        showControls: Bool = true,
        showCount: Bool = true,
        showsIndicators: Bool = false,
        spacing: ProposedViewSize = .unspecified
    ) {
        self.defaultStyle = defaultStyle
        self.showHeadline = showHeadline
        self.showControls = showControls
        self.showCount = showCount
        self.showsIndicators = showsIndicators
        self.spacing = spacing
    }
}
//}

//extension View {
//    @ViewBuilder
//    func containerRelativeFrame(if cond: Bool, axis: Axis.Set
//    ) -> some View {
//        let mod = cond ? OptionalFrame(active: true, axis: axis) : EmptyModifier()
//        modifier(mod)
//    }
//}


struct OptionalFrame: ViewModifier {
    let active: Bool
    let axis: Axis.Set = [.vertical, .horizontal]
    
    func body(content: Content) -> some View {
        Group {
            if active {
                content
                    .containerRelativeFrame(axis) { length, axis in
                        return length
                    }
            } else {
                content
            }
        }
    }
}


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
        self.tile = tile
    }
    
    var axis: Axis.Set {
        switch visualStyle {
            case .page: .horizontal
            case .carousel: .horizontal
            case .table:   .vertical
            case .grid: .vertical
        }
    }
    
    func proposedSize(in gp: GeometryProxy
    ) -> ProposedViewSize {
        let (wd, ht) = (gp.size.width, gp.size.height)
        return switch visualStyle {
            case .page: rval(wd: wd, ht: ht)
            case .table: rval(wd: wd, ht: nil)
            case .carousel: .unspecified
            case .grid: .unspecified
        }

        func rval(wd: CGFloat?, ht: CGFloat?) -> ProposedViewSize {
            ProposedViewSize(width: wd, height: ht)
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
    
    var layout: some Layout {
        let space = configuration.spacing
        let lo: any Layout = switch visualStyle {
        case .page:
            HStackLayout(spacing: space.width)
        case .grid:
            FlowLayout(spacing: space.width)
        case .table:
            VStackLayout(spacing: space.height)
        case .carousel:
            HStackLayout(spacing: space.width)
        }
        return AnyLayout(lo)
    }
}

struct LockupLayout: Layout {
        
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 1)
        return subviews[0].sizeThatFits(.unspecified)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews[0]
            .place(at: bounds.origin, proposal: proposal)
    }
}

extension Catalog where Element == Int {
    init(count: Int) {
        self = Catalog<Int>("Int", Array(1...count))
    }
}

#Preview {
    CatalogView(
        catalog: Catalog(count: 20),
        tile: {
            LockupTile(id: $0)
                .frame(minWidth: 100, minHeight: 100)
        })
        .padding()
        .frame(width: 360, height: 400)
        .border(.red)
        .padding()
}

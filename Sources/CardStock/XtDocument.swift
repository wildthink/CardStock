//
//  XtDocument.swift
//  CardStock
//
//  Created by Jason Jobe on 2/8/25.
//

import Foundation
@preconcurrency import Markdown

public final class XtDocument: @unchecked Sendable {
    let document: Document
    let tree: XMLDocument
    let data: String?
    
    init (_ data: String) {
        self.data = data
        let doc = Document(parsing: data, options: [.parseBlockDirectives])
        tree = XtMarkdownToXML.read(doc)
        document = doc
    }
}

extension XtDocument: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
        hasher.combine(ObjectIdentifier(tree))
        hasher.combine(data?.hashValue ?? 0)
    }
    
    public static func == (lhs: XtDocument, rhs: XtDocument) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension XMLDocument {
    func formatted() -> String {
        let data = xmlData(options: .nodePrettyPrint)
        let str:String? = String(data: data, encoding: .utf8)
        return str ?? "<XML Document>"
    }
}

extension XMLNode {
    
    enum PathComponent {
        case anyone
        case anypath
        case tag(String)
        case index(Int)
        case condition((XMLNode) -> Bool)
    }
    
    func nodes(matching path: [PathComponent]) -> [XMLNode] {
        var result: [XMLNode] = []
        nodes(matching: path[0...], into: &result)
        return result
    }

    /// Returns all leaf nodes that are found matching the path component
    /// "anyone" matches any single node, "anypath" any number intermediate nodes
//    func _nodes(matching path: ArraySlice<PathComponent>, into list: inout [XMLNode]) {
////        print("CHECK", self.name ?? "NONE")
//        guard let cond = path.first else {
//            list.append(self)
//            return
//        }
//        let matches = switch cond {
//            case .tag(let tagName): name == tagName
//            case .index(let idx):   idx == index
//            case .condition(let predicate): predicate(self)
//            case .anyone:   true
//            case .anypath:  true
//        }
//        guard matches else { return }
//        let tail = path.dropFirst()
//        if case .anypath = cond {
//            decendents(matching: tail, into: &list)
//        } else if case .anyone = cond, let children {
//            children.forEach {
//                $0.nodes(matching: tail, into: &list)
//            }
//        } else {
//            list.append(self)
//        }
//    }
    
    func nodes(matching path: ArraySlice<PathComponent>, into list: inout [XMLNode]) {
        guard let cond = path.first else {
            list.append(self)
            return
        }
        let tail = path.dropFirst()
        
        switch cond {
        case .tag(let tagName):
            let kids = children?.filter { $0.name == tagName } ?? []
            nodes(matching: tail, into: &list)
            case .index(let idx):
            if idx == index {
                
            }
            case .condition(let predicate):
            if predicate(self) {
                nodes(matching: tail, into: &list)
            }
            case .anyone:
                children?.forEach {
                    $0.nodes(matching: tail, into: &list)
                }
            case .anypath:
                decendents(matching: tail, into: &list)
        }
     }

    func decendents(matching path: ArraySlice<PathComponent>, into list: inout [XMLNode]) {
        guard let children, !path.isEmpty else { return }
        for child in children {
            child.decendents(matching: path, into: &list)
//            child.children?.forEach {
            child.nodes(matching: path, into: &list)
//            }
        }
    }
}

struct Transducer<E> {
    var call: (_ e: [E]) -> [E]

    static var filter: Transducer<E> {
        Transducer { $0 }
    }
    
    static func index(_ i: Int) -> Transducer<E> {
        Transducer {
            $0.indices.contains(i) ? [$0[i]] : []
        }
    }
    
    static func transduce(_ fn: @escaping (E) -> [E]) -> Transducer<E> {
        Transducer { (xs: [E]) -> [E] in
            xs.flatMap(fn)
        }
    }
}

extension Array {
    // filter -> test(Element)
    // index  -> self[safe: index]
    // */fn(E)->[E]   -> flatMap(fn)
}

extension XtDocument {
    
    func nodes(forXPath xPath: String) -> [XMLMarkup] {
        let ns = try? tree.nodes(forXPath: xPath)
        return ns as? [XMLMarkup] ?? []
    }

    func markup(forXPath xPath: String) -> [any Markup] {
        nodes(forXPath: xPath)
            .compactMap(\.markup)
    }
    
    func markup<M: Markup>(type: M.Type = M.self, forXPath xPath: String) -> [M] {
        var visitor = GetNodes<M>()
        let nodes = nodes(forXPath: xPath)
            .compactMap(\.markup)
        
        return visitor.visit(nodes)
    }

    var links: [xLink] {
        markup(type: Link.self, forXPath: "//links")
            .compactMap(xLink.init)
    }
    
    func attributedStrings(forXPath xPath: String) -> [AttributedString] {
        var mdv = Markdownosaur()
        let nodes = nodes(forXPath: xPath)
            .compactMap(\.markup)
            .compactMap(fn)
        
        return nodes
        func fn(_ md: Markup) -> AttributedString {
            mdv.visit(md).str
        }
        
//        var visitor = MarkdownVisitor<AttributedString> {
//            var md = Markdownosaur()
//            return md.visit($0).str
//        }
//        return nodes.flatMap { visitor.apply($0) }
    }

    func attributedString() -> AttributedString {
        var md = Markdownosaur()
        return md.attributedString(from: document)
    }
}

struct GetNodes<M: Markup>: MarkupVisitor {
    public typealias Result = ()
    public private(set) var nodes: [M] = []
    public init() {}

    mutating func visit(_ markup: [any Markup]) -> [M]{
        for node in markup {
            visit(node)
        }
        return nodes
    }
    
    mutating
    public func defaultVisit(_ markup: Markup) {
        if let markup = markup as? M {
            nodes.append(markup)
        }
       for child in markup.children {
            visit(child)
        }
    }
}

struct MarkdownVisitor<Element>: MarkupVisitor {
    public typealias Result = ()
    public private(set) var marks: [Element] = []
    var fn: (any Markup) -> Element?
    
    public init (fn: @escaping (any Markup) -> Element?) {
        self.fn = fn
    }
    
    mutating public func apply(_ markup: Markup?) -> [Element] {
        guard let markup = markup else { return [] }
        visit(markup)
        return marks
    }
    
    mutating
    public func defaultVisit(_ markup: Markup) {
        if let mark = fn(markup) {
            marks.append(mark)
        }
       for child in markup.children {
            visit(child)
        }
    }
}

public extension XtDocument {
}

extension XtMarkdownToXML {
    static func read(_ document: Document) -> XMLDocument {
        var reader = XtMarkdownToXML()
        reader.visit(document)
        return XMLDocument(rootElement: reader.tree)
    }
}

// Custom iterator for XMLNode traversal
//public struct XMLNodeIterator<Output>: IteratorProtocol {
//    public typealias Modififier = (XMLNode) -> Output?
//    private var stack: [XMLNode]
//    private var currentIndex = 0
//    private let xform: Modififier?
//    
//    public init(
//        root: XMLNode,
//        currentIndex: Int = 0,
//        xform: Modififier? = nil
//    ) {
//        self.stack = [root]
//        self.currentIndex = currentIndex
//        self.xform = xform
//    }
//    
//    public mutating func next() -> XMLNode? {
//        guard let top = stack.last else { return nil }
//        if currentIndex >= top.childCount {
//            // if at last child then try and recurse
//            // 1st child (only if it has children
//            if let child = top.children?.first, child.childCount > 0 {
//                stack.append(child)
//                currentIndex = 0
//                return next()
//            }
//            stack.removeLast()
//            currentIndex = 0
//        }
//        defer { currentIndex += 1 }
//        return stack[currentIndex]
//    }
//}

// Make XMLNode conform to Sequence
//extension XMLNode: @retroactive Sequence {
//    public func makeIterator() -> XMLNodeIterator<XMLNode> {
//        return XMLNodeIterator(root: self)
//    }
//}

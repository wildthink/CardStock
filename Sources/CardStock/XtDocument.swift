//
//  XtDocument.swift
//  CardStock
//
//  Created by Jason Jobe on 2/8/25.
//

import Foundation
@preconcurrency import Markdown

public final class XtDocument: @unchecked Sendable {
    var document: Document
    var tree: XMLDocument
    var data: String?
    
    init (_ data: String) {
        self.data = data
        let doc = Document(parsing: data, options: [.parseBlockDirectives])
        tree = XtMarkdownToXML.read(doc)
        document = doc
    }
}

extension XMLDocument {
    func formatted() -> String {
        let data = xmlData(options: .nodePrettyPrint)
        let str:String? = String(data: data, encoding: .utf8)
        return str ?? "<XML Document>"
    }
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
    
//    var hero: URL? {
//        let md: [Markup] = markup(forXPath: "//hero")
//        return switch md {
//        case let it as [Markdown.Image]:
//            URL(string: it.first?.source ?? "")
//        case let it as [Markdown.Link]:
//            URL(string: it.destination ?? "")
//        default : nil
//        }
//    }

//    var links: [xLink] {
//        let ns = nodes(forXPath: "//links")
//        var md = Markdownosaur()
//        guard let first = ns.first, let markup = first.markup
//        else { return [] }
//        let str = md.visit(markup).str
//        var result: [xLink] = []
//        for (link, _) in str.runs[\.link] {
//            guard let link else { continue }
//            let xl = xLink(label: "link", url: link)
//            result.append(xl)
//        }
//        return result
//    }
    
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

//enum NodeType {
//    case section
//    case directive
//    case table
//    case list
//    case block
//}
//
//extension XtDocument: MarkupVisitor {
//    public typealias Result = ()
//    
//    mutating func read(document: Document) -> () {
//        
//    }
//    
//    mutating public
//    func defaultVisit(_ markup: any Markdown.Markup) -> () {
//        
//    }
//    
//    
//}

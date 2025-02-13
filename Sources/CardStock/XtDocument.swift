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
        tree = XtMarkdownReader.read(doc)
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
    
    func markup<M: Markup>(type: M.Type, forXPath xPath: String) -> [M] {
        var visitor = GetNodes<M>()
        let nodes = nodes(forXPath: xPath)
            .compactMap(\.markup)
        
        return visitor.visit(nodes)
    }

    var links: [xLink] {
        markup(type: Link.self, forXPath: "//links")
            .map(xLink.init)
    }
    
    func attributedStrings(forXPath xPath: String) -> [AttributedString] {
        var md = Markdownosaur()
        return markup(type: Link.self, forXPath: xPath)
            .map { md.visit($0).str }
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
    public func defaultVisit(_ markup: any Markup) {
        if let markup = markup as? M {
            nodes.append(markup)
        }
       for child in markup.children {
            visit(child)
        }
    }
}
//
//struct GetLinks: MarkupVisitor {
//    public typealias Result = ()
//    public private(set) var links: [Link] = []
//    public init() {}
//    mutating func defaultVisit(_ markup: any Markdown.Markup) { }
//    
//    public mutating func visitLink(_ link: Link) {
//        links.append(link)
//    }
//}
//
//public extension XtDocument {
//}

extension XtMarkdownReader {
    static func read(_ document: Document) -> XMLDocument {
        var reader = XtMarkdownReader()
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

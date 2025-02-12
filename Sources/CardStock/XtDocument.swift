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
        tree = MarkdownReader.read(doc)
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
    
    var links: [xLink] {
        let ns = nodes(forXPath: "//links")
        var md = Markdownosaur()
        guard let first = ns.first, let markup = first.markup
        else { return [] }
        let str = md.visit(markup).str
        var result: [xLink] = []
        for (link, _) in str.runs[\.link] {
            guard let link else { continue }
            let xl = xLink(label: "link", url: link)
            result.append(xl)
        }
        return result
    }
    
    func attributedString() -> AttributedString {
        var md = Markdownosaur()
        return md.attributedString(from: document)
    }
}

public extension XtDocument {
}

extension MarkdownReader {
    static func read(_ document: Document) -> XMLDocument {
        var reader = MarkdownReader()
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

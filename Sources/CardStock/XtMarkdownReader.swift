//
//  XtMarkdownReader.swift
//  CardStock
//
//  Created by Jason Jobe on 2/10/25.
//
import Foundation
import Markdown

public final class XMLMarkup: XMLElement {
    public var markup: (any Markup)?
    public var markdownLevel: Int = 0
    public var range: SourceRange? { markup?.range }
    public var source: SourceLocation? { range?.lowerBound }
    
    public override init(
        name: String,
        uri URI: String? = nil
    ) {
        super.init(name: name, uri: URI)
    }

    public convenience init(markup: any Markup, name: String, kind: XMLNode.Kind = .element) {
        self.init(name: name)
        self.markup = markup
//        self.objectValue = markup
    }
}

extension XMLElement {
    func addAttribute(name: String, value: Any) {
        let sv = String(describing: value)
        addAttribute(XMLNode.attribute(withName: name, stringValue: sv) as! XMLNode)
    }
}

public extension XMLMarkup {
    var attributedString: AttributedString? {
        guard let markup else { return nil }
        var reader = Markdownosaur()
        return reader.visit(markup).str
    }
}

public struct XtMarkdownReader: MarkupVisitor {
    public typealias Result = ()
    typealias Node = any Markup
    typealias XElement = XMLMarkup
    
    private(set) var tree: XElement
    private(set) var stack: [XElement] = []

    public init() {
        tree = XElement(name: "root")
    }
    
    mutating
    public func defaultVisit(_ markup: any Markup) -> Result {
        return descendInto(markup)
    }
    
    mutating func descendInto(_ node: Node) -> Result {
        for child in node.children {
            visit(child)
        }
    }
        
    // MARK: XML Stack functions
    var top: XElement { stack.last ?? tree }

    @discardableResult mutating func pop() -> XElement? {
        stack.isEmpty ? nil : stack.removeLast()
    }
    
    mutating func push(_ node: XElement) {
        top.addChild(node)
        stack.append(node)
    }
    
    func currentHeadingLevel() -> Int {
        // Traverse the stack from the top, searching for the most recent heading node
        for element in stack.reversed() {
            if element.kind == .element {  // Assuming .element indicates a heading
                return element.markdownLevel
            }
        }
        return 0  // Default level when no heading is found
    }
    
    mutating public func visitBlockDirective(_ node: BlockDirective) -> Result {
        let xn = XElement(markup: node, name: node.name, kind: .processingInstruction)
        push(xn)
        descendInto(node)
        print("count", node.childCount)
        for child in node.children {
            let p = child.print()
            print(p)
        }
        pop()
    }

    mutating public func visitHeading(_ heading: Heading) {
        let xn = XElement(markup: heading, name: "section")
//        xn.markdownLevel = heading.level
//        xn.addAttribute(name: "level", value: heading.level)

        let title = XElement(markup: heading, name: "heading")
        title.addAttribute(name: "markdownLevel", value: heading.level)
        title.stringValue = heading.plainText
        xn.addChild(title)
        
        // Pop elements until we find a proper parent
        while let top = stack.last, top.markdownLevel >= heading.level {
            pop()
        }

        push(xn)
    }
}

public extension Markup {
    func visit(_ visitor: (any Markup) -> Bool) {
        guard visitor(self) else { return }
        for child in children {
            child.visit(visitor)
        }
    }
}

public extension Markup {
    var typeName: String {
        String(describing: type(of: self))
    }

    func print(softbreak: String = " ") -> String {
        var s: String = ""
        self.print(to: &s, softbreak: softbreak)
        return s
    }
    
    func print(to cout: inout String, softbreak: String) {
        switch self {
            case is SoftBreak:
                Swift.print(softbreak, terminator: "", to: &cout)
            case is Paragraph:
                children.forEach({ $0.print(to: &cout, softbreak: softbreak)})
            case let l as Link:
                Swift.print(l.title ?? "link", l.destination ?? "dest",  terminator: "", to: &cout)
            case let p as PlainTextConvertibleMarkup:
                Swift.print(p.plainText, terminator: "", to: &cout)
            default:
                children.forEach({ $0.print(to: &cout, softbreak: softbreak)})
        }
    }
}

extension XMLMarkup {
    func print(_ indent: Int = 0) {
        let pad = String(repeating: " ", count: indent)
        Swift.print(pad, level, ":", markdownLevel, name ?? "<name>")
        guard let children else { return }
        for child in children where child is XMLMarkup {
            guard let child = child as? XMLMarkup else { continue }
            child.print(indent + 2)
        }
    }
}

let sampleMarkdown = """
@meta(version: 1.2) {
    key: v1
    key2: v2
}

# Jason Jobe
![Jason](https://wildthink.com/apps/jason/avatar.png)

## Section 1
Section one stuff

### Section 1.1
Some subsection stuff.
Line two.

## Section 2

# Top Section

@lede {
Professional iOS Application Architect
Amateur Social Scientist
Tinker, Maker, Smith
}

@comment{ links include linkedIn, github, instagram, etc }
@place() {
    @location(lat: 124, log: 456)
Oakland, Maryland US
}
"""


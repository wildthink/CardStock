//
//  XtMarkdownToXML.swift
//  CardStock
//
//  Created by Jason Jobe on 2/10/25.
//
import Foundation
import Markdown

@dynamicMemberLookup
struct BlackBox<Item>: CustomStringConvertible {
    let item: Item
    
    init(_ item: Item) {
        self.item = item
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Item, T>) -> T {
        item[keyPath: keyPath]
    }
    
    var description: String {
        ""
//        "(\(String(describing: Item.self)))"
    }
}

     
open class XMLMarkup: XMLElement {
    public var markup: Markup?
    //    {
    //        get { (objectValue as? BlackBox<Markup>)?.item }
    //        set { objectValue = newValue.map(BlackBox.init) }
    //    }
    
    public var markdownLevel: Int = 0
    public var range: SourceRange? { markup?.range }
    public var source: SourceLocation? { range?.lowerBound }
    
    public override init(name: String, uri URI: String? = nil) {
        super.init(name: name, uri: URI)
        self.uri = URI
        self.name = name
    }
    
    public convenience init(markup: any Markup, name: String) {
        self.init(name: name)
        self.markup = markup
//        self.objectValue = BlackBox(markup)
    }
    
    public convenience init(instruction: BlockDirective, name: String? = nil) {
        self.init(name: name ?? instruction.name)
        self.markup = instruction
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

public struct XtMarkdownToXML: MarkupVisitor {
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
    
    /**
        The @id BlockDirective is a special case used to addAttributes(...) to its parent XMLElement.
        Using this can reduce annoying nesting level management.
     */
    mutating public func visitBlockDirective(_ node: BlockDirective) -> Result {
        if node.name.lowercased() == "id" {
            let xe = top
            let argv = node.argumentText.parseNameValueArguments()
            for arg in argv {
                if arg.name.isEmpty {
                    xe.name = arg.value
                } else {
                    xe.addAttribute(name: arg.name, value: arg.value)
                }
            }
        } else {
            let xn = XElement(instruction: node)
            top.addChild(xn)
        }
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
    func apply(_ visitor: (any Markup) -> Bool) {
        guard visitor(self) else { return }
        for child in children {
            child.apply(visitor)
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
@hero {
![Jason](https://wildthink.com/apps/jason/Jason_AI.jpeg)
}

@Caption {
- Professional iOS Application Architect
- Amateur Social Scientist
- Tinker, Maker, Smith
}

@links {
    [Gravatar](https://jasonjobe.link)
    [](https://www.linkedin.com/in/jason-jobe-bb0b991/)
    [](https://medium.com/@jasonjobe)
    [](https://github.com/wildthink)
    [](https://www.instagram.com/jmj_02021/)
}

#### Elevator Pitch
@id(pitch, ax: b
c 889)
Here is where I say a little bit about myself.
Perhaps, what I like to do for fun.
Or anything else.

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


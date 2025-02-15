//import Testing
@testable import CardStock
import XCTest
import OSLog
import SwiftUI

final class carbonTests: XCTestCase {
    
    func testURL() {
        report("isbn:5670-9898-765")
        report("isbn:/5670-9898-765")
        report("isbn://5670-9898-765")
        report("isbn:///5670-9898-765")
        print("done", #function)
    }
    
    func report(_ url: String, line: Int = #line) {
        guard let u = URL(string: url) else {
            print("BAD URL", url)
            return
        }
        print("URL[\(line)] \(u)")
        pr(u, \.scheme)
        pr(u, \.host)
        pr(u, \.path)
    }
    
//    var dateString: AttributedString {
//            var attributedString = Date.now.formatted(.dateTime
//                .hour()
//                .minute()
//                .weekday()
//                .attributed
//            )
//            let weekContainer = AttributeContainer()
//                .dateField(.weekday)
//            let colorContainer = AttributeContainer()
//                .foregroundColor(.red)
//            attributedString.replaceAttributes(weekContainer, with: colorContainer)
//            return attributedString
//    }
    
//    func testAttributedString() {
////        print(dateString)
//        let doc: Document = profileDoc
//        var mdp = Markdownosaur()
//        let attrString = mdp.attributedString(from: doc)
//        print(attrString)
//    }
    
//    func testReader() throws {
////        print(dateString)
//        let doc: Document = profileDoc
//        var mr = XtMarkdownToXML()
//        mr.visit(doc)
////        mr.tree.print()
//        print(doc.debugDescription())
//        
//        let xs = mr.tree.xmlString(options: .nodePrettyPrint)
//        print(xs)
//        
//        if let links = try? mr.tree.nodes(forXPath: "*/links") {
//            print(links)
//            if let it = links.first as? XMLMarkup, let md = it.markup {
//                print("range", md.range as Any)
//                print(md.print())
//            }
//        }
//        
//        let l = jason.links
//        print(l)
//    }
    
    func testXpath() {
        let doc = jason
        let hero = doc.attributedStrings(forXPath: "//hero")
        print(hero)

//        let heros = doc.tree.nodes(matching: [.anypath, .tag("hero")])
//        print(heros)
        
//        let links: [xLink] = doc
//            .markup(type: Link.self, forXPath: "//links")
//            .compactMap(xLink.init)
//        print(links)
  
        let headings = doc.tree
            .foreach()
            .lazy
            .matching(path: "/heading")
    
//        print("nth(1)", headings.nth(1)!.format())
        
        for h1 in headings {
            print(h1.format())
        }
        print("fin", #function)
//        let h1 = doc.markup(forXPath: "(//section/heading)[1]")
//        print(h1)
//
//        let h1s = doc.tree.nodes(matching: [.anypath, .tag("section"), .index(1)])
//        for n in h1s {
//            print(n.name!, n.stringValue ?? "")
//        }

    }
    
    func testXMLIterator() {
        // Example XML
        let xmlString = """
        <catalog>
            <book id="bk101">
                <title>XML Developer's Guide</title>
                <author>John Doe</author>
            </book>
            <book id="bk102">
                <title>Learning Swift</title>
                <author>Jane Smith</author>
            </book>
        </catalog>
        """

        func id(_ n: XMLNode) -> String {
            (n as? XMLElement)?.attribute(forName: "id")?.stringValue ?? ""
        }
        func pr(_ n: XMLNode) {
            print(n.name ?? String(describing: type(of:n)), id(n), n.stringValue ?? "No Content")
        }
        
        /*
         // layout(xpath: "//section[1]/heading[1]", axis: .vertical)
         // e.g. catalog[*].section[1].*heading
         // e.g. catalog//.book[1].title
         // catalog//.title[1] -> match "title" in depth -> Seq().nth(1)
         // catalog.book[1].title -> explicit path
         */
        
        // Parse XML
        guard let xmlData = xmlString.data(using: .utf8),
           let xmlDoc = try? XMLDocument(data: xmlData, options: .documentTidyXML),
           let root = xmlDoc.rootElement()
        else { return }

        let itr = XMLIterator(root)
        
        print(root.format())
        
        let titles = itr.filter { $0.name == "title" }
        print(titles)
        
        if let n = itr.nth(1) {
            pr(n)
        }
        
        for x in itr where !id(x).isEmpty {
            pr(x)
        }
//        }
        print("done")
    }
}

extension XMLNode {

    func matches(path: String) -> Bool {
        let p = path.split(separator: "/")
        return matches(path: p[0...])
    }
    
    func matches(path: ArraySlice<String.SubSequence>) -> Bool {
        guard let key = path.last, let name, name == key
        else { return false }
        let rest = path.dropLast()
        if rest.isEmpty { return true }
        // No parent but expects one => false / no match
        return parent?.matches(path: rest) ?? false
    }
}

extension XMLNode {
//    func foreach() -> any Sequence<XMLNode> {
    func foreach() -> XMLIterator {
        XMLIterator(self)
    }
}

public struct XMLIterator: IteratorProtocol, Sequence {
    private var queue: [XMLNode]
    // TODO: Add pruning filter function
    //
    private var prune: ((XMLNode) -> Bool)?
    
    public init(_ parent: XMLNode) {
        queue = parent.children ?? []
    }

    public init(_ nodes: [XMLNode]) {
        queue = nodes
    }

    mutating func enqueue(_ nodes: [XMLNode]?) {
        guard let nodes else { return }
        if let prune = prune {
            queue.append(contentsOf: nodes.filter(prune))
        } else {
            queue.append(contentsOf: nodes)
        }
    }
    
    public mutating func next() -> XMLNode? {
        guard !queue.isEmpty else { return nil }
        
        let node = queue.removeFirst()
        enqueue(node.children)
        return node
    }
}

extension LazySequence where Elements.Element == XMLNode {
    func nodes(named name: String) -> LazyFilterSequence<Elements> {
        return self.filter { $0.name == name }
    }
    
    func matching(path: String) -> LazyFilterSequence<Elements> {
        filter { $0.matches(path: path) }
    }
}

extension Sequence where Element == XMLNode {
    func nodes(named name: String) -> [Element] {
        filter { $0.name == name }
    }
    
    func matching(path: String) -> [Element] {
        filter { $0.matches(path: path) }
    }
}

//public extension LazyFilterSequence {
//    func Xmatching(_ isIncluded: @escaping (Self.Elements.Element) -> Bool) -> LazyFilterSequence<Self.Elements>
//    {
//        filter(isIncluded)
//    }
//    
//    func matching(path: String) -> LazyFilterSequence<Self.Elements>
////    where Base == XMLNode
//    {
//        filter { $0.matches(path: path) }
//    }
//
//////    func matching(_ path: String) -> Self {
//////        return self
//////            .filter { $0.matches(path: path) }
//////    }
//}

// LazyFilterSequence
public extension Sequence {
    func nth(_ ndx: Int) -> Element? {
        guard ndx > 0 else {
            return nil
        }
        var count = 1
        for x in self {
            if count == ndx {
                return x
            }
            count += 1
        }
        return nil
    }
}

import Foundation

extension XMLNode {
    
    func format() -> String {
        var str = ""
        self.format(to: &str)
        return str
    }

    func format<OS: TextOutputStream>(_ level: Int = 0, to str: inout OS, isLast: Bool = true, prefix: String = "") {
        
        let connector = isLast ? "└── " : "├── "
        let newPrefix = prefix + (isLast ? String(repeating: " ", count: level * 2) : "│   ")
        
        let name = self.name ?? self.stringValue ?? "(null)"
        if level == 0 {
            Swift.print(name, separator: "", terminator: "\n", to: &str)
        } else {
            Swift.print(prefix, connector, name, separator: "", terminator: "\n", to: &str)
        }

        guard let children = self.children, !children.isEmpty else { return }
        
        for (index, child) in children.enumerated() {
            let isLastChild = index == children.count - 1
            child.format(level + 1, to: &str, isLast: isLastChild, prefix: newPrefix)
        }
    }
}

struct ArrayWrapper<Store, Element>: RandomAccessCollection {
    private var array: [Store]
    var fn: (Store) -> Element
    
    init(array: [Store], fn: @escaping (Store) -> Element) {
        self.array = array
        self.fn = fn
    }
    
    var startIndex: Int {
        array.startIndex
    }

    var endIndex: Int {
        array.endIndex
    }

    subscript(index: Int) -> Element {
        fn(array[index])
    }

    func index(after i: Int) -> Int {
        array.index(after: i)
    }

    func index(before i: Int) -> Int {
        array.index(before: i)
    }
    
    func transmute<Item>(_ fn: @escaping (Element) -> Item) -> ArrayWrapper<Store, Item> {
        .init(array: array, fn: { fn(self.fn($0)) })
    }
}

func testXfrom() {
    // Sample input sequence (numbers)
    let numbers = [1, 2, 3, 4, 5]

    // Define a transformation function (e.g., square each number)
    let squareTransform: (Int) -> String = { "Square of \($0) is \($0 * $0)" }

    // Get an iterator that transforms numbers to strings
    var transformedIterator = numbers.transformingIterator(squareTransform)

    // Iterate and print transformed values
    while let transformedValue = transformedIterator.next() {
        print(transformedValue)
    }
    print("Complete", #function)
}

import Foundation

// Generic Transforming Iterator
struct TransformingIterator<Input, Output>: IteratorProtocol {
    private var baseIterator: AnyIterator<Input>
    private let transform: (Input) -> Output

    init<I: IteratorProtocol>(iterator: I, transform: @escaping (Input) -> Output) where I.Element == Input {
        self.baseIterator = AnyIterator(iterator)
        self.transform = transform
    }

    mutating func next() -> Output? {
        guard let nextInput = baseIterator.next() else { return nil }
        return transform(nextInput)
    }
}

// Make Sequence support transforming iterators
extension Sequence {
    func transformingIterator<Output>(_ transform: @escaping (Element) -> Output) -> AnyIterator<Output> {
        return AnyIterator(TransformingIterator(iterator: self.makeIterator(), transform: transform))
    }
}


// Example Usage


func prettyFormat(xmlString:String) -> String? {
  do {
    let xml = try XMLDocument.init(xmlString: xmlString)
    let data = xml.xmlData(options: .nodePrettyPrint)
    let str:String? = String(data: data, encoding: .utf8)
    return str
  }
  catch {
    print (error.localizedDescription)
  }
  return nil
}

@preconcurrency import Markdown
//let profileDoc: Document = Document(parsing: md, options: [.parseBlockDirectives])
let jason = XtDocument(sampleMarkdown)

//let md = """
//@meta(version: 1.2) {
//    key: v1
//    key2: v2
//}
//
//# Jason Jobe
//@id(jason)
//@hero {
//[Jason](https://wildthink.com/apps/jason/avatar.png)
//}
//
//@links {
//- [Gravatar](https://jasonjobe.link)
//- [l](https://www.linkedin.com/in/jason-jobe-bb0b991/)
//- [m](https://medium.com/@jasonjobe)
//- [g](https://github.com/wildthink)
//- [i](https://www.instagram.com/jmj_02021/)
//}
//
//## Section 1
//Section one stuff
//
//### Section 1.1
//Some subsection stuff.
//Line two.
//
//## Section 2
//
//# Top Section
//@lede {
//    Some introductory content.
//}
//@comment {
//    Comment on the section.
//}
//@place {
//    @location {
//        # Place Name
//        Information about a place.
//        Specific location within the place.
//    }
//}
//
//"""
//
//let hold = """
//
//@lede {
//Professional iOS Application Architect
//Amateur Social Scientist
//Tinker, Maker, Smith
//}
//
//@comment{ links include linkedIn, github, instagram, etc }
//@place() {
//    @location(lat: 124, log: 456)
//Oakland, Maryland US
//}
//"""

func pr<T,V>(_ t: T, _ k: KeyPath<T,V>, line: Int = #line) {
    let value = t[keyPath: k]
    print("  ", String(describing: k), String(describing: value))
}

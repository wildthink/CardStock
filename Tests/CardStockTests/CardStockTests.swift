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
//        let hero = doc.attributedStrings(forXPath: "//hero")
//        print(hero)
//
//        let heros = doc.tree.nodes(matching: [.anypath, .tag("hero")])
//        print(heros)
        
//        let links: [xLink] = doc
//            .markup(type: Link.self, forXPath: "//links")
//            .compactMap(xLink.init)
//        print(links)
  
        let items = doc.tree
            .foreach()
            .matching(path: "/section/heading")
    
//        print("nth(1)", headings.nth(1)!.format())
        
        for h1 in items {
            print(h1.format())
        }
        
        let links = doc.select(links: "links")
        links.forEach({ print($0)})
        
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
        
        print(root.format())

        let tests = [
            "/catalog/book", "catalog/book",
            "book",
            "/book", "bad/book",
        ]
        for t in tests {
            let items = root
                .foreach()
                .matching(path: t)
                .first
            print("TEST", t)
            if let str = items?.format() { print(str) }
        }
        print("done")
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
    let transformedIterator = numbers.transformingIterator(squareTransform)

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


//func prettyFormat(xmlString:String) -> String? {
//  do {
//    let xml = try XMLDocument.init(xmlString: xmlString)
//    let data = xml.xmlData(options: .nodePrettyPrint)
//    let str:String? = String(data: data, encoding: .utf8)
//    return str
//  }
//  catch {
//    print (error.localizedDescription)
//  }
//  return nil
//}

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

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
        
        let tx = doc
            .select("section")
            .nth(1)
//            .cast(to: XMLMarkup.self)
//            .map(trace)
//            .map(\.string)
//            .compactMap(\.markup)
//            .nodes(ofType: Text.self)

            print(tx)
 
        let n1 = doc.select("caption")
        n1.forEach({ print($0) })

        func trace<T>(_ v: T) -> T {
            print(String(describing: v))
            return v
        }
        
        let mlinks = doc.select("links", ofType: Link.self)
//        let xlinks = mlinks
            .compactMap(xLink.init)
        mlinks.forEach({ print($0) })
        
//        let links = doc.tree
//            .foreach()
//            .lazy
//            .matching(path: "links")
//            .cast(to: XMLMarkup.self)
//            .compactMap(\.markup)
//            .nodes(ofType: Link.self)
//            .compactMap(xLink.init)
//        
//
//        links.forEach({ print($0) })
        
        print("fin", #function)
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
    
    func testStringCompare() {
        print("Foo ~ foo", "Foo" ~ "foo")
        print("foo ~ foo", "foo" ~ "foo")
        print("foo ~ foO", "foo" ~ "foO")
    }
    
    func testGetDomain() {
        let host: String? = "www.example.com"
        guard let host else { return }
        let list = host.split(separator: ".")
        let it = list.count >= 2 ? list[list.count - 2] : ""
        print (it)
        
//        let p1 = Bundle.module.path(forResource: "globe", ofType: nil)
//        let p2 = Bundle.module.path(forResource: "Resources/linkedin", ofType: nil)
//        let p3 = Bundle.module.urlForImageResource("linkedin")
//        print("Bundle", Bundle.module.bundlePath)
//        print(p1, p2, p3)
    }
}


// Make Sequence support transforming iterators
extension Sequence {
    
//    func cast<T>(to : T.Type) -> (Self.Element) -> [T] {
//        var values = [T]()
//        
//        for element in self {
//            if let it = element as? T {
//                values.append(it)
//            }
//        }
//        return values
//    }

//    func map<T, E>(_ transform: (Self.Element) (E) -> [T] where E : Error
//    {
//        
//    }
    
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
//let jason = XtDocument(sampleMarkdown)

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

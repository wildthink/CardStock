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
    
    func testAttributedString() {
//        print(dateString)
        let doc: Document = profileDoc
        var mdp = Markdownosaur()
        let attrString = mdp.attributedString(from: doc)
        print(attrString)
    }
    
    func testReader() throws {
//        print(dateString)
        let doc: Document = profileDoc
        var mr = MarkdownReader()
        mr.visit(doc)
        mr.tree.print()
        
        let xs = mr.tree.xmlString(options: .nodePrettyPrint)
        print(xs)
        
        if let links = try? mr.tree.nodes(forXPath: "*/links") {
            print(links)
            if let it = links.first as? XMLMarkup, let md = it.markup {
                print("range", md.range)
                print(md.print())
            }
        }
        
        let l = jason.links
        print(l)
    }
}

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
let profileDoc: Document = Document(parsing: md, options: [.parseBlockDirectives])
let jason = XtDocument(jason_md)

let md = """
@meta(version: 1.2) {
    key: v1
    key2: v2
}

# Jason Jobe @id(jason)
![Jason](https://wildthink.com/apps/jason/avatar.png)

@links {
- [Gravatar](https://jasonjobe.link)
- [l](https://www.linkedin.com/in/jason-jobe-bb0b991/)
- [m](https://medium.com/@jasonjobe)
- [g](https://github.com/wildthink)
- [i](https://www.instagram.com/jmj_02021/)
}

## Section 1
Section one stuff

### Section 1.1
Some subsection stuff.
Line two.

## Section 2

# Top Section
@lede {
    Some introductory content.
}
@comment {
    Comment on the section.
}
@place {
    @location {
        # Place Name
        Information about a place.
        Specific location within the place.
    }
}

"""

let hold = """

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

func pr<T,V>(_ t: T, _ k: KeyPath<T,V>, line: Int = #line) {
    let value = t[keyPath: k]
    print("  ", String(describing: k), String(describing: value))
}

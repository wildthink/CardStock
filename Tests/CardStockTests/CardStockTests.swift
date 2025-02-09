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
    
    var dateString: AttributedString {
            var attributedString = Date.now.formatted(.dateTime
                .hour()
                .minute()
                .weekday()
                .attributed
            )
            let weekContainer = AttributeContainer()
                .dateField(.weekday)
            let colorContainer = AttributeContainer()
                .foregroundColor(.red)
            attributedString.replaceAttributes(weekContainer, with: colorContainer)
            return attributedString
    }
    
    func testAttributedString() {
//        print(dateString)
        let doc: Document = profileDoc
        var mdp = Markdownosaur()
        let attrString = mdp.attributedString(from: doc)
        print(attrString)
    }
}

@preconcurrency import Markdown
let profileDoc: Document = Document(parsing: md, options: [.parseBlockDirectives])

let md = """
# Jason Jobe
![Jason](https://wildthink.com/apps/jason/avatar.png)

@lede {
Professional iOS Application Architect
Amateur Social Scientist
Tinker, Maker, Smith
}

@comment{ links include linkedIn, github, instagram, etc }
@place() {
Oakland, Maryland US
}

@links {
    [Gravatar](https://jasonjobe.link)
    [l](https://www.linkedin.com/in/jason-jobe-bb0b991/)
    [m](https://medium.com/@jasonjobe)
    [g](https://github.com/wildthink)
    [i](https://www.instagram.com/jmj_02021/)
}

"""
        
func pr<T,V>(_ t: T, _ k: KeyPath<T,V>, line: Int = #line) {
    let value = t[keyPath: k]
    print("  ", String(describing: k), String(describing: value))
}

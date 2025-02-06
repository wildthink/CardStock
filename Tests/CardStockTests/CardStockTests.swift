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
let profileDoc: Document = Document(parsing: """
# Jason Jobe
### Tinker, Maker, Smith

^[email](mailto:box@example.com)

""",
options: [.parseBlockDirectives]
)

func pr<T,V>(_ t: T, _ k: KeyPath<T,V>, line: Int = #line) {
    let value = t[keyPath: k]
    print("  ", String(describing: k), String(describing: value))
}

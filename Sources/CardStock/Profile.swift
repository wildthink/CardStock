//
//  Profile.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import SwiftUI
@preconcurrency import Markdown

/*
 message (Apple)
 bubble
 envelope emailto:jane@jetsons.com
 phone tel:199999
 globe https: http:
 mappin.and.ellipse 􀎫 geo:25.245470,51.454009
 */

struct xLink: Identifiable {
    var id: Int { url.absoluteString.hashValue }
    var label: String
    var url: URL
    var customIcon: SwiftUI.Image?
    
    var icon: SwiftUI.Image {
        customIcon ??
            .init(systemName: commonFavicon ?? defaultIcon)
    }
}

extension xLink {
    
    init?(_ link: Markdown.Image) {
        guard let urlString = link.source,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self.customIcon = nil
    }

    init?(_ link: Markdown.Link) {
        guard let urlString = link.destination,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self.customIcon = nil
    }
}

extension xLink {
    var defaultIcon: String {
        switch url.scheme {
            case "https", "http": "globe"
        case "tel": "phone"
        case "geo": "mappin.and.ellipse"
        case "sms": "bubble"
            case "mailto": "envelope"
        default:
            "link"
        }
    }
    
    var commonFavicon: String? {
        switch url.host {
        case "apple.com":
            "apple.logo"
        default:
             nil
        }
    }
}

struct LinkView: View {
    enum Style { case iconOnly, iconAndLabel, labelOnly }
    var model: xLink
    var style: Style = .iconAndLabel
    
    var body: some View {
        switch style {
            case .iconOnly:
            model.icon.resizable()
                .frame(width: 16, height: 16)
        case .iconAndLabel:
            HStack(alignment: .center) {
                model.icon.resizable()
                    .frame(width: 16, height: 16)
                Text(model.label)
            }
        case .labelOnly:
            Text(model.label)
        }
    }
}

struct xText: View {
    var body: some View {
        Text("")
    }
}

extension [AttributedString] {
    mutating func append(_ new: AttributedSubstring) {
        self.append(AttributedString(new))
    }
}

struct ProfileView: View {
    var doc: XtDocument = jason

    var body: some View {
        ScrollView {
            hero
                .padding(48)
            VStack(alignment: .leading) {
                ForEach(doc.links) {
                    LinkView(model: $0)
                }
            }
        }
    }
    
    @ViewBuilder
    var hero: some View {
        if let str = doc.attributedStrings(forXPath: "//hero").first {
            view(str)
        }
    }

    @ViewBuilder
    func view(_ attr: AttributedString) -> some View {
        if attr.link != nil {
            Text(attr)
                .border(.red)
        } else if let url = attr.imageURL {
            AsyncImage(url: url) { image in
                   image
                       .resizable()
                       .scaledToFill()
               } placeholder: {
                   ProgressView()
               }
               .background(Color.gray)
               .clipShape(Circle())
        } else {
            Text(attr)
        }
    }

}

struct ContentView: View {
    var doc: XtDocument = XtDocument(sampleMarkdown)
//    @State var mdp = Markdownosaur(baseSize: 8)
    let img = Image(systemName: "message.badge.filled.fill")
    let ns_img = NSImage(systemSymbolName: "message.badge.filled.fill", accessibilityDescription: nil)!
    
    var body: some View {
        TabView {
            ProfileView(doc: doc)
//            ScrollView {
//                VStack(alignment: .leading, spacing: 0) {
//                    ForEach(parts, id: \.offset) {
//                        view($0.element)
//                    }
//                    ForEach(doc.links) {
//                        LinkView(model: $0)
//                    }
//                }
//            }

            .tabItem {
                Label("Profile", systemImage: "doc")
            }
            
            ScrollView {
                Text(doc.tree.formatted())
            }
            .tabItem {
                Label("XML", systemImage: "doc")
            }

            ScrollView {
                Text(doc.document.debugDescription())
            }
            .tabItem {
                Label("Markdown", systemImage: "doc")
            }
        }
        .environment(\.openURL, OpenURLAction(handler: { url in
            print("Tap on URL: \(url)")
            return .discarded
        }))
    }
    
    
    var parts: [(offset: Int, element: AttributedString)] {
        let it = Array(partition().enumerated())
        return it
    }

    func partition() -> [AttributedString] {
//        let str = mdp.attributedString(from: doc)
        let str = doc.attributedString()
//        var new = str
//        let nl = AttributedString("\n")
        var parts: [AttributedString] = []
        for (_, range) in str.runs[\.imageURL] {
            parts.append(str[range])
        }
        return parts
    }

}

//func foo() -> AttributedString {
//    let img = NSImage(systemSymbolName: "message.badge.filled.fill", accessibilityDescription: nil)!
//    let attachment = NSTextAttachment(data: nil, ofType: "")
//    attachment.image = img
//    return AttributedString(NSAttributedString(attachment: attachment))
//}

#Preview {
    ContentView()
        .frame(width: 400, height: 500)
        .padding()
}

let jason = XtDocument(jason_md)

//let jason: Document = Document(parsing: jason_md,options: [.parseBlockDirectives])

let jason_md = """
@meta {
    baseURL: https://wildthink.com/apps/jason
}

# Jason
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
"""
/*
@comment{ links include linkedIn, github, instagram, etc }
@place(coordinates: []) {
Oakland, Maryland US
}
*/


let profileDoc: Document = Document(parsing: """
# Heading I
## Heading II
### Heading III
#### Heading IV
##### Heading V
###### Heading VI

@() {
[email](mailto:box@example.com)
[example.com](https://example.com)
}

![Image_x](https://wildthink.com/apps/Images/AppIcon.png)

@comment{ links include linkedIn, github, instagram, etc }


> Block Quote\n
> line 2\n
> line 3

##### List
1. one
1. two
- [ ] check
- [x] checked
- three

One sentence here.

```
Some code
line 2
line 3
```

""",
options: [.parseBlockDirectives]
)

// MARK: Misc
#if os(macOS)
import Cocoa

//extension NSImage {
//    public func attributedString() -> NSAttributedString {
//        let attachment = ImageAttachment()
//        attachment.image = self
//        return .init(attachment: attachment)
//    }
//}

func foo() -> NSAttributedString {
    let fullString = NSMutableAttributedString(string: "Start of text")
    
    // create our NSTextAttachment
    let image1Attachment = NSTextAttachment()
    image1Attachment.image = NSImage(systemSymbolName: "star", accessibilityDescription: nil)
    //    image1Attachment.image = UIImage(named: "awesomeIcon.png")
    
    // wrap the attachment in its own attributed string so we can append it
    let image1String = NSAttributedString(attachment: image1Attachment)
    
    // add the NSTextAttachment wrapper to our full string, then add some more text.
    fullString.append(image1String)
    fullString.append(NSAttributedString(string: "End of text"))
    return fullString
    // draw the result in a label
    //    yourLabel.attributedText = fullString
}
#endif


//    func _partition() -> [AttributedString] {
//        let str = mdp.attributedString(from: doc)
//        var result: [AttributedString] = []
//        var currentRange: Range<AttributedString.Index>? = nil
//
//        for run in str.runs {
////            if let scope = run.scope {
////                print("Scope: \(scope)")
////            }
//            if let link = run.link {
//                // Add the current accumulated text range to the result before handling the link
//                if let range = currentRange {
//                    result.append(AttributedString(str[range]))
//                    currentRange = nil
//                }
//
////                print("link", link)
//                result.append(str[run.range])
//            } else if let img = run.imageURL {
//                // Add the current accumulated text range to the result before handling the image
//                if let range = currentRange {
//                    result.append(AttributedString(str[range]))
//                    currentRange = nil
//                }
//
//                print("img", img)
//                result.append(str[run.range])
//                // You could optionally add an image representation here if needed
////            } else if let scope = run.scope {
////                print("Scope: \(scope)")
////
//            } else {
//                if let sp = run.textBreak {
//                    print("Text break: \(sp)")
//                }
//
//                // Accumulate ranges of consecutive text runs
//                if let existingRange = currentRange {
//                    currentRange = existingRange.lowerBound..<run.range.upperBound
//                } else {
//                    currentRange = run.range
//                }
//            }
//        }
//
//        // Add any remaining accumulated text to the result
//        if let range = currentRange {
//            result.append(AttributedString(str[range]))
//        }
//
//        return result
//    }

//
//  Profile.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import SwiftUI
@preconcurrency import Markdown

struct xText: ModelView {
    var model: AttributedString
    
    init(_ model: Model) {
        self.model = model
    }

    var body: some View {
        Text(model)
    }
}

//extension xText where Model == AttributedString {
//    var body: some View {
//        Text(model)
//    }
//}
//
//extension xText where Model == String {
//    var body: some View {
//        Text(model)
//    }
//}

extension [AttributedString] {
    mutating func append(_ new: AttributedSubstring) {
        self.append(AttributedString(new))
    }
}

//extension XtDocument {
//    func select(_ xpath: String) {
//        
//    }
//}

public protocol ModelView<Model>: View where Model: Hashable {
    associatedtype Model
    var model: Model { get }
}

struct ProfileView: ModelView {
    var model: XmDocument = jason
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                layout(first: "hero")
                    .frame(width: 200)
                    .padding()
                layout(first: "caption")
//                layout(all: "section", axis: .vertical)
                layout(first: "section/heading")
                layout(first: "section/text")
                    .frame(maxWidth: 300)

//                layout(all: "section/heading", axis: .vertical)
//                    .padding(48)
                VStack(alignment: .leading) {
                    ForEach(model.links) {
                        LinkView(model: $0)
//                            .border(.red)
                    }
                }
            }
        }
    }
}


public extension ModelView where Model == XmDocument {

    @ViewBuilder
    func layout(first xpath: String) -> some View {
        if let item = model.tree
            .foreach()
            .matching(path: xpath)
            .compactMap({ $0 as? XMLMarkup })
            .compactMap(\.attributedString)
            .first
        {
            view(item)
        }
    }
    
    @ViewBuilder
    func layout(all xpath: String, axis: Axis) -> some View {
        let attr = model.tree
            .foreach()
            .matching(path: xpath)
            .compactMap({ $0 as? XMLMarkup })
            .compactMap(\.attributedString)

        switch axis {
        case .horizontal:
            HStack {
                ForEach(attr, id: \.self) {
                    view($0).border(.red)
                }
            }
        case .vertical:
            VStack {
                ForEach(attr, id: \.self) {
                    view($0).border(.red)
                }
            }
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
               .clipShape(.rect(cornerRadius: 8))
        } else {
            xText(attr)
        }
    }

}

#if canImport(AppKit)
    func pbCopy(_ str: @autoclosure () -> String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(str(), forType: .string)
    }
#endif
    
#if canImport(UIKit)
    func pbCopy(_ str: @autoclosure () -> String) {
        let pb = UIPasteboard.general
        pb.string = str()
    }
#endif

//@ViewBuilder
////func CopyButton(_ str: @autoclosure @escaping () -> String) -> some View {
//    Button(action: { pbCopy(str()) }) {
//        Image(systemName: "square.and.arrow.up")
//    }
//}

extension SwiftUI.Image {
    init?(qname: String, bundle: Bundle? = nil) {
        #if os(macOS)
        let img =
                NSImage(systemSymbolName: qname, accessibilityDescription: nil)
                ?? NSImage(named: qname)
        if let img {
            self = Image(nsImage: img)
        } else {
            self = Image(qname, bundle: bundle)
        }
        #else
        if let img =
            UIImage(systemName: qname) {
            self = Image(uiImage: img)
        } else {
            self = Image(qname, bundle: bundle)
        }
        #endif
    }
}

struct ContentView: View {
    var doc: XmDocument = jason
//    @State var mdp = Markdownosaur(baseSize: 8)
    let img = Image(qname: "message.badge.filled.fill")
//    let ns_img = NSImage(systemSymbolName: "message.badge.filled.fill", accessibilityDescription: nil)!
    
    var body: some View {
        TabView {
            ProfileView(model: doc)
            .tabItem {
                Label("Profile", systemImage: "doc")
            }
            
            ScrollView {
//                let str = doc.tree.rootElement()!.xmlString(options: .nodePrettyPrint)
                let str = doc.tree.xml
                Text(str)
                    .multilineTextAlignment(.leading)
                    .monospaced()
                    .onTapGesture {_ in
                        pbCopy(str)
                    }
            }
            .tabItem {
                Label("XML", systemImage: "doc")
            }

            ScrollView {
//                let str = doc.tree.rootElement()!.format()
                let str = doc.tree.format()
               Text(str)
                    .multilineTextAlignment(.leading)
                    .monospaced()
                    .onTapGesture {_ in
                        pbCopy(str)
                    }
            }
            .tabItem {
                Label("XTree", systemImage: "doc")
            }

            if let text = doc.data {
                ScrollView {
                    Text(text)
                        .onTapGesture {_ in
                            pbCopy(text)
                        }
                }
                .tabItem {
                    Label("Text", systemImage: "doc")
                }
            }
            ScrollView {
                Text(doc.document.debugDescription())
                    .monospaced()
            }
            .tabItem {
                Label("Tree", systemImage: "doc")
            }
        }
        .environment(\.openURL, OpenURLAction(handler: { url in
            print("Tap on URL: \(url)")
            return .discarded
        }))
    }
    
    
//    var parts: [(offset: Int, element: AttributedString)] {
//        let it = Array(partition().enumerated())
//        return it
//    }

//    func partition() -> [AttributedString] {
////        let str = mdp.attributedString(from: doc)
//        let str = doc.attributedString()
////        var new = str
////        let nl = AttributedString("\n")
//        var parts: [AttributedString] = []
//        for (_, range) in str.runs[\.imageURL] {
//            parts.append(str[range])
//        }
//        return parts
//    }

}

//func foo() -> AttributedString {
//    let img = NSImage(systemSymbolName: "message.badge.filled.fill", accessibilityDescription: nil)!
//    let attachment = NSTextAttachment(data: nil, ofType: "")
//    attachment.image = img
//    return AttributedString(NSAttributedString(attachment: attachment))
//}

#Preview {
    ContentView()
//        .frame(width: 500, height: 700)
        .padding()
}

//let jason: Document = Document(parsing: jason_md,options: [.parseBlockDirectives])

let jason = XmDocument(jason_md)

let jason_md = """
@meta {
    baseURL: https://wildthink.com/apps/jason
}

@hero {
![Jason](https://wildthink.com/apps/jason/Jason_AI.jpeg)
}

# **Jason**
@profile(aka: jason, tags: [pro, public])
@index(hints_column: swift)

@caption {
- iOS Application Architect
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
@id(pitch, ax: b c 889)
Here is where I say a little bit about myself.
Perhaps, what I like to do for fun.
Or anything else.

##### Pitch Deck

## Section 1
Section one stuff

### Section 1.1
Some subsection stuff.
Line two.

## Section 2

# Top Section


"""
/*
@comment{ links include linkedIn, github, instagram, etc }
@place(coordinates: []) {
Oakland, Maryland US
}
*/


//let profileDoc: Document = Document(parsing: """
//# Heading I
//## Heading II
//### Heading III
//#### Heading IV
//##### Heading V
//###### Heading VI
//
//@() {
//[email](mailto:box@example.com)
//[example.com](https://example.com)
//}
//
//![Image_x](https://wildthink.com/apps/Images/AppIcon.png)
//
//@comment{ links include linkedIn, github, instagram, etc }
//
//
//> Block Quote\n
//> line 2\n
//> line 3
//
//##### List
//1. one
//1. two
//- [ ] check
//- [x] checked
//- three
//
//One sentence here.
//
//```
//Some code
//line 2
//line 3
//```
//
//""",
//options: [.parseBlockDirectives]
//)

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

//
//  Profile.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import SwiftUI
@preconcurrency import Markdown


struct ProfileView: View {
    var doc: Document = profileDoc
    @State var mdp = Markdownosaur()
    let img = Image(systemName: "message.badge.filled.fill")
    let ns_img = NSImage(systemSymbolName: "message.badge.filled.fill", accessibilityDescription: nil)!

    var body: some View {
        ScrollView {
            VStack {
                runs()
//                Text(mdp.attributedString(from: doc))
//                Divider()
//                Image(nsImage: ns_img)
//                img
                Divider()
                Text(doc.debugDescription())
            }
        }
        .environment(\.openURL, OpenURLAction(handler: { url in
            print("Tap on URL: \(url)")
            return .discarded
          }))
    }
    
    func runs() -> SwiftUI.Text {
        let str = mdp.attributedString(from: doc)
        var t = SwiftUI.Text("")
        
        print("Run count", str.runs.count)
        
        for run in str.runs {
            if let link = run.link {
                print("link", link)
            }
            if let img = run.imageURL {
                print("img", img)
                let t2 = SwiftUI.Text("Hello, \(Image(systemName: "pencil")) World! \(Image(systemName: "pencil.circle"))")
                let t3 = SwiftUI.Text("\(self.img)")
                t = t + t3 + t2
            }
            let slice = str[run.range]
            t = t + SwiftUI.Text(AttributedString(slice))
        }
        
        return t
    }
}

//func foo() -> AttributedString {
//    let img = NSImage(systemSymbolName: "message.badge.filled.fill", accessibilityDescription: nil)!
//    let attachment = NSTextAttachment(data: nil, ofType: "")
//    attachment.image = img
//    return AttributedString(NSAttributedString(attachment: attachment))
//}

#if os(macOS)
import Cocoa

extension NSImage {
    public func attributedString() -> NSAttributedString {
        let attachment = ImageAttachment()
        attachment.image = self
        return .init(attachment: attachment)
    }
}

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

#elseif os(iOS)

//import UIKit
//
//extension UIImage: AttributedStringConvertible {
//    public func attributedString(environment: Environment) -> [NSAttributedString] {
//        let attachment = NSTextAttachment()
//        attachment.image = self
//        return [
//            .init(attachment: attachment)
//        ]
//    }
//}

#endif

#Preview {
    ProfileView()
        .padding()
}
let jason: Document = Document(parsing: """
# Jasn Jobe
![Jason](https://wildthink.com/apps/jason/avatar.png)

Tinker, Maker, Smith

@comment{ links include linkedIn, github, instagram, etc }
@place() {
Oakland, Maryland US
}

@links {
    [Gravatar](https://jasonjobe.link)
    [](https://www.linkedin.com/in/jason-jobe-bb0b991/)
    [](https://medium.com/@jasonjobe)
    [](https://github.com/wildthink)
    [](https://www.instagram.com/jmj_02021/)
}

""")

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

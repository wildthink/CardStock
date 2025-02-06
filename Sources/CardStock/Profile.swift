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

    var body: some View {
        ScrollView {
            VStack {
                Text(mdp.attributedString(from: doc))
                Divider()
                img
                Divider()
                Text(doc.debugDescription())
            }
        }
        .environment(\.openURL, OpenURLAction(handler: { url in
            print("Tap on URL: \(url)")
            return .discarded
          }))
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
        let attachment = NSTextAttachment()
        attachment.image = self
        return .init(attachment: attachment)
    }
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

let profileDoc: Document = Document(parsing: """
# Heading I
## Heading II
### Heading III
#### Heading IV
##### Heading V
###### Heading VI

^[email](mailto:box@example.com)

[example.com](https://example.com)

![Image_x](https://wildthink.com/apps/Images/AppIcon.png)

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

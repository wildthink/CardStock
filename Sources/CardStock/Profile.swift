//
//  Profile.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import SwiftUI
@preconcurrency import Markdown

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
    var doc: Document = jason
    @State var mdp = Markdownosaur()
    let img = Image(systemName: "message.badge.filled.fill")
    let ns_img = NSImage(systemSymbolName: "message.badge.filled.fill", accessibilityDescription: nil)!
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(parts, id: \.offset) {
                    view($0.element)
                }
            }
            Divider()
            ScrollView {
                Text(doc.debugDescription())
            }
            //            }
        }
        .environment(\.openURL, OpenURLAction(handler: { url in
            print("Tap on URL: \(url)")
            return .discarded
        }))
    }
    
    @ViewBuilder
    func view(_ attr: AttributedString) -> some View {
        if attr.link != nil {
            Text(attr)
        } else if let value = attr.imageURL {
//            Text("Image: \(value)")
            AsyncImage(url: value)
        } else {
            Text(attr)
        }
    }
    
    var parts: [(offset: Int, element: AttributedString)] {
        let it = Array(partition().enumerated())
        print("count:", it.count)
        return it
    }

    func partition() -> [AttributedString] {
        let str = mdp.attributedString(from: doc)
        var result: [AttributedString] = []
        var currentRange: Range<AttributedString.Index>? = nil

        for run in str.runs {
            if let scope = run.scope {
                print("Scope: \(scope)")
            }
            if let link = run.link {
                // Add the current accumulated text range to the result before handling the link
                if let range = currentRange {
                    result.append(AttributedString(str[range]))
                    currentRange = nil
                }

//                print("link", link)
                result.append(str[run.range])
            } else if let img = run.imageURL {
                // Add the current accumulated text range to the result before handling the image
                if let range = currentRange {
                    result.append(AttributedString(str[range]))
                    currentRange = nil
                }
                
                //                print("img", img)
                result.append(str[run.range])
                // You could optionally add an image representation here if needed
//            } else if let scope = run.scope {
//                print("Scope: \(scope)")
//
            } else {
                if let sp = run.textBreak {
                    print("Text break: \(sp)")
                }
                
                // Accumulate ranges of consecutive text runs
                if let existingRange = currentRange {
                    currentRange = existingRange.lowerBound..<run.range.upperBound
                } else {
                    currentRange = run.range
                }
            }
        }

        // Add any remaining accumulated text to the result
        if let range = currentRange {
            result.append(AttributedString(str[range]))
        }

        return result
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
#endif

#Preview {
    ProfileView()
        .frame(height: 500)
        .padding()
}

let jason: Document = Document(parsing: """
@meta {
    baseURL: https://wildthink.com/apps/jason
}

# Jason Jobe
![Jason](avatar.png)

@Caption {
- Professional iOS Application Architect
- Amateur Social Scientist
- Tinker, Maker, Smith
}

@links {
- [Gravatar](https://jasonjobe.link)
- [](https://www.linkedin.com/in/jason-jobe-bb0b991/)
- [](https://medium.com/@jasonjobe)
- [](https://github.com/wildthink)
- [](https://www.instagram.com/jmj_02021/)
}

Here is where I say a little bit about myself.
Perhaps, what I like to do for fun.
Or anything else.

@comment{ links include linkedIn, github, instagram, etc }
@place(coordinates: []) {
Oakland, Maryland US
}


"""
,options: [.parseBlockDirectives]
)

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

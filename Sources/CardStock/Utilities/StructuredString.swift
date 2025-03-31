//
//  StructuredString.swift
//  CardStock
//
//  Created by Jason Jobe on 3/31/25.
//

import Foundation
import Markdown

typealias PresentationIntentAttribute = AttributeScopes.FoundationAttributes.PresentationIntentAttribute

extension AttributedString {
    mutating func append(_ string: String) {
        self.append(AttributedString(string))
    }
    
    init(_ string: String, intent: InlinePresentationIntent) {
        self = AttributedString(string)
        self.inlinePresentationIntent = intent
    }
    
    var presentationKind: PresentationIntent.Kind? {
        get { nil }
        set {
            guard let newValue else { return }
            self.presentationIntent = .init(newValue, identity: 1)
        }
    }
    init(_ string: String, intent: PresentationIntent.Kind) {
        self = AttributedString(string)
        self.presentationKind = intent
    }
}

public struct StructuredString: MarkupVisitor {
    let baseFontSize: CGFloat = 15.0
    
    public init() {}
    
    public mutating func attributedString(from document: Document) -> AttributedString {
        return visit(document)
    }
    
    mutating public func defaultVisit(_ markup: Markup) -> AttributedString {
        var result = AttributedString()
        
        for child in markup.children {
            result.append(visit(child))
        }
        
        return result
    }
    
    mutating public func visitText(_ text: Text) -> AttributedString {
        AttributedString(text.plainText)
    }
    
    mutating public func visitSoftBreak(_ softBreak: SoftBreak) -> AttributedString {
        AttributedString(softBreak.plainText, intent: .softBreak)
    }
    
    mutating public func visitLineBreak(_ lineBreak: LineBreak) -> AttributedString {
        AttributedString(lineBreak.plainText, intent: .lineBreak)
    }
    
    mutating public func visitThematicBreak(_ lineBreak: ThematicBreak) -> AttributedString {
        AttributedString("---", intent: .thematicBreak)
    }

    mutating public func visitImage(_ image: Image) -> AttributedString {
        var result = AttributedString()
        
        for child in image.children {
            result.append(visit(child))
        }
        result.link = image.source != nil ? URL(string: image.source!) : nil
        
        return result
    }
    
    mutating public func visitEmphasis(_ emphasis: Emphasis) -> AttributedString {
        var result = AttributedString()
        
        for child in emphasis.children {
            result.append(visit(child))
        }
        result.inlinePresentationIntent = .emphasized
        
        return result
    }
    
    mutating public func visitStrong(_ strong: Strong) -> AttributedString {
        var result = AttributedString()
        
        for child in strong.children {
            result.append(visit(child))
        }
        
        result.inlinePresentationIntent = .stronglyEmphasized

        return result
    }
    
    mutating public func visitParagraph(_ paragraph: Paragraph) -> AttributedString {
        var result = AttributedString()
        
        for child in paragraph.children {
            result.append(visit(child))
        }
        result.presentationIntent = .init(.paragraph, identity: 1)
        return result
    }
    
    mutating public func visitHeading(_ heading: Heading) -> AttributedString {
        var result = AttributedString()
        
        for child in heading.children {
            result.append(visit(child))
        }
        result.presentationKind = .header(level: heading.level)
        return result
    }
    
    mutating public func visitLink(_ link: Link) -> AttributedString {
        var result = AttributedString()
        
        for child in link.children {
            result.append(visit(child))
        }
        result.link = link.destination != nil ? URL(string: link.destination!) : nil

        return result
    }
    
    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> AttributedString {
        AttributedString(inlineCode.code, intent: .code)
    }
    
    public func visitCodeBlock(_ codeBlock: CodeBlock) -> AttributedString {
        AttributedString(codeBlock.code, intent: .codeBlock(languageHint: codeBlock.language))
    }
    
    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> AttributedString {
        var result = AttributedString()
        
        for child in strikethrough.children {
            result.append(visit(child))
        }
        result.inlinePresentationIntent = .strikethrough
        return result
    }
    
    mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> AttributedString {
        var result = AttributedString()
                
        for listItem in unorderedList.listItems {
            result.append(visit(listItem))
        }
        result.presentationKind = .unorderedList
        return result
    }
    
    mutating public func visitListItem(_ listItem: ListItem) -> AttributedString {
        var result = AttributedString()
        
        for child in listItem.children {
            result.append(visit(child))
        }
        result.presentationKind = .listItem(ordinal: listItem.indexInParent)
        return result
    }
    
    mutating public func visitOrderedList(_ orderedList: OrderedList) -> AttributedString {
        var result = AttributedString()
        
        for item in orderedList.listItems {
            result.append(visit(item))
        }
        return result
    }
    
    mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> AttributedString {
        var result = AttributedString()
        
        for child in blockQuote.children {
             result.append(visit(child))
        }
        result.presentationKind = .blockQuote
        return result
    }
}

// MARK: - Extensions Land


extension ListItemContainer {
    /// Depth of the list if nested within others. Index starts at 0.
    var listDepth: Int {
        var index = 0
        
        var currentElement = parent
        
        while currentElement != nil {
            if currentElement is ListItemContainer {
                index += 1
            }
            
            currentElement = currentElement?.parent
        }
        
        return index
    }
}

extension BlockQuote {
    /// Depth of the quote if nested within others. Index starts at 0.
    var quoteDepth: Int {
        var index = 0
        
        var currentElement = parent
        
        while currentElement != nil {
            if currentElement is BlockQuote {
                index += 1
            }
            
            currentElement = currentElement?.parent
        }
        
        return index
    }
}

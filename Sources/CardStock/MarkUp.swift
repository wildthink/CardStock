//
//  Markdown.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//
/*
 https://fatbobman.com/en/posts/attributedstring/
 */
import Foundation
import SwiftUI
import Markdown

struct StringDesign: Sendable {

    var plain: AttributeContainer = AttributeContainer()

    func attributes(for node: InlineAttributes) -> AttributeContainer {
        // FIXME: Check for URL's vs other parameters (eg style)
        var container = AttributeContainer()
//        container.merge(self.container) stack??
        container.foregroundColor = .red
        if !node.attributes.isEmpty {
            let url = URL(string: node.attributes)
//            print(node.attributes, "=>", url)
            container.link = url
        }
        return container
    }
    
    func attributes(forHeading heading: Heading) -> AttributeContainer {
        var container = AttributeContainer()
//        container.merge(self.container) stack??
        container.font = .systemFont(ofSize: fontSize(forHeading: heading.level))
        return container
    }

    func fontSize(forHeading level: Int) -> CGFloat {
        switch level {
        case 1: return 34  // H1
        case 2: return 28  // H2
        case 3: return 22  // H3
        case 4: return 20  // H4
        case 5: return 18  // H5
        case 6: return 16  // H6
        default: return 14 // Default size for body text or unsupported levels
        }
    }
    
    enum Style { case emphasis, strong }
    
    func apply(_ style: Style, to txt: inout RichText) -> RichText {
        switch style {
        case .emphasis:
            txt.underlineStyle = .single
        case .strong:
            txt.underlineStyle = .double
        }
        return txt
    }
}

#if os(macOS)
//@preconcurrency import Cocoa
//public typealias XColor = NSColor
//public typealias XFont = NSFont

#elseif os(iOS)
import UIKit
public typealias XColor = UIColor
public typealias XFont = UIFont

public extension XColor {
    static var textColor: XColor { UIColor.darkText }
    static var gray: XColor { UIColor.systemGray }
}

typealias NSFontDescriptor = UIFontDescriptor
extension NSFontDescriptor.SymbolicTraits {
    static let bold: NSFontDescriptor.SymbolicTraits = .traitBold
    static let italic: NSFontDescriptor.SymbolicTraits = .traitItalic
}
#endif

typealias XFontDescriptor = NSFontDescriptor
public typealias RichText = AttributedString

public struct Markdownosaur: MarkupVisitor {
    let baseFontSize: CGFloat = 15.0
    let design = StringDesign()
    
    public init() {}
    
    public mutating func attributedString(from document: Document) -> RichText {
        return visit(document)
    }
    
    mutating public func defaultVisit(_ markup: Markup) -> RichText {
        richText(for: markup.children)
//        var result = RichText()
//        
//        for child in markup.children {
//            result.append(visit(child))
//        }
//        
//        return result
    }
    
    mutating public
    func richText(for children: MarkupChildren) -> RichText {
        var result = RichText()
        
        for child in children {
            result.append(visit(child))
        }
        return result
    }
    
    mutating public func visitText(_ text: Markdown.Text) -> RichText {
        var txt = RichText(text.plainText)
        txt.setAttributes(design.plain)
        return txt
    }
    
    mutating public func visitEmphasis(_ emphasis: Emphasis) -> RichText {
        var txt = richText(for: emphasis.children)
        return design.apply(.emphasis, to: &txt)
    }
    
    mutating public func visitStrong(_ strong: Strong) -> RichText {
        var txt = richText(for: strong.children)
        return design.apply(.strong, to: &txt)
    }
    
    mutating public func visitParagraph(_ paragraph: Paragraph) -> RichText {
        var result = richText(for: paragraph.children)
        
        if paragraph.hasSuccessor {
            result += (paragraph.isContainedInList ? "\n" : "\n\n")
        }
        
        return result
    }
    
    public func visitSoftBreak(_ softBreak: SoftBreak) -> RichText {
        // FIXME: Check active Directive for soft-break value
        RichText()
    }
    
    mutating public func visitHeading(_ heading: Heading) -> RichText {
        var result = richText(for: heading.children)
        result.mergeAttributes(design.attributes(forHeading: heading))
        
        if heading.hasSuccessor {
            result += "\n"
        }
        
        return result
    }
    
    mutating public
    func visitInlineAttributes(_ attributes: InlineAttributes) -> AttributedString {
        var result = richText(for: attributes.children)
        result.mergeAttributes(design.attributes(for: attributes))
        return result
    }
    
    mutating public func visitLink(_ link: Markdown.Link) -> RichText {
        var result = richText(for: link.children)

        let url = link.destination != nil ? URL(string: link.destination!) : nil
        
        result.link = url
        result.foregroundColor = .purple
//        result.applyLink(withURL: url)
        
        return result
    }
    
    public mutating func visitImage(_ image: Markdown.Image) -> RichText {
        let title = switch image.title {
            case .some(let string) where !string.isEmpty:
                string
            default:
                image.plainText.isEmpty ? "<image placeholder>" : image.plainText
        }
        var result = RichText(title)
        if let src = image.source, let url = URL(string: src) {
            result.imageURL = url
        }
        return result
    }

    public mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> RichText {
        RichText(inlineHTML.rawHTML)
    }

//    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> RichText {
//        return RichText(string: inlineCode.code, attributes: [.font: XFont.monospacedSystemFont(ofSize: baseFontSize - 1.0, weight: .regular), .foregroundColor: XColor.systemGray])
//    }
    
//    public func visitCodeBlock(_ codeBlock: CodeBlock) -> RichText {
//        let result = NSMutableAttributedString(string: codeBlock.code, attributes: [.font: XFont.monospacedSystemFont(ofSize: baseFontSize - 1.0, weight: .regular), .foregroundColor: XColor.systemGray])
//        
//        if codeBlock.hasSuccessor {
//            result.append(.singleNewline(withFontSize: baseFontSize))
//        }
//    
//        return result
//    }
    
    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> RichText {
        var result = richText(for: strikethrough.children)
        result.strikethroughStyle = .single
        return result
    }
    
//    mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> RichText {
//        var result = RichText()
//        
//        let font = XFont.systemFont(ofSize: baseFontSize, weight: .regular)
//                
//        for listItem in unorderedList.listItems {
//            var listItemAttributes: [RichText.Key: Any] = [:]
//            
//            let listItemParagraphStyle = NSMutableParagraphStyle()
//            
//            let baseLeftMargin: CGFloat = 15.0
//            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(unorderedList.listDepth))
//            let spacingFromIndex: CGFloat = 8.0
//            let bulletWidth = ceil(RichText(string: "•", attributes: [.font: font]).size().width)
//            let firstTabLocation = leftMarginOffset + bulletWidth
//            let secondTabLocation = firstTabLocation + spacingFromIndex
//            
//            listItemParagraphStyle.tabStops = [
//                NSTextTab(textAlignment: .right, location: firstTabLocation),
//                NSTextTab(textAlignment: .left, location: secondTabLocation)
//            ]
//            
//            listItemParagraphStyle.headIndent = secondTabLocation
//            
//            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
//            listItemAttributes[.font] = XFont.systemFont(ofSize: baseFontSize, weight: .regular)
//            listItemAttributes[.listDepth] = unorderedList.listDepth
//            
//            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
//            listItemAttributedString.insert(RichText(string: "\t• ", attributes: listItemAttributes), at: 0)
//            
//            result.append(listItemAttributedString)
//        }
//        
//        if unorderedList.hasSuccessor {
//            result.append(.doubleNewline(withFontSize: baseFontSize))
//        }
//        
//        return result
//    }
    
//    mutating public func visitListItem(_ listItem: ListItem) -> RichText {
//        var result = RichText()
//        
//        for child in listItem.children {
//            result.append(visit(child))
//        }
//        
//        if listItem.hasSuccessor {
//            result.append(.singleNewline(withFontSize: baseFontSize))
//        }
//        
//        return result
//    }
    
//    mutating public func visitOrderedList(_ orderedList: OrderedList) -> RichText {
//        var result = RichText()
//        
//        for (index, listItem) in orderedList.listItems.enumerated() {
//            var listItemAttributes: [RichText.Key: Any] = [:]
//            
//            let font = XFont.systemFont(ofSize: baseFontSize, weight: .regular)
//            let numeralFont = XFont.monospacedDigitSystemFont(ofSize: baseFontSize, weight: .regular)
//            
//            let listItemParagraphStyle = NSMutableParagraphStyle()
//            
//            // Implement a base amount to be spaced from the left side at all times to better visually differentiate it as a list
//            let baseLeftMargin: CGFloat = 15.0
//            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(orderedList.listDepth))
//            
//            // Grab the highest number to be displayed and measure its width (yes normally some digits are wider than others but since we're using the numeral mono font all will be the same width in this case)
//            let highestNumberInList = orderedList.childCount
//            let numeralColumnWidth = ceil(RichText(string: "\(highestNumberInList).", attributes: [.font: numeralFont]).size().width)
//            
//            let spacingFromIndex: CGFloat = 8.0
//            let firstTabLocation = leftMarginOffset + numeralColumnWidth
//            let secondTabLocation = firstTabLocation + spacingFromIndex
//            
//            listItemParagraphStyle.tabStops = [
//                NSTextTab(textAlignment: .right, location: firstTabLocation),
//                NSTextTab(textAlignment: .left, location: secondTabLocation)
//            ]
//            
//            listItemParagraphStyle.headIndent = secondTabLocation
//            
//            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
//            listItemAttributes[.font] = font
//            listItemAttributes[.listDepth] = orderedList.listDepth
//
//            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
//            
//            // Same as the normal list attributes, but for prettiness in formatting we want to use the cool monospaced numeral font
//            var numberAttributes = listItemAttributes
//            numberAttributes[.font] = numeralFont
//            
//            let numberAttributedString = RichText(string: "\t\(index + 1).\t", attributes: numberAttributes)
//            listItemAttributedString.insert(numberAttributedString, at: 0)
//            
//            result.append(listItemAttributedString)
//        }
//        
//        if orderedList.hasSuccessor {
//            result.append(orderedList.isContainedInList ? .singleNewline(withFontSize: baseFontSize) : .doubleNewline(withFontSize: baseFontSize))
//        }
//        
//        return result
//    }
    
//    mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> RichText {
//        var result = RichText()
//        
//        for child in blockQuote.children {
//            var quoteAttributes: [RichText.Key: Any] = [:]
//            
//            let quoteParagraphStyle = NSMutableParagraphStyle()
//            
//            let baseLeftMargin: CGFloat = 15.0
//            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(blockQuote.quoteDepth))
//            
//            quoteParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: leftMarginOffset)]
//            
//            quoteParagraphStyle.headIndent = leftMarginOffset
//            
//            quoteAttributes[.paragraphStyle] = quoteParagraphStyle
//            quoteAttributes[.font] = XFont.systemFont(ofSize: baseFontSize, weight: .regular)
//            quoteAttributes[.listDepth] = blockQuote.quoteDepth
//            
//            let quoteAttributedString = visit(child).mutableCopy() as! NSMutableAttributedString
//            quoteAttributedString.insert(RichText(string: "\t", attributes: quoteAttributes), at: 0)
//            
//            quoteAttributedString.addAttribute(.foregroundColor, value: XColor.systemGray)
//            
//            result.append(quoteAttributedString)
//        }
//        
//        if blockQuote.hasSuccessor {
//            result.append(.doubleNewline(withFontSize: baseFontSize))
//        }
//        
//        return result
//    }
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

//extension RichText.Key {
//    static let listDepth = RichText.Key("ListDepth")
//    static let quoteDepth = RichText.Key("QuoteDepth")
//}
//
//extension NSMutableAttributedString {
//    func addAttribute(_ name: RichText.Key, value: Any) {
//        addAttribute(name, value: value, range: NSRange(location: 0, length: length))
//    }
//    
//    func addAttributes(_ attrs: [RichText.Key : Any]) {
//        addAttributes(attrs, range: NSRange(location: 0, length: length))
//    }
//}

extension Markup {
    /// Returns true if this element has sibling elements after it.
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
    
    var isContainedInList: Bool {
        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                return true
            }

            currentElement = currentElement?.parent
        }
        
        return false
    }
}

//extension RichText {
//    static func singleNewline(withFontSize fontSize: CGFloat) -> RichText {
//        RichText("\n")
////        return RichText(string: "\n", attributes: [.font: XFont.systemFont(ofSize: fontSize, weight: .regular)])
//    }
//    
//    static func doubleNewline(withFontSize fontSize: CGFloat) -> RichText {
//        RichText("\n\n")
////        return RichText(string: "\n", attributes: [.font: XFont.systemFont(ofSize: fontSize, weight: .regular)])
//    }
//}

public extension String {
    /// Native Support for styling Markdown is limited. This is just a stub to
    /// hook into later.
    func markdown() -> AttributedString {
        (try? AttributedString(markdown: self)) ?? AttributedString(self)
    }
}

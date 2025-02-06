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

    var typography: Typography = Typography()
    
    var plain: AttributeContainer = AttributeContainer()

    var thematicBreak: AttributedString = {
        var str = AttributedString("\n\u{00A0} \u{0009} \u{00A0}\n")
        str.underlineStyle = .double
        str.underlineColor = .gray
        str.foregroundColor = .gray
        return str
    }()

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
    
    // https://github.com/NateBaldwinDesign/proportio/
    enum FontScale: CGFloat {
        case minorSecond = 1.067
        case majorSecond = 1.125
        case minorThird = 1.2
        case majorThird = 1.25
        case perfectFourth = 1.333
        case minorFifth = 1.5
        case majorFifth = 1.667
        case minorSixth = 1.8
        case majorSixth = 2
    }
    
    var typographyScale: FontScale = .perfectFourth
    var typographyBase: CGFloat = 12
    var typographyMaxLevel: Int = 6
    
    var baseCornerRadius: CGFloat = 4
    var radiusScale: CGFloat = 2
    
    func cornerRadius(level: CGFloat) -> CGFloat {
        baseCornerRadius * pow(radiusScale, level)
    }
    
    func elevation(level: CGFloat) -> CGFloat {
        baseCornerRadius * pow(radiusScale, level)
    }

    func padding(level: Int, base: CGFloat? = nil) -> CGPoint {
        let pt = round(fontScale(level: level, base: base)/1.333)
        return CGPoint(x: pt, y: pt)
    }
    
    func calculateScale(baseSize: CGFloat, scale: CGFloat, increment: CGFloat, scaleMethod: String) -> CGFloat {
        if (scaleMethod == "power") {
            baseSize * pow(scale, increment)
        } else if (scaleMethod == "linear") {
            baseSize + scale * increment
        } else { scale * baseSize }
    }
    
    func typeIconSpace(level: Int, base: CGFloat? = nil) -> CGFloat {
        round(fontScale(level: level, base: base)/3.0)
    }
    
    func fontScale(level: Int, base: CGFloat? = nil) -> CGFloat {
        let scale = typographyScale
        let base = base ?? typographyBase
        return if level < 1 {
            round(base * pow(1.0/scale.rawValue, CGFloat(-level)))
        } else {
            round(base * pow(scale.rawValue, CGFloat(level)))
        }
    }

    func fontSize(forHeading level: Int, base: CGFloat? = nil) -> CGFloat {
        return if level > 0 {
            fontScale(level: typographyMaxLevel-level, base: base)
        } else {
            fontScale(level: level, base: base)
        }
    }
    
    enum Style { case emphasis, strong, code }
    var baseFontSize: CGFloat = 14
    
    func attributed(code: String, language: String? = nil) -> AttributedString {
        var txt = RichText(code)
        return if language != nil {
            // TODO: Real Code Styling
            apply(.code, to: &txt)
        } else {
            txt
        }
    }

    func attributedString(for code: String, style: Style) -> AttributedString {
        var txt = RichText(code)
        return apply(style, to: &txt)
    }
    
    func apply(_ style: Style, to txt: inout RichText) -> RichText {
        switch style {
        case .emphasis:
            txt.underlineStyle = .single
        case .strong:
            txt.underlineStyle = .double
        case .code:
            txt.foregroundColor = .systemGray
            txt.font = .monospacedSystemFont(ofSize: baseFontSize, weight: .regular)
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
    
    var paragraphTrailingLines: String {
        "\n\n"
    }

    mutating public func visitParagraph(_ paragraph: Paragraph) -> RichText {
        var result = richText(for: paragraph.children)
        
        if paragraph.hasSuccessor {
            result += (paragraph.isContainedInList ? "\n" :  "\n\n")
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

    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> RichText {
        design.attributedString(for: inlineCode.code, style: .code)
    }
    
    public func visitCodeBlock(_ codeBlock: CodeBlock) -> RichText {
        var result = design.attributed(code: codeBlock.code, language: codeBlock.language)

        if codeBlock.hasSuccessor {
            result += "\n"
        }
    
        return result
    }
    
    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> RichText {
        var result = richText(for: strikethrough.children)
        result.strikethroughStyle = .single
        return result
    }
    
    mutating public
    func visitOrderedList(_ orderedList: OrderedList) -> RichText {
        visit(list: orderedList)
    }

    mutating public
    func visitUnorderedList(_ unorderedList: UnorderedList) -> RichText {
        visit(list: unorderedList)
    }

    mutating private func visit(list: ListItemContainer) -> RichText {

        let isOrdered = list is OrderedList
        var result: RichText = ""
        
        for (item, number) in zip(list.listItems, 1...) {

            let prefix: String = switch item.checkbox {
                case .checked: "[x]"
                case .unchecked: "[  ]"
                case _ where isOrdered:
                    "\(number)."
                default:
                "•"  // TODO: design.bullet
            }
            result.append(AttributedString("\t\(prefix) "))
            result.append(visit(item))
        }
        result += "\n"
        return result
    }
    
    func paragraphStyle(for list: ListItemContainer) -> AttributeContainer {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.headIndent = 0
//        return style
    
        style.tabStops[0] = NSTextTab(textAlignment: .right, location: style.tabStops[0].location)
        style.tabStops[1] = NSTextTab(textAlignment: .left, location: style.tabStops[0].location + 10)
        style.headIndent += style.tabStops[1].location
        style.paragraphSpacing = 0 // Remove spacing between list items

        var textstyle = AttributeContainer()
        textstyle.paragraphStyle = style
        return textstyle
    }

    mutating public
    func visitListItem(_ listItem: ListItem) -> RichText {
//        stylesheet.listItem(attributes: &attributes, checkbox: listItem.checkbox?.bool)

//        richText(for: listItem.children)
        var first = true
        var result = RichText()
        
        for child in listItem.children {
            result.append(visit(child))
            if first {
                result += "\n"
                first = false
            }
        }
        return result
    }

    mutating public
    func visitBlockQuote(_ blockQuote: BlockQuote) -> RichText {
        richText(for: blockQuote.children)
        //        stylesheet.blockQuote(attributes: &attributes)
    }

    mutating public
    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> RichText {
        return design.thematicBreak
    }
    

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

public extension String {
    /// Native Support for styling Markdown is limited. This is just a stub to
    /// hook into later.
    func markdown() -> AttributedString {
        (try? AttributedString(markdown: self)) ?? AttributedString(self)
    }
}

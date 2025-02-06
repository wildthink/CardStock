//
//  TagAttribute.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import SwiftUI

/*
 https://fatbobman.com/en/posts/mixing_text_and_graphics_with_text_in_swiftui/
 https://fatbobman.com/en/posts/creating-stunning-dynamic-text-effects-with-textrender/
 
 //        let img = Image(systemName: "message.badge.filled.fill")
 //              .renderingMode(.original)
 //        result.imageURL = URL(string: "https://wildthink.com/apps/Images/AppIcon.png")
         let img = NSImage(systemSymbolName: "hand.wave", accessibilityDescription: nil)!
         let attachment = NSTextAttachment(data: nil, ofType: "")
         attachment.image = img
         result.attachment = attachment
 //        result.adaptiveImageGlyph = img
         //        if let source = image.source, !source.isEmpty {
         //            result += " src=\"\(source)\""
         //        }
 */

struct TagAttribute: TextAttribute {}

struct TagEffect: TextRenderer {
    
  let tagBackgroundColor: Color

    func sizeThatFits(proposal: ProposedViewSize, text: TextProxy) -> CGSize {
//        let (h, w) = (proposal.height, proposal.width)
        var size = text.sizeThatFits(proposal)
        size.width += 0
        return size
    }
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
    for run in layout.flattenedRuns {
      if run[TagAttribute.self] != nil {
        let rect = run.typographicBounds.rect
        let copy = context
        // Draw the tag's background
          var box = rect // rect.insetBy(dx: -20, dy: -20)
//          box.size.width = 50
//          box.size.height = 50
        let shape = RoundedRectangle(cornerRadius: 5).path(in: box)
        copy.fill(shape, with: .color(tagBackgroundColor))
      }
      context.draw(run)
    }
  }
}

extension Text.Layout {
  var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
    flatMap { line in
      line
    }
  }
}

struct TagEffectDemo: View {
  let tagCount: Int
  let tag: LocalizedStringResource
  let title: LocalizedStringResource
  let fontSize: CGFloat
  let tagBackgroundColor: Color
  let tagFontColor: Color
  var body: some View {
    let tagPlaceholderText = Text(" \(tag) ")
      .monospaced()
      .font(.system(size: fontSize, weight: .heavy))
      .foregroundStyle(tagFontColor)
      .customAttribute(TagAttribute())

    Text("\(tagPlaceholderText) \(title)")
      .font(.system(size: fontSize))
      .textRenderer(
        TagEffect(
          tagBackgroundColor: tagBackgroundColor
        )
      )
  }
}

#Preview {
  TagEffectDemo(
    tagCount: 6,
    tag: .init("JOIN"),
    title: .init("Get weekly handpicked updates on Swift and SwiftUI!"),
    fontSize: 16,
    tagBackgroundColor: .red,
    tagFontColor: .white
  )
  .frame(width: 160)
  .padding()
}


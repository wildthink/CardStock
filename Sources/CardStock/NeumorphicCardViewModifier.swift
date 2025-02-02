//
//  NeumorphicCardViewModifier.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//

// https://www.justinmind.com/ui-design/neumorphism

import SwiftUI

public struct NeumorphicCardViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    public var cornerRadius: CGFloat = 15
    public var depth: CGFloat = 5
    
    public init(cornerRadius: CGFloat, depth: CGFloat) {
        self.cornerRadius = cornerRadius
        self.depth = depth
    }

    public func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .shadow(color: shadowColor, radius: depth, x: depth, y: depth)
                        .shadow(color: highlightColor, radius: depth, x: -depth, y: -depth)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .shadow(color: shadowColor.opacity(0.3), radius: depth/2, x: depth/2, y: depth/2)
                        .shadow(color: highlightColor.opacity(0.3), radius: depth/2, x: -depth/2, y: -depth/2)
                }
            )
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.6) : Color.gray.opacity(0.5)
    }
    
    private var highlightColor: Color {
        colorScheme == .dark ? Color(white: 0.3) : Color.white
    }
}

public extension View {
    func neumorphicCardStyle(cornerRadius: CGFloat = 15, depth: CGFloat = 5) -> some View {
        self.modifier(NeumorphicCardViewModifier(cornerRadius: cornerRadius, depth: depth))
    }
}

// MARK:
public struct _NeumorphicCardViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    public var cornerRadius: CGFloat = 15
    public var depth: CGFloat = 5
    
    public init(cornerRadius: CGFloat, depth: CGFloat) {
        self.cornerRadius = cornerRadius
        self.depth = depth
    }

    public func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    let absDepth = abs(depth)
                    if depth > 0 {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(backgroundColor)
                            .shadow(
                                color: depth > 0 ? shadowColor : highlightColor,
                                radius: absDepth,
                                x: absDepth,
                                y: absDepth
                            )
                            .shadow(
                                color: depth > 0 ? highlightColor : shadowColor,
                                radius: absDepth,
                                x: -absDepth,
                                y: -absDepth
                            )
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(backgroundColor)
                            .shadow(
                                color: (depth > 0 ? shadowColor : highlightColor).opacity(0.3),
                                radius: absDepth / 2,
                                x: absDepth / 2,
                                y: absDepth / 2
                            )
                            .shadow(
                                color: (depth > 0 ? highlightColor : shadowColor).opacity(0.3),
                                radius: absDepth / 2,
                                x: -absDepth / 2,
                                y: -absDepth / 2
                            )
                    }
                }
            )
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.6) : Color.gray.opacity(0.5)
    }
    
    private var highlightColor: Color {
        colorScheme == .dark ? Color(white: 0.3) : Color.white
    }
}
// MARK: - Preview

#Preview("Manual") {
    @Previewable @State var depth: CGFloat = 4
    @Previewable @State var radius: CGFloat = 4
    VStack {
        Text("Custom Radius")
            .padding()
            .neumorphicCardStyle(cornerRadius: radius, depth: depth)
        Text("Custom Radius Card")
            .cardStyle(cornerRadius: radius, shadowRadius: 6)

        Text("Pushed Radius")
            .padding()
            .neumorphicCardStyle(cornerRadius: radius, depth: -depth)

        HStack {
            Text(radius, format: .number.precision(.significantDigits(2)))
            Text(depth, format: .number.precision(.significantDigits(2)))
        }
        Slider(value: $radius, in: 0...30.0)
        Slider(value: $depth, in: 0...50.0)
    }
    .padding()
    .background(Color(white: 0.9))
    .preferredColorScheme(.light)
}

struct NeumorphicCardViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Text("Neumorphic Card")
                .padding()
                .neumorphicCardStyle()
            
            Text("Custom Depth")
                .padding()
                .neumorphicCardStyle(depth: 10)
            
            Text("Custom Radius")
                .padding()
                .neumorphicCardStyle(cornerRadius: 5, depth: 5)
        }
        .padding(30)
        .background(Color(white: 0.9))
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
        
        VStack(spacing: 30) {
            Text("Dark Mode Card")
                .padding()
                .neumorphicCardStyle()
            
            Text("Custom Depth")
                .padding()
                .neumorphicCardStyle(depth: 10)
            
            Text("Custom Radius")
                .padding()
                .neumorphicCardStyle(cornerRadius: 25)
        }
        .padding(30)
        .background(Color(white: 0.2))
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}

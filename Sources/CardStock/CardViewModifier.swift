//
//  CardViewModifier.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//


import SwiftUI

public struct CardViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 4
    
    public init(cornerRadius: CGFloat, shadowRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    public func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : .white
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.2)
    }
}

public extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        self.modifier(CardViewModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// MARK: - Preview

struct CardViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Light Mode Card")
                .cardStyle()
            
            Text("Custom Radius Card")
                .cardStyle(cornerRadius: 20, shadowRadius: 6)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
        .padding()
        
        VStack(spacing: 20) {
            Text("Dark Mode Card")
                .cardStyle()
            
            Text("Custom Radius Card")
                .cardStyle(cornerRadius: 20, shadowRadius: 6)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}

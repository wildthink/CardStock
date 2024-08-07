//
//  CardGroupBoxStyle.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//
import SwiftUI

struct CardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
//        .background(Color.systemGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension GroupBoxStyle where Self == CardGroupBoxStyle {
    static var card: Self {
        CardGroupBoxStyle()
    }
}

struct BoxDisclosureStyle: DisclosureGroupStyle {
    let pad: CGFloat = 8
//    let buttonSize: CGFloat = 32
    
    func makeBody(configuration: Configuration) -> some View {
        let isExpanded = configuration.isExpanded

        VStack() {
            HStack(spacing: 4) {
                Image(systemName: (isExpanded ? "chevron.down" : "chevron.right"))
                    .font(.system(size: 12, weight: .medium))
                configuration.label
                Spacer()
            }
            .contentShape(.rect)
            .onTapGesture {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            }
            if configuration.isExpanded {
                Divider()
                configuration.content
                    .padding(.leading, pad)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: configuration.isExpanded)
    }
}

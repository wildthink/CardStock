//
//  SchoolOfThoughtLogo.swift
//  CardStock
//
//  Created by Jason Jobe on 4/1/25.
//

import SwiftUI

public struct SchoolOfThoughtLogo: View {
    @Environment(\.openURL) var openURL
    let url = URL(string: "https://therulesofcivilconversation.org")!
    let bgColor = Color(#colorLiteral(red: 0.200694561, green: 0, blue: 0.538043499, alpha: 1))
    let agreement: Agreement
    
    public init(agreement: Agreement = .iAgree) {
        self.agreement = agreement
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Please agree to the")
                .padding(.bottom, 4)
                .font(.system(size: 18, weight: .light, design: .default))
            Text("RULES OF CIVIL CONVERSTATION")
                .font(.system(size: 24, weight: .regular, design: .default))
            Divider()
                .padding(.vertical, 8)
                .frame(maxWidth: 240)
            Image("schoolOfThought_logo", bundle: .module)
        }
        .foregroundStyle(.white.opacity(0.9))
        .overlay(alignment: .topTrailing) {
            ZStack {
                Color.clear.frame(width: 24, height: 24)
                Image(systemName: "info.circle")
                    .foregroundStyle(.white.opacity(0.9))
            }
            .offset(x: 8, y: -4)
            .onTapGesture {
                openURL(url)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(bgColor, in: .rect(cornerRadius: 8))
    }
    
    public enum Agreement: String {
        case pleaseAgreeToTheRulesOfCivilConversation = "Please agree to the"
        case iAgree = "I agree to the"
        case weAgree = "We agree to the"
    }
}

#Preview {
    SchoolOfThoughtLogo()
            .scaleEffect(0.8)
        .padding()
}

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
    let bgColor = Color(#colorLiteral(red: 0.200694561, green: 0, blue: 0.538043499, alpha: 1)).opacity(0.85)
    let agreement: Agreement
    let scale: CGFloat
    let axis: Axis
    
    public init(
        axis: Axis = .vertical,
        scale: CGFloat = 1.0,
        agreement: Agreement = .pleaseAgree
    ) {
        self.agreement = agreement
        self.scale = scale
        self.axis = axis
    }
    
    public var body: some View {
        Group {
            if axis == .vertical {
                vbody
            } else {
                hbody
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(bgColor, in: .rect(cornerRadius: 8))
    }
    
    @ViewBuilder
    public var vbody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(agreement.rawValue)
                .padding(.bottom, 4)
                .font(.system(size: 18*scale, weight: .light, design: .default))
            Text("RULES OF CIVIL CONVERSTATION")
                .font(.system(size: 24*scale, weight: .regular, design: .default))
                .minimumScaleFactor(0.2)
            Divider()
                .padding(.vertical, 2)
//                .frame(maxWidth: 240)
            Image("schoolOfThought_logo", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 30)
//                .scaleEffect(scale, anchor: .topLeading)
//                .border(.red)
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
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
//        .background(bgColor, in: .rect(cornerRadius: 8))
    }
    
    @ViewBuilder
    public var hbody: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text(agreement.rawValue)
                    .padding(.bottom, 4)
                    .font(.system(size: 18*scale, weight: .light, design: .default))
                Text("RULES OF CIVIL CONVERSTATION")
                    .font(.system(size: 24*scale, weight: .regular, design: .default))
            }
            VStack(alignment: .trailing) {
                Image("schoolOfThought_logo", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: 12, y: 4)
            }
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
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
//        .background(bgColor, in: .rect(cornerRadius: 8))
    }
    
    public enum Agreement: String {
        case pleaseAgree = "Please agree to the"
        case iAgree = "I agree to the"
        case weAgree = "We agree to the"
        case iSupport = "I support the"
        case weSupport = "We support the"
    }
}

#Preview {
    Group {
        SchoolOfThoughtLogo()
        SchoolOfThoughtLogo(scale: 0.5)
        SchoolOfThoughtLogo(axis: .horizontal, scale: 0.5)
    }
    .frame(maxWidth: 300)
    .padding()
}

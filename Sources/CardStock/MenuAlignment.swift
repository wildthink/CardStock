//
//  MenuAlignment.swift
//  CardStock
//
//  Created by Jason Jobe on 2/2/25.
//
import SwiftUI

struct MenuAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        print("context", context)
        return context[VerticalAlignment.center]
    }
}

extension VerticalAlignment {
    static let menu = VerticalAlignment(MenuAlignment.self)
}

struct MenuLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .foregroundColor(.primary.opacity(0.1))
                }
//                .alignmentGuide(.menu, computeValue: {
//                    $0[.center]
//                })
        }
        .font(.footnote)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .menu) {
            Col()
            Col()
            Col()
            VStack {
                Color.red.frame(width: 30, height: 30)
                    .alignmentGuide(.menu, computeValue: {
                        print($0[.trailing])
                        return $0[VerticalAlignment.bottom]
                    })
                
                Color.yellow.frame(width: 30, height: 100)
            }
//            Color.red.frame(width: 30, height: 100)
//                .alignmentGuide(.menu, computeValue: {
//                    $0[VerticalAlignment.center] + 10
//                })
//            
//            Color.red.frame(width: 30, height: 100)
//            Color.red.frame(width: 30, height: 100)
        }
        .border(.green, width: 3)
        .frame(height: 300)
        .padding(20)
    }
}

struct Col: View {
    var body: some View {
        VStack {
            Color.red.frame(width: 30, height: 100)
                .alignmentGuide(.menu, computeValue: {
                    $0[VerticalAlignment.bottom]
                })
            
            Color.yellow.frame(width: 30, height: 100)
                .alignmentGuide(.menu, computeValue: {
                    $0[VerticalAlignment.top] - 10
                })
        }
    }
}

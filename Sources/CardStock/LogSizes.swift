//
//  ContentView.swift
//  LayoutMeasurement
//
//  Created by Chris Eidhof on 09.08.22.
//

import SwiftUI

public struct LayoutSizes {
    var label: String
    var proposed: ProposedViewSize = .unspecified
    var natural: CGSize = .zero
    var reported: CGSize = .zero
}

extension LayoutSizes: CustomStringConvertible {
    public var description: String {
        "Layout:\(label) [\(natural.pretty)]  \(proposed.pretty) -> \(reported.pretty)"
    }
}

public extension View {
    
    func onLayout(_ label: String) -> some View {
        LogSizes(label: label, reporter: { print($0) }) {
            self
        }
    }

    func onLayout(
        _ label: String,
        perform action: @escaping (LayoutSizes) -> Void
    ) -> some View {
        LogSizes(label: label, reporter: action) { self }
    }

}

extension CGFloat {
    var pretty: String {
        String(format: "%.0f", self)
    }
}

extension CGSize {
    var pretty: String {
        "\(width.pretty)⨉\(height.pretty)"
    }
}

extension Optional where Wrapped == CGFloat {
    var pretty: String {
        self?.pretty ?? "nil"
    }
}

extension ProposedViewSize {
    var pretty: String {
        "\(width.pretty)⨉\(height.pretty)"
    }
}

struct LogSizes: Layout {
    typealias Report = (LayoutSizes) -> Void
    var label: String
    var reporter: Report? = nil
    
//    func _report(_ sizes: LayoutSizes) {
//        if let reporter {
//            reporter(sizes)
//        } else {
//            print(sizes)
//        }
//    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 1)
        guard let reporter else {
            return subviews[0].sizeThatFits(proposal)
        }
        var report = LayoutSizes(label: label)
        report.proposed = proposal
        report.natural = subviews[0].sizeThatFits(.unspecified)
//        print("Propose \(label): \(proposal.pretty)")
        report.reported = subviews[0].sizeThatFits(proposal)
        
//        print("Report: \(report)")
        reporter(report)
        return report.reported
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews[0].place(at: bounds.origin, proposal: proposal)
    }
}

#Preview {
    @Previewable @State var proposedSize: CGSize = CGSize(width: 100, height: 100)
    
    VStack {
        Text("Hello, world!")
            .font(.title)
            .onLayout("Text")
            .padding(10)
            .onLayout("Padding")
            .background {
                Color.orange.opacity(0.6)
                    .frame(width: 200, height: 200)
                    .onLayout("Orange")
            }
            .onLayout("Background")
            .border(Color.red)
            .frame(width: proposedSize.width, height: proposedSize.height)
            .border(Color.green)
        Slider(value: $proposedSize.width, in: 0...300, label: { Text("Width")})
    }
    .frame(width: 300, height: 300)
}

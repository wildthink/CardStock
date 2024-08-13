import SwiftUI

public typealias EntityID = UUID

// MARK: - Preview

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NoteView(note: .constant(.preview))
            .cardStyle(cornerRadius: 12, shadowRadius: 6)
            .groupBoxStyle(.card)
            Spacer()
        }
        .environment(\.openURL, OpenURLAction { url in
            print(url) // Define this method to take appropriate action.
            return .handled
        })
        .frame(minHeight: 400)
        .padding(20)
    }
}

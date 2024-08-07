import SwiftUI


// MARK: - Note View

struct NoteView: View {
    @Binding var note: Note
    @State private var isEditing = false
    @State private var isShowingComments = false
    
    var body: some View {
        GroupBox(label: headerView) {
            VStack(alignment: .leading, spacing: 8) {
                tagStrip()
                bodyView
                accessoryView
            }
            Divider()
            footerView
        }
        .toolbar {
            toolbarView
        }
        .groupBoxStyle(.card)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(note.title)
                .font(.title)
                .fontWeight(.bold)
            
            if let subtitle = note.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    func tagStrip() -> some View {
        HStack {
            TagView(tag: note.domain)
                .background(Color.blue.opacity(0.1))
            
            Spacer()
            
            ForEach(note.tags, id: \.self) { tag in
                TagView(tag: tag)
                    .background(Color.green.opacity(0.1))
            }
        }
    }
    
    private var bodyView: some View {
        Text(note.body)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var accessoryView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !note.links.isEmpty {
                Text("Related Links:")
                    .font(.headline)
                ForEach(note.links, id: \.self) { link in
                    Link(link.absoluteString, destination: link)
                }
            }
            
            if let rating = note.rating {
                RatingView(rating: rating)
            }
        }
    }
    
    var footerView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Created: \(formattedDate(note.creationDate))")
                .font(.caption)
            Text("Last modified: \(formattedDate(note.lastModifiedDate))")
                .font(.caption)
            commentsView
        }
    }
    
    private var commentsView: some View {
        DisclosureGroup("Comments", isExpanded: $isShowingComments) {
            
            VStack(alignment: .leading, spacing: 5) {
                if !note.comments.isEmpty {
                    ForEach(note.comments) { comment in
                        CommentView(comment: comment)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disclosureGroupStyle(BoxDisclosureStyle())
        .symbolVariant(.circle)
    }
    
    private var toolbarView: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: { isEditing.toggle() }) {
                Image(systemName: isEditing ? "checkmark.circle" : "pencil")
            }
            Button(action: { /* Implement share functionality */ }) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(comment.author)
                .font(.caption)
                .fontWeight(.bold)
            Text(comment.content)
                .font(.caption)
            Text(formattedDate(comment.date))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(5)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TagView: View {
    var tag: String
    
    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(5)
            .cornerRadius(5)
    }
}

// MARK: - Preview

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NoteView(note: .constant(.preview))
            .cardStyle(cornerRadius: 20, shadowRadius: 6)
            .groupBoxStyle(.card)
        }
        .frame(width: 500)
        .padding(20)
    }
}

struct RatingView: View {
    var rating: Rating
    
    var body: some View {
        LabeledContent(rating.name) {
            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating.value ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

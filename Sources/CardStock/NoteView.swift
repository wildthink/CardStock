//
//  NoteView.swift
//  CardStock
//
//  Created by Jason Jobe on 8/8/24.
//
import SwiftUI


public struct NoteView: View {
    @State var isEditing: Bool
    @Binding var note: Note
    @State private var expandComents: Bool
    
    public init(note: Binding<Note>, expandComents: Bool = false) {
        self._isEditing = .init(initialValue: false)
        self._note = note
        self.expandComents = expandComents
    }
    
    public var body: some View {
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
        DisclosureGroup("Comments", isExpanded: $expandComents) {
            
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

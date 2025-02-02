//
//  CommentView.swift
//  CardStock
//
//  Created by Jason Jobe on 8/8/24.
//
import SwiftUI

public struct RatingView: View {
    let rating: Rating
    
    public init(rating: Rating) {
        self.rating = rating
    }
    
    public var body: some View {
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

public struct CommentView: View {
    let comment: Comment
    
    public init(comment: Comment) {
        self.comment = comment
    }
    
    public var body: some View {
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

public struct TagView: View {
    var tag: String
    
    public init(tag: String) {
        self.tag = tag
    }
    
    public var body: some View {
        Text(tag)
            .font(.caption)
            .padding(5)
            .cornerRadius(5)
    }
}

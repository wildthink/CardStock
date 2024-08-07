//
//  Models.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//

import Foundation

// MARK: - Note Data Structure

struct Note: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String?
    var tags: [String]
    var domain: String
    var body: AttributedString
    var creationDate: Date
    var lastModifiedDate: Date
    var links: [URL]
    var rating: Rating?
    var comments: [Comment]
}

struct Comment: Identifiable {
    let id = UUID()
    var author: String
    var content: String
    var date: Date
}

struct Rating {
    var name: String
    var voteCount: Int
    var value: Int
    
    init(name: String = "Rating", voteCount: Int = 1, value: Int) {
        self.name = name
        self.voteCount = voteCount
        self.value = value
    }
}

// MARK: Preview Models
extension Note {
    static let preview = Note(
        title: "Sample Note",
        subtitle: "A brief description",
        tags: ["SwiftUI", "iOS"],
        domain: "Programming",
        body: previewBody,
        creationDate: Date().addingTimeInterval(-86400),
        lastModifiedDate: Date(),
        links: [URL(string: "https://apple.com")!],
        rating: .preview,
        comments: [
            .preview
        ])
    
    static let previewBody = try! AttributedString(markdown:
        """
        # Sample Title
        
        A list of items
        
        - one
        - two
        - three
        """
    )
}

extension Comment {
    static let preview = Comment(
        author: "John",
        content: "Great note!",
        date: Date()
    )
}

extension Rating {
    static let preview = Rating(name: "Preview Rating", value: 4)
}

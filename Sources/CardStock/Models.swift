//
//  Models.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//

import Foundation

// MARK: - Note Data Structure

public enum VisualPlacement: Int, Sendable {
    case top
    case bottom
    case leading
    case trailing
    case center
    case `default`
}

public struct Note: Identifiable, Sendable {
    
    public let id = EntityID()
    public var owner: EntityID?
    public var creationDate: Date
    public var lastModifiedDate: Date
    
    public var title: String
    public var subtitle: String?
    public var tags: [String]
    public var domain: String
    public var body: AttributedString
    public var links: [URL]
    public var rating: Rating?
    public var comments: [Comment]
    
    public init(title: String, subtitle: String? = nil, tags: [String], domain: String, body: AttributedString, creationDate: Date, lastModifiedDate: Date, links: [URL], rating: Rating? = nil, comments: [Comment]) {
        self.title = title
        self.subtitle = subtitle
        self.tags = tags
        self.domain = domain
        self.body = body
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
        self.links = links
        self.rating = rating
        self.comments = comments
    }
}



public struct Comment: Identifiable, Sendable {
    public let id = EntityID()
    public var author: String
    public var content: String
    public var date: Date
    
    public init(author: String, content: String, date: Date) {
        self.author = author
        self.content = content
        self.date = date
    }
}

public struct Rating: Sendable {
    public var name: String
    var voteCount: Int
    var value: Int
    
    public init(name: String = "Rating", voteCount: Int = 1, value: Int) {
        self.name = name
        self.voteCount = voteCount
        self.value = value
    }
}

// MARK: Preview Models
public extension Note {
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
        Some **simple** markdown with a [link](https://apple.com).
        """
    )
}

public extension Comment {
    static let preview = Comment(
        author: "John",
        content: "Great note!",
        date: Date()
    )
}

public extension Rating {
    static let preview = Rating(name: "Preview Rating", value: 4)
}

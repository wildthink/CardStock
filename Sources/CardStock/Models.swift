//
//  Models.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//

import Foundation
/*
 Log line - A logline is a one-sentence summary of the story's main conflict.
            It is not a statement of theme but rather a premise.
 lede / abstract
 */
// MARK: - Note Data Structure

public struct Note: Identifiable, Sendable {
    
    public let id = EntityID()
    public let subject_id: Int64

    public var owner: EntityID?
    public var creationDate: Date
    public var lastModifiedDate: Date
    
    public var title: String
    public var subtitle: String?
    
    var attachments: [Note.Attachment]
    
    public var domain: String
    public var body: AttributedString
    
    public init(title: String, subject: Int64 = 0,
                subtitle: String? = nil, tags: [String], domain: String,
                body: AttributedString,
                creationDate: Date, lastModifiedDate: Date,
                links: [URL], rating: Rating? = nil, comments: [Comment]
    ) {
        self.title = title
        self.subject_id = subject
        
        self.subtitle = subtitle
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate

        self.body = body
        self.domain = domain
        self.attachments = []
        
        attach(.tag, tags)
        attach(.link, links)
        if let rating {
            attach(.rating, [rating])
        }
        attach(.comment, comments)
    }
}

extension Note {
    var links: [URL] { components() }
    var comments: [Comment] { components() }
    var tags: [String] { components() }
    var ratings: [Rating] { components() }
}

public extension Note {
    enum Component: Int16, Sendable { case any, tag, domain, link, rating, comment }
    
    struct Attachment: @unchecked Sendable {
        var value: Any
        let valueType: Any.Type
        let component: Component

        init<S>(_ c: Component, _ value: S) {
            self.component = c
            self.value = value
            self.valueType = S.self
        }
    }
    
    func components<S>(_ c: Component = .any, like t: S.Type = S.self) -> [S] {
        if c == .any {
            attachments.compactMap { $0.value as? S }
        } else {
            attachments.filter({ $0.component == c }).compactMap { $0.value as? S }
        }
    }
    
    mutating
    func attach<S: Sendable>(_ c: Component, _ values: [S]) {
        let new = values.map({ Attachment(c, $0) })
        attachments.append(contentsOf: new)
    }
}

// MARK: Note Stencils

// URL -> Data -> Stencil -> Markdown -> AttributedString

struct NoteContent: Sendable {
    
    var buildDate: Date?
    var subjectType: Any.Type
    var content: String
    var body: AttributedString
    
    func buildBody() {
        
    }
}

// MARK: Note Components
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

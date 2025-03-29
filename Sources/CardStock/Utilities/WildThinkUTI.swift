//
//  WildThinkUTI.swift
//  CardStock
//
//  Created by Jason Jobe on 3/27/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// This overload of the matching operator for ``UTType`` enables a
/// a clean ergonmic and safer check using the UTType confomance
/// hierarchy.
func ~= (pattern: UTType?, value: UTType?) -> Bool {
    guard let pattern, let value else { return false }
    return value.conforms(to: pattern)
}

// MARK: URL Extensions
prefix operator ~/

// net.daringfireball.markdown
// com.wildthink.persona // profile/company org

// MARK: UTType Extensions
public extension UTType {
    
    /// WildThink Types
    /// UTType(exportedAs: "com.wildthink.myType", conformingTo: .text)

    static let structuredMarkdown: UTType =
    UTType(importedAs: "com.wildthink.structuredMarkdown", conformingTo: .text)

    /**
 A persona (plural personae or personas) is a strategic mask of identity in public,[1]
 the public image of one's personality, the social role that one adopts, or simply a
 fictional character.[2] It is also considered "an intermediary between the individual
 and the institution."[3]
 */
    static let persona: UTType =
    UTType(importedAs: "com.wildthink.persona", conformingTo: .item)

    static let placemark: UTType =
    UTType(importedAs: "com.wildthink.placemark", conformingTo: .item)

    /**
     A Venue is the place where something happens, especially an organized event
     such as a concert, conference, or sports event
        - Coordinates (lat/long)
        - Street Address
     
        - Placemark
        - Postal Address
     */
    static let venue: UTType =
    UTType(importedAs: "com.wildthink.venue", conformingTo: .placemark)

    /// UTType(exportedAs: "com.wildthink.myType", conformingTo: .text)

    /// Daringfireball Markdown Document, ext: .md, .markdown
    static let markdown: UTType =
    UTType(importedAs: "net.daringfireball.markdown", conformingTo: .text)
    
    /// OPML XML Document, ext: .opml
    static let opml: UTType =
    UTType(importedAs: "org.opml.opml", conformingTo: .xml)

    /// The UTType for Xcode project.pbxproj files
    static let pbxproj: UTType =
    UTType(filenameExtension: "pbxproj", conformingTo: .text)!
    
    // TODO: webarchive, .url
    /**
     Example: Contents of "to_example.url"
    [InternetShortcut]
    URL=http://www.example.com
     */
}

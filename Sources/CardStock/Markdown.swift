//
//  Markdown.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//

import Foundation

public extension String {
    /// Native Support for styling Markdown is limited. This is just a stub to
    /// hook into later.
    func markdown() -> AttributedString {
        (try? AttributedString(markdown: self)) ?? AttributedString(self)
    }
}

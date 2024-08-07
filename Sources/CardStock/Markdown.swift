//
//  Markdown.swift
//  CardStock
//
//  Created by Jason Jobe on 8/7/24.
//

import Foundation

public extension String {
    func markdown() -> AttributedString {
        (try? AttributedString(markdown: self)) ?? AttributedString(self)
    }
}

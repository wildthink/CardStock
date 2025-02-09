//
//  MarkdownTree.swift
//  CardStock
//
//  Created by Jason Jobe on 2/8/25.
//

import Foundation
import Markdown

public struct MarkdownTree {
    var document: Document
    var tree: XMLDocument
}

enum NodeType {
    case section
    case directive
    case table
    case list
    case block
}

extension MarkdownTree: MarkupVisitor {
    public typealias Result = ()
    
    mutating func read(document: Document) -> () {
        
    }
    
    mutating public
    func defaultVisit(_ markup: any Markdown.Markup) -> () {
        
    }
    
    
}

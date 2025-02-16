//
//  XMLIterator.swift
//  CardStock
//
//  Created by Jason Jobe on 2/15/25.
//

import Foundation

public extension XMLNode {

    func foreach() -> XMLIterator {
        XMLIterator(self)
    }

    func matches(path: String) -> Bool {
        let p = path.split(separator: "/", omittingEmptySubsequences: false)
        return matches(path: p[0...])
    }
    
    func matches(path: ArraySlice<String.SubSequence>) -> Bool {
        let name = self.name ?? ""
        guard let key = path.last, name == key
        else { return false }

        let rest = path.dropLast()
        if rest.isEmpty { return true }
        // No parent but expects one => false / no match
        return parent?.matches(path: rest) ?? false
    }
}

public struct XMLIterator: IteratorProtocol, Sequence {
    private var queue: [XMLNode]
    // TODO: Add pruning filter function
    //
    private var prune: ((XMLNode) -> Bool)?
    
    public init(_ parent: XMLNode) {
        queue = parent.children ?? []
    }

    public init(_ nodes: [XMLNode]) {
        queue = nodes
    }

    mutating func enqueue(_ nodes: [XMLNode]?) {
        guard let nodes else { return }
        if let prune = prune {
            queue.append(contentsOf: nodes.filter(prune))
        } else {
            queue.append(contentsOf: nodes)
        }
    }
    
    public mutating func next() -> XMLNode? {
        guard !queue.isEmpty else { return nil }
        
        let node = queue.removeFirst()
        enqueue(node.children)
        return node
    }
}

// MARK: Sequence<XMLNode> Extenstions
public extension LazySequence where Elements.Element == XMLNode {
    func nodes(named name: String) -> LazyFilterSequence<Elements> {
        return self.filter { $0.name == name }
    }
    
    func matching(path: String) -> LazyFilterSequence<Elements> {
        filter { $0.matches(path: path) }
    }
}

public extension Sequence where Element == XMLNode {
    func nodes(named name: String) -> [Element] {
        filter { $0.name == name }
    }
    
    func matching(path: String) -> [Element] {
        filter { $0.matches(path: path) }
    }
}

// LazyFilterSequence
public extension Sequence {
    func nth(_ ndx: Int) -> Element? {
        guard ndx > 0 else {
            return nil
        }
        var count = 1
        for x in self {
            if count == ndx {
                return x
            }
            count += 1
        }
        return nil
    }
}

public extension XMLNode {
    
    func format() -> String {
        var str = ""
        self.format(to: &str)
        return str
    }

    func format<OS: TextOutputStream>(_ level: Int = 0, to str: inout OS, isLast: Bool = true, prefix: String = "") {
        
        let connector = isLast ? "└── " : "├── "
        let newPrefix = prefix + (isLast ? String(repeating: " ", count: level * 2) : "│   ")
        
        let name = self.name ?? self.stringValue ?? "(null)"
        if level == 0 {
            Swift.print(name, separator: "", terminator: "\n", to: &str)
        } else {
            Swift.print(prefix, connector, name, separator: "", terminator: "\n", to: &str)
        }

        guard let children = self.children, !children.isEmpty else { return }
        
        for (index, child) in children.enumerated() {
            let isLastChild = index == children.count - 1
            child.format(level + 1, to: &str, isLast: isLastChild, prefix: newPrefix)
        }
    }
}

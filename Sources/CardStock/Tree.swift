//
//  Tree.swift
//  CardStock
//
//  Created by Jason Jobe on 2/13/25.
//
import Foundation

final class Tree<Element> {
    weak var parent: Tree?
    var tag: String
    var index: Int
    var attributes: [String: Any]
    var element: Element
    var children: [Tree]
    
    var isRoot: Bool { parent == nil }
    var isLeaf: Bool { children.isEmpty }
    var hasChildren: Bool { !isLeaf }
    
    init(parent: Tree? = nil, tag: String, attributes: [String : Any], element: Element, children: [Tree]) {
        self.parent = parent
        self.tag = tag
        self.attributes = attributes
        self.element = element
        self.children = children
        self.index = 0
    }
    
    func addChild(_ tree: Tree) {
        children.append(tree)
        tree.parent = self
        tree.index = children.count
    }
    
    func attribute<A>(_ t: A.Type = A.self, named: String) -> A? {
        attributes[named] as? A
    }
    func attribute(set key: String, to value: Any) {
        attributes[key] = value
    }
}

// MARK: XPath like Support
extension Tree {
    enum PathComponent {
        case anyone
        case anypath
        case tag(String)
        case index(Int)
        case condition((Tree<Element>) -> Bool)
    }
    
    /// Returns all leaf nodes that are found matching the path component
    /// "anyone" matches any single node, "anypath" any number intermediate nodes
    func nodes(matching path: Slice<[PathComponent]>, into list: inout [Tree]) {
        guard let cond = path.first else {
            list.append(self)
            return
        }
        let matches = switch cond {
            case .tag(let tagName): tag == tagName
            case .index(let idx):   idx == index
            case .condition(let predicate): predicate(self)
            case .anyone:   true
            case .anypath:  true
        }
        guard matches else { return }
        let tail = path.dropFirst()
        if case .anypath = cond {
            decendents(matching: tail, into: &list)
        } else {
            children.forEach {
                $0.nodes(matching: tail, into: &list)
            }
        }
    }
    
    func decendents(matching path: Slice<[PathComponent]>, into list: inout [Tree]) {
        if path.isEmpty { return }
        for child in children {
            child.nodes(matching: path, into: &list)
            decendents(matching: path, into: &list)
        }
    }
}

// MARK: More Tree Extensions
extension Tree: Hashable {
    static func == (lhs: Tree<Element>, rhs: Tree<Element>) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Tree {
    /// Returns a path of tree nodes that traverses from this node to the first
    /// node (breadth-first) that matches the given predicate.
    func path(toFirstWhere predicate: (Element) -> Bool) -> [Tree] {
        var visited: Set<Tree> = []
        var toVisit: [Tree] = [self]
        var currentIndex = 0
        
        // For each node, the neighbor that is most efficiently used to reach
        // that node.
        var cameFrom: [Tree: Tree] = [:]
        
        while let current = toVisit[currentIndex...].first {
            currentIndex += 1
            if predicate(current.element) {
                // Reconstruct the path from `self` to `current`.
                return sequence(first: current, next: { cameFrom[$0] }).reversed()
            }
            visited.insert(current)
            
            for child in current.children where !visited.contains(child) {
                if !toVisit.contains(child) {
                    toVisit.append(child)
                }
                
                // Coming from `current` is the best path to `neighbor`.
                cameFrom[child] = current
            }
        }
        
        // Didn't find a path!
        return []
    }
}

//
//  Topic.swift
//  CardStock
//
//  Created by Jason Jobe on 3/8/25.
//

import Foundation

struct Topic: Identifiable {
    var id: Int64
    var name: String
    var aka: [String]?
    var tags: [String]?
    var summary: String
    var content: String
}

typealias AnyCodable = Any

struct Qualifier {
    var name: String
    var value: AnyCodable?
}

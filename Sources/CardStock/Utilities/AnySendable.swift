//
//  AnySendable.swift
//  CardStock
//
//  Created by Jason Jobe on 8/13/24.
//
import Foundation

public struct AnySendable: Sendable {
    private let box: any _AnySendableBox

    public init<T: Sendable>(_ value: T) {
        self.box = SendableBox(value)
    }
    
    public func value<T: Sendable>(as t: T.Type = T.self) -> T? {
        return (box as? SendableBox<T>)?.value
    }
    
    public func callAsFunction<T: Sendable>(as t: T.Type = T.self) -> T? {
        return (box as? SendableBox<T>)?.value
    }
}

// The protocol that both boxes conform to, ensuring Sendable conformance
private protocol _AnySendableBox: Sendable {}

private struct SendableBox<T: Sendable>: _AnySendableBox {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

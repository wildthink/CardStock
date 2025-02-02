//
//  AnySendable.swift
//  CardStock
//
//  Created by Jason Jobe on 8/13/24.
//
import Foundation
import Combine

private final class SafeBox<Value>: @unchecked Sendable {
    private let lock = NSRecursiveLock()
    private var _wrappedValue: Value

    var wrappedValue: Value {
        _read {
            lock.lock()
            defer { lock.unlock() }
            yield _wrappedValue
        }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_wrappedValue
        }
        set {
            lock.withLock { _wrappedValue = newValue }
        }
    }
    init(_ wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
#if canImport(SwiftUI)
//    private var cancellable: AnyCancellable?

//    func subscribe(state: State<Int>) {
//        guard #unavailable(iOS 17, macOS 14, tvOS 17, watchOS 10) else { return }
//        _ = state.wrappedValue
//        func open(_ publisher: some Publisher<Value, Never>) -> AnyCancellable {
//            publisher.dropFirst().sink { _ in
//                state.wrappedValue &+= 1
//            }
//        }
//        let cancellable = open(_wrappedValue.publisher)
//        lock.withLock { self.cancellable = cancellable }
//    }
#endif
}

//public struct AnySendable: Sendable {
//    private let box: any _AnySendableBox
//
//    public init<T: Sendable>(_ value: T) {
//        self.box = SendableBox(value)
//    }
//
//    public func value<T: Sendable>(as t: T.Type = T.self) -> T? {
//        return (box as? SendableBox<T>)?.value
//    }
//
//    public func callAsFunction<T: Sendable>(as t: T.Type = T.self) -> T? {
//        return (box as? SendableBox<T>)?.value
//    }
//}
//
//// The protocol that both boxes conform to, ensuring Sendable conformance
//private protocol _AnySendableBox: Sendable {}
//
//private struct SendableBox<T: Sendable>: _AnySendableBox {
//    let value: T
//
//    init(_ value: T) {
//        self.value = value
//    }
//}

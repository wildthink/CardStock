//
//  File.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import Foundation

infix operator ???: NilCoalescingPrecedence

public func ???<V>(lhs: @autoclosure () throws -> V, rhs: V) -> V {
    do {
//        withoutActuallyEscaping(closure) { escapingClosure in
//            function(escapingClosure)
//        }
        return try lhs()
    } catch {
        return rhs
    }
}

func stress() -> String {
    try punts(true) ??? "default"
}

func punts(_ flag: Bool) throws -> String {
    throw NSError(domain: "", code: 0, userInfo: nil)
}

func performOperation<T>(
    with closure: () -> T,
    using function: (@escaping () -> T) -> Void
) {
    withoutActuallyEscaping(closure) { escapingClosure in
        function(escapingClosure)
    }
}

prefix operator ∫

prefix func ∫(_ lhs: String) -> String {
    lhs
}

func ¨(_ lhs: String) -> String {
    lhs
}

func sample() {
    let x = ¨("okay")
    let y = ∫"okay"
    print(x, y)
}

func Ω() {
    
}

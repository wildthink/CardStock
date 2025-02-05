//
//  File.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import Foundation


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
}

func Ω() {
    
}

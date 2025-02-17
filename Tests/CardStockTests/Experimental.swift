//
//  File.swift
//  CardStock
//
//  Created by Jason Jobe on 2/16/25.
//

import Foundation

struct ArrayWrapper<Store, Element>: RandomAccessCollection {
    private var array: [Store]
    var fn: (Store) -> Element
    
    init(array: [Store], fn: @escaping (Store) -> Element) {
        self.array = array
        self.fn = fn
    }
    
    var startIndex: Int {
        array.startIndex
    }

    var endIndex: Int {
        array.endIndex
    }

    subscript(index: Int) -> Element {
        fn(array[index])
    }

    func index(after i: Int) -> Int {
        array.index(after: i)
    }

    func index(before i: Int) -> Int {
        array.index(before: i)
    }
    
    func transmute<Item>(_ fn: @escaping (Element) -> Item) -> ArrayWrapper<Store, Item> {
        .init(array: array, fn: { fn(self.fn($0)) })
    }
}

func testXfrom() {
    // Sample input sequence (numbers)
    let numbers = [1, 2, 3, 4, 5]

    // Define a transformation function (e.g., square each number)
    let squareTransform: (Int) -> String = { "Square of \($0) is \($0 * $0)" }

    // Get an iterator that transforms numbers to strings
    let transformedIterator = numbers.transformingIterator(squareTransform)

    // Iterate and print transformed values
    while let transformedValue = transformedIterator.next() {
        print(transformedValue)
    }
    print("Complete", #function)
}

import Foundation

// Generic Transforming Iterator
struct TransformingIterator<Input, Output>: IteratorProtocol {
    private var baseIterator: AnyIterator<Input>
    private let transform: (Input) -> Output

    init<I: IteratorProtocol>(iterator: I, transform: @escaping (Input) -> Output) where I.Element == Input {
        self.baseIterator = AnyIterator(iterator)
        self.transform = transform
    }

    mutating func next() -> Output? {
        guard let nextInput = baseIterator.next() else { return nil }
        return transform(nextInput)
    }
}

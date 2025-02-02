//
//  File.swift
//  CardStock
//
//  Created by Jason Jobe on 8/10/24.
//

import Foundation
//import Carbon14

@dynamicMemberLookup
struct ValueContainer <Subject> {
    var store: [AnyHashable: Any]
    var defaultValue: Subject
    
//    var styles: [any FormatStyle] = []
    
    subscript<M>(dynamicMember key: KeyPath<Subject,M>) -> M {
        get { store[key] as? M ?? defaultValue[keyPath: key] }
    }
    
    subscript<M>(dynamicMember key: WritableKeyPath<Subject,M>) -> M {
        get { store[key] as? M ?? defaultValue[keyPath: key] }
        set { store[key] = newValue }
    }
    
//    func demo() {
//        let f = styles[0]
//        let it = try? f.format(any: 45)
//        print(it)
//    }
}

extension FormatStyle {
    var inputType: Any.Type  { Self.FormatInput.self }
    var outputType: Any.Type { Self.FormatOutput.self }
    
    func canFormat<A>(any: Any, as out: A.Type) -> Bool {
        return (any is FormatInput) && (A.Type.self is FormatOutput.Type)
    }
    
    func format(any: Any) throws -> FormatOutput {
        guard let ok = any as? FormatInput
        else { throw NSError() }
        return format(ok)
    }
}

// ExpressibleByStringLiteral

protocol ExpressibleByStringParser {
    associatedtype Strategy = ParseStrategy
    init(with: String, parseStrategy: Strategy)
}

struct Foo {
    var name: String
    var count: Int
}

struct FooFormatStyle: FormatStyle {
    func format(_ value: String) -> Foo {
        Foo(name: value, count: 0)
    }
    
//    typealias FormatInput = String
//    typealias FormatOutput = Foo
}

//init(
//    _ value: String,
//    format: Decimal.FormatStyle,
//    lenient: Bool = true
//) throws

extension Foo {
    init<F: FormatStyle>(
        _ value: String,
        format: F,
        lenient: Bool = true
    ) throws
    where F.FormatInput == String, F.FormatOutput == Self {
        self = format.format(value)
    }
}

protocol CustomFilePathConvertable {
    var standardFilePath: String { get }
}

extension URL: CustomFilePathConvertable {
    var standardFilePath: String {
        self.standardizedFileURL.path()
    }
}

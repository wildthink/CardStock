//
//  Test.swift
//  CardStock
//
//  Created by Jason Jobe on 3/16/25.
//

@testable import CardStock
import Testing
import Foundation

struct Test {

    @Test func testMediaURI() async throws {
        func pr(_ str: String) {
            let m1 = URL(string: str)!
            print(m1.scheme, m1.host, m1.path)
        }
//        let m = Media(host: nil, mediaType: .color, location: .module(nil, "orange"))
//        let p = try encode(m)
//        print(p)
//        let dm: Media = try decode(p)
//        print(dm)
////        #expect(p == "media://color/module/orange")
    }

}

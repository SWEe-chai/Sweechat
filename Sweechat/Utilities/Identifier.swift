//
//  Identifier.swift
//  Sweechat
//
//  Created by Christian James Welly on 11/4/21.
//

struct Identifier<Value>: Hashable {
    let val: String
}

// Allows us to do: let id: Identifier = "123"
// instead of: let id: Identifier = Identifier("123")
extension Identifier: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        val = value
    }
}

// Allows us to make print(identifier) print a string literal directly
extension Identifier: CustomStringConvertible {
    var description: String {
        val
    }
}

extension Identifier: Equatable {
    static func == (lhs: Identifier, rhs: Identifier) -> Bool {
        lhs.val == rhs.val
    }
}

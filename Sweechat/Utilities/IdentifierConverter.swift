//
//  IdentifierConverter.swift
//  Sweechat
//
//  Created by Christian James Welly on 12/4/21.
//

struct IdentifierConverter {
    // TODO: Use Generics
    static func toOptionalMessageId(from optionalStringId: String?) -> Identifier<Message>? {
        guard let stringId = optionalStringId else {
            return nil
        }

        return Identifier(val: stringId)
    }
}

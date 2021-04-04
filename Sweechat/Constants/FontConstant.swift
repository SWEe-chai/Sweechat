//
//  FontConstant.swift
//  Sweechat
//
//  Created by Agnes Natasya on 3/4/21.
//

import SwiftUI

struct FontConstant {
    static let OpenSans_Bold = "OpenSans-Bold"
    static let OpenSans_Light = "OpenSans-Light"
    static let Inter_Light = "Inter-Light"

    static let ModuleTitle = Font.custom("Montserrat-Regular", size: 40)
    static let ModuleDescription = Font.custom("OpenSans-LightItalic", size: 14)
    static let Heading1 = Font.custom("OpenSans-Bold", size: 27)

    static let MessageSender = Font.custom(OpenSans_Bold, size: 16)
    static let MessageText = Font.custom(Inter_Light, size: 16)
    static let MessageReplySender = Font.custom(OpenSans_Bold, size: 14)
    static let MessageReplyText = Font.custom(Inter_Light, size: 14)
}

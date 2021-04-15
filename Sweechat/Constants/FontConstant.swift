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

    static let ModuleTitle = Font.custom("LemonMilk-Regular", size: 38)
    static let ModuleDescription = Font.custom("OpenSans-LightItalic", size: 15)
    static let Heading1 = Font.custom("OpenSans-Bold", size: 27)
    static let Heading4 = Font.custom("OpenSans-Bold", size: 18)
    static let Heading5 = Font.custom("OpenSans-Bold", size: 15)
    static let MessageSender = Font.custom(OpenSans_Bold, size: 16)
    static let ChatRoomTypeButton = Font.custom(OpenSans_Bold, size: 14)
    static let ForumPost = Font.custom("Inter-Regular", size: 20)
    static let MessageText = Font.custom(Inter_Light, size: 16)
    static let MessageReplySender = Font.custom(OpenSans_Bold, size: 14)
    static let MessageReplyText = Font.custom(Inter_Light, size: 14)
}

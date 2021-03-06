//
//  AsyncHelper.swift
//  Sweechat
//
//  Created by Agnes Natasya on 15/4/21.
//

import Foundation

struct AsyncHelper {
    static let shortInterval = 0.01
    static let mediumInterval = 0.1
    static let longInterval = 1.0
    static func checkAsync(interval: Double,
                           repeatableFunction: @escaping () -> Bool,
                           timeToLive: Int = 50) {
        if timeToLive == 0 {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if repeatableFunction() {
                AsyncHelper.checkAsync(interval: interval,
                                       repeatableFunction: repeatableFunction,
                                       timeToLive: timeToLive - 1)
            }
        }
    }
}

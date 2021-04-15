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
    static func checkAsync(interval: Double, repeatableFunction: @escaping () -> Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if repeatableFunction() {
                AsyncHelper.checkAsync(interval: interval, repeatableFunction: repeatableFunction)
            }
        }
    }
}

//
//  AsyncHelper.swift
//  Sweechat
//
//  Created by Agnes Natasya on 15/4/21.
//

import Foundation

struct AsyncHelper {
    static func checkAsync(interval: Double, repeatableFunction: @escaping () -> Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if repeatableFunction() {
                AsyncHelper.checkAsync(interval: interval, repeatableFunction: repeatableFunction)
            }
        }
    }
}

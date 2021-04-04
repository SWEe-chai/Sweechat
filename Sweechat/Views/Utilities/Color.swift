//
//  Color.swift
//  Sweechat
//
//  Created by Agnes Natasya on 4/4/21.
//
import SwiftUI

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...0.5),
            green: .random(in: 0...0.5),
            blue: .random(in: 0...0.5)
        )
    }
}

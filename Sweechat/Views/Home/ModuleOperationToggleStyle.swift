//
//  ModuleOperationToggleStyle.swift
//  Sweechat
//
//  Created by Agnes Natasya on 4/4/21.
//

import SwiftUI

struct ModuleOperationToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(ColorConstant.primary)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(.all, 3)
                        .overlay(
                            GeometryReader { proxy in
                                if !configuration.isOn {
                                    Image(systemName: "plus.magnifyingglass")
                                        .foregroundColor(ColorConstant.dark)
                                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                                } else {
                                    Image(systemName: "plus.app")
                                        .foregroundColor(ColorConstant.dark)
                                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                                }

                            }
                        )
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
                        .animation(Animation.linear(duration: 0.1))

                ).cornerRadius(20)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

//
//  HomeToolbarView.swift
//  Sweechat
//
//  Created by Hai Nguyen on 28/3/21.
//

import SwiftUI

struct HomeToolbarView: View {
    @Binding var isShowingJoinView: Bool
    @Binding var isShowingAddView: Bool
    var body: some View {
        HStack {
            Button(action: {
                isShowingJoinView = true
                isShowingAddView = false
            }) {
                Image(systemName: "plus.magnifyingglass")
            }
            Button(action: {
                isShowingJoinView = false
                isShowingAddView = true
            }) {
                Image(systemName: "plus.app")
            }
        }
    }
}

struct HomeToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        HomeToolbarView(
            isShowingJoinView: .constant(false),
            isShowingAddView: .constant(false))
    }
}

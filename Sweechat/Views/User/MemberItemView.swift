//
//  MemberItemView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import SwiftUI

struct MemberItemView: View {
    @ObservedObject var viewModel: MemberPreviewViewModel

    var body: some View {
        HStack {
            viewModel.memberName
        }
    }
}

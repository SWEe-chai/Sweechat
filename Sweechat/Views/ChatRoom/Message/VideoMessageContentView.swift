//
//  VideoMessageContentView.swift
//  Sweechat
//
//  Created by Christian James Welly on 31/3/21.
//

import AVKit
import SwiftUI

struct VideoMessageContentView: View {
    @ObservedObject var viewModel: VideoMessageViewModel
    var body: some View {
        if let url = viewModel.url {
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
        } else {
            Text("The link to this video is broken.")
        }
    }
}

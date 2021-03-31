//
//  VideoMessageContentView.swift
//  Sweechat
//
//  Created by Christian James Welly on 31/3/21.
//

import AVKit
import SwiftUI

struct VideoMessageContentView: View {
    // TODO: Force unwrapping. Will be refactored anyway
    @ObservedObject var viewModel: VideoMessageViewModel
    var body: some View {
        VideoPlayer(player: AVPlayer(url: viewModel.url))
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
    }
}

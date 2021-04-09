//
//  VideoMessageContentView.swift
//  Sweechat
//
//  Created by Christian James Welly on 31/3/21.
//

import AVKit
import SwiftUI

struct VideoMessageContentView: View {
    var viewModel: VideoMessageViewModel
    var body: some View {
        LocalVideoPlayer(viewModel: viewModel.localFileViewModel)
    }
}

struct LocalVideoPlayer: View {
    @ObservedObject var viewModel: LocalFileViewModel
    var body: some View {
        switch viewModel.state {
        case .success:
            if let localUrl = viewModel.localUrl {
                VideoPlayer(player: AVPlayer(url: localUrl))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            } else {
                Text("The link to this video is broken.")
            }
        case .loading:
            Text("Loading...")
        case .failed:
            Text("The link to this video is broken.")
        }
    }
}

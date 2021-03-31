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
    private let player = AVPlayer(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
    var body: some View {
        VideoPlayer(player: player)
    }
}

//
//  ParentPreviewMetadata.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/4/21.
//

struct ParentPreviewMetadata {
    var parentMessage: MessageViewModel
    var tappedPreview: Bool = false
    var previewType: PreviewType
}

// MARK: Equatable
extension ParentPreviewMetadata: Equatable {
}

enum PreviewType {
    case reply, edit
}

//
//  CanvasView.swift
//  Sweechat
//
//  Created by Agnes Natasya on 1/4/21.
//
import SwiftUI
import PencilKit

struct CanvasView: View {
    @Binding var showingModal: Bool
    @Binding var media: Any?
    @Binding var mediaType: MediaType?
    var canvasView = PKCanvasView()

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "xmark")
                    .onTapGesture {
                        showingModal = false
                    }
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .onTapGesture {
                        media = canvasView.drawing.image(
                            from: CGRect(
                                x: 0,
                                y: 0,
                                width: UIScreen.main.bounds.size.width,
                                height: UIScreen.main.bounds.size.height
                            ), scale: 1.0)
                        mediaType = MediaType.image
                        showingModal = false
                    }
            }
            MyCanvas(canvasView: canvasView)
        }
    }
}

struct MyCanvas: UIViewRepresentable {
    var canvasView: PKCanvasView
    let picker = PKToolPicker()

    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.tool = PKInkingTool(.pen, color: .black, width: 10)
        self.canvasView.becomeFirstResponder()
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        picker.addObserver(canvasView)
        picker.setVisible(true, forFirstResponder: uiView)
        DispatchQueue.main.async {
            uiView.becomeFirstResponder()
        }
    }
}

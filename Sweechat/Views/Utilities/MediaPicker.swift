// Derived from:
// https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-uiimagepickercontroller

import SwiftUI

enum MediaType {
    case image, video
}

struct MediaPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: MediaPicker

        init(_ parent: MediaPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.media = uiImage
                parent.mediaType = .image
            } else if let mediaURL = info[.mediaURL] {
                parent.media = mediaURL
                parent.mediaType = .video
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    @Environment(\.presentationMode) var presentationMode
    @Binding var media: Any? // UIImage in the case of photo, URL in the case of video
    @Binding var mediaType: MediaType?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MediaPicker>) -> UIImagePickerController {
        // select something from photo library
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

}

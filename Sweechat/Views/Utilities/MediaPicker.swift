// Derived from:
// https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-uiimagepickercontroller

import SwiftUI

enum PickedMediaType {
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
                parent.pickedMedia = uiImage
                parent.pickedMediaType = .image
            } else if let mediaURL = info[.mediaURL] {
                parent.pickedMedia = mediaURL
                parent.pickedMediaType = .video
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    @Environment(\.presentationMode) var presentationMode
    @Binding var pickedMedia: Any? // UIImage in the case of photo, URL in the case of video
    @Binding var pickedMediaType: PickedMediaType?

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

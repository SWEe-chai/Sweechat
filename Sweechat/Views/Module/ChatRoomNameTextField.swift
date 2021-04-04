import SwiftUI

struct ChatRoomNameTextField: View {
    var placeholder: String
    @Binding var name: String
    var body: some View {
        TextField(placeholder, text: $name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .cornerRadius(5)
            .frame(idealHeight: 20, maxHeight: 60)
            .multilineTextAlignment(.leading)
            .padding()
    }
}

struct ChatRoomNameTextField_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomNameTextField(placeholder: "Group Name", name: .constant(""))
    }
}

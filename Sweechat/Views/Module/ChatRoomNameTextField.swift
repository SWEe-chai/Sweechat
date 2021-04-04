import SwiftUI

struct ChatRoomNameTextField: View {
    var placeholder: String
    @Binding var name: String
    var body: some View {
        TextField(placeholder, text: $name)
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .font(FontConstant.Heading5)
            .foregroundColor(ColorConstant.medium)
            .frame(idealHeight: 20, maxHeight: 60)
            .multilineTextAlignment(.leading)
    }
}

struct ChatRoomNameTextField_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomNameTextField(placeholder: "Group Name", name: .constant(""))
    }
}

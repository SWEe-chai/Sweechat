import SwiftUI

struct JoinModuleView: View {
    @State var moduleSecret: String = ""
    var viewModel: HomeViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Join a Module")
                .font(FontConstant.Heading1)
                .foregroundColor(ColorConstant.dark)
                .padding(.top)
            HStack {
                TextField("Module Secret", text: $moduleSecret)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .font(FontConstant.Heading5)
                    .foregroundColor(ColorConstant.medium)
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(ColorConstant.dark)
                    .onTapGesture { tappedCreate() }
            }
            .padding(.top, 7)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(ColorConstant.base)
    }

    func tappedCreate() {
        if moduleSecret.isEmpty {
            return
        }
        viewModel.handleJoinModule(secret: moduleSecret)
        moduleSecret = ""
    }
}

 struct JoinModuleView_Previews: PreviewProvider {
    static var previews: some View {
        JoinModuleView(
            viewModel: HomeViewModel(
                user: User(id: "123"),
                notificationMetadata: NotificationMetadata()
            )
        )
    }
 }

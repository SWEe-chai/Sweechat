import SwiftUI

struct MemberItemView: View {
    var viewModel: MemberItemViewModel
    var body: some View {
        HStack {
            ProfilePicture(url: viewModel.profilePictureUrl)

            VStack(alignment: .leading) {
                Text("\(viewModel.memberName)")
                    .font(FontConstant.Heading4)
                    .foregroundColor(ColorConstant.dark)
                Text("Some information...")
                    .font(FontConstant.Description)
                    .foregroundColor(ColorConstant.dark)
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

struct MemberItemView_Previews: PreviewProvider {
    static var previews: some View {
        MemberItemView(viewModel:
            MemberItemViewModel(
                member:
                    User(
                        id: "1",
                        name: "Hai Nguyen",
                        profilePictureUrl: """
                                    https://lh3.googleusercontent.com/
                                    a-/AOh14Gh7yXK1BE34ZK09UVtZHy_lGrGaqbUP2VGMmxsHzw=s96-c
                                    """)))
    }
}

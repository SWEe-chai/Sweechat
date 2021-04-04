import SwiftUI

struct MemberItemView: View {
    var viewModel: MemberItemViewModel
    var body: some View {
        HStack {
            UserProfilePicture(url: viewModel.profilePictureUrl)
            VStack(alignment: .leading) {
                Text("\(viewModel.memberName)").font(FontConstant.Heading4)
                Text("Some information...")
                    .font(FontConstant.ModuleDescription)
            }
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

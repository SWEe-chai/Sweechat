import SwiftUI

struct ProfilePicture: View {
    var url: String?
    var body: some View {
        if let profilePictureUrl = url, !profilePictureUrl.isEmpty {
            RemoteImage(url: profilePictureUrl,
                        failure: Image(systemName: "person"))
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(ColorConstant.light)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.3")
                )
        }
    }
}

struct UserProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicture(url: "")
    }
}

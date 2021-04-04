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
                .fill(Color.random)
                .frame(width: 50, height: 50)
//                .clipShape(Circle())
                .overlay(
//                    Circle().fill(Color.random)
                    Image(systemName: "person")
                )
        }
    }
}

struct UserProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicture(url: "")
    }
}

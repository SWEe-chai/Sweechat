import SwiftUI

struct UserProfilePicture: View {
    var url: String?
    var body: some View {
        if let profilePictureUrl = url {
            RemoteImage(url: profilePictureUrl,
                        failure: Image(systemName: "person"))
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            Image(systemName: "person")
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
}

struct UserProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        UserProfilePicture(url: "")
    }
}

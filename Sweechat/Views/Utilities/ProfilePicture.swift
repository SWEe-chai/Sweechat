import SwiftUI

struct ProfilePicture: View {
    var url: String?
    let size: CGFloat

    init(url: String?, size: CGFloat = 50) {
        self.url = url
        self.size = size
    }

    var body: some View {
        if let profilePictureUrl = url, !profilePictureUrl.isEmpty {
            RemoteImage(url: profilePictureUrl,
                        failure: Image(systemName: "person"))
                .frame(width: self.size, height: self.size)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(ColorConstant.light)
                .frame(width: self.size, height: self.size)
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

import Foundation

class User {

    var uid: UUID
    var username: String?
    var email: String
    var firstName: String?
    var lastName: String?
    var profilePictureURL: String?

    init(uid: UUID, firstName: String, lastName: String, avatarURL: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.uid = uid
        self.email = email
        self.profilePictureURL = avatarURL
    }
}

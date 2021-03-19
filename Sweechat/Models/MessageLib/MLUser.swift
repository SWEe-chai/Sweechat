import Foundation

class MLUser {

    var id: String
    var username: String?
    var email: String
    var firstName: String?
    var lastName: String?
    var profilePictureURL: String?

    init(id: String, firstName: String, lastName: String, avatarURL: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.email = email
        self.profilePictureURL = avatarURL
    }

    var name: String {
       (self.firstName ?? "") + (self.lastName ?? "")
    }
}

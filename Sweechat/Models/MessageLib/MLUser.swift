class MLUser {

    var id: String
    var username: String?
    var email: String
    var firstName: String?
    var lastName: String?
    var photoUrl: String?

    init() {
        self.id = ""
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.photoUrl = ""
    }

    init(id: String, firstName: String, lastName: String, photoUrl: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.email = email
        self.photoUrl = photoUrl
    }

    var name: String {
       (self.firstName ?? "") + (self.lastName ?? "")
    }
}

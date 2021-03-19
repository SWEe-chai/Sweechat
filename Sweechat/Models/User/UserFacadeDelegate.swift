import Foundation

protocol UserFacadeDelegate: AnyObject {
    func updateUserData(withDetails details: UserDetails)
}

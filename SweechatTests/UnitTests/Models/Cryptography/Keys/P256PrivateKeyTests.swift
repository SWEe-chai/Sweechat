import CryptoKit
import XCTest
@testable import Sweechat

class P256PrivateKeyTests: XCTestCase {
    private var publicKey: PublicKey!
    private var sut: PrivateKey!

    override func setUp() {
        super.setUp()
        (sut, publicKey) = P256KeyFactory().generateKeyPair()
    }

    override func tearDown() {
        publicKey = nil
        sut = nil
        super.tearDown()
    }
}

import ExtrasUUID
import XCTest

final class SIMDTests: XCTestCase {
    func testInitFromStringSuccess() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = XUUID.fromUUIDStringUsingSIMD(string)
        XCTAssertEqual(uuid, XUUID(uuidString: string))

        XCTAssertEqual(uuid?.lowercased, string.lowercased())
    }

    func testInitFromStringMissingCharacterAtEnd() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5"
        let uuid = XUUID.fromUUIDStringUsingSIMD(string)
        XCTAssertNil(uuid)
    }

    func testInitFromStringUsingSIMDInvalidSeparatorCharacter() {
        // illegal character: _
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F8-C36C-495A-93FC_0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F8-C36C-495A_93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F8-C36C_495A-93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F8_C36C-495A-93FC-0C247A3E6E5F"))

        // illegal character: 0
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F8-C36C-495A-93FC00C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F8-C36C-495A093FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F8-C36C0495A-93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingSIMD("E621E1F80C36C-495A-93FC-0C247A3E6E5F"))
    }

    func testInitWithSIMDVector() {
        let uuid = XUUID()
        let simd = uuid.vector
        let new = XUUID(vector: simd)

        XCTAssertEqual(uuid, new)
    }
}

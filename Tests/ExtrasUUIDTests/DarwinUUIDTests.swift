import ExtrasUUID
import XCTest

#if canImport(Darwin)
final class DarwinUUIDTests: XCTestCase {
    func testExample() {
        let a = XUUID()
        let b = XUUID()

        XCTAssertNotEqual(a, b)
    }

    func testInitFromStringSuccess() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = XUUID.fromUUIDStringUsingUUIDParse(string)
        XCTAssertEqual(uuid, try XUUID(uuidString: XCTUnwrap(UUID(uuidString: string)?.uuidString)))

        XCTAssertEqual(uuid?.lowercased(), string.lowercased())
    }

    func testInitFromStringMissingCharacterAtEnd() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5"
        let uuid = XUUID.fromUUIDStringUsingUUIDParse(string)
        XCTAssertNil(uuid)
    }
}
#endif

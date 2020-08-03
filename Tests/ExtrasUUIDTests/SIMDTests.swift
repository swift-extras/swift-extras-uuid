import ExtrasUUID
import XCTest

final class SIMDTests: XCTestCase {
    func testInitFromStringSuccess() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = XUUID.fromUUIDStringUsingSIMD(string)
        XCTAssertEqual(uuid, try XUUID(uuidString: XCTUnwrap(UUID(uuidString: string)?.uuidString)))

        XCTAssertEqual(uuid?.lowercased(), string.lowercased())
    }

    func testInitFromStringMissingCharacterAtEnd() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5"
        let uuid = XUUID.fromUUIDStringUsingSIMD(string)
        XCTAssertNil(uuid)
    }

    func testInitWithSIMDVector() {
        let uuid = XUUID()
        let simd = uuid.vector
        let new = XUUID(vector: simd)

        XCTAssertEqual(uuid, new)
    }

    func testStructSize() {
        XCTAssertEqual(MemoryLayout<XUUID>.size, 16)
    }
}

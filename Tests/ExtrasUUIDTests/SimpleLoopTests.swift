import ExtrasUUID
import XCTest

final class SimpleLoopTests: XCTestCase {
    func testInitFromStringSuccess() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = XUUID.fromUUIDStringUsingLoop(string)
        XCTAssertEqual(uuid, try XUUID(uuidString: XCTUnwrap(UUID(uuidString: string)?.uuidString)))

        XCTAssertEqual(uuid?.uppercased(), string)
    }

    func testInitFromLowercaseStringSuccess() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F".lowercased()
        let uuid = XUUID.fromUUIDStringUsingLoop(string)
        XCTAssertEqual(uuid, try XUUID(uuidString: XCTUnwrap(UUID(uuidString: string)?.uuidString)))

        XCTAssertEqual(uuid?.lowercased(), string)
    }

    func testInitFromStringMissingCharacterAtEnd() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5"
        let uuid = XUUID.fromUUIDStringUsingLoop(string)
        XCTAssertNil(uuid)
    }

    func testInitFromStringInvalidCharacterAtEnd() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5H"
        let uuid = XUUID.fromUUIDStringUsingLoop(string)
        XCTAssertNil(uuid)
    }

    func testInitFromStringInvalidSeparatorCharacter() {
        // illegal character: _
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F8-C36C-495A-93FC_0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F8-C36C-495A_93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F8-C36C_495A-93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F8_C36C-495A-93FC-0C247A3E6E5F"))

        // illegal character: 0
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F8-C36C-495A-93FC00C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F8-C36C-495A093FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F8-C36C0495A-93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID.fromUUIDStringUsingLoop("E621E1F80C36C-495A-93FC-0C247A3E6E5F"))
    }

    func testUnparse() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = XUUID.fromUUIDStringUsingLoop(string)
        XCTAssertEqual(string.lowercased(), uuid?.lowercasedSimple())
    }

    func testDescription() {
        let xuuid = XUUID()
        let fduuid = UUID(uuid: xuuid.uuid)

        XCTAssertEqual(fduuid.description, xuuid.description)
        XCTAssertEqual(fduuid.debugDescription, xuuid.debugDescription)
    }

    func testCustomMirror() {
        let xuuid = XUUID()
        let fduuid = UUID(uuid: xuuid.uuid)

        XCTAssertEqual(String(reflecting: fduuid), String(reflecting: xuuid))

        let psmirror = xuuid.customMirror
        XCTAssert(psmirror.subjectType is XUUID.Type)
        XCTAssertEqual(psmirror.description, "Mirror for XUUID")
        XCTAssertEqual(psmirror.displayStyle, .struct)
    }

    func testHashing() {
        let xuuid = XUUID()
        let fduuid = UUID(uuid: xuuid.uuid)
        XCTAssertEqual(fduuid.hashValue, xuuid.hashValue)

        var _uuid = xuuid.uuid
        _uuid.0 = _uuid.0 > 0 ? _uuid.0 - 1 : 1
        XCTAssertNotEqual(UUID(uuid: _uuid).hashValue, xuuid.hashValue)
    }

    func testEncoding() {
        struct Test: Codable {
            let uuid: XUUID
        }
        let uuid = XUUID()
        let test = Test(uuid: uuid)

        var data: Data?
        XCTAssertNoThrow(data = try JSONEncoder().encode(test))
        XCTAssertEqual(try String(decoding: XCTUnwrap(data), as: Unicode.UTF8.self), #"{"uuid":"\#(uuid.uuidString)"}"#)
    }

    func testDecodingSuccess() {
        struct Test: Codable {
            let uuid: XUUID
        }
        let uuid = XUUID()
        let data = #"{"uuid":"\#(uuid.uuidString)"}"# .data(using: .utf8)

        var result: Test?
        XCTAssertNoThrow(result = try JSONDecoder().decode(Test.self, from: XCTUnwrap(data)))
        XCTAssertEqual(result?.uuid, uuid)
    }

    func testDecodingFailure() {
        struct Test: Codable {
            let uuid: XUUID
        }
        let uuid = XUUID()
        var uuidString = uuid.uuidString
        _ = uuidString.removeLast()
        let data = #"{"uuid":"\#(uuidString)"}"# .data(using: .utf8)

        XCTAssertThrowsError(_ = try JSONDecoder().decode(Test.self, from: XCTUnwrap(data))) { error in
            XCTAssertNotNil(error as? DecodingError)
        }
    }
}

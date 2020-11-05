import ExtrasUUID
import XCTest

final class XUUIDTests: XCTestCase {
    func testInitFromStringSuccess() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = XUUID(uuidString: string)
        XCTAssertEqual(uuid?.uuidString, UUID(uuidString: string)?.uuidString)

        XCTAssertEqual(uuid?.uppercased(), string)
    }

    func testInitFromLowercaseStringSuccess() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F".lowercased()
        let uuid = XUUID(uuidString: string)
        XCTAssertEqual(uuid?.uuidString, UUID(uuidString: string)?.uuidString)

        XCTAssertEqual(uuid?.lowercased(), string)
    }

    func testInitFromNSStringSuccess() {
        let nsString = NSMutableString(capacity: 16)
        nsString.append("E621E1F8")
        nsString.append("-")
        nsString.append("C36C")
        nsString.append("-")
        nsString.append("495A")
        nsString.append("-")
        nsString.append("93FC")
        nsString.append("-")
        nsString.append("0C247A3E6E5F")

        // TODO: I would love to enforce that the nsstring is not contiguous
        //       here to enforce a special code path. I have no idea how to
        //       achieve this though at the moment
        // XCTAssertFalse((nsString as String).isContiguousUTF8)
        let uuid = XUUID(uuidString: nsString as String)
        XCTAssertEqual(uuid?.uuidString, UUID(uuidString: nsString as String)?.uuidString)

        XCTAssertEqual(uuid?.uppercased(), nsString as String)
    }

    func testInitFromStringMissingCharacterAtEnd() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5"
        let uuid = XUUID(uuidString: string)
        XCTAssertNil(uuid)
    }

    func testInitFromStringInvalidCharacterAtEnd() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5H"
        let uuid = XUUID(uuidString: string)
        XCTAssertNil(uuid)
    }

    func testInitFromStringInvalidSeparatorCharacter() {
        // illegal character: _
        XCTAssertNil(XUUID(uuidString: "E621E1F8-C36C-495A-93FC_0C247A3E6E5F"))
        XCTAssertNil(XUUID(uuidString: "E621E1F8-C36C-495A_93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID(uuidString: "E621E1F8-C36C_495A-93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID(uuidString: "E621E1F8_C36C-495A-93FC-0C247A3E6E5F"))

        // illegal character: 0
        XCTAssertNil(XUUID(uuidString: "E621E1F8-C36C-495A-93FC00C247A3E6E5F"))
        XCTAssertNil(XUUID(uuidString: "E621E1F8-C36C-495A093FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID(uuidString: "E621E1F8-C36C0495A-93FC-0C247A3E6E5F"))
        XCTAssertNil(XUUID(uuidString: "E621E1F80C36C-495A-93FC-0C247A3E6E5F"))
    }

    func testUnparse() {
        let string = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = XUUID(uuidString: string)
        XCTAssertEqual(string.lowercased(), uuid?.lowercased())
    }

    func testDescription() {
        let xuuid = XUUID()
        let fduuid = UUID(uuid: xuuid.uuid)

        XCTAssertEqual(fduuid.description, xuuid.description)
        XCTAssertEqual(fduuid.debugDescription, xuuid.debugDescription)
    }

    func testFoundationInteropFromFoundation() {
        let fduuid = UUID()
        let xuuid = XUUID(uuid: fduuid.uuid)

        XCTAssertEqual(fduuid.uuid.0, xuuid.uuid.0)
        XCTAssertEqual(fduuid.uuid.1, xuuid.uuid.1)
        XCTAssertEqual(fduuid.uuid.2, xuuid.uuid.2)
        XCTAssertEqual(fduuid.uuid.3, xuuid.uuid.3)
        XCTAssertEqual(fduuid.uuid.4, xuuid.uuid.4)
        XCTAssertEqual(fduuid.uuid.5, xuuid.uuid.5)
        XCTAssertEqual(fduuid.uuid.6, xuuid.uuid.6)
        XCTAssertEqual(fduuid.uuid.7, xuuid.uuid.7)
        XCTAssertEqual(fduuid.uuid.8, xuuid.uuid.8)
        XCTAssertEqual(fduuid.uuid.9, xuuid.uuid.9)
        XCTAssertEqual(fduuid.uuid.10, xuuid.uuid.10)
        XCTAssertEqual(fduuid.uuid.11, xuuid.uuid.11)
        XCTAssertEqual(fduuid.uuid.12, xuuid.uuid.12)
        XCTAssertEqual(fduuid.uuid.13, xuuid.uuid.13)
        XCTAssertEqual(fduuid.uuid.14, xuuid.uuid.14)
        XCTAssertEqual(fduuid.uuid.15, xuuid.uuid.15)
    }

    func testFoundationInteropToFoundation() {
        let xuuid = XUUID()
        let fduuid = UUID(uuid: xuuid.uuid)

        XCTAssertEqual(fduuid.uuid.0, xuuid.uuid.0)
        XCTAssertEqual(fduuid.uuid.1, xuuid.uuid.1)
        XCTAssertEqual(fduuid.uuid.2, xuuid.uuid.2)
        XCTAssertEqual(fduuid.uuid.3, xuuid.uuid.3)
        XCTAssertEqual(fduuid.uuid.4, xuuid.uuid.4)
        XCTAssertEqual(fduuid.uuid.5, xuuid.uuid.5)
        XCTAssertEqual(fduuid.uuid.6, xuuid.uuid.6)
        XCTAssertEqual(fduuid.uuid.7, xuuid.uuid.7)
        XCTAssertEqual(fduuid.uuid.8, xuuid.uuid.8)
        XCTAssertEqual(fduuid.uuid.9, xuuid.uuid.9)
        XCTAssertEqual(fduuid.uuid.10, xuuid.uuid.10)
        XCTAssertEqual(fduuid.uuid.11, xuuid.uuid.11)
        XCTAssertEqual(fduuid.uuid.12, xuuid.uuid.12)
        XCTAssertEqual(fduuid.uuid.13, xuuid.uuid.13)
        XCTAssertEqual(fduuid.uuid.14, xuuid.uuid.14)
        XCTAssertEqual(fduuid.uuid.15, xuuid.uuid.15)
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
        let data = #"{"uuid":"\#(uuid.uuidString)"}"#.data(using: .utf8)

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
        let data = #"{"uuid":"\#(uuidString)"}"#.data(using: .utf8)

        XCTAssertThrowsError(_ = try JSONDecoder().decode(Test.self, from: XCTUnwrap(data))) { error in
            XCTAssertNotNil(error as? DecodingError)
        }
    }

    func testStructSize() {
        XCTAssertEqual(MemoryLayout<XUUID>.size, 16)
    }
}

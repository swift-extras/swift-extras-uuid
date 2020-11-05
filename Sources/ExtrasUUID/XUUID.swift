public typealias xuuid_t = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

public struct XUUID {
    private let _uuid: xuuid_t

    public var uuid: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        _uuid
    }

    static let null: xuuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    public init() {
        self = Self.generateRandom()
    }

    public init?(uuidString string: String) {
        guard let uuid = Self.fromUUIDString(string) else {
            return nil
        }

        self = uuid
    }

    public init(uuid: xuuid_t) {
        self._uuid = uuid
    }

    public var uuidString: String {
        self.uppercased()
    }

    public func lowercased() -> String {
        self.toString(characters: Self.lowercaseLookup)
    }

    public func uppercased() -> String {
        self.toString(characters: Self.uppercaseLookup)
    }
}

// MARK: - Protocol extensions -

extension XUUID: Hashable {
    public func hash(into hasher: inout Hasher) {
        var value = self._uuid
        withUnsafeBytes(of: &value) { ptr in
            hasher.combine(bytes: ptr)
        }
    }
}

extension XUUID: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._uuid.0 == rhs._uuid.0 &&
            lhs._uuid.1 == rhs._uuid.1 &&
            lhs._uuid.2 == rhs._uuid.2 &&
            lhs._uuid.3 == rhs._uuid.3 &&
            lhs._uuid.4 == rhs._uuid.4 &&
            lhs._uuid.5 == rhs._uuid.5 &&
            lhs._uuid.6 == rhs._uuid.6 &&
            lhs._uuid.7 == rhs._uuid.7 &&
            lhs._uuid.8 == rhs._uuid.8 &&
            lhs._uuid.9 == rhs._uuid.9 &&
            lhs._uuid.10 == rhs._uuid.10 &&
            lhs._uuid.11 == rhs._uuid.11 &&
            lhs._uuid.12 == rhs._uuid.12 &&
            lhs._uuid.13 == rhs._uuid.13 &&
            lhs._uuid.14 == rhs._uuid.14 &&
            lhs._uuid.15 == rhs._uuid.15
    }
}

extension XUUID: CustomStringConvertible {
    public var description: String {
        self.uuidString
    }
}

extension XUUID: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.uuidString
    }
}

extension XUUID: CustomReflectable {
    public var customMirror: Mirror {
        let children = [(label: String?, value: Any)]()
        return Mirror(self, children: children, displayStyle: .struct)
    }
}

extension XUUID: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let uuidString = try container.decode(String.self)

        guard let uuid = XUUID(uuidString: uuidString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Attempted to decode UUID from invalid UUID string.")
        }

        self = uuid
    }
}

extension XUUID: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.uuidString)
    }
}

// MARK: - SIMD -

public extension XUUID {
    init(vector: SIMD16<UInt8>) {
        self._uuid = (vector[0], vector[1], vector[2], vector[3],
                      vector[4], vector[5], vector[6], vector[7],
                      vector[8], vector[9], vector[10], vector[11],
                      vector[12], vector[13], vector[14], vector[15])
    }

    var vector: SIMD16<UInt8> {
        SIMD16(self._uuid.0, self._uuid.1, self._uuid.2, self._uuid.3,
               self._uuid.4, self._uuid.5, self._uuid.6, self._uuid.7,
               self._uuid.8, self._uuid.9, self._uuid.10, self._uuid.11,
               self._uuid.12, self._uuid.13, self._uuid.14, self._uuid.15)
    }

    static func fromUUIDStringUsingSIMD(_ string: String) -> XUUID? {
        guard string.utf8.count == 36 else {
            // invalid length
            return nil
        }

        guard let values = string.utf8.withContiguousStorageIfAvailable({ (ptr) -> SIMD32<UInt8>? in
            guard ptr[8] == UInt8(ascii: "-"), ptr[13] == UInt8(ascii: "-"), ptr[18] == UInt8(ascii: "-"), ptr[23] == UInt8(ascii: "-") else {
                return nil
            }

            return SIMD32<UInt8>(UInt8(ptr[0]), UInt8(ptr[1]), UInt8(ptr[2]), UInt8(ptr[3]),
                                 UInt8(ptr[4]), UInt8(ptr[5]), UInt8(ptr[6]), UInt8(ptr[7]), // dash
                                 UInt8(ptr[9]), UInt8(ptr[10]), UInt8(ptr[11]), UInt8(ptr[12]), // dash
                                 UInt8(ptr[14]), UInt8(ptr[15]), UInt8(ptr[16]), UInt8(ptr[17]), // dash
                                 UInt8(ptr[19]), UInt8(ptr[20]), UInt8(ptr[21]), UInt8(ptr[22]), // dash
                                 UInt8(ptr[24]), UInt8(ptr[25]), UInt8(ptr[26]), UInt8(ptr[27]),
                                 UInt8(ptr[28]), UInt8(ptr[29]), UInt8(ptr[30]), UInt8(ptr[31]),
                                 UInt8(ptr[32]), UInt8(ptr[33]), UInt8(ptr[34]), UInt8(ptr[35]))
        }) else {
            var string = string
            string.makeContiguousUTF8()
            return self.fromUUIDStringUsingSIMD(string)
        }

        guard var vector = values else {
            return nil
        }

        let maskGreaterThanZero = vector .>= UInt8(ascii: "0")
        let maskSmallerThanNine = vector .<= UInt8(ascii: "9")
        let asciiNumber = maskGreaterThanZero .& maskSmallerThanNine

        let maskGreaterThanSmallA = vector .>= UInt8(ascii: "a")
        let maskSmallerThanSmallF = vector .<= UInt8(ascii: "f")
        let smallCharacter = maskGreaterThanSmallA .& maskSmallerThanSmallF

        let maskGreaterThanCapitalA = vector .>= UInt8(ascii: "A")
        let maskSmallerThanCapitalF = vector .<= UInt8(ascii: "F")
        let capitalCharacter = maskGreaterThanCapitalA .& maskSmallerThanCapitalF

        var subtractNumber = SIMD32<UInt8>.zero
        subtractNumber.replace(with: UInt8(ascii: "0"), where: asciiNumber)

        var subtractLowercaseChar = SIMD32<UInt8>.zero
        subtractLowercaseChar.replace(with: UInt8(ascii: "a") - 10, where: smallCharacter)

        var subtractUppercaseChar = SIMD32<UInt8>.zero
        subtractUppercaseChar.replace(with: UInt8(ascii: "A") - 10, where: capitalCharacter)

        vector &-= subtractNumber
        vector &-= subtractLowercaseChar
        vector &-= subtractUppercaseChar

        let xor = asciiNumber .^ (smallCharacter .^ capitalCharacter)
        guard all(xor) else { return nil }

        vector.evenHalf &<<= 4
        vector.evenHalf &+= vector.oddHalf

        let _uuid = (vector[0], vector[2], vector[4], vector[6],
                     vector[8], vector[10], vector[12], vector[14],
                     vector[16], vector[18], vector[20], vector[22],
                     vector[24], vector[26], vector[28], vector[30])

        return Self(uuid: _uuid)
    }
}

// MARK: - Implementation details -

extension XUUID {
    /// thread safe secure random number generator.
    private static var generator = SystemRandomNumberGenerator()
    static func generateRandom() -> XUUID {
        var _uuid: xuuid_t = Self.null
        // https://tools.ietf.org/html/rfc4122#page-14

        // o  Set all the other bits to randomly (or pseudo-randomly) chosen
        //    values.
        withUnsafeMutableBytes(of: &_uuid) { ptr in
            ptr.storeBytes(of: Self.generator.next(), toByteOffset: 0, as: UInt64.self)
            ptr.storeBytes(of: Self.generator.next(), toByteOffset: 8, as: UInt64.self)
        }

        // o  Set the four most significant bits (bits 12 through 15) of the
        //    time_hi_and_version field to the 4-bit version number from
        //    Section 4.1.3.
        _uuid.6 = (_uuid.6 & 0x0F) | 0x40

        // o  Set the two most significant bits (bits 6 and 7) of the
        //    clock_seq_hi_and_reserved to zero and one, respectively.
        _uuid.8 = (_uuid.8 & 0x3F) | 0x80
        return XUUID(uuid: _uuid)
    }

    static func fromUUIDString(_ string: String) -> XUUID? {
        guard string.utf8.count == 36 else {
            // invalid length
            return nil
        }

        let _uuid = string.utf8.withContiguousStorageIfAvailable { (ptr) -> xuuid_t? in
            var uuid = Self.null

            let success = withUnsafeMutableBytes(of: &uuid) { (uuid) -> (Bool) in
                func newIndex(index: Int) -> (Int, Bool) {
                    var index = index
                    switch index {
                    case 0 ..< 8:
                        break
                    case 9 ..< 13:
                        index -= 1
                    case 14 ..< 18:
                        index -= 2
                    case 19 ..< 23:
                        index -= 3
                    case 24 ..< 36:
                        index -= 4
                    default:
                        preconditionFailure()
                    }

                    return (index / 2, index % 2 == 0)
                }

                loop: for index in 0 ... 35 {
                    let value = ptr[index]

                    switch (index, value) {
                    case (8, UInt8(ascii: "-")), (13, UInt8(ascii: "-")), (18, UInt8(ascii: "-")), (23, UInt8(ascii: "-")):
                        continue loop
                    case (8, _), (13, _), (18, _), (23, _):
                        // invalid syntax
                        return false
                    case (_, UInt8(ascii: "0") ... UInt8(ascii: "9")):
                        var v = value - UInt8(ascii: "0")
                        let (nIndex, shift) = newIndex(index: index)
                        if shift {
                            v = v << 4
                        }
                        uuid[nIndex] += v
                    case (_, UInt8(ascii: "a") ... UInt8(ascii: "f")):
                        var v = value - UInt8(ascii: "a") + 10
                        let (nIndex, shift) = newIndex(index: index)
                        if shift {
                            v = v << 4
                        }
                        uuid[nIndex] += v
                    case (_, UInt8(ascii: "A") ... UInt8(ascii: "F")):
                        var v = value - UInt8(ascii: "A") + 10
                        let (nIndex, shift) = newIndex(index: index)
                        if shift {
                            v = v << 4
                        }
                        uuid[nIndex] += v
                    default:
                        return false
                    }
                }
                return true
            }

            return success ? uuid : nil
        }

        guard let u = _uuid, let uuid = u else {
            return nil
        }

        return .init(uuid: uuid)
    }

    private static let lowercaseLookup: [UInt8] = [
        UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"),
        UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "7"),
        UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "a"), UInt8(ascii: "b"),
        UInt8(ascii: "c"), UInt8(ascii: "d"), UInt8(ascii: "e"), UInt8(ascii: "f"),
    ]

    private static let uppercaseLookup: [UInt8] = [
        UInt8(ascii: "0"), UInt8(ascii: "1"), UInt8(ascii: "2"), UInt8(ascii: "3"),
        UInt8(ascii: "4"), UInt8(ascii: "5"), UInt8(ascii: "6"), UInt8(ascii: "7"),
        UInt8(ascii: "8"), UInt8(ascii: "9"), UInt8(ascii: "A"), UInt8(ascii: "B"),
        UInt8(ascii: "C"), UInt8(ascii: "D"), UInt8(ascii: "E"), UInt8(ascii: "F"),
    ]

    /// Use this type to create the backing store of a UUID String on stack.
    ///
    /// Using this type we ensure to only have one allocation for creating a String
    /// even before Swift 5.3
    private typealias xuuid_string_t = (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )

    private static let nullString: xuuid_string_t = (
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    )

    func toString(characters: [UInt8]) -> String {
        var string: xuuid_string_t = Self.nullString
        // to get the best performance we access the lookup table's unsafe buffer pointer
        // since the lookup table has 16 elements and we shift the byte values in such a way
        // that the max value is 15 (last 4 bytes = 16 values). For this reason the lookups
        // are safe and we don't need Swifts safety guards.
        return characters.withUnsafeBufferPointer { (lookup) -> String in
            withUnsafeMutableBytes(of: &string) { (ptr) -> String in
                ptr[0] = lookup[Int(uuid.0 >> 4)]
                ptr[1] = lookup[Int(uuid.0 & 0x0F)]
                ptr[2] = lookup[Int(uuid.1 >> 4)]
                ptr[3] = lookup[Int(uuid.1 & 0x0F)]
                ptr[4] = lookup[Int(uuid.2 >> 4)]
                ptr[5] = lookup[Int(uuid.2 & 0x0F)]
                ptr[6] = lookup[Int(uuid.3 >> 4)]
                ptr[7] = lookup[Int(uuid.3 & 0x0F)]
                ptr[8] = UInt8(ascii: "-")
                ptr[9] = lookup[Int(uuid.4 >> 4)]
                ptr[10] = lookup[Int(uuid.4 & 0x0F)]
                ptr[11] = lookup[Int(uuid.5 >> 4)]
                ptr[12] = lookup[Int(uuid.5 & 0x0F)]
                ptr[13] = UInt8(ascii: "-")
                ptr[14] = lookup[Int(uuid.6 >> 4)]
                ptr[15] = lookup[Int(uuid.6 & 0x0F)]
                ptr[16] = lookup[Int(uuid.7 >> 4)]
                ptr[17] = lookup[Int(uuid.7 & 0x0F)]
                ptr[18] = UInt8(ascii: "-")
                ptr[19] = lookup[Int(uuid.8 >> 4)]
                ptr[20] = lookup[Int(uuid.8 & 0x0F)]
                ptr[21] = lookup[Int(uuid.9 >> 4)]
                ptr[22] = lookup[Int(uuid.9 & 0x0F)]
                ptr[23] = UInt8(ascii: "-")
                ptr[24] = lookup[Int(uuid.10 >> 4)]
                ptr[25] = lookup[Int(uuid.10 & 0x0F)]
                ptr[26] = lookup[Int(uuid.11 >> 4)]
                ptr[27] = lookup[Int(uuid.11 & 0x0F)]
                ptr[28] = lookup[Int(uuid.12 >> 4)]
                ptr[29] = lookup[Int(uuid.12 & 0x0F)]
                ptr[30] = lookup[Int(uuid.13 >> 4)]
                ptr[31] = lookup[Int(uuid.13 & 0x0F)]
                ptr[32] = lookup[Int(uuid.14 >> 4)]
                ptr[33] = lookup[Int(uuid.14 & 0x0F)]
                ptr[34] = lookup[Int(uuid.15 >> 4)]
                ptr[35] = lookup[Int(uuid.15 & 0x0F)]

                return String(decoding: ptr, as: Unicode.UTF8.self)
            }
        }
    }
}

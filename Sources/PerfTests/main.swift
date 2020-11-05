import ExtrasUUID
import Foundation
#if canImport(Darwin)
import Darwin.C
#endif

let runs = 1_000_000

@discardableResult
func timing(name: String, execute: () throws -> Void) rethrows -> TimeInterval {
    let start = Date()
    try execute()
    let time = -start.timeIntervalSinceNow
    print("\(name) | took: \(String(format: "%.5f", time))s")
    return time
}

print("------------------------------------------")
print("Creating UUIDs: \(runs)")

let psCreate = timing(name: "Random Generator") {
    var result = [XUUID]()
    result.reserveCapacity(runs)
    for _ in 0 ..< runs {
        result.append(XUUID())
    }
}

let foundationCreate = timing(name: "Foundation      ") {
    var result = [UUID]()
    result.reserveCapacity(runs)
    for _ in 0 ..< runs {
        result.append(UUID())
    }
}

let strings = (0 ..< runs).map { _ in UUID().uuidString }

print("------------------------------------------")
print("Parsing UUIDs: \(runs)")

#if canImport(Darwin)
let uuidParse = timing(name: "uuid_parse      ") {
    let uuids = strings.compactMap { XUUID.fromUUIDStringUsingUUIDParse($0) }
    precondition(uuids.count == strings.count, "expected to parse all")
}
#endif

var xuuids = [XUUID]()
let loopParse = timing(name: "ExtrasUUID      ") {
    xuuids = strings.compactMap { XUUID(uuidString: $0) }
    precondition(xuuids.count == strings.count, "expected to parse all")
}

let simdParse = timing(name: "ExtrasUUID SIMD ") {
    let uuids = strings.compactMap { XUUID.fromUUIDStringUsingSIMD($0) }
    precondition(uuids.count == strings.count, "expected to parse all")
}

var fduuids = [UUID]()
let foundationParse = timing(name: "Foundation      ") {
    fduuids = strings.compactMap { UUID(uuidString: $0) }
    precondition(fduuids.count == strings.count, "expected to parse all")
}

print("------------------------------------------")
print("Create UUID Strings: \(runs)")

#if canImport(Darwin)
let uuidUnparse = timing(name: "uuid_unparse    ") {
    let strings = xuuids.compactMap { $0.lowercasedUsingUUID() }
    precondition(strings.count == xuuids.count, "expected to unparse all")
}
#endif

let simpleUnparse = timing(name: "ExtrasUUID      ") {
    let strings = xuuids.compactMap { $0.lowercased() }
    precondition(strings.count == xuuids.count, "expected to unparse all")
}

let foundationUnparse = timing(name: "Foundation      ") {
    let strings = fduuids.compactMap { $0.uuidString }
    precondition(strings.count == fduuids.count, "expected to unparse all")
}

print("------------------------------------------")
print("Compare UUIDs: \(runs)")

let xuuidslice = xuuids[0 ..< 10000]

let xuuidCompare = timing(name: "UUIDKit         ") {
    xuuidslice.forEach { uuid in
        let first = xuuidslice.first { $0 == uuid }
        precondition(first != nil, "expected to find something")
    }
}

let fduuidslice = fduuids[0 ..< 10000]
let foundationCompare = timing(name: "Foundation      ") {
    fduuidslice.forEach { uuid in
        let first = fduuidslice.first { $0 == uuid }
        precondition(first != nil, "expected to find something")
    }
}

// MARK: Other implementation to compare performance against

#if canImport(Darwin)
extension XUUID {
    public static func fromUUIDStringUsingUUIDParse(_ string: String) -> XUUID? {
        // This is the base implementation... I guess this is what is done for
        // Foundation.UUID
        let _uuid = string.withCString { (cString) -> uuid_t? in
            var _uuid: xuuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            guard uuid_parse(cString, &_uuid.0) == 0 else {
                return nil
            }

            return _uuid
        }

        guard let uuid = _uuid else {
            return nil
        }

        return Self(uuid: uuid)
    }

    public func lowercasedUsingUUID() -> String {
        var value: xuuid_t = self.uuid
        let target = UnsafeMutablePointer<Int8>.allocate(capacity: 37)
        uuid_unparse_lower(&value.0, target)
        return String(cString: target)
    }
}
#endif

extension XUUID {
    
    public static func fromUUIDStringUsingSIMD(_ string: String) -> XUUID? {
        guard string.utf8.count == 36 else {
            // invalid length
            return nil
        }

        var values = string.utf8.withContiguousStorageIfAvailable { (ptr) -> SIMD32<UInt8> in
            SIMD32<UInt8>(UInt8(ptr[0]), UInt8(ptr[1]), UInt8(ptr[2]), UInt8(ptr[3]),
                          UInt8(ptr[4]), UInt8(ptr[5]), UInt8(ptr[6]), UInt8(ptr[7]), // dash
                          UInt8(ptr[9]), UInt8(ptr[10]), UInt8(ptr[11]), UInt8(ptr[12]), // dash
                          UInt8(ptr[14]), UInt8(ptr[15]), UInt8(ptr[16]), UInt8(ptr[17]), // dash
                          UInt8(ptr[19]), UInt8(ptr[20]), UInt8(ptr[21]), UInt8(ptr[22]), // dash
                          UInt8(ptr[24]), UInt8(ptr[25]), UInt8(ptr[26]), UInt8(ptr[27]),
                          UInt8(ptr[28]), UInt8(ptr[29]), UInt8(ptr[30]), UInt8(ptr[31]),
                          UInt8(ptr[32]), UInt8(ptr[33]), UInt8(ptr[34]), UInt8(ptr[35]))
        }!

        let maskGreaterThanZero = values .>= UInt8(ascii: "0")
        let maskSmallerThanNine = values .<= UInt8(ascii: "9")
        let asciiNumber = maskGreaterThanZero .& maskSmallerThanNine

        let maskGreaterThanSmallA = values .>= UInt8(ascii: "a")
        let maskSmallerThanSmallF = values .<= UInt8(ascii: "f")
        let smallCharacter = maskGreaterThanSmallA .& maskSmallerThanSmallF

        let maskGreaterThanCapitalA = values .>= UInt8(ascii: "A")
        let maskSmallerThanCapitalF = values .<= UInt8(ascii: "F")
        let capitalCharacter = maskGreaterThanCapitalA .& maskSmallerThanCapitalF

        var subtractNumber = SIMD32<UInt8>.zero
        subtractNumber.replace(with: UInt8(ascii: "0"), where: asciiNumber)

        var subtractLowercaseChar = SIMD32<UInt8>.zero
        subtractLowercaseChar.replace(with: UInt8(ascii: "a") - 10, where: smallCharacter)

        var subtractUppercaseChar = SIMD32<UInt8>.zero
        subtractUppercaseChar.replace(with: UInt8(ascii: "A") - 10, where: capitalCharacter)

        values &-= subtractNumber
        values &-= subtractLowercaseChar
        values &-= subtractUppercaseChar

        let xor = asciiNumber .^ (smallCharacter .^ capitalCharacter)
        guard all(xor) else { return nil }

        values.evenHalf &<<= 4
        values.evenHalf &+= values.oddHalf

        let _uuid = (values[0], values[2], values[4], values[6],
                     values[8], values[10], values[12], values[14],
                     values[16], values[18], values[20], values[22],
                     values[24], values[26], values[28], values[30])

        return Self(uuid: _uuid)
    }

    
}

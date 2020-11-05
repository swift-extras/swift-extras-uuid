import ExtrasUUID
import Foundation

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
    let strings = xuuids.compactMap { $0.lowercased }
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

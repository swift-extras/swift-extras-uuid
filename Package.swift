// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-extras-uuid",
    products: [
        .library(name: "ExtrasUUID", targets: ["ExtrasUUID"]),
    ],
    targets: [
        .target(name: "PerfTests", dependencies: ["ExtrasUUID"]),
        .target(name: "ExtrasUUID", dependencies: []),
        .testTarget(name: "ExtrasUUIDTests", dependencies: ["ExtrasUUID"]),
    ]
)

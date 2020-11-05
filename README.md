# swift-extras-uuid

A reimplementation of UUID in Swift without the use of Foundation or any other dependency. 

[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-blue.svg)](https://swift.org/download/)
[![github-actions](https://github.com/fabianfett/swift-extras-uuid/workflows/CI/badge.svg)](https://github.com/fabianfett/swift-extras-uuid/actions)
[![codecov](https://codecov.io/gh/fabianfett/swift-extras-uuid/branch/main/graph/badge.svg)](https://codecov.io/gh/fabianfett/swift-extras-uuid)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)

### Motivation

Foundation on non Darwin platforms (Linux, Windows) has often worse performance and/or missing features compared to its Darwin counterpart. That's why I like to limit the use of Foundation classes and structs to the absolute minimum when writing server side or cross platform Swift code. This package offers the same UUID functionality that Foundation provides, without actually using Foundation. The performance is slightly better on Linux compared to the Foundation implementation and comparable on macOS. 

### How to use it?

Add dependency to your `Package.swift`.

```swift
  dependencies: [
    .package(url: "https://github.com/fabianfett/swift-extras-uuid.git", .upToNextMajor(from: "0.1.0")),
  ],
```

Add `ExtrasUUID` to the target you want to use it in.

```swift
  targets: [
    .target(name: "MyFancyTarget", dependencies: [
      .product(name: "ExtrasUUID", package: "swift-extras-uuid"),
    ])
  ]
```

Import the library and use it. This package's UUID is prefixed with an X to avoid naming conflicts in cases where you import Foundation in the same file.

```swift
import ExtrasUUID

let uuid = XUUID()
```

### Interop with Foundation

You can easily convert between a Foundation UUID and an swift-extras XUUID.

From Foundation:

```swift
let fduuid = UUID() 
let xuuid = XUUID(uuid: fduuid.uuid)
```

To Foundation:
```swift
let xuuid = XUUID() 
let fduuid = UUID(uuid: xuuid.uuid)
```

### Performance

To run simple performance tests, check out this repository and run:

```
swift run -c release --enable-test-discovery
```

The performance tests will 

- create 1m uuids
- parse 1m uuids 
- create 1m uuid strings
- compare 10k uuids

#### Linux - Swift 5.3

|  | Creating Random | Parsing | Stringify | Comparing |
|:--|:--|:--|:--|:--|
| Foundation   | 3.94s | 1.01s | 0.8s | 0.16s |
| ExtrasUUID | 2.06s | 0.34s | 0.16s | 0.13s |
| Speedup | ~2x | ~3x | ~5x | ~1x |


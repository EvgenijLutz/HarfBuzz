# HarfBuzz

A cross-platform [HarfBuzz](https://github.com/harfbuzz/harfbuzz) wrapper for Apple platforms, distributed as a Swift Package with C and C++ interop, [FreeType](https://github.com/freetype/freetype) and [libpng](https://github.com/pnggroup/libpng) support, and XCFramework binary integration.

Supports **iOS**, **macOS**, **tvOS**, **watchOS**, **visionOS** - device and simulator - all in one neat package.

## Features

- Built from official HarfBuzz source with `minsize` and `-O2` optimizations
- Linked FreeType (optional via `freetype=enabled`)
- C and C++ headers available to Swift
- Minimal binary size (≈2.2 MB per platform)
- Delivered as `.xcframework` via Swift Package Manager

## Installation

Add the following to your `Package.swift` dependency:

```swift
.package(url: "https://github.com/EvgenijLutz/HarfBuzz", from: "11.4.5")
```

Then add HarfBuzz as a dependency in your target:

```swift
.target(
  name: "YourApp",
  dependencies: [
    .product(name: "HarfBuzz", package: "HarfBuzz")
  ]
)
```

Or use **Xcode > Add Package Dependency**.

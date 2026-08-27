# HarfBuzz

A cross-platform [HarfBuzz](https://github.com/harfbuzz/harfbuzz) wrapper for Apple platforms, distributed as a Swift Package with C and C++ interop and [libpng](https://github.com/pnggroup/libpng) support, and XCFramework binary integration.

Supports **iOS**, **macOS**, **tvOS**, **watchOS**, **visionOS** - device and simulator - all in one neat package.


## Features

- Built from official HarfBuzz source with `minsize` and `-O2` optimizations
- Linked [FreeType](https://freetype.org/index.html) (optional via `freetype=enabled`)
- Linked [libpng](https://github.com/pnggroup/libpng) (optional via `png=enabled`)
- Included the `subset` library
- Included the experimental `raster` library
- Included the experimental `vector` library
- Included the experimental `gpu` library (optional via `gpu=enabled`)
- C and C++ headers available to Swift
- Minimal binary size (≈2.3 MB for the core harfbuzz library per platform)
- Delivered as `.xcframework` via Swift Package Manager


## Installation

Add the following to your `Package.swift` dependency:

```swift
.package(url: "https://github.com/EvgenijLutz/HarfBuzz", from: "14.4.0")
```

Then add one of HarfBuzz dependencies in your target:

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "HarfBuzz", package: "HarfBuzz"),
    .product(name: "HarfBuzzGPU", package: "HarfBuzz"),
    .product(name: "HarfBuzzRaster", package: "HarfBuzz"),
    .product(name: "HarfBuzzSubset", package: "HarfBuzz"),
    .product(name: "HarfBuzzVector", package: "HarfBuzz"),
    .product(name: "HarfBuzzFreeType", package: "HarfBuzz"),
  ]
)
```

Or use **Xcode > Add Package Dependency**.

Voilà, you're good to go!


## Package products

The package exposes seven products that are accessible from C, C++ and Swift.


### HarfBuzz

Links against the core `harfbuzz` library.


### HarfBuzzGPU

Links against the `harfbuzz-gpu` library. Has a dependency to the `HarfBuzz` package product.


### HarfBuzzRaster

Links against the `harfbuzz-raster` library. Has a dependency to the `HarfBuzz` package product and `png` library.


### HarfBuzzSubset

Links against the `harfbuzz-subset` library. Has a dependency to the `HarfBuzz` package product.


### HarfBuzzVector

Links against the `harfbuzz-raster` library. Has a dependency to the `HarfBuzz` package product, `z` and `bz2` library (both included in all Apple platforms).


### HarfBuzzFreeType

Links against the core `harfbuzz` [FreeType](https://github.com/EvgenijLutz/FreeType) libraries.

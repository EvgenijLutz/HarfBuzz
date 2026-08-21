// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HarfBuzz",
    platforms: [
        .macOS(.v11),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "HarfBuzz", targets: ["HarfBuzz"]),
        .library(name: "HarfBuzzGPU", targets: ["HarfBuzzGPU"]),
        .library(name: "HarfBuzzRaster", targets: ["HarfBuzzRaster"]),
        .library(name: "HarfBuzzSubset", targets: ["HarfBuzzSubset"]),
        .library(name: "HarfBuzzVector", targets: ["HarfBuzzVector"]),
    ],
    dependencies: {
#if true
        [
            .package(url: "https://github.com/EvgenijLutz/LibPNG.git", from: "1.6.58-rev1"),
        ]
#else
        [
            .package(name: "LibPNG", path: "../LibPNG"),
        ]
#endif
    }(),
    targets: [
        .binaryTarget(name: "libharfbuzz", path: "Binaries/libharfbuzz.xcframework"),
        .binaryTarget(name: "libharfbuzz-gpu", path: "Binaries/libharfbuzz-gpu.xcframework"),
        .binaryTarget(name: "libharfbuzz-raster", path: "Binaries/libharfbuzz-raster.xcframework"),
        .binaryTarget(name: "libharfbuzz-subset", path: "Binaries/libharfbuzz-subset.xcframework"),
        .binaryTarget(name: "libharfbuzz-vector", path: "Binaries/libharfbuzz-vector.xcframework"),
        .target(
            name: "HarfBuzz",
            dependencies: [
                .target(name: "libharfbuzz"),
            ],
            cSettings: [ .enableWarning("all") ]
        ),
        .target(
            name: "HarfBuzzGPU",
            dependencies: [
                .target(name: "HarfBuzz"),
                .target(name: "libharfbuzz-gpu"),
            ],
            cSettings: [ .enableWarning("all") ]
        ),
        .target(
            name: "HarfBuzzRaster",
            dependencies: [
                .product(name: "LibPNGC", package: "LibPNG"),
                .target(name: "HarfBuzz"),
                .target(name: "libharfbuzz-raster"),
            ],
            cSettings: [ .enableWarning("all") ]
        ),
        .target(
            name: "HarfBuzzSubset",
            dependencies: [
                .target(name: "HarfBuzz"),
                .target(name: "libharfbuzz-subset"),
            ],
            cSettings: [ .enableWarning("all") ]
        ),
        .target(
            name: "HarfBuzzVector",
            dependencies: [
                .target(name: "HarfBuzz"),
                .target(name: "libharfbuzz-vector"),
            ],
            cSettings: [
                .enableWarning("all")
            ],
            linkerSettings: [
                // Links libz.tbd that comes with all Apple and Android systems
                .linkedLibrary("z"),
                // Links libbz2.tbd that comes with all Apple systems, but not Android :(
                .linkedLibrary("bz2", .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS]))
            ]
        ),
        .target(
            name: "HarfBuzzC",
            dependencies: [
                .target(name: "libharfbuzz"),
                .product(name: "LibPNGC", package: "LibPNG")
            ],
            cSettings: [ .enableWarning("all") ]
        ),
    ],
    // The HarfBuzz library was compiled using c17, so set it also here
    cLanguageStandard: .c17,
    // Also use c++20, we don't live in the stone age, but still not ready to accept c++23
    cxxLanguageStandard: .cxx20
)

// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HarfBuzz",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "HarfBuzz",
            targets: ["HarfBuzz"]
        ),
        .library(
            name: "HarfBuzzC",
            targets: ["HarfBuzzC"]
        ),
        .library(
            name: "libharfbuzz",
            targets: ["libharfbuzz"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/EvgenijLutz/FreeType.git", exact: "2.13.3-alpha5"),
    ],
    targets: [
        .binaryTarget(
            name: "libharfbuzz",
            path: "Binaries/libharfbuzz.xcframework"
        ),
        .target(
            name: "HarfBuzzC",
            dependencies: [
                .product(name: "FreeTypeC", package: "FreeType"),
                .target(name: "libharfbuzz")
            ]
        ),
        .target(
            name: "HarfBuzz",
            dependencies: [
                .product(name: "FreeType", package: "FreeType"),
                .target(name: "HarfBuzzC")
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
    ],
    // The lcms2 library was compiled using c17, so set it also here
    cLanguageStandard: .c17,
    // Also use c++20, we don't live in the stone age, but still not ready to accept c++23
    cxxLanguageStandard: .cxx20
)

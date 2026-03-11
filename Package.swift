// swift-tools-version: 6.2
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
        {
#if true
            .package(url: "https://github.com/EvgenijLutz/FreeType.git", from: "2.14.2")
#else
            .package(name: "FreeType", path: "../FreeType")
#endif
        }()
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
            ],
            cSettings: [
                .enableWarning("all")
            ],
            cxxSettings: [
                .enableWarning("all")
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

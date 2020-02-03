// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Maaku",
    products: [
        .library(
            name: "Maaku",
            targets: ["Maaku"]),
    ],
    dependencies: [
        .package(url: "https://github.com/KristopherGBaker/libcmark_gfm.git", from: "0.29.3"),
    ],
    targets: [
        .target(
            name: "Maaku",
            dependencies: ["libcmark_gfm"])
    ],
    swiftLanguageVersions: [.v5]
)

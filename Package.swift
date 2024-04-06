// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Maaku",
    products: [
        .library(
            name: "Maaku",
            targets: ["Maaku"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-cmark.git", branch: "gfm")
    ],
    targets: [
        .target(
            name: "Maaku",
            dependencies: [
              .product(name: "cmark-gfm", package: "swift-cmark"),
              .product(name: "cmark-gfm-extensions", package: "swift-cmark")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)

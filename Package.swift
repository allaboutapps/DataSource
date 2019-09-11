// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DataSource",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "DataSource", targets: ["DataSource"])
    ],
    dependencies: [
        .package(url: "https://github.com/tonyarnold/Differ.git", from: "1.4.3")
    ],
    targets: [
        .target(name: "DataSource", dependencies: ["Differ"], path: "DataSource/DataSource")
    ],
    swiftLanguageVersions: [.v5]
)

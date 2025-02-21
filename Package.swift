// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CardStock",
    platforms: [
        .macOS(.v15), .iOS(.v18),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CardStock",
            targets: ["CardStock"]),
    ],
    dependencies: [
        .package(path: "/Users/jason/dev/ThirdParty/AEXML"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CardStock",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "AEXML", package: "AEXML"),
            ],
            resources: [
                .process("Resources/Media.xcassets"),
                .process("Resources/Icons.xcassets"),
            ]
        ),
        .testTarget(
            name: "CardStockTests",
            dependencies: [
                "CardStock",
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),
    ]
)

import Foundation
func localDependency(_ name: String) -> String {
    FileManager.default
        .homeDirectoryForCurrentUser
        .appending(components: "dev", "packages", name)
        .path
}

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CardStock",
    platforms: [
        .macOS(.v14), .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CardStock",
            targets: ["CardStock"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CardStock",
            dependencies: [
//                .product(name: "Stencil", package: "stencil"),
            ]
        ),
        .testTarget(
            name: "CardStockTests",
            dependencies: ["CardStock"]
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

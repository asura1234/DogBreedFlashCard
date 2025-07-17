// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GamePackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "GamePackage",
            targets: ["GamePackage"]
        )
    ],
    dependencies: [
        .package(path: "../ModelsPackage"),
        .package(path: "../ServicesPackage"),
    ],
    targets: [
        .target(
            name: "GamePackage",
            dependencies: [
                "ModelsPackage",
                "ServicesPackage",
            ]
        ),
        .testTarget(
            name: "GamePackageTests",
            dependencies: ["GamePackage"]
        ),
    ]
)

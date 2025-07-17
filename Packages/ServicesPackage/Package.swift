// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ServicesPackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ServicesPackage",
            targets: ["ServicesPackage"]
        )
    ],
    dependencies: [
        .package(path: "../ModelsPackage")
    ],
    targets: [
        .target(
            name: "ServicesPackage",
            dependencies: ["ModelsPackage"]
        ),
        .testTarget(
            name: "ServicesPackageTests",
            dependencies: ["ServicesPackage"]
        )
    ]
)

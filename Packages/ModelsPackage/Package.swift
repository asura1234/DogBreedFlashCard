// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ModelsPackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ModelsPackage",
            targets: ["ModelsPackage"]
        )
    ],
    targets: [
        .target(
            name: "ModelsPackage",
            dependencies: []
        ),
        .testTarget(
            name: "ModelsPackageTests",
            dependencies: ["ModelsPackage"]
        )
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "liquid_glass_container",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "liquid-glass-container", targets: ["liquid_glass_container"])
    ],
    dependencies: [
        .package(name: "FlutterMacOSFramework", path: "../FlutterMacOSFramework")
    ],
    targets: [
        .target(
            name: "liquid_glass_container",
            dependencies: [
                .product(name: "FlutterMacOSFramework", package: "FlutterMacOSFramework")
            ]
        )
    ]
)

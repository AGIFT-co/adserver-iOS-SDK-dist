// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AdServerSDK",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "AdServerSDK", targets: ["AdServerSDK"])
    ],
    targets: [
        .binaryTarget(
            name: "AdServerSDK",
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.2-rc.4/AdServerSDK.xcframework.zip",
            checksum: "2fcc6adb67bc3c86a1b9871413df6a0315a05d4d5a8a3ab566e6f496a5c0df11"
        )
    ]
)

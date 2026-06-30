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
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.2-rc.1/AdServerSDK.xcframework.zip",
            checksum: "b925b7b724d67220c290bc63729569877176bcf194ea323b97c422908cbc0856"
        )
    ]
)

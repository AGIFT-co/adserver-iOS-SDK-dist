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
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.2/AdServerSDK.xcframework.zip",
            checksum: "6e9fa6a4dc5e813e6bb8304c7e9f716918900bfbb0b8e25926a5c85849d0f9ab"
        )
    ]
)

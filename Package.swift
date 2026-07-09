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
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.3/AdServerSDK.xcframework.zip",
            checksum: "01c6934be4daaf01ed108b021ef03008321712240ffd9a087a02bb51db3bb9a5"
        )
    ]
)

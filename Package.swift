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
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.2-rc.3/AdServerSDK.xcframework.zip",
            checksum: "a99fa6a8e8e112ec68080007af0707add7bb42afabc8cce457a5055c31ce658b"
        )
    ]
)

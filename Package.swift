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
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.2-rc.2/AdServerSDK.xcframework.zip",
            checksum: "cbe0c52228ada0faceab3c4b104e2c0d2b07dc62d72eaf47a24a650d560a09f2"
        )
    ]
)

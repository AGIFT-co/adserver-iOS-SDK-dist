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
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.4/AdServerSDK.xcframework.zip",
            checksum: "9ca377a53eaac75ef9f5fe2a2695cfda5104df9a1691ce7b330ddd1b9c65e012"
        )
    ]
)

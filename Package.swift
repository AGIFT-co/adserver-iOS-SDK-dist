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
            url: "https://github.com/AGIFT-co/adserver-iOS-SDK-dist/releases/download/v0.0.5/AdServerSDK.xcframework.zip",
            checksum: "9386a3dd214e4abdaf82de80c0df2d53c057bd39b2f7ffda2d546802f8c922d2"
        )
    ]
)

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GMASPM",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "GoogleMobileAds", targets: ["GoogleMobileAds"])
    ],
    targets: [
        .binaryTarget(
            name: "GoogleMobileAds",
            path: "../GoogleMobileAdsSdkiOS-12.6.0/GoogleMobileAds.xcframework"
        )
    ]
)

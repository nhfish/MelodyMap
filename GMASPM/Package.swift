// swift-tools-version:5.5
// Xcode 13.2.1 Swift version

import PackageDescription

let package = Package(
    name: "GMASPM",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "GoogleMobileAds", targets: ["GoogleMobileAds"])
    ],
   targets: [
   	.binaryTarget(
        		name: "GoogleMobileAds",
        		path: "./GoogleMobileAds.xcframework"   // ← relative path to the folder you just unzipped
    	)
	]
)

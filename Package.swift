// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AwesomeDictionary",
    products: [
        .library(
            name: "AwesomeDictionary",
            targets: ["AwesomeDictionary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pumperknickle/Bedrock.git", from: "0.2.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.2"),
    ],
    targets: [
        .target(
            name: "AwesomeDictionary",
            dependencies: ["Bedrock"]),
        .testTarget(
            name: "AwesomeDictionaryTests",
            dependencies: ["AwesomeDictionary", "Quick", "Nimble", "Bedrock"]),
    ]
)

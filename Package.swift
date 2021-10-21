// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AwesomeDictionary",
    products: [
        .library(
            name: "AwesomeDictionary",
            targets: ["AwesomeDictionary"]),
        .executable(name: "my-benchmark", targets: ["MyBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pumperknickle/Bedrock.git", from: "0.2.4"),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.1.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "AwesomeDictionary",
            dependencies: ["Bedrock"]),
        .testTarget(
            name: "AwesomeDictionaryTests",
            dependencies: ["AwesomeDictionary", "Quick", "Nimble", "Bedrock"]),
        .target(
             name: "MyBenchmark",
             dependencies: [
               .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
                "AwesomeDictionary"
             ]),
    ]
)

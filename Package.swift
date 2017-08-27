// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "BroBot",
    dependencies: [
        .Package(url: "https://github.com/Azoy/Sword", majorVersion: 0, minor: 8),
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4)
    ]
)

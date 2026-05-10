// swift-tools-version: 6.0
//
//  Package.swift
//  AppData
//
//  Created by jch on 4/15/26.
//

import PackageDescription

let package = Package(
    name: "AppData",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppData",
            targets: ["AppData"]
        )
    ],
    dependencies: [
        .package(path: "../AppDomain"),
        .package(path: "../../Core/Infrastructure/Networking"),
        .package(path: "../../Core/Infrastructure/Persistence"),
        .package(path: "../../Core/Infrastructure/SearchEngine")
    ],
    targets: [
        .target(
            name: "AppData",
            dependencies: [
                "AppDomain",
                "Networking",
                "Persistence",
                "SearchEngine"
            ],
            path: "Sources/AppData",
            resources: [.process("Resources")],
            linkerSettings: [

            ]
        ),
        .testTarget(
            name: "AppDataTests",
            dependencies: [
                "AppDomain",
                "AppData",
                "Networking",
                "Persistence",
                "SearchEngine"
                
            ],
            path: "Tests/AppDataTests",
            linkerSettings: [
                
            ]
        )
    ]
)

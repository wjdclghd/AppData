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
        .package(path: "../Networking")
    ],
    targets: [
        .target(
            name: "AppData",
            dependencies: [
                "AppDomain",
                "Networking"
            ],
            path: "Sources/AppData",
            linkerSettings: [
                
            ]
        ),
        .testTarget(
            name: "AppDataTests",
            dependencies: [
                "AppDomain",
                "AppData",
                "Networking"
                
            ],
            path: "Tests/AppDataTests",
            linkerSettings: [
                
            ]
        )
    ]
)

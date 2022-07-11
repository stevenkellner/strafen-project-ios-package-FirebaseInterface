// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseInterface",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FirebaseInterface",
            targets: ["FirebaseInterface"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/alickbass/CodableFirebase.git", from: "0.2.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.0.0"),
        .package(url: "https://github.com/stevenkellner/strafen-project-ios-package-StrafenProjectTypes.git", from: "0.1.0"),
        .package(url: "https://github.com/stevenkellner/strafen-project-ios-package-Crypter.git", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FirebaseInterface",
            dependencies: [
                .product(name: "CodableFirebase", package: "CodableFirebase"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "StrafenProjectTypes", package: "strafen-project-ios-package-StrafenProjectTypes"),
                .product(name: "Crypter", package: "strafen-project-ios-package-Crypter")
            ]
        ),
        .testTarget(
            name: "FirebaseInterfaceTests",
            dependencies: ["FirebaseInterface"],
            resources: [
                .process("GoogleService-Info.plist"),
                .process("Secrets-Info.plist")
            ]
        )
    ]
)

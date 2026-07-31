// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OpenRouterMenuBar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "OpenRouterMenuBar",
            path: "Sources/OpenRouterMenuBar",
            resources: [
                .copy("Resources/MenuBarIcon.pdf")
            ]
        )
    ]
)

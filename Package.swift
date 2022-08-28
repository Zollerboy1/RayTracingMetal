// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RayTracingMetal",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "RayTracingMetal",
            targets: ["RayTracingMetal"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Zollerboy1/GLFW.git", from: "1.1.1"),
        .package(url: "https://github.com/Zollerboy1/ImGui.git", from: "2.3.1"),
        .package(url: "https://github.com/Zollerboy1/SwiftySIMD.git", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "cRayTracingMetalCore",
            dependencies: []),
        .target(
            name: "RayTracingMetalCore",
            dependencies: [
                "cRayTracingMetalCore",
                "GLFW",
                "ImGui",
                "SwiftySIMD",
                .product(name: "ImGuiImplMetal", package: "ImGui")
            ],
            resources: [
                .copy("Resources/FiraSans-Regular.ttf")
            ]
        ),
        .executableTarget(
            name: "RayTracingMetal",
            dependencies: ["RayTracingMetalCore", "ImGui", "SwiftySIMD"])
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx20
)

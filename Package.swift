// swift-tools-version: 5.9

import PackageDescription
import Foundation

let opentelemetry = (name: "opentelemetry-swift", url: "https://github.com/open-telemetry/opentelemetry-swift.git", version: Version("2.0.0"))

let platforms: [SupportedPlatform] = [.iOS(.v13), .tvOS(.v13), .macOS(.v12), .watchOS(.v7)]

let internalSwiftSettings: [SwiftSetting] = ProcessInfo.processInfo.environment["DD_BENCHMARK"] != nil ?
    [.define("DD_BENCHMARK")] : []

let package = Package(
    name: "Datadog",
    platforms: platforms,
    products: [
        .library(
            name: "DatadogCore",
            targets: ["DatadogCore"]
        ),
        .library(
            name: "DatadogLogs",
            targets: ["DatadogLogs"]
        ),
        .library(
            name: "DatadogRUM",
            targets: ["DatadogRUM"]
        ),
        .library(
            name: "DatadogCrashReporting",
            targets: ["DatadogCrashReporting"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/microsoft/plcrashreporter.git", from: "1.12.0"),
        .package(url: opentelemetry.url, exact: opentelemetry.version),
    ],
    targets: [
        .target(
            name: "DatadogCore",
            dependencies: [
                .target(name: "DatadogInternal"),
                .target(name: "DatadogPrivate"),
            ],
            path: "DatadogCore",
            sources: ["Sources"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [.define("SPM_BUILD")] + internalSwiftSettings
        ),
        .target(
            name: "DatadogPrivate",
            path: "DatadogCore/Private"
        ),

        .target(
            name: "DatadogInternal",
            path: "DatadogInternal/Sources",
            swiftSettings: internalSwiftSettings
        ),
        .testTarget(
            name: "DatadogInternalTests",
            dependencies: [
                .target(name: "DatadogInternal"),
                .target(name: "TestUtilities"),
            ],
            path: "DatadogInternal/Tests"
        ),

        .target(
            name: "DatadogLogs",
            dependencies: [
                .target(name: "DatadogInternal"),
            ],
            path: "DatadogLogs/Sources"
        ),
        .testTarget(
            name: "DatadogLogsTests",
            dependencies: [
                .target(name: "DatadogLogs"),
                .target(name: "TestUtilities"),
            ],
            path: "DatadogLogs/Tests"
        ),

        .target(
            name: "DatadogRUM",
            dependencies: [
                .target(name: "DatadogInternal"),
            ],
            path: "DatadogRUM",
            sources: ["Sources"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "DatadogRUMTests",
            dependencies: [
                .target(name: "DatadogRUM"),
                .target(name: "TestUtilities"),
            ],
            path: "DatadogRUM/Tests"
        ),

        .target(
            name: "DatadogCrashReporting",
            dependencies: [
                .target(name: "DatadogInternal"),
                .product(name: "CrashReporter", package: "PLCrashReporter"),
            ],
            path: "DatadogCrashReporting",
            sources: ["Sources"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "DatadogCrashReportingTests",
            dependencies: [
                .target(name: "DatadogCrashReporting"),
                .target(name: "TestUtilities"),
            ],
            path: "DatadogCrashReporting/Tests"
        ),

        .target(
            name: "TestUtilities",
            dependencies: [
                .target(name: "DatadogCore"),
                .target(name: "DatadogPrivate"),
                .target(name: "DatadogInternal"),
                .target(name: "DatadogLogs"),
                .target(name: "DatadogRUM"),
                .target(name: "DatadogCrashReporting"),
            ],
            path: "TestUtilities/Sources",
            swiftSettings: [.define("SPM_BUILD")] + internalSwiftSettings
        )
    ]
)

// If the `DD_TEST_UTILITIES_ENABLED` development ENV is set, export additional utility packages.
// To set this ENV for Xcode projects that fetch this package locally, use `open --env DD_TEST_UTILITIES_ENABLED path/to/<project or workspace>`.
if ProcessInfo.processInfo.environment["DD_TEST_UTILITIES_ENABLED"] != nil {
    package.products.append(
        .library(
            name: "TestUtilities",
            targets: ["TestUtilities"]
        )
    )
}

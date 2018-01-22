// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
	name: "XibLoc",
	products: [
		.library(
			name: "XibLoc",
			targets: ["XibLoc"]
		)
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "XibLoc",
			dependencies: []
		),
		.testTarget(
			name: "XibLocTests",
			dependencies: ["XibLoc"]
		)
	]
)

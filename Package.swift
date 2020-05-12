// swift-tools-version:5.0
import PackageDescription


let package = Package(
	name: "XibLoc",
	products: [
		.library(name: "XibLoc", targets: ["XibLoc"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.2.0")
	],
	targets: [
		.target(name: "XibLoc", dependencies: [
			.product(name: "Logging", package: "swift-log")
		]),
		.testTarget(name: "XibLocTests", dependencies: ["XibLoc"], exclude: ["XibLocTestsObjC.m"])
	]
)

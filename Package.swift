// swift-tools-version:5.3
import PackageDescription


let package = Package(
	name: "XibLoc",
	defaultLocalization: "en",
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
		.testTarget(name: "XibLocTests", dependencies: ["XibLoc"], exclude: ["XibLocTestsObjC.m"], resources: [Resource.process("Helpers/en.lproj/Localizable.strings")])
	]
)

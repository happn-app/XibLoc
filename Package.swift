// swift-tools-version:4.2
import PackageDescription


let package = Package(
	name: "XibLoc",
	products: [
		.library(name: "XibLoc", targets: ["XibLoc"])
	],
	dependencies: [
		.package(url: "git@github.com:happn-app/DummyLinuxOSLog.git", from: "1.0.0")
	],
	targets: [
		.target(name: "XibLoc", dependencies: ["DummyLinuxOSLog"]),
		.testTarget(name: "XibLocTests", dependencies: ["XibLoc"])
	]
)

# XibLoc
![Platforms](https://img.shields.io/badge/platform-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20Linux-lightgrey.svg?style=flat) [![SPM compatible](https://img.shields.io/badge/SPM-compatible-E05C43.svg?style=flat)](https://swift.org/package-manager/) [![License](https://img.shields.io/github/license/happn-tech/XibLoc.svg)](License.txt) [![happn](https://img.shields.io/badge/from-happn-0087B4.svg?style=flat)](https://happn.com)

A new format for your locs.

## Installation
Use SPM.

In your `Package.swift`, in the dependencies argument, add:
```swift
.package(url: "https://github.com/happn-tech/XibLoc.git", from: "1.0.0")
```

and add `XibLoc` to the list of dependencies of your app.

If you’re using Xcode, add a Swift Package in the settings of your project.

### Important Note
The repository does have an `xcodeproj` with a shared scheme for debug purposes. The project
might be compatible with Carthage–or not. It is not officially supported but might work for you.

## Important Information for `XibLoc`’s Devs
If you’re working on XibLoc on macOS, you have to use the xcodeproj in the project and not
open Package.swift in Xcode.  
The project does not compile because the tests need macOS 10.11 to run when launching the
Package.swift directly. And even when setting the correct minimum version for macOS, some
tests are still not run (ObjC tests) and some tests only work when launched with the xcodeproj
(use resources in a bundle).

## Credits
This project was originally created by [François Lamboley](https://github.com/Frizlab) while working at [happn](https://happn.com).

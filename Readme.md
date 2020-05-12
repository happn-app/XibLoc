# XibLoc
![Platforms](https://img.shields.io/badge/platform-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20Linux-lightgrey.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![SPM compatible](https://img.shields.io/badge/SPM-compatible-E05C43.svg?style=flat)](https://swift.org/package-manager/) [![License](https://img.shields.io/github/license/happn-tech/XibLoc.svg)](License.txt) [![happn](https://img.shields.io/badge/from-happn-0087B4.svg?style=flat)](https://happn.com)

A new format for your locs.

## Important Information for `XibLoc`’s Devs
If you’re working on XibLoc on macOS, you have to use the xcodeproj in the project and not
open Package.swift in Xcode.  
The project does not compile because the tests need macOS 10.11 to run when launching the
Package.swift directly. And even when setting the correct minimum version for macOS, some
tests are still not run (ObjC tests) and some tests only work when launched with the xcodeproj
(use resources in a bundle).

## Credits
This project was originally created by [François Lamboley](https://github.com/Frizlab) while working at [happn](https://happn.com).

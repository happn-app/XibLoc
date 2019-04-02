#!/bin/bash

# Strictly speaking unneeded as the tests can be launched from Xcode, but there you go!
swift test -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.11"

/*
Copyright 2019 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import Foundation



extension String {
	
	public func applying(xibLocInfo: XibLocResolvingInfo<String, String>) -> String {
		return ParsedXibLoc.cachedOrNewParsedXibLoc(source: self, parserHelper: StringParserHelper.self, forXibLocResolvingInfo: xibLocInfo).resolve(xibLocResolvingInfo: xibLocInfo, returnTypeHelperType: StringParserHelper.self)
	}
	
	#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
	
	public func applying(xibLocInfo: XibLocResolvingInfo<String, NSMutableAttributedString>) -> NSMutableAttributedString {
		return ParsedXibLoc.cachedOrNewParsedXibLoc(source: self, parserHelper: StringParserHelper.self, forXibLocResolvingInfo: xibLocInfo).resolve(xibLocResolvingInfo: xibLocInfo, returnTypeHelperType: NSMutableAttributedStringParserHelper.self)
	}
	
	public func applying(xibLocInfo: XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>, defaultAttributes: [NSAttributedString.Key: Any]?) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: self, attributes: defaultAttributes).applying(xibLocInfo: xibLocInfo)
	}
	
	#endif
	
}


#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

extension NSAttributedString {
	
	public func applying(xibLocInfo: XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>) -> NSMutableAttributedString {
		let mutableAttrStr: NSMutableAttributedString
		if let mself = self as? NSMutableAttributedString {mutableAttrStr = mself}
		else                                              {mutableAttrStr = NSMutableAttributedString(attributedString: self)}
		let resolved = ParsedXibLoc.cachedOrNewParsedXibLoc(source: mutableAttrStr, parserHelper: NSMutableAttributedStringParserHelper.self, forXibLocResolvingInfo: xibLocInfo).resolve(xibLocResolvingInfo: xibLocInfo, returnTypeHelperType: NSMutableAttributedStringParserHelper.self)
		return resolved
	}
	
}

extension NSMutableAttributedString {
	
	public func apply(xibLocInfo: XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>) {
		let resolved = applying(xibLocInfo: xibLocInfo)
		replaceCharacters(in: NSRange(location: 0, length: length), with: resolved)
	}
	
}

#endif

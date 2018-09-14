/*
 * XibLoc.swift
 * Localizer
 *
 * Created by François Lamboley on 12/7/15.
 * Copyright © 2015 happn. All rights reserved.
 */

import Foundation



public extension String {
	
	public func applying(xibLocInfo: XibLocResolvingInfo<String, String>) -> String {
		return ParsedXibLoc(source: self, parserHelper: StringParserHelper.self, forXibLocResolvingInfo: xibLocInfo).resolve(xibLocResolvingInfo: xibLocInfo, returnTypeHelperType: StringParserHelper.self)
	}
	
	public func applying(xibLocInfo: XibLocResolvingInfo<String, NSMutableAttributedString>) -> NSMutableAttributedString {
		return ParsedXibLoc(source: self, parserHelper: StringParserHelper.self, forXibLocResolvingInfo: xibLocInfo).resolve(xibLocResolvingInfo: xibLocInfo, returnTypeHelperType: NSMutableAttributedStringParserHelper.self)
	}
	
	public func applying(xibLocInfo: XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>, defaultAttributes: [NSAttributedString.Key: Any]?) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: self, attributes: defaultAttributes).applying(xibLocInfo: xibLocInfo)
	}
	
}

public extension NSAttributedString {
	
	public func applying(xibLocInfo: XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>) -> NSMutableAttributedString {
		let mutableAttrStr: NSMutableAttributedString
		if let mself = self as? NSMutableAttributedString {mutableAttrStr = mself}
		else                                              {mutableAttrStr = NSMutableAttributedString(attributedString: self)}
		let resolved = ParsedXibLoc(source: mutableAttrStr, parserHelper: NSMutableAttributedStringParserHelper.self, forXibLocResolvingInfo: xibLocInfo).resolve(xibLocResolvingInfo: xibLocInfo, returnTypeHelperType: NSMutableAttributedStringParserHelper.self)
		return resolved
	}
	
}

public extension NSMutableAttributedString {
	
	public func apply(xibLocInfo: XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>) {
		let resolved = applying(xibLocInfo: xibLocInfo)
		replaceCharacters(in: NSRange(location: 0, length: length), with: resolved)
	}
	
}

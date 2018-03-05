/*
 * ParserHelpers+String.swift
 * XibLoc
 *
 * Created by François Lamboley on 12/11/17.
 * Copyright © 2017 happn. All rights reserved.
 */

import Foundation



struct StringParserHelper : ParserHelper {
	
	typealias ParsedType = String
	
	static func copy(source: String) -> String {
		return source
	}
	
	static func stringRepresentation(of source: String) -> String {
		return source
	}
	
	static func slice<R>(strRange: (r: R, s: String), from source: String) -> String where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source)
//		print("slicing range \(strRange.r) from source \"\(source)\"")
//		print("   --> Result: \"\(source[strRange.r])\"")
		return String(source[strRange.r])
	}
	
	static func remove<R>(strRange: (r: R, s: String), from source: inout String) where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source)
//		print("removing range \(strRange.r) from source \"\(source)\"")
		source.removeSubrange(strRange.r)
//		print("   --> Result: \"\(source)\"")
	}
	
	static func replace<R>(strRange: (r: R, s: String), with replacement: String, in source: inout String) -> String where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source)
//		print("replacing range \(strRange.r) from source \"\(source)\" with \"\(replacement)\"")
		source.replaceSubrange(strRange.r, with: replacement)
//		print("   --> Result: \"\(source)\"")
		return replacement
	}
	
}

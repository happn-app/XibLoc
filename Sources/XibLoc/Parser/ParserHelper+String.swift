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
		return String(source[strRange.r])
	}
	
	static func remove<R>(strRange: (r: R, s: String), from source: inout String) where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source)
		source.removeSubrange(strRange.r)
	}
	
	static func replace<R>(strRange: (r: R, s: String), with replacement: String, in source: inout String) -> String where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source)
		source.replaceSubrange(strRange.r, with: replacement)
		return replacement
	}
	
}

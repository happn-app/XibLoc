/*
 * ParserHelper.swift
 * XibLoc
 *
 * Created by François Lamboley on 9/3/17.
 * Copyright © 2017 happn. All rights reserved.
 */

import Foundation


/* Note: We might want to merge the source and return type helpers! They already
 *       have the replace and remove method in common. */


protocol ParserHelper {
	
	/** Can be anything. Usually it will be a String or an NSMutableString. */
	associatedtype ParsedType
	
	/* When asked to (remove, replace, whatever) something from the source type,
	 * the given range will always contain a String range, and the corresponding
	 * String from which the range comes from. In theory, the given string should
	 * **always** be the stringRepresentation of the given source. */
	typealias StrRange<R> = (r: R, s: String) where R : RangeExpression, R.Bound == String.Index
	
	/** Convert the source to its string representation. The conversion should be
	a surjection. Also, you must be able to manipulate your ParsedType with the
	indexes of the given string. */
	static func stringRepresentation(of source: ParsedType) -> String
	
	static func slice<R>(strRange: StrRange<R>, from source: ParsedType) -> ParsedType where R : RangeExpression, R.Bound == String.Index
	
	static func remove<R>(strRange: StrRange<R>, from source: inout ParsedType) where R : RangeExpression, R.Bound == String.Index
	static func replace<R>(strRange: StrRange<R>, with replacement: ParsedType, in source: inout ParsedType) -> String where R : RangeExpression, R.Bound == String.Index
	
}

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



public protocol ParserHelper {
	
	/**
	 Can be anything.
	 Usually it will be a String or an NS(Mutable)AttributedString. */
	associatedtype ParsedType
	
	/**
	 Workaround the NSMutableAttributedString are reference types problem.
	 
	 For reference types, copy the referenced object and return the copy.
	 For value types, there is nothing to do, you can simply return the input. */
	static func copy(source: ParsedType) -> ParsedType
	
	/**
	 When asked to (remove, replace, whatever) something from the source type,
	 the given range will always contain a String range, and the corresponding String from which the range comes from.
	 
	 In theory, the given string should **always** be the stringRepresentation of the given source. */
	typealias StrRange<R> = (r: R, s: String) where R : RangeExpression, R.Bound == String.Index
	
	/**
	 Convert the source to its string representation.
	 
	 The conversion should be a surjection.
	 
	 Also, you must be able to manipulate your ParsedType with the indexes of the given string. */
	static func stringRepresentation(of source: ParsedType) -> String
	
	static func slice<R>(strRange: StrRange<R>, from source: ParsedType) -> ParsedType where R : RangeExpression, R.Bound == String.Index
	
	static func remove<R>(strRange: StrRange<R>, from source: inout ParsedType) where R : RangeExpression, R.Bound == String.Index
	static func replace<R>(strRange: StrRange<R>, with replacement: ParsedType, in source: inout ParsedType) -> String where R : RangeExpression, R.Bound == String.Index
	
}

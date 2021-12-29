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



@available(macOS,   deprecated: 12, message: "Use AttributedString")
@available(iOS,     deprecated: 15, message: "Use AttributedString")
@available(tvOS,    deprecated: 15, message: "Use AttributedString")
@available(watchOS, deprecated: 8,  message: "Use AttributedString")
struct NSMutableAttributedStringParserHelper : ParserHelper {
	
	/* While the NSAttributedString is not “Swifted” to support let/var, we prefer dealing with mutable attributed string directly for convenience. */
	typealias ParsedType = NSMutableAttributedString
	
	static func copy(source: NSMutableAttributedString) -> NSMutableAttributedString {
		return NSMutableAttributedString(attributedString: source)
	}
	
	static func stringRepresentation(of source: NSMutableAttributedString) -> String {
		return source.string
	}
	
	static func slice<R>(strRange: (r: R, s: String), from source: NSMutableAttributedString) -> NSMutableAttributedString where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source.string)
		let nsrange = NSRange(strRange.r, in: strRange.s)
		return NSMutableAttributedString(attributedString: source.attributedSubstring(from: nsrange))
	}
	
	static func remove<R>(strRange: (r: R, s: String), from source: inout NSMutableAttributedString) where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source.string)
		
		let nsrange = NSRange(strRange.r, in: strRange.s)
		source.replaceCharacters(in: nsrange, with: "")
	}
	
	static func replace<R>(strRange: (r: R, s: String), with replacement: NSMutableAttributedString, in source: inout NSMutableAttributedString) -> String where R : RangeExpression, R.Bound == String.Index {
		assert(strRange.s == source.string)
		
		let nsrange = NSRange(strRange.r, in: strRange.s)
		source.replaceCharacters(in: nsrange, with: replacement)
		
		return replacement.string
	}
	
}

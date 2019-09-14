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

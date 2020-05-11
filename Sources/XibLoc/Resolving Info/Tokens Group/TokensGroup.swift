/*
Copyright 2020 happn

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



public protocol TokensGroup {
	
	static var tokensExceptEscape: Set<String> {get}
	
	var str2StrXibLocInfo: Str2StrXibLocInfo {get}
	#if !os(Linux)
	var str2AttrStrXibLocInfo: Str2AttrStrXibLocInfo {get}
	#endif
	
}


extension TokensGroup {
	
	public static func escape(_ string: String, with escapeToken: String) -> String {
		assert(!tokensExceptEscape.contains(escapeToken))
		return ([escapeToken] + Array(tokensExceptEscape)).reduce(string, { $0.replacingOccurrences(of: $1, with: escapeToken + $1) })
	}
	
}


extension String {
	
	public func applying(tokensGroup group: TokensGroup) -> String {
		return applying(xibLocInfo: group.str2StrXibLocInfo)
	}
	
	#if !os(Linux)
	
	public func applying(tokensGroupAttributed group: TokensGroup) -> NSMutableAttributedString {
		return applying(xibLocInfo: group.str2AttrStrXibLocInfo)
	}
	
	#endif
	
}

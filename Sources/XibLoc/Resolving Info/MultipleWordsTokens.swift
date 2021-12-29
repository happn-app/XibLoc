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



public struct MultipleWordsTokens : Hashable {
	
	public let leftToken: String
	public let interiorToken: String
	public let rightToken: String
	
	public init(exteriorToken: String, interiorToken: String) {
		self.init(leftToken: exteriorToken, interiorToken: interiorToken, rightToken: exteriorToken)
	}
	
	public init(leftToken lt: String, interiorToken it: String, rightToken rt: String) {
		leftToken = lt
		interiorToken = it
		rightToken = rt
	}
	
	/**
	 A convenience init for multiple words tokens with a one-char left, right and interior tokens.
	 
	 The short tokens form is a concatenation of the left, interior and right tokens.
	 The count of a short tokens form is thus always 3.
	 
	 Examples:
	 - Left and right token: “`|`”, Interior token: “`:`” -> Short tokens form: “`|:|`”
	 - Left token: “`<`”, Interior token: “`:`”, Right token: “`>`” -> Short tokens form: “`<:>`” */
	public init?(shortTokensForm string: String) {
		guard string.count == 3 else {return nil}
		self.init(leftToken: String(string.first!), interiorToken: String(string.dropFirst().first!), rightToken: String(string.dropFirst(2).first!))
	}
	
}

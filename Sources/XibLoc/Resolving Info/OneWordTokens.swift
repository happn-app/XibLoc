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



public struct OneWordTokens : Hashable {
	
	public let leftToken: String
	public let rightToken: String
	
	public init(token: String) {
		self.init(leftToken: token, rightToken: token)
	}
	
	public init(leftToken lt: String, rightToken rt: String) {
		leftToken = lt
		rightToken = rt
	}
	
	/**
	 A convenience init for one word tokens with a one-char left and right tokens.
	 
	 The short tokens form is a concatenation of the left and right tokens.
	 If the left and right tokens are the same, it does not need to be put twice.
	 
	 Examples:
	 - Left and right token: “`|`” -> Short tokens form: “`|`” or “`||`”
	 - Left token: “`{`”, Right token: “`}`” -> Short tokens form: “`{}`” */
	public init?(shortTokensForm string: String) {
		switch string.count {
			case 1: self.init(token: string)
			case 2: self.init(leftToken: String(string.first!), rightToken: String(string.dropFirst().first!))
			default: return nil
		}
	}
	
}

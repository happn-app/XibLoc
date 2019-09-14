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
	
	public static func ==(lhs: OneWordTokens, rhs: OneWordTokens) -> Bool {
		return lhs.leftToken == rhs.leftToken && lhs.rightToken == rhs.rightToken
	}
	
}

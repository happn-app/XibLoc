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



struct XibLocParsingInfo : Hashable {
	
	/**
	 Are the given token valid or do they overlap in a way we cannot guarantee the parsing will work?
	 
	 We apply the following rules:
	 - Take all the tokens (left, right, internal, escape token) and place them in an array, with the following exception: if `lsep == rsep`, only add the separator only once;
	 - For each token, verify none of all the non-empty prefixes possible of the token is a suffix of another token.
	 
	 Example with the following tokens: `abc`, `def`, `ghi`.
	 We first take the token `abc`, and verify `a` is not the suffix of the other tokens, then `ab`, and finally `abc`.
	 Then we do the same for `def` and `ghi`. */
	static func validateTokens(escapeToken: String?, oneWordTokens: [OneWordTokens], multipleWordsTokens: [MultipleWordsTokens]) -> Bool {
		var tokens = [String]()
		if let escapeToken = escapeToken {
			tokens.append(escapeToken)
		}
		for token in oneWordTokens {
			tokens.append(token.leftToken)
			if token.leftToken != token.rightToken {
				tokens.append(token.rightToken)
			}
		}
		for token in multipleWordsTokens {
			tokens.append(token.leftToken)
			tokens.append(token.interiorToken)
			if token.leftToken != token.rightToken {
				tokens.append(token.rightToken)
			}
		}
		
		for (idx, token) in tokens.enumerated() {
			guard !token.isEmpty else {
				return false
			}
			var testedString = ""
			for c in token {
				testedString += String(c)
				for (idx2, token2) in tokens.enumerated() {
					guard idx2 != idx else {
						continue
					}
					guard !token2.hasSuffix(testedString) else {
						return false
					}
				}
			}
		}
		return true
	}
	
	let escapeToken: String?
	
	let simpleSourceTypeReplacements: [OneWordTokens]
	let orderedReplacements: [MultipleWordsTokens]
	let pluralGroups: [MultipleWordsTokens]
	
	let attributesModifications: [OneWordTokens]
	let simpleReturnTypeReplacements: [OneWordTokens]
	
	var oneWordTokens: [OneWordTokens] {
		return simpleSourceTypeReplacements + attributesModifications + simpleReturnTypeReplacements
	}
	
	var multipleWordsTokens: [MultipleWordsTokens] {
		return orderedReplacements + pluralGroups
	}
	
	init?<SourceType, ReturnType>(resolvingInfo: XibLocResolvingInfo<SourceType, ReturnType>) {
		escapeToken = resolvingInfo.escapeToken
		
		simpleSourceTypeReplacements = Array(resolvingInfo.simpleSourceTypeReplacements.keys)
		orderedReplacements = Array(resolvingInfo.orderedReplacements.keys)
		pluralGroups = resolvingInfo.pluralGroups.map{ $0.0 }
		
		attributesModifications = Array(resolvingInfo.attributesModifications.keys)
		simpleReturnTypeReplacements = Array(resolvingInfo.simpleReturnTypeReplacements.keys)
		
		guard XibLocParsingInfo.validateTokens(escapeToken: escapeToken, oneWordTokens: oneWordTokens, multipleWordsTokens: multipleWordsTokens) else {
			return nil
		}
	}
	
}

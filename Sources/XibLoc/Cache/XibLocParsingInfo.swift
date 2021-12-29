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
	 - If `lsep == rsep`, reduce to only sep;
	 - No char used in any separator (left, right, internal, escape token) must be used in another separator;
	 - But the same char can be used multiple time in one separator.
	 
	 - Note: We’re currently overly cautious.
	 There are probably less restrictive rules we could apply. */
	static func validateTokens(escapeToken: String?, oneWordTokens: [OneWordTokens], multipleWordsTokens: [MultipleWordsTokens]) -> Bool {
		/* Soft TODO: Find better, less restrictive rules, maybe. */
		struct ValidationError : Error {}
		var chars = Set<Character>()
		
		let processToken = { (token: String) throws -> Void in
			guard !token.isEmpty else {throw ValidationError()}
			let tokenChars = Set(token)
			
			guard chars.intersection(tokenChars).isEmpty else {throw ValidationError()}
			chars.formUnion(tokenChars)
		}
		
		do {
			if let e = escapeToken {
				try processToken(e)
			}
			
			for w in oneWordTokens {
				try processToken(w.leftToken)
				if w.leftToken != w.rightToken {try processToken(w.rightToken)}
			}
			
			for w in multipleWordsTokens {
				try processToken(w.leftToken)
				try processToken(w.interiorToken)
				if w.leftToken != w.rightToken {try processToken(w.rightToken)}
			}
			
			return true
		} catch {
			return false
		}
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

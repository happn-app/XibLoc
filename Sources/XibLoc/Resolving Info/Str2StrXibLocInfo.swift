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



public typealias Str2StrXibLocInfo = XibLocResolvingInfo<String, String>

extension XibLocResolvingInfo where SourceType == String, ReturnType == String {
	
	@available(*, deprecated, message: "Use the new Str2StrXibLocInfo init methods")
	public init(simpleReplacementWithToken token: String, value: String, escapeToken e: String? = XibLocConfig.defaultEscapeToken) {
		self.init(replacements: [token: value], escapeToken: e)!
	}
	
	@available(*, deprecated, message: "Use the new Str2StrXibLocInfo init methods")
	public init(pluralValue: XibLocNumber? = nil, genderMeIsMale isMeMale: Bool? = nil, genderOtherIsMale isOtherMale: Bool? = nil, escapeToken e: String? = XibLocConfig.defaultEscapeToken) {
		self.init(replacements: [:], pluralValue: pluralValue, genderMeIsMale: isMeMale, genderOtherIsMale: isOtherMale, escapeToken: e)!
	}
	
	@available(*, deprecated, message: "Use the new Str2StrXibLocInfo init methods")
	public init(replacement: String, pluralValue: XibLocNumber? = nil, genderMeIsMale isMeMale: Bool? = nil, genderOtherIsMale isOtherMale: Bool? = nil, escapeToken e: String? = XibLocConfig.defaultEscapeToken) {
		self.init(replacements: ["|": replacement], pluralValue: pluralValue, genderMeIsMale: isMeMale, genderOtherIsMale: isOtherMale, escapeToken: e)!
	}
	
	@available(*, deprecated, message: "Use the new Str2StrXibLocInfo init methods")
	public init?(replacements: [String: String], pluralValue: XibLocNumber? = nil, genderMeIsMale isMeMale: Bool? = nil, genderOtherIsMale isOtherMale: Bool? = nil, escapeToken e: String? = XibLocConfig.defaultEscapeToken) {
		defaultPluralityDefinition = XibLocConfig.defaultPluralityDefinition
		escapeToken = e
		attributesModifications = [:]
		simpleSourceTypeReplacements = [:]
		
		var simpleReturnTypeReplacementsBuilding = [OneWordTokens: (String) -> String]()
		for (t, v) in replacements {simpleReturnTypeReplacementsBuilding[OneWordTokens(token: t)] = { _ in v }}
		if let xibLocNumber = pluralValue {
			simpleReturnTypeReplacementsBuilding[OneWordTokens(token: "#")] = { _ in xibLocNumber.localizedString }
			pluralGroups = [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), xibLocNumber.pluralValue)]
		} else {
			pluralGroups = []
		}
		
		var orderedReplacementsBuilding = [MultipleWordsTokens: Int]()
		if let isMeMale = isMeMale       {orderedReplacementsBuilding[MultipleWordsTokens(leftToken: "{", interiorToken: "₋", rightToken: "}")] = isMeMale ? 0 : 1}
		if let isOtherMale = isOtherMale {orderedReplacementsBuilding[MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´")] = isOtherMale ? 0 : 1}
		orderedReplacements = orderedReplacementsBuilding
		
		simpleReturnTypeReplacements = simpleReturnTypeReplacementsBuilding
		identityReplacement = { $0 }
		
		/* See definition of parsingInfo var for explanation of this. */
		guard initParsingInfo() else {
			return nil
		}
	}
	
}

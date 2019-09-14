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
	
	public init(simpleReplacementWithToken token: String, value: String, escapeToken e: String? = di.defaultEscapeToken) {
		self.init(replacements: [token: value], escapeToken: e)
	}
	
	public init(replacement: String, pluralValue: NumberAndFormat? = nil, genderMeIsMale isMeMale: Bool? = nil, genderOtherIsMale isOtherMale: Bool? = nil, escapeToken e: String? = di.defaultEscapeToken) {
		self.init(replacements: ["|": replacement], pluralValue: pluralValue, genderMeIsMale: isMeMale, genderOtherIsMale: isOtherMale, escapeToken: e)
	}
	
	public init(numberReplacement: NumberAndFormat, pluralValue: NumberAndFormat? = nil, genderMeIsMale isMeMale: Bool? = nil, genderOtherIsMale isOtherMale: Bool? = nil, escapeToken e: String? = di.defaultEscapeToken) {
		self.init(replacements: ["#": numberReplacement.asString()], pluralValue: pluralValue, genderMeIsMale: isMeMale, genderOtherIsMale: isOtherMale, escapeToken: e)
	}
	
	public init(numberReplacements: [String: NumberAndFormat], pluralValue: NumberAndFormat? = nil, genderMeIsMale isMeMale: Bool? = nil, genderOtherIsMale isOtherMale: Bool? = nil, escapeToken e: String? = di.defaultEscapeToken) {
		self.init(replacements: numberReplacements.mapValues{ $0.asString() }, pluralValue: pluralValue, genderMeIsMale: isMeMale, genderOtherIsMale: isOtherMale, escapeToken: e)
	}
	
	public init(replacements: [String: String] = [:], pluralValue: NumberAndFormat? = nil, genderMeIsMale isMeMale: Bool? = nil, genderOtherIsMale isOtherMale: Bool? = nil, escapeToken e: String? = di.defaultEscapeToken) {
		defaultPluralityDefinition = di.defaultPluralityDefinition
		escapeToken = e
		attributesModifications = [:]
		simpleSourceTypeReplacements = [:]
		
		var simpleReturnTypeReplacementsBuilding = [OneWordTokens: (String) -> String]()
		for (t, v) in replacements {simpleReturnTypeReplacementsBuilding[OneWordTokens(token: t)] = { _ in v }}
		if let numberAndFormat = pluralValue {
			simpleReturnTypeReplacementsBuilding[OneWordTokens(token: "#")] = { _ in numberAndFormat.asString() }
			pluralGroups = [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), numberAndFormat.number)]
		} else {
			pluralGroups = []
		}
		
		var orderedReplacementsBuilding = [MultipleWordsTokens: Int]()
		if let isOtherMale = isOtherMale {orderedReplacementsBuilding[MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´")] = isOtherMale ? 0 : 1}
		if let isMeMale = isMeMale       {orderedReplacementsBuilding[MultipleWordsTokens(leftToken: "{", interiorToken: "₋", rightToken: "}")] = isMeMale ? 0 : 1}
		orderedReplacements = orderedReplacementsBuilding
		
		simpleReturnTypeReplacements = simpleReturnTypeReplacementsBuilding
		dictionaryReplacements = nil
		identityReplacement = { $0 }
	}
	
}

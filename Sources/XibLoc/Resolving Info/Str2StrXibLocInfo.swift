/*
 * Str2StrXibLocInfo.swift
 * XibLoc
 *
 * Created by François Lamboley on 1/23/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



public typealias Str2StrXibLocInfo = XibLocResolvingInfo<String, String>

public extension XibLocResolvingInfo where SourceType == String, ReturnType == String {
	
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
		if let isMeMale = isMeMale       {orderedReplacementsBuilding[MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´")] = isMeMale ? 0 : 1}
		if let isOtherMale = isOtherMale {orderedReplacementsBuilding[MultipleWordsTokens(leftToken: "{", interiorToken: "⟷", rightToken: "}")] = isOtherMale ? 0 : 1}
		if let isMeMale = isMeMale, let isOtherMale = isOtherMale {orderedReplacementsBuilding[MultipleWordsTokens(leftToken: "⎡", interiorToken: "⟡", rightToken: "⎤")] = isMeMale || isOtherMale ? 0 : 1}
		orderedReplacements = orderedReplacementsBuilding
		
		simpleReturnTypeReplacements = simpleReturnTypeReplacementsBuilding
		dictionaryReplacements = nil
		identityReplacement = { $0 }
	}
	
}

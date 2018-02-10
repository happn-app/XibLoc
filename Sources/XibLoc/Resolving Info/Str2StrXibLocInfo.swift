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
	
	public init(replacement: String? = nil, pluralValue: (PluralValue, NumberFormatter.Style)? = nil, genderIsMale isMale: Bool? = nil) {
		defaultPluralityDefinition = di.defaultPluralityDefinition
		escapeToken = nil
		attributesModifications = [:]
		simpleSourceTypeReplacements = [:]
		var simpleReturnTypeReplacementsBuilding = [OneWordTokens: (String) -> String]()
		if let replacement = replacement {simpleReturnTypeReplacementsBuilding[OneWordTokens(token: "|")] = { _ in replacement }}
		if let (pluralValue, formatterStyle) = pluralValue {
			let strPluralValue = NumberFormatter.localizedString(from: pluralValue.asNumber(), number: formatterStyle)
			simpleReturnTypeReplacementsBuilding[OneWordTokens(token: "#")] = { _ in strPluralValue }
			pluralGroups = [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), pluralValue)]
		} else {
			pluralGroups = []
		}
		if let isMale = isMale {orderedReplacements = [MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´"): isMale ? 0 : 1]}
		else                   {orderedReplacements = [:]}
		simpleReturnTypeReplacements = simpleReturnTypeReplacementsBuilding
		dictionaryReplacements = nil
		identityReplacement = { $0 }
	}
	
	public init(simpleReplacementWithToken token: String, escapeToken e: String? = nil, value: String) {
		self.init(simpleReplacementWithLeftToken: token, rightToken: token, escapeToken: e, value: value)
	}
	
	public init(simpleReplacementWithLeftToken leftToken: String, rightToken: String, escapeToken e: String? = nil, value: String) {
		defaultPluralityDefinition = PluralityDefinition()
		escapeToken = e
		attributesModifications = [:]
		simpleSourceTypeReplacements = [:]
		simpleReturnTypeReplacements = [OneWordTokens(leftToken: leftToken, rightToken: rightToken): { _ in value }]
		orderedReplacements = [:]
		pluralGroups = []
		dictionaryReplacements = nil
		identityReplacement = { $0 }
	}
	
	public init(genderReplacementWithLeftToken leftToken: String, interiorToken: String, rightToken: String, escapeToken e: String? = nil, valueIsMale: Bool) {
		defaultPluralityDefinition = PluralityDefinition()
		escapeToken = e
		attributesModifications = [:]
		simpleSourceTypeReplacements = [:]
		simpleReturnTypeReplacements = [:]
		orderedReplacements = [MultipleWordsTokens(leftToken: leftToken, interiorToken: interiorToken, rightToken: rightToken): valueIsMale ? 0 : 1]
		pluralGroups = []
		dictionaryReplacements = nil
		identityReplacement = { $0 }
	}
	
}

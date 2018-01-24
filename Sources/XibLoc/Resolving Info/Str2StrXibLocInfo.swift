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
		var simpleReturnTypeReplacementsBuilding = [OneWordTokens: String]()
		if let replacement = replacement {simpleReturnTypeReplacementsBuilding[OneWordTokens(token: "|")] = replacement}
		if let (pluralValue, formatterStyle) = pluralValue {
			let strPluralValue = NumberFormatter.localizedString(from: pluralValue.asNumber(), number: formatterStyle)
			simpleReturnTypeReplacementsBuilding[OneWordTokens(token: "#")] = strPluralValue
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
	
	public init(simpleReplacementWithToken token: String, value: String) {
		self.init(simpleReplacementWithLeftToken: token, rightToken: token, value: value)
	}
	
	public init(simpleReplacementWithLeftToken leftToken: String, rightToken: String, value: String) {
		defaultPluralityDefinition = PluralityDefinition()
		escapeToken = nil
		attributesModifications = [:]
		simpleSourceTypeReplacements = [:]
		simpleReturnTypeReplacements = [OneWordTokens(leftToken: leftToken, rightToken: rightToken): value]
		orderedReplacements = [:]
		pluralGroups = []
		dictionaryReplacements = nil
		identityReplacement = { $0 }
	}
	
	public init(genderReplacementWithLeftToken leftToken: String, interiorToken: String, rightToken: String, valueIsMale: Bool) {
		defaultPluralityDefinition = PluralityDefinition()
		escapeToken = nil
		attributesModifications = [:]
		simpleSourceTypeReplacements = [:]
		simpleReturnTypeReplacements = [:]
		orderedReplacements = [MultipleWordsTokens(leftToken: leftToken, interiorToken: interiorToken, rightToken: rightToken): valueIsMale ? 0 : 1]
		pluralGroups = []
		dictionaryReplacements = nil
		identityReplacement = { $0 }
	}
	
}
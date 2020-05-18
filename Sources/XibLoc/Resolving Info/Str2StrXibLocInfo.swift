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
	
	public init() {
		self.init(identityReplacement: { $0 })!
	}
	
	/**
	Convenience init for an Str2StrXibLocInfo.
	
	Usually you should get a XibLocInfo from a tokens group. In case you have a
	translation that does not fit within a tokens group, you can use this
	convenience to create the info you need easily.
	
	All the keys in the dictionaries must represent the short form of the one
	word or multiple words tokens they represent. */
	public init?(replacements: [String: String] = [:], plurals: [(valueTokens: String, pluralTokens: String, value: XibLocNumber)] = [], orderedReplacements or: [String: Int] = [:], escapeToken e: String? = XibLocConfig.defaultEscapeToken, defaultPluralityDefinition dpd: PluralityDefinition = XibLocConfig.defaultPluralityDefinition) {
		var orderedReplacementsBuilding = [MultipleWordsTokens: Int]()
		var pluralGroupsBuilding = [(MultipleWordsTokens, PluralValue)]()
		var simpleReturnTypeReplacementsBuilding = [OneWordTokens: (String) -> String]()
		
		for (tokenStr, v) in replacements {
			guard let token = OneWordTokens(shortTokensForm: tokenStr), simpleReturnTypeReplacementsBuilding[token] == nil else {
				return nil
			}
			simpleReturnTypeReplacementsBuilding[token] = { _ in v }
		}
		for (valueTokensStr, pluralTokensStr, value) in plurals {
			guard let valueTokens = OneWordTokens(shortTokensForm: valueTokensStr), simpleReturnTypeReplacementsBuilding[valueTokens] == nil else {
				return nil
			}
			simpleReturnTypeReplacementsBuilding[valueTokens] = { _ in value.localizedString }
			
			guard let pluralTokens = MultipleWordsTokens(shortTokensForm: pluralTokensStr) else {
				return nil
			}
			pluralGroupsBuilding.append((pluralTokens, value.pluralValue))
		}
		for (tokenStr, v) in or {
			guard let token = MultipleWordsTokens(shortTokensForm: tokenStr), orderedReplacementsBuilding[token] == nil else {
				return nil
			}
			orderedReplacementsBuilding[token] = v
		}
		
		self.init(
			defaultPluralityDefinition: dpd, escapeToken: e,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: orderedReplacementsBuilding,
			pluralGroups: pluralGroupsBuilding,
			attributesModifications: [:],
			simpleReturnTypeReplacements: simpleReturnTypeReplacementsBuilding,
			identityReplacement: { $0 }
		)
	}
	
}

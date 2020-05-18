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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation



public typealias Str2AttrStrXibLocInfo = XibLocResolvingInfo<String, NSMutableAttributedString>

extension XibLocResolvingInfo where SourceType == String, ReturnType == NSMutableAttributedString {
	
	/**
	Convenience init for an Str2AttrStrXibLocInfo.
	
	Takes an str2str xib loc info and convert it to an str2attrstr xib loc info
	with no additional tokens. */
	public init(strResolvingInfo: Str2StrXibLocInfo, defaultAttributes: [NSAttributedString.Key: Any]? = XibLocConfig.defaultStr2AttrStrAttributes) {
		let simpleSourceTypeReplacements = strResolvingInfo.simpleSourceTypeReplacements.merging(strResolvingInfo.simpleReturnTypeReplacements, uniquingKeysWith: { _, _ in
			fatalError("The given str2str xib loc info was not valid: it had source and return type replacements which had the same tokens!")
		})
		
		/* We’re initing ourselves from a valid loc info and do not add new
		 * tokens: we _know_ the tokens are valid and the init will succeed. */
		self.init(
			defaultPluralityDefinition: strResolvingInfo.defaultPluralityDefinition, escapeToken: strResolvingInfo.escapeToken,
			simpleSourceTypeReplacements: simpleSourceTypeReplacements,
			orderedReplacements: strResolvingInfo.orderedReplacements,
			pluralGroups: strResolvingInfo.pluralGroups,
			attributesModifications: [:], simpleReturnTypeReplacements: [:],
			identityReplacement: { NSMutableAttributedString(string: $0, attributes: defaultAttributes) }
		)!
	}
	
}

#endif

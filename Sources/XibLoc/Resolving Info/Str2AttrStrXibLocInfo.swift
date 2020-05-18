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
	
	public init(strResolvingInfo: Str2StrXibLocInfo, defaultAttributes: [NSAttributedString.Key: Any]? = XibLocConfig.defaultStr2AttrStrAttributes) {
		defaultPluralityDefinition = strResolvingInfo.defaultPluralityDefinition
		escapeToken = strResolvingInfo.escapeToken
		pluralGroups = strResolvingInfo.pluralGroups
		orderedReplacements = strResolvingInfo.orderedReplacements
		simpleSourceTypeReplacements = strResolvingInfo.simpleReturnTypeReplacements
		
		attributesModifications = [:]
		simpleReturnTypeReplacements = [:]
		
		identityReplacement = { NSMutableAttributedString(string: $0, attributes: defaultAttributes) }
		
		/* We must call initParsingInfo(). In theory we should check it returns
		 * true and fail the init if it does not. However, because we’re initing
		 * ourselves from a valid loc info and do not add new tokens, we _know_
		 * the tokens are valid and the method call will succeed. */
		_ = initParsingInfo()
	}
	
}

#endif

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



#if os(Linux)

/** A default Tokens Group.

See doc of the non Linux variant for more info.

List of tokens:
- Escape: `~`
- Simple replacement 1: `|`
- Simple replacement 2: `^`
- Plural: `<` `:` `>`
- Plural value: `#`
- Gender me: `{` `₋` `}`
- Gender other: \` `¦` `´` */
public struct CommonTokensGroup : TokensGroup {
	
	public static let tokensExceptEscape = Set(arrayLiteral: "|", "^", "#", "<", ":", ">", "{", "₋", "}", "`", "¦", "´")
	
	/** Token is `|` */
	public var simpleReplacement1: String?
	/** Token is `^` */
	public var simpleReplacement2: String?
	/** See discussion for the tokens.
	
	Tokens:
	- For the number replacement: `#`
	- For the plural value: `<` `:` `>` */
	public var number: XibLocNumber?
	
	/** Tokens: `{` `₋` `}`
	- Important: The dash is not a standard dash… */
	public var genderMeIsMale: Bool?
	/** Tokens: \` `¦` `´`
	
	(Xcode Formatting note: I did not find a way to specify the first token is
	code (because it’s the same token as the token used to specify we have code
	in Xcode comments). Doesn’t matter, it’s not really visible though.)*/
	public var genderOtherIsMale: Bool?
	
	/** Defaults to `~` */
	public var escapeToken: String?
	
	public init(
		simpleReplacement1 r1: String? = nil,
		simpleReplacement2 r2: String? = nil,
		number n: XibLocNumber? = nil,
		genderMeIsMale gm: Bool? = nil,
		genderOtherIsMale go: Bool? = nil,
		escapeToken e: String? = di.defaultEscapeToken
	) {
		simpleReplacement1 = r1
		simpleReplacement2 = r2
		number = n
		genderMeIsMale = gm
		genderOtherIsMale = go
		escapeToken = e
	}
	
	public var str2StrXibLocInfo: Str2StrXibLocInfo {
		return Str2StrXibLocInfo(
			defaultPluralityDefinition: di.defaultPluralityDefinition,
			escapeToken: escapeToken,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [
				MultipleWordsTokens(leftToken: "{", interiorToken: "₋", rightToken: "}"): genderMeIsMale.flatMap{ $0 ? 0 : 1 },
				MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´"): genderOtherIsMale.flatMap{ $0 ? 0 : 1 }
			].compactMapValues{ $0 },
			pluralGroups: [number.flatMap{ (MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), $0.pluralValue) }].compactMap{ $0 },
			attributesModifications: [:],
			simpleReturnTypeReplacements: [
				OneWordTokens(token: "|"): simpleReplacement1.flatMap{ r in { _ in r } },
				OneWordTokens(token: "^"): simpleReplacement2.flatMap{ r in { _ in r } },
				OneWordTokens(token: "#"): number.flatMap{ n in { _ in n.localizedString } }
			].compactMapValues{ $0 },
			identityReplacement: { $0 }
		)! /* We force unwrap because we _know_ these tokens are valid. */
	}
	
}


extension String {
	
	/** Apply a `CommonTokensGroup` on your string.
	
	- parameter simpleReplacement1: Token is `|`
	- parameter simpleReplacement2: Token is `^`
	- parameter number: Tokens are `#` (number value), `<` `:` `>` (plural)
	- parameter genderMeIsMale: Tokens are `{` `₋` `}`
	- parameter genderOtherIsMale: Tokens are \` `¦` `´` */
	public func applyingCommonTokens(
		simpleReplacement1: String? = nil,
		simpleReplacement2: String? = nil,
		number: XibLocNumber? = nil,
		genderMeIsMale: Bool? = nil,
		genderOtherIsMale: Bool? = nil,
		escapeToken: String? = di.defaultEscapeToken
	) -> String {
		return applying(xibLocInfo: CommonTokensGroup(
			simpleReplacement1: simpleReplacement1,
			simpleReplacement2: simpleReplacement2,
			number: number,
			genderMeIsMale: genderMeIsMale,
			genderOtherIsMale: genderOtherIsMale,
			escapeToken: escapeToken
		).str2StrXibLocInfo)
	}
	
}

#endif

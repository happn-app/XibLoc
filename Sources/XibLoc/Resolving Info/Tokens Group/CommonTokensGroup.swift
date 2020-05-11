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



#if !os(Linux)

/** A default Tokens Group.

This tokens group should be enough to process most, if not all of your
translations.
If you need more tokens, you can create your own groups, the same way this one
has been done (or any other way you want, the idea is simply to get a
`XibLocResolvingInfo` at the end; you can even extend `XibLocResolvingInfo` to
create a custom init if you prefer, though you must remember to call
`initParsingInfo` at the end of your init).

The default init of this group will set the `defaultBoldAttrsChangesDescription`
and `defaultItalicAttrsChangesDescription` resp. to the `*` and `_` tokens. If
you don’t want bold or italic, you must explicitly disable it, whether when
initing the group, or by setting the defaults in the `di` variable.

List of tokens:
- Escape: `~`
- Simple replacement 1: `|`
- Simple replacement 2: `^`
- Plural: `<` `:` `>`
- Plural value: `#`
- Gender me: `{` `₋` `}`
- Gender other: \` `¦` `´`
- Bold: `*`
- Italic: `_`

(This § is here because Xcode does not know how to parse comments and does
weird sh*t… Thanks Xcode, go home, you’re drunk.)

- Note:
Only the transformations set to a non-nil value will see their tokens parsed.
Which means, the following string `hello_world_how_are_you`, if processed with a
`CommonTokensGroup()` (using all default arguments), will yield the same string
when processed with the str2str resolving info, but will yield the attributed
strig `helloworldhowareyou` with the words “`world`” and “`are`” in italic if
processed with the str2attrstr resolving info.

This is because an str2str resolving info will not do anything with the bold and
italic tokens and thus, they are not put in the str2str resolving info.

If you’re processing translations automatically through some kind of script or
app, because of the behaviour described above, it is recommended you escape as
many tokens as possible. XibLoc will simply remove the escape token in front of
stuff that are not of importance for the parsing.
For instance, using the previous example, one should use the string
`hello~_world~_how~_are~_you` whether they expect the translation to be used in
an attributed or a non-attributed string. Finally, don’t forget to escape the
escape token if it is in the original string.

The list of all the tokens (except the escape one!) is given in a static
variable for convenience, as well as a static method to escape all of the tokens
in a string. */
public struct CommonTokensGroup : TokensGroup {
	
	public static let tokensExceptEscape = Set(arrayLiteral: "|", "^", "#", "<", ":", ">", "{", "₋", "}", "`", "¦", "´", "*", "_")
	
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
	
	public var baseFont: XibLocFont?
	public var baseColor: XibLocColor?
	public var baseAttributes: [NSAttributedString.Key: Any]?
	
	/** Token is `*` */
	public var boldAttrsChangesDescription: StringAttributesChangesDescription?
	/** Token is `_` */
	public var italicAttrsChangesDescription: StringAttributesChangesDescription?
	
	public init(
		simpleReplacement1 r1: String? = nil,
		simpleReplacement2 r2: String? = nil,
		number n: XibLocNumber? = nil,
		genderMeIsMale gm: Bool? = nil,
		genderOtherIsMale go: Bool? = nil,
		escapeToken e: String? = di.defaultEscapeToken,
		baseFont f: XibLocFont? = nil,
		baseColor c: XibLocColor? = nil,
		baseAttributes attrs: [NSAttributedString.Key: Any]? = di.defaultStr2AttrStrAttributes,
		boldAttrsChangesDescription boldAttrsChanges: StringAttributesChangesDescription? = di.defaultBoldAttrsChangesDescription,
		italicAttrsChangesDescription italicAttrsChanges: StringAttributesChangesDescription? = di.defaultItalicAttrsChangesDescription
	) {
		simpleReplacement1 = r1
		simpleReplacement2 = r2
		number = n
		genderMeIsMale = gm
		genderOtherIsMale = go
		escapeToken = e
		
		baseFont = f
		baseColor = c
		baseAttributes = attrs
		
		boldAttrsChangesDescription = boldAttrsChanges
		italicAttrsChangesDescription = italicAttrsChanges
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
	
	public var str2AttrStrXibLocInfo: Str2AttrStrXibLocInfo {
		var defaultAttributes = baseAttributes ?? [:]
		if let f = baseFont  {defaultAttributes[.font] = f}
		if let c = baseColor {defaultAttributes[.foregroundColor] = c}
		
		return Str2AttrStrXibLocInfo(
			defaultPluralityDefinition: di.defaultPluralityDefinition,
			escapeToken: escapeToken,
			simpleSourceTypeReplacements: [
				OneWordTokens(token: "|"): simpleReplacement1.flatMap{ r in { _ in r } },
				OneWordTokens(token: "^"): simpleReplacement2.flatMap{ r in { _ in r } },
				OneWordTokens(token: "#"): number.flatMap{ n in { _ in n.localizedString } }
			].compactMapValues{ $0 },
			orderedReplacements: [
				MultipleWordsTokens(leftToken: "{", interiorToken: "₋", rightToken: "}"): genderMeIsMale.flatMap{ $0 ? 0 : 1 },
				MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´"): genderOtherIsMale.flatMap{ $0 ? 0 : 1 }
			].compactMapValues{ $0 },
			pluralGroups: [number.flatMap{ (MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), $0.pluralValue) }].compactMap{ $0 },
			attributesModifications: [
				OneWordTokens(token: "*"):   boldAttrsChangesDescription.flatMap{ c in { attrStr, strRange, refStr in assert(refStr == attrStr.string); c.apply(to: attrStr, range: NSRange(strRange, in: refStr)) } },
				OneWordTokens(token: "_"): italicAttrsChangesDescription.flatMap{ c in { attrStr, strRange, refStr in assert(refStr == attrStr.string); c.apply(to: attrStr, range: NSRange(strRange, in: refStr)) } },
			].compactMapValues{ $0 },
			simpleReturnTypeReplacements: [:],
			identityReplacement: { NSMutableAttributedString(string: $0, attributes: defaultAttributes) }
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
	
	/** Apply a `CommonTokensGroup` on your string w/ attributed string result.
	
	- parameter simpleReplacement1: Token is `|`
	- parameter simpleReplacement2: Token is `^`
	- parameter number: Tokens are `#` (number value), `<` `:` `>` (plural)
	- parameter genderMeIsMale: Tokens are `{` `₋` `}`
	- parameter genderOtherIsMale: Tokens are \` `¦` `´`
	- parameter boldAttrsChangesDescription: Token is `*`
	- parameter italicAttrsChangesDescription: Token is `_` */
	public func applyingAttrCommonTokens(
		simpleReplacement1: String? = nil,
		simpleReplacement2: String? = nil,
		number: XibLocNumber? = nil,
		genderMeIsMale: Bool? = nil,
		genderOtherIsMale: Bool? = nil,
		escapeToken: String? = di.defaultEscapeToken,
		baseFont: XibLocFont? = nil,
		baseColor: XibLocColor? = nil,
		baseAttributes: [NSAttributedString.Key: Any]? = di.defaultStr2AttrStrAttributes,
		boldAttrsChangesDescription: StringAttributesChangesDescription? = di.defaultBoldAttrsChangesDescription,
		italicAttrsChangesDescription: StringAttributesChangesDescription? = di.defaultItalicAttrsChangesDescription
	) -> NSAttributedString {
		return applying(xibLocInfo: CommonTokensGroup(
			simpleReplacement1: simpleReplacement1,
			simpleReplacement2: simpleReplacement2,
			number: number,
			genderMeIsMale: genderMeIsMale,
			genderOtherIsMale: genderOtherIsMale,
			escapeToken: escapeToken,
			baseFont: baseFont,
			baseColor: baseColor,
			baseAttributes: baseAttributes,
			boldAttrsChangesDescription: boldAttrsChangesDescription,
			italicAttrsChangesDescription: italicAttrsChangesDescription
		).str2AttrStrXibLocInfo)
	}
	
}

#endif

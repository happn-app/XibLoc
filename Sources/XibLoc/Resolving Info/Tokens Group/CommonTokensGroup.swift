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

The way this group has been build, **all** of the tokens are parsed, even if you
don’t use some of them. Even the bold or italic tokens are processed with the
string to string resolving info. They just don’t do anything but the tokens will
disappear from the string after processing.

TODO: Do we really want the behavior above? Initially the idea was to simplify
      escaping the tokens, but it turns out I forgot XibLoc simply remove an
      escape token if the token escapes nothing, so it does not really matter…

List of tokens:
- Escape: `~`
- Simple replacement 1: `|`
- Simple replacement 2: `^`
- Plural: `<` `:` `>`
- Plural value: `#`
- Gender me: `{` `₋` `}`
- Gender other: \` `¦` `´`
- Bold: `*`
- Italic: `_` */
public struct CommonTokensGroup {
	
	/** Token is `|` */
	public var simpleReplacement1: String
	/** Token is `^` */
	public var simpleReplacement2: String
	/** See discussion for the tokens.
	
	Tokens:
	- For the number replacement: `#`
	- For the plural value: `<` `:` `>` */
	public var number: XibLocNumber
	
	/** Tokens: `{` `₋` `}`
	- Important: The dash is not a standard dash… */
	public var genderMeIsMale: Bool
	/** Tokens: \` `¦` `´`
	
	(Xcode Formatting note: I did not find a way to specify the first token is
	code (because it’s the same token as the token used to specify we have code
	in Xcode comments). Doesn’t matter, it’s not really visible though.)*/
	public var genderOtherIsMale: Bool = true
	
	/** Defaults to `~` */
	public var escapeToken: String?
	
	public var baseFont: XibLocFont?
	public var baseColor: XibLocColor?
	public var baseAttributes: [NSAttributedString.Key: Any]?
	
	/** Token is `*` */
	public var boldAttrsChangesDescription: StringAttributesChangesDescription
	/** Token is `_` */
	public var italicAttrsChangesDescription: StringAttributesChangesDescription
	
	public init(
		simpleReplacement1 r1: String = "",
		simpleReplacement2 r2: String = "",
		number n: XibLocNumber = XibLocNumber(0),
		genderMeIsMale gm: Bool = true,
		genderOtherIsMale go: Bool = true,
		escapeToken e: String? = di.defaultEscapeToken,
		baseFont f: XibLocFont? = nil,
		baseColor c: XibLocColor? = nil,
		baseAttributes attrs: [NSAttributedString.Key: Any]? = di.defaultStr2AttrStrAttributes,
		boldAttrsChangesDescription boldAttrsChanges: StringAttributesChangesDescription = di.defaultBoldAttrsChangesDescription,
		italicAttrsChangesDescription italicAttrsChanges: StringAttributesChangesDescription = di.defaultItalicAttrsChangesDescription
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
				MultipleWordsTokens(leftToken: "{", interiorToken: "₋", rightToken: "}"): genderMeIsMale ? 0 : 1,
				MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´"): genderOtherIsMale ? 0 : 1
			],
			pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), number.pluralValue)],
			attributesModifications: [
				OneWordTokens(token: "*"): { _, _, _ in },
				OneWordTokens(token: "_"): { _, _, _ in }
			],
			simpleReturnTypeReplacements: [
				OneWordTokens(token: "|"): { _ in self.simpleReplacement1 },
				OneWordTokens(token: "^"): { _ in self.simpleReplacement2 },
				OneWordTokens(token: "#"): { _ in self.number.localizedString }
			],
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
				OneWordTokens(token: "|"): { _ in self.simpleReplacement1 },
				OneWordTokens(token: "^"): { _ in self.simpleReplacement2 },
				OneWordTokens(token: "#"): { _ in self.number.localizedString }
			],
			orderedReplacements: [
				MultipleWordsTokens(leftToken: "{", interiorToken: "₋", rightToken: "}"): genderMeIsMale ? 0 : 1,
				MultipleWordsTokens(leftToken: "`", interiorToken: "¦", rightToken: "´"): genderOtherIsMale ? 0 : 1
			],
			pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), number.pluralValue)],
			attributesModifications: [
				OneWordTokens(token: "*"): { attrStr, strRange, refStr in assert(refStr == attrStr.string); self.boldAttrsChangesDescription.apply(to: attrStr, range: NSRange(strRange, in: refStr)) },
				OneWordTokens(token: "_"): { attrStr, strRange, refStr in assert(refStr == attrStr.string); self.italicAttrsChangesDescription.apply(to: attrStr, range: NSRange(strRange, in: refStr)) },
			],
			simpleReturnTypeReplacements: [:],
			identityReplacement: { NSMutableAttributedString(string: $0, attributes: defaultAttributes) }
		)! /* We force unwrap because we _know_ these tokens are valid. */
	}
	
}

extension String {
	
	/** Apply a `CommonTokensGroup` on your string.
	
	Also applies tokens `*` and `_` as attributes replacements which do nothing.
	
	- parameter simpleReplacement1: Token is `|`
	- parameter simpleReplacement2: Token is `^`
	- parameter number: Tokens are `#` (number value), `<` `:` `>` (plural)
	- parameter genderMeIsMale: Tokens are `{` `₋` `}`
	- parameter genderOtherIsMale: Tokens are \` `¦` `´` */
	public func applyingCommonTokens(
		simpleReplacement1: String = "",
		simpleReplacement2: String = "",
		number: XibLocNumber = XibLocNumber(0),
		genderMeIsMale: Bool = true,
		genderOtherIsMale: Bool = true,
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
	public func applyingCommonAttrTokens(
		simpleReplacement1: String = "",
		simpleReplacement2: String = "",
		number: XibLocNumber = XibLocNumber(0),
		genderMeIsMale: Bool = true,
		genderOtherIsMale: Bool = true,
		escapeToken: String? = di.defaultEscapeToken,
		baseFont: XibLocFont? = nil,
		baseColor: XibLocColor? = nil,
		baseAttributes: [NSAttributedString.Key: Any]? = di.defaultStr2AttrStrAttributes,
		boldAttrsChangesDescription: StringAttributesChangesDescription = di.defaultBoldAttrsChangesDescription,
		italicAttrsChangesDescription: StringAttributesChangesDescription = di.defaultItalicAttrsChangesDescription
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

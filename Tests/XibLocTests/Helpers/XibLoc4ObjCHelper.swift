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

@testable import XibLoc



#if !os(Linux)
@objc
final class ObjCXibLoc : NSObject {
	
	@objc
	static func objc_applyingXibLocSimpleReplacementLocString(base: String, replacement: String) -> String {
		return base.applyingCommonTokens(simpleReplacement1: replacement)
	}
	
	@objc
	static func objc_applyingXibLocSimpleReplacementAndGenderLocString(base: String, replacement: String, genderMeIsMale: Bool, genderOtherIsMale: Bool) -> String {
		return base.applyingCommonTokens(simpleReplacement1: replacement, genderMeIsMale: genderMeIsMale, genderOtherIsMale: genderOtherIsMale)
	}
	
	@objc
	static func objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPlural(base: String, baseFont: XibLocFont, baseColor: XibLocColor, replacement: String, pluralValue: Int, genderMeIsMale: Bool, genderOtherIsMale: Bool) throws -> NSMutableAttributedString {
		return NSMutableAttributedString(
			attributedString: base.applyingCommonAttrTokens(simpleReplacement1: replacement, number: XibLocNumber(pluralValue), genderMeIsMale: genderMeIsMale, genderOtherIsMale: genderOtherIsMale, baseFont: baseFont, baseColor: baseColor)
		)
	}
	
	@objc
	static func objc_applyingXibLocTransformForCustomBold(base: String, baseFont: XibLocFont, baseColor: XibLocColor, boldToken: String) throws -> NSMutableAttributedString {
		return try base.applying(xibLocInfo: XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [:],
			pluralGroups: [],
			attributesModifications: [OneWordTokens(token: boldToken): { attrStr, strRange, refStr in StringAttributesChangesDescription(changes: [.setBold]).apply(to: attrStr, range: NSRange(strRange, in: refStr)) }],
			simpleReturnTypeReplacements: [:], identityReplacement: { NSMutableAttributedString(string: $0, attributes: [.font: baseFont, .foregroundColor: baseColor]) }
		).get())
	}
	
	/**
	Set bold or italic to 0 for no bold/italic, 1 to set it, -1 to leave as-is. */
	@objc
	static func setBoldOrItalic(in base: NSMutableAttributedString, bold: Int, italic: Int, range: NSRange) {
		func intToOptBool(_ i: Int) -> Bool? {
			switch i {
			case -1: return nil
			case  0: return false
			default: return true
			}
		}
		base.setBoldOrItalic(bold: intToOptBool(bold), italic: intToOptBool(italic), range: range)
	}
	
	private override init() {}
	
}
#endif

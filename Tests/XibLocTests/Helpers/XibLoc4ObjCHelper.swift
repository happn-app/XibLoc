/*
 * XibLoc4ObjCHelper.swift
 * XibLocTests
 *
 * Created by François Lamboley on 18/03/2019.
 * Copyright © 2019 happn. All rights reserved.
 */

import Foundation

import XibLoc



@objc
final class ObjCXibLoc : NSObject {
	
	@objc
	static func objc_applyingXibLocSimpleReplacementLocString(base: String, replacement: String) -> String {
		return base.applying(xibLocInfo: Str2StrXibLocInfo(replacement: replacement))
	}
	
	@objc
	static func objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPlural(base: String, baseFont: XibLocFont, baseColor: XibLocColor, replacement: String, pluralValue: Int, genderMeIsMale: Bool, genderOtherIsMale: Bool) -> NSMutableAttributedString {
		return base.applying(xibLocInfo: Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(replacement: replacement, pluralValue: NumberAndFormat(pluralValue), genderMeIsMale: genderMeIsMale, genderOtherIsMale: genderOtherIsMale),
			boldType: .custom(.boldSystemFont(ofSize: 1)), baseFont: baseFont, baseColor: baseColor
		))
	}
	
	private override init() {}
	
}

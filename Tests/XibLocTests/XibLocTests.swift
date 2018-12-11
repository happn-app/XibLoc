/*
 * XibLocTests.swift
 * XibLocTests
 *
 * Created by François Lamboley on 8/26/17.
 * Copyright © 2017 happn. All rights reserved.
 */

import XCTest
@testable import XibLoc



class XibLocTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		di.defaultEscapeToken = "\\"
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testEscapedSimpleReplacement() {
		let info = XibLocResolvingInfo(simpleReplacementWithToken: "|", value: "replacement")
		XCTAssertEqual(
			"the \\|replaced\\|".applying(xibLocInfo: info),
			"the |replaced|"
		)
	}
	
	func testNonEscapedButPrecededByEscapeTokenSimpleReplacement() {
		let info = XibLocResolvingInfo(simpleReplacementWithToken: "|", value: "replacement")
		XCTAssertEqual(
			"the \\\\|replaced|".applying(xibLocInfo: info),
			"the \\replacement"
		)
	}
	
	func testOneSimpleReplacement() {
		let info = XibLocResolvingInfo(simpleReplacementWithToken: "|", value: "replacement")
		XCTAssertEqual(
			"the |replaced|".applying(xibLocInfo: info),
			"the replacement"
		)
	}
	
	func testOneOrderedReplacement1() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
			pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"the <first:second>".applying(xibLocInfo: info),
			"the first"
		)
	}
	
	func testOneOrderedReplacement2() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
			pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"the <first:second>".applying(xibLocInfo: info),
			"the second"
		)
	}
	
	func testOneOrderedReplacementTwice() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
			pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"the <first:second> and also <first here:second here>".applying(xibLocInfo: info),
			"the first and also first here"
		)
	}
	
	func testOneOrderedReplacementAboveMax() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 2],
			pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"the <first:second>".applying(xibLocInfo: info),
			"the second"
		)
	}
	
	func testOnePluralReplacement() {
		let n = 1
		var nStr = ""
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(string: "(1)(*)"), escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { o in nStr = o; return "\(n)" }],
			orderedReplacements: [:],
			pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), .int(n))], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"#n# <house:houses>".applying(xibLocInfo: info),
			"1 house"
		)
		XCTAssertEqual(nStr, "n")
	}
	
	func testOnePluralReplacementMissingOneZone() {
		let n = 2
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(string: "(1)(2→4:^*[^1][2→4]$)?(*)"), escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { _ in "\(n)" }],
			orderedReplacements: [:],
			pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), .int(n))], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"#n# <house:houses>".applying(xibLocInfo: info),
			"2 houses"
		)
	}
	
	func testOneOrderedReplacementAndSimpleReplacement1() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "first" }],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
			pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"the <|fiftieth|:second>".applying(xibLocInfo: info),
			"the first"
		)
		XCTAssertEqual(
			"the <|1st|:second>".applying(xibLocInfo: info),
			"the first"
		)
		XCTAssertEqual(
			"the <||:second>".applying(xibLocInfo: info),
			"the first"
		)
	}
	
	func testOneOrderedReplacementAndSimpleReplacement2() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "first" }],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
			pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		XCTAssertEqual(
			"the <|fiftieth|:second>".applying(xibLocInfo: info),
			"the second"
		)
	}
	
	func testThaiGender() {
		let str = "`a¦b´ต้`a¦b´"
		let info = Str2StrXibLocInfo(genderOtherIsMale: true)
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			"aต้a"
		)
	}
	
	/* TBH, this is the same test as testThaiGender... */
	func testEmojiGender() {
		let str = "`a¦b´🤷‍♂️`a¦b´"
		let info = Str2StrXibLocInfo(genderOtherIsMale: true)
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			"a🤷‍♂️a"
		)
	}
	
	func testEmojiGenderBis() {
		let str = "`a¦b´🧒🏻`a¦b´"
		let info = Str2StrXibLocInfo(genderOtherIsMale: true)
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			"a🧒🏻a"
		)
	}
	
	func testInvalidOverlappingReplacements() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "*"): { w in "<b>" + w + "</b>" }, OneWordTokens(token: "_"): { w in "<i>" + w + "</i>" }],
			orderedReplacements: [:], pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
			dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		let r = "the *bold _and* italic_".applying(xibLocInfo: info)
		XCTAssertTrue(r == "the *bold <i>and* italic</i>" || r == "the <b>bold _and</b> italic_")
	}
	
	func testTwoVariablesChangesInOrderedReplacementGroup() {
		let info = Str2StrXibLocInfo(replacement: "sᴉoɔuɐɹℲ", pluralValue: NumberAndFormat(42))
		let result = "42 months for sᴉoɔuɐɹℲ/month"
		XCTAssertEqual(
			"<#n# month for |string var|/month:#n# months for |string var|/month>".applying(xibLocInfo: info),
			result
		)
	}
	
	func testTwoVariablesChangesAndGenderInOrderedReplacementGroup() {
		let info = Str2StrXibLocInfo(replacement: "sᴉoɔuɐɹℲ", pluralValue: NumberAndFormat(42), genderOtherIsMale: false)
		let result = "42 months for sᴉoɔuɐɹℲ/year"
		XCTAssertEqual(
			"<#n# month for |string var|/month:#n# months for |string var|/`month¦year´>".applying(xibLocInfo: info),
			result
		)
	}
	
	func testEmbeddedSimpleReplacements() {
		let info = Str2StrXibLocInfo(replacements: ["#": "42", "|": "replacement_value"])
		XCTAssertEqual(
			"Let's replace |#some text#|".applying(xibLocInfo: info),
			"Let's replace replacement_value"
		)
	}
	
	#if os(macOS)
	/* ************************
	   MARK: - macOS Only Tests
	   ************************ */
	
	/* The tests below are only macOS compatible. Other oses either do not have
	 * NSAttributedString (Linux), or do not have the necessary attributes to
	 * test attributed strings (we could find one, be there is no need, really). */
	
	func testOneOrderedReplacementAndIdentityAttributeModification1() {
		let info = XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
			pluralGroups: [],
			attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
			simpleReturnTypeReplacements: [:], dictionaryReplacements: nil, identityReplacement: { NSMutableAttributedString(string: $0) }
		)
		let result = NSMutableAttributedString(string: "the ")
		result.append(NSAttributedString(string: "first", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
		XCTAssertEqual(
			"the <$first$:second>".applying(xibLocInfo: info),
			result
		)
	}
	
	func testOneOrderedReplacementAndIdentityAttributeModification2() {
		let info = XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
			pluralGroups: [],
			attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
			simpleReturnTypeReplacements: [:], dictionaryReplacements: nil, identityReplacement: { NSMutableAttributedString(string: $0) }
		)
		XCTAssertEqual(
			"the <$first$:second>".applying(xibLocInfo: info),
			NSMutableAttributedString(string: "the second")
		)
	}
	
	func testOneOrderedReplacementAndIdentityAttributeModification3() {
		let info = XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
			pluralGroups: [],
			attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
			simpleReturnTypeReplacements: [:], dictionaryReplacements: nil, identityReplacement: { NSMutableAttributedString(string: $0) }
		)
		let result = NSMutableAttributedString(string: "the ")
		result.append(NSAttributedString(string: "first", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
		XCTAssertEqual(
			"the $<first:second>$".applying(xibLocInfo: info),
			result
		)
	}
	
	func testOneOrderedReplacementAndIdentityAttributeModification4() {
		let info = XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
			pluralGroups: [],
			attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
			simpleReturnTypeReplacements: [:], dictionaryReplacements: nil, identityReplacement: { NSMutableAttributedString(string: $0) }
		)
		let result = NSMutableAttributedString(string: "the ")
		result.append(NSAttributedString(string: "second", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
		XCTAssertEqual(
			"the $<first:second>$".applying(xibLocInfo: info),
			result
		)
	}
	
	func testOneAttributesChange() {
		let info = XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:], orderedReplacements: [:], pluralGroups: [],
			attributesModifications: [OneWordTokens(token: "*"): helperAddTestAttributeLevel],
			simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { NSMutableAttributedString(string: $0) }
		)
		let result = NSMutableAttributedString(string: "the ")
		result.append(NSAttributedString(string: "test", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
		XCTAssertEqual(
			"the *test*".applying(xibLocInfo: info),
			result
		)
	}
	
	func testOneAttributesChangeTwice() {
		let info = XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:], orderedReplacements: [:], pluralGroups: [],
			attributesModifications: [OneWordTokens(token: "*"): helperAddTestAttributeLevel],
			simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { NSMutableAttributedString(string: $0) }
		)
		let result = NSMutableAttributedString(string: "the ")
		result.append(NSAttributedString(string: "testtwice", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
		XCTAssertEqual(
			"the *test**twice*".applying(xibLocInfo: info),
			result
		)
	}
	
	func testTwoOverlappingAttributesChange() {
		let info = XibLocResolvingInfo<String, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [:], orderedReplacements: [:], pluralGroups: [],
			attributesModifications: [
				OneWordTokens(token: "*"): helperAddTestAttributeLevel,
				OneWordTokens(token: "_"): helperAddTestAttributeIndex
			], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { NSMutableAttributedString(string: $0) }
		)
		let result = NSMutableAttributedString(string: "the test ")
		result.append(NSAttributedString(string: "one ", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
		result.append(NSAttributedString(string: "and", attributes: [.accessibilityListItemLevel: NSNumber(value: 0), .accessibilityListItemIndex: NSNumber(value: 0)]))
		result.append(NSAttributedString(string: " two", attributes: [.accessibilityListItemIndex: NSNumber(value: 0)]))
		XCTAssertEqual(
			"the test *one _and* two_".applying(xibLocInfo: info),
			result
		)
	}
	
	func testApplyingOnStringTwice() {
		let info = XibLocResolvingInfo<String, String>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "replaced" }], orderedReplacements: [:], pluralGroups: [],
			attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		let tested = "the test |replacement|"
		let parsedXibLoc = ParsedXibLoc(source: tested, parserHelper: StringParserHelper.self, forXibLocResolvingInfo: info)
		XCTAssertEqual(
			parsedXibLoc.resolve(xibLocResolvingInfo: info, returnTypeHelperType: StringParserHelper.self),
			"the test replaced"
		)
		XCTAssertEqual(
			parsedXibLoc.resolve(xibLocResolvingInfo: info, returnTypeHelperType: StringParserHelper.self),
			"the test replaced"
		)
	}
	
	func testApplyingOnMutableAttributedStringTwice() {
		let info = XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>(
			defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in NSMutableAttributedString(string: "replaced") }], orderedReplacements: [:], pluralGroups: [],
			attributesModifications: [:], simpleReturnTypeReplacements: [:], dictionaryReplacements: nil,
			identityReplacement: { $0 }
		)
		let tested = NSMutableAttributedString(string: "the test |replacement|")
		let parsedXibLoc = ParsedXibLoc(source: tested, parserHelper: NSMutableAttributedStringParserHelper.self, forXibLocResolvingInfo: info)
		XCTAssertEqual(
			parsedXibLoc.resolve(xibLocResolvingInfo: info, returnTypeHelperType: NSMutableAttributedStringParserHelper.self),
			NSMutableAttributedString(string: "the test replaced")
		)
		XCTAssertEqual(
			parsedXibLoc.resolve(xibLocResolvingInfo: info, returnTypeHelperType: NSMutableAttributedStringParserHelper.self),
			NSMutableAttributedString(string: "the test replaced")
		)
	}
	
	func testVariableChangeAfterAttrChangeInOrderedReplacementGroup1() {
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(replacement: "sᴉoɔuɐɹℲ", genderOtherIsMale: true),
			boldType: .default, baseFont: baseFont, baseColor: baseColor
		)
		let result = NSMutableAttributedString(string: "Yo sᴉoɔuɐɹℲ", attributes: [.font: baseFont, .foregroundColor: baseColor])
		result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: 2))
		XCTAssertEqual(
			"`*Yo* |username|¦Nope. We don’t greet women.´".applying(xibLocInfo: info),
			result
		)
		XCTAssertEqual(
			"`*Yo* |username|¦*Hey* |username|!´".applying(xibLocInfo: info),
			result
		)
	}
	
	func testVariableChangeAfterAttrChangeInOrderedReplacementGroup2() {
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(replacement: "sᴉoɔuɐɹℲ", genderOtherIsMale: false),
			boldType: .default, baseFont: baseFont, baseColor: baseColor
		)
		let result = NSMutableAttributedString(string: "Yo sᴉoɔuɐɹℲ", attributes: [.font: baseFont, .foregroundColor: baseColor])
		result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: 2))
		XCTAssertEqual(
			"`Nope. We don’t greet women.¦*Yo* |username|´".applying(xibLocInfo: info),
			result
		)
		XCTAssertEqual(
			"`*Hey* |username|!¦*Yo* |username|´".applying(xibLocInfo: info),
			result
		)
	}
	
	func testOverlappingAttributesChangesWithPluralInTheMiddle() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "abcdefghijklmnqrstuvwxyzABCDEFGHIJKLMNOP", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 4, length: 13))
		result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 9, length: 13))
		XCTAssertEqual(
			"abcd*efghi_jkl<mn:op>qrs*tuvwx_yzABCDEFGHIJKLMNOP".applying(xibLocInfo: info),
			result
		)
	}
	
	func testFromHappn1() {
		let str = "{*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!₋*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकती हैं कि आपको किसने पसंद किया!}"
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(replacement: "", pluralValue: NumberAndFormat(0), genderMeIsMale: true, genderOtherIsMale: true),
			boldType: .default, baseFont: baseFont, baseColor: baseColor
		)
		let result = NSMutableAttributedString(string: "CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!", attributes: [.font: baseFont, .foregroundColor: baseColor])
		result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: 15))
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			result
		)
	}
	
	func testFromHappn1Bis() {
		let str = "{CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!₋CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकती हैं कि आपको किसने पसंद किया!}"
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(replacement: "", pluralValue: NumberAndFormat(0), genderMeIsMale: true, genderOtherIsMale: true),
			boldType: .default, baseFont: baseFont, baseColor: baseColor
		)
		let result = NSMutableAttributedString(string: "CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!", attributes: [.font: baseFont, .foregroundColor: baseColor])
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			result
		)
	}
	
	func testFromHappn1Ter() {
		let str = "*लें*"
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(replacement: "", pluralValue: NumberAndFormat(0), genderMeIsMale: true, genderOtherIsMale: true),
			boldType: .default, baseFont: baseFont, baseColor: baseColor
		)
		let resultStr = "लें"
		let result = NSMutableAttributedString(string: resultStr, attributes: [.font: baseFont, .foregroundColor: baseColor])
		result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			result
		)
	}
	
	/* Same as Ter TBH… */
	func testFromHappn1Quater() {
		let str = "*🧒🏻*"
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(replacement: "", pluralValue: NumberAndFormat(0), genderMeIsMale: true, genderOtherIsMale: true),
			boldType: .default, baseFont: baseFont, baseColor: baseColor
		)
		let resultStr = "🧒🏻"
		let result = NSMutableAttributedString(string: resultStr, attributes: [.font: baseFont, .foregroundColor: baseColor])
		result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			result
		)
	}
	
	func testFromHappn1Quinquies() {
		let str = "🧒🏻*🧒🏻"
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(identityReplacement: { $0 }),
			attributesReplacements: [OneWordTokens(token: "🧒🏻"): StringAttributesChangesDescription(changes: [.setBold])], returnTypeReplacements: nil,
			defaultAttributes: [.font: baseFont, .foregroundColor: baseColor]
		)
		let resultStr = "*"
		let result = NSMutableAttributedString(string: resultStr, attributes: [.font: baseFont, .foregroundColor: baseColor])
		result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			result
		)
	}
	
	func testFromHappn1Sexies() {
		let str = "🧒🏻👳🏿‍♀️🧒🏻"
		let baseColor = XibLocColor.black
		let baseFont = XibLocFont.systemFont(ofSize: 14)
		let info = Str2AttrStrXibLocInfo(
			strResolvingInfo: Str2StrXibLocInfo(identityReplacement: { $0 }),
			attributesReplacements: [OneWordTokens(token: "🧒🏻"): StringAttributesChangesDescription(changes: [.setBold])], returnTypeReplacements: nil,
			defaultAttributes: [.font: baseFont, .foregroundColor: baseColor]
		)
		let resultStr = "👳🏿‍♀️"
		let result = NSMutableAttributedString(string: resultStr, attributes: [.font: baseFont, .foregroundColor: baseColor])
		result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
		XCTAssertEqual(
			str.applying(xibLocInfo: info),
			result
		)
	}
	
	/* ***** Doc Cases Tests ***** */
	/* Config:
	 *    "*" is a left and right token for an attributes modification
	 *    "_" is a left and right token for an attributes modification
	 *    "|" is a left and right token for a simple replacement
	 *    "<" ":" ">" are resp. a left, interior and right tokens for an ordered replacement. */
	
	func testDocCase1() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 19))
		result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 10))
		XCTAssertEqual(
			"This text will be *bold _and italic_ too*!".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase2() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 19))
		result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 14))
		XCTAssertEqual(
			"This text will be *bold _and italic too*_!".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase3() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 19))
		result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 14))
		XCTAssertEqual(
			"This text will be *bold _and italic too_*!".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase4() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 8))
		result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 14))
		XCTAssertEqual(
			"This text will be *bold _and* italic too_!".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase5() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "replacement_value to be replaced", attributes: baseAttributes)
		XCTAssertEqual(
			"|*some text*| to be replaced".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase6() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "Let's replace replacement_value", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
		XCTAssertEqual(
			"Let's replace *|some text|*".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase6Variant() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "Let's replace replacement_value", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
		result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
		XCTAssertEqual(
			"Let's replace _<*|some text|*:val2>_".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase7() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "Let's replace with either this is chosen or nope", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 26, length: 4))
		XCTAssertEqual(
			"Let's replace with either <*this* is chosen:nope> or <nope:_that_>".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase8() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "Let's replace with either this is chosen or nope", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 26, length: 22))
		result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 44, length: 4))
		XCTAssertEqual(
			"Let's replace with either *<this is chosen:_nope_> or <_nope_:that>*".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase9() {
		let (info, baseAttributes) = docCasesInfo
		let result1 = NSMutableAttributedString(string: "Let's replace *replacement_value", attributes: baseAttributes)
		let result2 = NSMutableAttributedString(string: "Let's replace |some text|", attributes: baseAttributes)
		result2.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 5))
		let processed = "Let's replace *|some* text|".applying(xibLocInfo: info)
		XCTAssert(processed == result1 || processed == result2)
	}
	
	func testDocCase10() {
		let (info, baseAttributes) = docCasesInfo
		let result = NSMutableAttributedString(string: "Let's replace multiple", attributes: baseAttributes)
		result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 8))
		XCTAssertEqual(
			"Let's replace <*multiple*:*choices*:stuff>".applying(xibLocInfo: info),
			result
		)
	}
	
	func testDocCase11() {
		let (info, baseAttributes) = docCasesInfo
		let result1 = NSMutableAttributedString(string: "Let's replace *multiple", attributes: baseAttributes)
		let result2 = NSMutableAttributedString(string: "Let's replace <multiple:choices:stuff>", attributes: baseAttributes)
		result2.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
		let processed = "Let's replace *<multiple:choices*:stuff>".applying(xibLocInfo: info)
		XCTAssert(processed == result1 || processed == result2)
	}
	
	func testDocCase12() {
		let (info, baseAttributes) = docCasesInfo
		let result1 = NSMutableAttributedString(string: "Let's replace *multiple", attributes: baseAttributes)
		let result2 = NSMutableAttributedString(string: "Let's replace <multiple:choices:stuff>", attributes: baseAttributes)
		result2.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 15, length: 16))
		let processed = "Let's replace <*multiple:choices*:stuff>".applying(xibLocInfo: info)
		XCTAssert(processed == result1 || processed == result2)
	}
	
	
	func helperAddTestAttributeLevel(to attributedString: inout NSMutableAttributedString, strRange: Range<String.Index>, refStr: String) {
		attributedString.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(strRange, in: refStr))
	}
	
	func helperAddTestAttributeIndex(to attributedString: inout NSMutableAttributedString, strRange: Range<String.Index>, refStr: String) {
		attributedString.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(strRange, in: refStr))
	}
	
	lazy var docCasesInfo: (Str2AttrStrXibLocInfo, [NSAttributedString.Key: Any]) = {
		let baseAttributes: [NSAttributedString.Key: Any] = [.font: XibLocFont.systemFont(ofSize: 14), .foregroundColor: XibLocColor.black]
		let info = Str2AttrStrXibLocInfo(
			escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "replacement_value" }],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
			attributesModifications: [
				OneWordTokens(token: "*"): helperAddTestAttributeIndex,
				OneWordTokens(token: "_"): helperAddTestAttributeLevel
			],
			identityReplacement: { NSMutableAttributedString(string: $0, attributes: baseAttributes) }
		)
		return (info, baseAttributes)
	}()
	
	#endif
	
	
	/* Fill this array with all the tests to have Linux testing compatibility. */
	static var allTests = [
		("testEscapedSimpleReplacement", testEscapedSimpleReplacement),
		("testNonEscapedButPrecededByEscapeTokenSimpleReplacement", testNonEscapedButPrecededByEscapeTokenSimpleReplacement),
		("testOneSimpleReplacement", testOneSimpleReplacement),
		("testOneOrderedReplacement1", testOneOrderedReplacement1),
		("testOneOrderedReplacement2", testOneOrderedReplacement2),
		("testOneOrderedReplacementTwice", testOneOrderedReplacementTwice),
		("testOneOrderedReplacementAboveMax", testOneOrderedReplacementAboveMax),
		("testOnePluralReplacement", testOnePluralReplacement),
		("testOnePluralReplacementMissingOneZone", testOnePluralReplacementMissingOneZone),
		("testOneOrderedReplacementAndSimpleReplacement1", testOneOrderedReplacementAndSimpleReplacement1),
		("testOneOrderedReplacementAndSimpleReplacement2", testOneOrderedReplacementAndSimpleReplacement2),
		("testThaiGender", testThaiGender),
		("testEmojiGender", testEmojiGender),
		("testEmojiGenderBis", testEmojiGenderBis),
		("testInvalidOverlappingReplacements", testInvalidOverlappingReplacements),
		("testTwoVariablesChangesInOrderedReplacementGroup", testTwoVariablesChangesInOrderedReplacementGroup),
		("testTwoVariablesChangesAndGenderInOrderedReplacementGroup", testTwoVariablesChangesAndGenderInOrderedReplacementGroup),
		("testEmbeddedSimpleReplacements", testEmbeddedSimpleReplacements),
		
		/* Not Linux compatible. */
//		("testOneOrderedReplacementAndIdentityAttributeModification1", testOneOrderedReplacementAndIdentityAttributeModification1),
//		("testOneOrderedReplacementAndIdentityAttributeModification2", testOneOrderedReplacementAndIdentityAttributeModification2),
//		("testOneOrderedReplacementAndIdentityAttributeModification3", testOneOrderedReplacementAndIdentityAttributeModification3),
//		("testOneOrderedReplacementAndIdentityAttributeModification4", testOneOrderedReplacementAndIdentityAttributeModification4),
//		("testOneAttributesChange", testOneAttributesChange),
//		("testOneAttributesChangeTwice", testOneAttributesChangeTwice),
//		("testTwoOverlappingAttributesChange", testTwoOverlappingAttributesChange),
//		("testApplyingOnStringTwice", testApplyingOnStringTwice),
//		("testApplyingOnMutableAttributedStringTwice", testApplyingOnMutableAttributedStringTwice),
//		("testVariableChangeAfterAttrChangeInOrderedReplacementGroup1", testVariableChangeAfterAttrChangeInOrderedReplacementGroup1),
//		("testVariableChangeAfterAttrChangeInOrderedReplacementGroup2", testVariableChangeAfterAttrChangeInOrderedReplacementGroup2),
//		("testOverlappingAttributesChangesWithPluralInTheMiddle", testOverlappingAttributesChangesWithPluralInTheMiddle),
//		("testFromHappn1", testFromHappn1),
//		("testFromHappn1Bis", testFromHappn1Bis),
//		("testFromHappn1Ter", testFromHappn1Ter),
//		("testFromHappn1Quater", testFromHappn1Quater),
//		("testFromHappn1Quinquies", testFromHappn1Quinquies),
//		("testFromHappn1Sexies", testFromHappn1Sexies),
//		("testDocCase1", testDocCase1),
//		("testDocCase2", testDocCase2),
//		("testDocCase3", testDocCase3),
//		("testDocCase4", testDocCase4),
//		("testDocCase5", testDocCase5),
//		("testDocCase6", testDocCase6),
//		("testDocCase6Variant", testDocCase6Variant),
//		("testDocCase7", testDocCase7),
//		("testDocCase8", testDocCase8),
//		("testDocCase9", testDocCase9),
//		("testDocCase10", testDocCase10),
//		("testDocCase11", testDocCase11),
//		("testDocCase12", testDocCase12),
	]
	
}

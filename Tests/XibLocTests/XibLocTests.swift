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
	
	func testVariableChangeAfterAttrChangeInOrderedReplacementGroup() {
		let baseColor = XibLocColor.white
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
	
	
	func helperAddTestAttributeLevel(to attributedString: inout NSMutableAttributedString, strRange: Range<String.Index>, refStr: String) {
		attributedString.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(strRange, in: refStr))
	}
	
	func helperAddTestAttributeIndex(to attributedString: inout NSMutableAttributedString, strRange: Range<String.Index>, refStr: String) {
		attributedString.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(strRange, in: refStr))
	}
	
	
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
		("testOneOrderedReplacementAndIdentityAttributeModification1", testOneOrderedReplacementAndIdentityAttributeModification1),
		("testOneOrderedReplacementAndIdentityAttributeModification2", testOneOrderedReplacementAndIdentityAttributeModification2),
		("testOneOrderedReplacementAndIdentityAttributeModification3", testOneOrderedReplacementAndIdentityAttributeModification3),
		("testOneOrderedReplacementAndIdentityAttributeModification4", testOneOrderedReplacementAndIdentityAttributeModification4),
		("testOneAttributesChange", testOneAttributesChange),
		("testTwoOverlappingAttributesChange", testTwoOverlappingAttributesChange),
		("testApplyingOnStringTwice", testApplyingOnStringTwice),
		("testApplyingOnMutableAttributedStringTwice", testApplyingOnMutableAttributedStringTwice),
		("testInvalidOverlappingReplacements", testInvalidOverlappingReplacements),
		("testVariableChangeAfterAttrChangeInOrderedReplacementGroup", testVariableChangeAfterAttrChangeInOrderedReplacementGroup)
	]
	
}

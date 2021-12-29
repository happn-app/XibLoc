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

import XCTest
@testable import XibLoc



#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

class XibLocTestsSwiftNSAttrStr : XCTestCase {
	
	/* All tests are repeated a few times in a loop as we actually got random crashes (first found was testFromHappn4/testFromHappn3ObjC; Swift should be good but who knows…). */
	let nRepeats = 150
	
	override func setUp() {
		super.setUp()
		
		Conf.cache = nil
		Conf.defaultEscapeToken = #"\"#
		Conf.defaultPluralityDefinition = PluralityDefinition()
		
		Conf.defaultStr2NSAttrStrAttributes = [
			.font: XibLocFont.systemFont(ofSize: 14),
			.foregroundColor: XibLocColor.black
		]
		
		Conf.defaultBoldAttrsChangesDescription = StringAttributesChangesDescription(changes: [.setBold])
		Conf.defaultItalicAttrsChangesDescription = nil
		
#if canImport(os)
		if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
			Conf.oslog = nil
		}
#endif
		Conf.logger = nil
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testCommonTokensGroupDocCaseAttrStr() {
		let nRepeats = 1
		for _ in 0..<nRepeats {
			/* Set needed defaults like in the doc. */
			Conf.defaultEscapeToken = "~"
			Conf.defaultItalicAttrsChangesDescription = StringAttributesChangesDescription(changes: [.setItalic])
			let info = CommonTokensGroup().str2NSAttrStrXibLocInfo
			
			print(info)
			let result = NSMutableAttributedString(string: "helloworldhowareyou", attributes: Conf.defaultStr2NSAttrStrAttributes!)
			Conf.defaultItalicAttrsChangesDescription?.nsapply(to: result, range: NSRange(location: 5, length: 5))
			Conf.defaultItalicAttrsChangesDescription?.nsapply(to: result, range: NSRange(location: 13, length: 3))
			
			XCTAssertEqual(
				"hello_world_how_are_you".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* Actually, the same as testFromHappn3ObjC */
	func testFromHappn4() throws {
		for _ in 0..<nRepeats {
			let info = CommonTokensGroup(genderMeIsMale: true, genderOtherIsMale: false).str2StrXibLocInfo
			XCTAssertEqual(
				Utils.localized("crossed path for the first time").applying(xibLocInfo: info),
				"Vous vous êtes croisés"
			)
		}
	}
	
#if os(macOS)
	/* ************************
	   MARK: - macOS Only Tests
	   ************************ */
	
	/* The tests below are only macOS compatible.
	 * Other oses either do not have NSAttributedString (Linux), or do not have the necessary attributes to test attributed strings (we could find one, be there is no need, really). */
	
	func testOneOrderedReplacementAndIdentityAttributeModification1() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
				pluralGroups: [],
				attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
				simpleReturnTypeReplacements: [:], identityReplacement: { NSMutableAttributedString(string: $0) }
			).get()
			let result = NSMutableAttributedString(string: "the ")
			result.append(NSAttributedString(string: "first", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
			XCTAssertEqual(
				"the <$first$:second>".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testOneOrderedReplacementAndIdentityAttributeModification2() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
				pluralGroups: [],
				attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
				simpleReturnTypeReplacements: [:], identityReplacement: { NSMutableAttributedString(string: $0) }
			).get()
			XCTAssertEqual(
				"the <$first$:second>".applying(xibLocInfo: info),
				NSMutableAttributedString(string: "the second")
			)
		}
	}
	
	func testOneOrderedReplacementAndIdentityAttributeModification3() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
				pluralGroups: [],
				attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
				simpleReturnTypeReplacements: [:], identityReplacement: { NSMutableAttributedString(string: $0) }
			).get()
			let result = NSMutableAttributedString(string: "the ")
			result.append(NSAttributedString(string: "first", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
			XCTAssertEqual(
				"the $<first:second>$".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testOneOrderedReplacementAndIdentityAttributeModification4() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
				pluralGroups: [],
				attributesModifications: [OneWordTokens(token: "$"): helperAddTestAttributeLevel],
				simpleReturnTypeReplacements: [:], identityReplacement: { NSMutableAttributedString(string: $0) }
			).get()
			let result = NSMutableAttributedString(string: "the ")
			result.append(NSAttributedString(string: "second", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
			XCTAssertEqual(
				"the $<first:second>$".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testOneAttributesChange() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:], orderedReplacements: [:], pluralGroups: [],
				attributesModifications: [OneWordTokens(token: "*"): helperAddTestAttributeLevel],
				simpleReturnTypeReplacements: [:],
				identityReplacement: { NSMutableAttributedString(string: $0) }
			).get()
			let result = NSMutableAttributedString(string: "the ")
			result.append(NSAttributedString(string: "test", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
			XCTAssertEqual(
				"the *test*".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testOneAttributesChangeTwice() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:], orderedReplacements: [:], pluralGroups: [],
				attributesModifications: [OneWordTokens(token: "*"): helperAddTestAttributeLevel],
				simpleReturnTypeReplacements: [:],
				identityReplacement: { NSMutableAttributedString(string: $0) }
			).get()
			let result = NSMutableAttributedString(string: "the ")
			result.append(NSAttributedString(string: "testtwice", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
			XCTAssertEqual(
				"the *test**twice*".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testTwoOverlappingAttributesChange() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:], orderedReplacements: [:], pluralGroups: [],
				attributesModifications: [
					OneWordTokens(token: "*"): helperAddTestAttributeLevel,
					OneWordTokens(token: "_"): helperAddTestAttributeIndex
				], simpleReturnTypeReplacements: [:],
				identityReplacement: { NSMutableAttributedString(string: $0) }
			).get()
			let result = NSMutableAttributedString(string: "the test ")
			result.append(NSAttributedString(string: "one ", attributes: [.accessibilityListItemLevel: NSNumber(value: 0)]))
			result.append(NSAttributedString(string: "and", attributes: [.accessibilityListItemLevel: NSNumber(value: 0), .accessibilityListItemIndex: NSNumber(value: 0)]))
			result.append(NSAttributedString(string: " two", attributes: [.accessibilityListItemIndex: NSNumber(value: 0)]))
			XCTAssertEqual(
				"the test *one _and* two_".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testApplyingOnStringTwice() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "replaced" }], orderedReplacements: [:], pluralGroups: [],
				attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
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
	}
	
	func testApplyingOnMutableAttributedStringTwice() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<NSMutableAttributedString, NSMutableAttributedString>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in NSMutableAttributedString(string: "replaced") }], orderedReplacements: [:], pluralGroups: [],
				attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
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
	}
	
	func testVariableChangeAfterAttrChangeInOrderedReplacementGroup1() throws {
		for _ in 0..<nRepeats {
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(simpleReplacement1: "sᴉoɔuɐɹℲ", genderOtherIsMale: true).str2NSAttrStrXibLocInfo
			let result = NSMutableAttributedString(string: "Yo sᴉoɔuɐɹℲ", attributes: Conf.defaultStr2NSAttrStrAttributes!)
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
	}
	
	func testVariableChangeAfterAttrChangeInOrderedReplacementGroup2() throws {
		for _ in 0..<nRepeats {
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(simpleReplacement1: "sᴉoɔuɐɹℲ", genderOtherIsMale: false).str2NSAttrStrXibLocInfo
			let result = NSMutableAttributedString(string: "Yo sᴉoɔuɐɹℲ", attributes: Conf.defaultStr2NSAttrStrAttributes!)
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
	}
	
	func testOverlappingAttributesChangesWithPluralInTheMiddle() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "abcdefghijklmnqrstuvwxyzABCDEFGHIJKLMNOP", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 4, length: 13))
			result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 9, length: 13))
			XCTAssertEqual(
				"abcd*efghi_jkl<mn:op>qrs*tuvwx_yzABCDEFGHIJKLMNOP".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* Also exists in ObjC */
	func testFromHappn1() throws {
		for _ in 0..<nRepeats {
			let str = "{*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!₋*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकती हैं कि आपको किसने पसंद किया!}"
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2NSAttrStrXibLocInfo
			let result = NSMutableAttributedString(string: "CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!", attributes: Conf.defaultStr2NSAttrStrAttributes!)
			result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: 15))
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testFromHappn1Bis() throws {
		for _ in 0..<nRepeats {
			let str = "{CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!₋CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकती हैं कि आपको किसने पसंद किया!}"
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2NSAttrStrXibLocInfo
			let result = NSMutableAttributedString(string: "CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!", attributes: Conf.defaultStr2NSAttrStrAttributes!)
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* Also exists in ObjC */
	func testFromHappn1Ter() throws {
		for _ in 0..<nRepeats {
			let str = "*लें*"
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2NSAttrStrXibLocInfo
			let resultStr = "लें"
			let result = NSMutableAttributedString(string: resultStr, attributes: Conf.defaultStr2NSAttrStrAttributes!)
			result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* Same as Ter TBH… */
	func testFromHappn1Quater() throws {
		for _ in 0..<nRepeats {
			let str = "*🧒🏻*"
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2NSAttrStrXibLocInfo
			let resultStr = "🧒🏻"
			let result = NSMutableAttributedString(string: resultStr, attributes: Conf.defaultStr2NSAttrStrAttributes!)
			result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testFromHappn1Quinquies() throws {
		for _ in 0..<nRepeats {
			let str = "🧒🏻*🧒🏻"
			let info = try Str2NSAttrStrXibLocInfo(
				attributesModifications: [OneWordTokens(token: "🧒🏻"): { attrStr, strRange, refStr in StringAttributesChangesDescription(changes: [.setBold]).nsapply(to: attrStr, range: NSRange(strRange, in: refStr)) }],
				identityReplacement: { NSMutableAttributedString(string: $0, attributes: Conf.defaultStr2NSAttrStrAttributes!) }
			).get()
			let resultStr = "*"
			let result = NSMutableAttributedString(string: resultStr, attributes: Conf.defaultStr2NSAttrStrAttributes!)
			result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* Also exists in ObjC */
	func testFromHappn1Sexies() throws {
		for _ in 0..<nRepeats {
			let str = "🧒🏻👳🏿‍♀️🧒🏻"
			let info = try Str2NSAttrStrXibLocInfo(
				attributesModifications: [OneWordTokens(token: "🧒🏻"): { attrStr, strRange, refStr in StringAttributesChangesDescription(changes: [.setBold]).nsapply(to: attrStr, range: NSRange(strRange, in: refStr)) }],
				identityReplacement: { NSMutableAttributedString(string: $0, attributes: Conf.defaultStr2NSAttrStrAttributes!) }
			).get()
			let resultStr = "👳🏿‍♀️"
			let result = NSMutableAttributedString(string: resultStr, attributes: Conf.defaultStr2NSAttrStrAttributes!)
			result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: (resultStr as NSString).length))
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* Copied from ObjC tests. */
	func testFromHappn1Septies() throws {
		for _ in 0..<nRepeats {
			let str = "🧔🏻*🧒🏻*"
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2NSAttrStrXibLocInfo
			let resultStr = "🧔🏻🧒🏻"
			let objcStart = ("🧔🏻" as NSString).length
			let result = NSMutableAttributedString(string: resultStr, attributes: Conf.defaultStr2NSAttrStrAttributes!)
			result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: objcStart, length: (resultStr as NSString).length - objcStart))
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* Copied from ObjC tests. */
	func testFromHappn1Octies() throws {
		for _ in 0..<nRepeats {
			let str = "🧔🏻*a*"
			/* Bold, italic, font and text color already setup in the tests setup. */
			let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2NSAttrStrXibLocInfo
			let resultStr = "🧔🏻a"
			let objcStart = ("🧔🏻" as NSString).length
			let result = NSMutableAttributedString(string: resultStr, attributes: Conf.defaultStr2NSAttrStrAttributes!)
			result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: objcStart, length: (resultStr as NSString).length - objcStart))
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				result
			)
		}
	}
	
	/* ***** Doc Cases Tests ***** */
	/* Config:
	 *    "*" is a left and right token for an attributes modification
	 *    "_" is a left and right token for an attributes modification
	 *    "|" is a left and right token for a simple replacement
	 *    "<" ":" ">" are resp. a left, interior and right tokens for an ordered replacement. */
	
	func testDocCase1() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 19))
			result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 10))
			XCTAssertEqual(
				"This text will be *bold _and italic_ too*!".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase2() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 19))
			result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 14))
			XCTAssertEqual(
				"This text will be *bold _and italic too*_!".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase3() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 19))
			result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 14))
			XCTAssertEqual(
				"This text will be *bold _and italic too_*!".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase4() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "This text will be bold and italic too!", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 18, length: 8))
			result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 23, length: 14))
			XCTAssertEqual(
				"This text will be *bold _and* italic too_!".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase5() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "replacement_value to be replaced", attributes: baseAttributes)
			XCTAssertEqual(
				"|*some text*| to be replaced".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase6() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "Let's replace replacement_value", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
			XCTAssertEqual(
				"Let's replace *|some text|*".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase6Variant() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "Let's replace replacement_value", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
			result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
			XCTAssertEqual(
				"Let's replace _<*|some text|*:val2>_".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase7() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "Let's replace with either this is chosen or nope", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 26, length: 4))
			XCTAssertEqual(
				"Let's replace with either <*this* is chosen:nope> or <nope:_that_>".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase8() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "Let's replace with either this is chosen or nope", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 26, length: 22))
			result.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(location: 44, length: 4))
			XCTAssertEqual(
				"Let's replace with either *<this is chosen:_nope_> or <_nope_:that>*".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase9() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result1 = NSMutableAttributedString(string: "Let's replace *replacement_value", attributes: baseAttributes)
			let result2 = NSMutableAttributedString(string: "Let's replace |some text|", attributes: baseAttributes)
			result2.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 5))
			let processed = "Let's replace *|some* text|".applying(xibLocInfo: info)
			XCTAssert(processed == result1 || processed == result2)
		}
	}
	
	func testDocCase10() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result = NSMutableAttributedString(string: "Let's replace multiple", attributes: baseAttributes)
			result.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 8))
			XCTAssertEqual(
				"Let's replace <*multiple*:*choices*:stuff>".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testDocCase11() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result1 = NSMutableAttributedString(string: "Let's replace *multiple", attributes: baseAttributes)
			let result2 = NSMutableAttributedString(string: "Let's replace <multiple:choices:stuff>", attributes: baseAttributes)
			result2.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 14, length: 17))
			let processed = "Let's replace *<multiple:choices*:stuff>".applying(xibLocInfo: info)
			XCTAssert(processed == result1 || processed == result2)
		}
	}
	
	func testDocCase12() throws {
		for _ in 0..<nRepeats {
			let (info, baseAttributes) = docCasesInfo
			let result1 = NSMutableAttributedString(string: "Let's replace *multiple", attributes: baseAttributes)
			let result2 = NSMutableAttributedString(string: "Let's replace <multiple:choices:stuff>", attributes: baseAttributes)
			result2.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(location: 15, length: 16))
			let processed = "Let's replace <*multiple:choices*:stuff>".applying(xibLocInfo: info)
			XCTAssert(processed == result1 || processed == result2)
		}
	}
	
	/* Baseline is set with XibLoc compiled with USE_UTF16_OFFSETS.
	 * USE_UTF16_OFFSETS is not used and is dangerous as it makes XibLoc crash for some Objective-C strings crash.
	 * See ParsedXibLoc.swift for more info. */
	func testPerf2() throws {
		measure{
			for _ in 0..<nRepeats {
				let str = "{*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!₋*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकती हैं कि आपको किसने पसंद किया!}"
				/* Bold, italic, font and text color already setup in the tests setup. */
				let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2NSAttrStrXibLocInfo
				let result = NSMutableAttributedString(string: "CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!", attributes: Conf.defaultStr2NSAttrStrAttributes!)
				result.setBoldOrItalic(bold: true, italic: nil, range: NSRange(location: 0, length: 15))
				XCTAssertEqual(
					str.applying(xibLocInfo: info),
					result
				)
			}
		}
	}
	
	
	private func helperAddTestAttributeLevel(to attributedString: inout NSMutableAttributedString, strRange: Range<String.Index>, refStr: String) {
		attributedString.addAttributes([.accessibilityListItemLevel: NSNumber(value: 0)], range: NSRange(strRange, in: refStr))
	}
	
	private func helperAddTestAttributeIndex(to attributedString: inout NSMutableAttributedString, strRange: Range<String.Index>, refStr: String) {
		attributedString.addAttributes([.accessibilityListItemIndex: NSNumber(value: 0)], range: NSRange(strRange, in: refStr))
	}
	
	private lazy var docCasesInfo: (Str2NSAttrStrXibLocInfo, [NSAttributedString.Key: Any]) = {
		let baseAttributes: [NSAttributedString.Key: Any] = [.font: XibLocFont.systemFont(ofSize: 14), .foregroundColor: XibLocColor.black]
		let info = Str2NSAttrStrXibLocInfo(
			escapeToken: nil,
			simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "replacement_value" }],
			orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
			attributesModifications: [
				OneWordTokens(token: "*"): helperAddTestAttributeIndex,
				OneWordTokens(token: "_"): helperAddTestAttributeLevel
			],
			identityReplacement: { NSMutableAttributedString(string: $0, attributes: baseAttributes) }
		)!
		return (info, baseAttributes)
	}()
	
#endif
	
}

#endif

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



class XibLocTestsSwiftStr : XCTestCase {
	
	/* All tests are repeated a few times in a loop as we actually got random crashes (first found was testFromHappn4/testFromHappn3ObjC; Swift should be good but who knows…). */
	let nRepeats = 150
	
	override func setUp() {
		super.setUp()
		
		Conf.cache = nil
		Conf.defaultEscapeToken = #"\"#
		Conf.defaultPluralityDefinition = PluralityDefinition()
		
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
	
	func testTokenGroupEscape() throws {
		XCTAssertEqual(CommonTokensGroup.escape("a~|b`c"), "a~~~|b~`c")
	}
	
	func testEscapedSimpleReplacement() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "replacement" }],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				#"the \|replaced\|"#.applying(xibLocInfo: info),
				#"the |replaced|"#
			)
		}
	}
	
	func testOneTokenEscapedSimpleReplacement() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "replacement" }],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				#"the |replaced\|"#.applying(xibLocInfo: info),
				#"the |replaced|"#
			)
		}
	}
	
	func testEscapeEscapingNothing() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "replacement" }],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				#"the\ |replaced|"#.applying(xibLocInfo: info),
				#"the replacement"#
			)
		}
	}
	
	func testNonEscapedButPrecededByEscapeTokenSimpleReplacement() throws {
		for _ in 0..<nRepeats {
			let info = CommonTokensGroup(simpleReplacement1: "replacement").str2StrXibLocInfo
			XCTAssertEqual(
				#"the ~~|replaced|"#.applying(xibLocInfo: info),
				#"the ~replacement"#
			)
		}
	}
	
	func testOneSimpleReplacement() throws {
		for _ in 0..<nRepeats {
			let info = CommonTokensGroup(simpleReplacement1: "replacement").str2StrXibLocInfo
			XCTAssertEqual(
				"the |replaced|".applying(xibLocInfo: info),
				"the replacement"
			)
		}
	}
	
	func testOneOrderedReplacement1() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
				pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"the <first:second>".applying(xibLocInfo: info),
				"the first"
			)
		}
	}
	
	func testOneOrderedReplacement2() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
				pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"the <first:second>".applying(xibLocInfo: info),
				"the second"
			)
		}
	}
	
	func testOneOrderedReplacementTwice() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
				pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"the <first:second> and also <first here:second here>".applying(xibLocInfo: info),
				"the first and also first here"
			)
		}
	}
	
	func testOneOrderedReplacementAboveMax() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [:],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 2],
				pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"the <first:second>".applying(xibLocInfo: info),
				"the second"
			)
		}
	}
	
	func testOnePluralReplacement() throws {
		for _ in 0..<nRepeats {
			let n = 1
			var nStr = ""
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(string: "(1)(*)"), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { o in nStr = o; return "\(n)" }],
				orderedReplacements: [:],
				pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), PluralValue(int: n))], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"#n# <house:houses>".applying(xibLocInfo: info),
				"1 house"
			)
			XCTAssertEqual(nStr, "n")
		}
	}
	
	func testOnePluralReplacementMissingOneZone() throws {
		for _ in 0..<nRepeats {
			let n = 2
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(string: "(1)(2→4:^*[^1][2→4]$)?(*)"), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { _ in "\(n)" }],
				orderedReplacements: [:],
				pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), PluralValue(int: n))], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"#n# <house:houses>".applying(xibLocInfo: info),
				"2 houses"
			)
		}
	}
	
	func testPluralWithNegativeIntervalOfInts() throws {
		for _ in 0..<nRepeats {
			let n = 2
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(string: "(1)(-2→4)(*)"), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { _ in "\(n)" }],
				orderedReplacements: [:],
				pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), PluralValue(int: n))], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"#n# <house:houses:housess>".applying(xibLocInfo: info),
				"2 houses"
			)
		}
	}
	
	func testPluralWithNonMatchingNegativeIntervalOfInts() throws {
		for _ in 0..<nRepeats {
			let n = -42
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(string: "(-42)(-2→4)(*)"), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { _ in "\(n)" }],
				orderedReplacements: [:],
				pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), PluralValue(int: n))], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"#n# <house:houses:housess>".applying(xibLocInfo: info),
				"-42 house"
			)
		}
	}
	
	func testPluralWithInvalidIntervalOfInts() throws {
		for _ in 0..<nRepeats {
			let n = 2
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(string: "(1)(2-6→4)(*)"), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { _ in "\(n)" }],
				orderedReplacements: [:],
				pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), PluralValue(int: n))], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"#n# <house:houses:housess>".applying(xibLocInfo: info),
				"2 housess"
			)
		}
	}
	
	func testPluralWithIntervalOfIntsNoStart() throws {
		for _ in 0..<nRepeats {
			let n = 2
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(string: "(→4)(*)"), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { _ in "\(n)" }],
				orderedReplacements: [:],
				pluralGroups: [(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"), PluralValue(int: n))], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"#n# <house:houses>".applying(xibLocInfo: info),
				"2 house"
			)
		}
	}
	
	func testOneOrderedReplacementAndSimpleReplacement1() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "first" }],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 0],
				pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
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
	}
	
	func testOneOrderedReplacementAndSimpleReplacement2() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "first" }],
				orderedReplacements: [MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">"): 1],
				pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"the <|fiftieth|:second>".applying(xibLocInfo: info),
				"the second"
			)
		}
	}
	
	func testThaiGender() throws {
		for _ in 0..<nRepeats {
			let str = "`a¦b´ต้`a¦b´"
			let info = CommonTokensGroup(genderOtherIsMale: true).str2StrXibLocInfo
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				"aต้a"
			)
		}
	}
	
	/* TBH, this is the same test as testThaiGender... */
	func testEmojiGender() throws {
		for _ in 0..<nRepeats {
			let str = "`a¦b´🤷‍♂️`a¦b´"
			let info = CommonTokensGroup(genderOtherIsMale: true).str2StrXibLocInfo
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				"a🤷‍♂️a"
			)
		}
	}
	
	func testEmojiGenderBis() throws {
		for _ in 0..<nRepeats {
			let str = "`a¦b´🧒🏻`a¦b´"
			let info = CommonTokensGroup(genderOtherIsMale: true).str2StrXibLocInfo
			XCTAssertEqual(
				str.applying(xibLocInfo: info),
				"a🧒🏻a"
			)
		}
	}
	
	func testInvalidOverlappingReplacements() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "*"): { w in "<b>" + w + "</b>" }, OneWordTokens(token: "_"): { w in "<i>" + w + "</i>" }],
				orderedReplacements: [:], pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			let r = "the *bold _and* italic_".applying(xibLocInfo: info)
			XCTAssertTrue(r == "the *bold <i>and* italic</i>" || r == "the <b>bold _and</b> italic_")
		}
	}
	
	func testTwoVariablesChangesInOrderedReplacementGroup() throws {
		for _ in 0..<nRepeats {
			let info = CommonTokensGroup(simpleReplacement1: "sᴉoɔuɐɹℲ", number: XibLocNumber(42)).str2StrXibLocInfo
			let result = "42 months for sᴉoɔuɐɹℲ/month"
			XCTAssertEqual(
				"<#n# month for |string var|/month:#n# months for |string var|/month>".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testTwoVariablesChangesAndGenderInOrderedReplacementGroup() throws {
		for _ in 0..<nRepeats {
			let info = CommonTokensGroup(simpleReplacement1: "sᴉoɔuɐɹℲ", number: XibLocNumber(42), genderOtherIsMale: false).str2StrXibLocInfo
			let result = "42 months for sᴉoɔuɐɹℲ/year"
			XCTAssertEqual(
				"<#n# month for |string var|/month:#n# months for |string var|/`month¦year´>".applying(xibLocInfo: info),
				result
			)
		}
	}
	
	func testEmbeddedSimpleReplacements() throws {
		for _ in 0..<nRepeats {
			let info = try XibLocResolvingInfo<String, String>(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: nil,
				simpleSourceTypeReplacements: [OneWordTokens(token: "#"): { w in "42" }, OneWordTokens(token: "|"): { w in "replacement_value" }],
				orderedReplacements: [:], pluralGroups: [], attributesModifications: [:], simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			XCTAssertEqual(
				"Let's replace |#some text#|".applying(xibLocInfo: info),
				"Let's replace replacement_value"
			)
		}
	}
	
	/* Also exists in ObjC (only ever failed in ObjC) */
	func testFromHappn3() throws {
		for _ in 0..<nRepeats {
			let info = CommonTokensGroup(genderMeIsMale: true, genderOtherIsMale: false).str2StrXibLocInfo
			XCTAssertEqual(
				"{Vous vous êtes croisés₋`Vous vous êtes croisés¦Vous vous êtes croisées´}".applying(xibLocInfo: info),
				"Vous vous êtes croisés"
			)
		}
	}
	
	/* Baseline is set with XibLoc compiled with USE_UTF16_OFFSETS.
	 * USE_UTF16_OFFSETS is not used and is dangerous as it makes XibLoc crash for some Objective-C strings crash.
	 * See ParsedXibLoc.swift for more info. */
	func testPerf1() throws {
		measure{
			for _ in 0..<nRepeats {
				let info = CommonTokensGroup(number: XibLocNumber(0), genderMeIsMale: true, genderOtherIsMale: true).str2StrXibLocInfo
				let str = "{CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!₋CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकती हैं कि आपको किसने पसंद किया!}"
				XCTAssertEqual(
					str.applying(xibLocInfo: info),
					"CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!"
				)
			}
		}
	}
	
	func testCommonTokensGroupDocCaseStr() {
		for _ in 0..<nRepeats {
			/* Case in doc has the default ~ escape token. */
			Conf.defaultEscapeToken = "~"
			let info = CommonTokensGroup().str2StrXibLocInfo
			XCTAssertEqual(
				"hello_world_how_are_you".applying(xibLocInfo: info),
				"hello_world_how_are_you"
			)
			XCTAssertEqual(
				"hello~_world~_how~_are~_you".applying(xibLocInfo: info),
				"hello_world_how_are_you"
			)
		}
	}
	
	func testOneAttributesChangeBeforeAnEscape() throws {
		let escapeToken = "4"
		for _ in 0..<nRepeats {
			let info = try Str2StrXibLocInfo(
				defaultPluralityDefinition: PluralityDefinition(), escapeToken: escapeToken,
				simpleSourceTypeReplacements: [:], orderedReplacements: [:], pluralGroups: [],
				attributesModifications: [OneWordTokens(token: "*"): { _, _, _ in }],
				simpleReturnTypeReplacements: [:],
				identityReplacement: { $0 }
			).get()
			
			func escape(_ str: String) -> String {
				return ([escapeToken, "|", "^", "#", "<", ":", ">", "{", "₋", "}", "`", "¦", "´", "*", "_"])
					.reduce(str, { $0.replacingOccurrences(of: $1, with: escapeToken + $1) })
			}
			
			let baseStr = "CHF•44.20"
			let currencyStr = "CHF"
			let xibLocStr = baseStr.replacingOccurrences(of: currencyStr, with: "*\(currencyStr)*", options: .literal)
			let xibLocStrNoReplacements = "*CHF*•44.20"
			XCTAssertEqual(xibLocStrNoReplacements, xibLocStr)
			
			XCTAssertEqual(
				/* No problem with xibLocStrNoReplacements, but it’s the same string as xibLocStr! */
				xibLocStr.applying(xibLocInfo: info),
				"CHF•4.20"
			)
		}
	}
	
	func testOneAttributesChangeBeforeAnEscapeButIsolatedToBug() throws {
		let baseStr = "CHF•44.20"
		let currencyStr = "CHF"
		var xibLocStr = baseStr.replacingOccurrences(of: currencyStr, with: "*\(currencyStr)*", options: .literal)
		
		let escapeToken = "4"
		var pos = xibLocStr.startIndex
		while let r = xibLocStr.range(of: escapeToken, options: [.literal], range: pos..<xibLocStr.endIndex) {
			xibLocStr.removeSubrange(r)
			pos = r.lowerBound
			
			if pos >= xibLocStr.endIndex {break}
			if xibLocStr[r] == escapeToken {pos = xibLocStr.index(pos, offsetBy: escapeToken.count)}
		}
		XCTAssertEqual(xibLocStr, "CHF•4.20")
	}
	
	func testOneAttributesChangeBeforeAnEscapeButEvenMoreIsolatedToBug() throws {
		let baseStr = "CHF•44.20"
		let currencyStr = "CHF"
		var xibLocStr = baseStr.replacingOccurrences(of: currencyStr, with: "*\(currencyStr)*", options: .literal)
		
		let range = xibLocStr.index(xibLocStr.startIndex, offsetBy: 6)..<xibLocStr.index(xibLocStr.startIndex, offsetBy: 7)
		xibLocStr.removeSubrange(range)
		XCTAssertEqual(xibLocStr[range], "4")
	}
	
}

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

import XCTest
@testable import XibLoc



class XibLocResolvingInfoTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testInvalidTokensInit() throws {
		XCTAssertNil(Str2StrXibLocInfo(
			simpleSourceTypeReplacements: [OneWordTokens(token: "|"): { _ in "hello" }],
			orderedReplacements: [MultipleWordsTokens(exteriorToken: "|", interiorToken: ":"): 2],
			identityReplacement: { $0 }
		))
	}
	
	func testAddingNewSourceTypeReplacement() throws {
		var info = try Str2StrXibLocInfo(orderedReplacements: [#"/,\"#: 0]).get()
		XCTAssertEqual(info.simpleSourceTypeReplacements.count, 0)
		XCTAssertTrue(info.addSimpleSourceTypeReplacement(tokens: OneWordTokens(token: "|"), replacement: { _ in "yo" }))
		XCTAssertEqual(info.simpleSourceTypeReplacements.count, 1)
		XCTAssertFalse(info.addSimpleSourceTypeReplacement(tokens: OneWordTokens(token: "|"), replacement: { _ in "yo" }))
		XCTAssertEqual(info.simpleSourceTypeReplacements.count, 1)
		XCTAssertTrue(info.addSimpleSourceTypeReplacement(tokens: OneWordTokens(token: "|"), replacement: { _ in "yo" }, allowReplace: true))
		XCTAssertEqual(info.simpleSourceTypeReplacements.count, 1)
		XCTAssertFalse(info.addSimpleSourceTypeReplacement(tokens: OneWordTokens(token: "/"), replacement: { _ in "yo" }))
		XCTAssertEqual(info.simpleSourceTypeReplacements.count, 1)
		XCTAssertTrue(info.addSimpleSourceTypeReplacement(tokens: OneWordTokens(token: ":"), replacement: { _ in "yo" }))
		XCTAssertEqual(info.simpleSourceTypeReplacements.count, 2)
		
		XCTAssertNil(info.addingSimpleSourceTypeReplacement(tokens: OneWordTokens(token: "|"), replacement: { _ in "yo" }))
		let info2 = info.addingSimpleSourceTypeReplacement(tokens: OneWordTokens(token: "'"), replacement: { _ in "yo" })
		XCTAssertNotNil(info2)
		XCTAssertEqual(info2?.simpleSourceTypeReplacements.count, 3)
	}
	
	func testRemovingTokens() throws {
		var info = CommonTokensGroup(simpleReplacement1: "yo1", simpleReplacement2: "yo2", number: XibLocNumber(42)).str2StrXibLocInfo
		
		XCTAssertEqual(info.simpleReturnTypeReplacements.count, 3)
		XCTAssertTrue(info.removeTokens(OneWordTokens(token: "#")))
		XCTAssertEqual(info.simpleReturnTypeReplacements.count, 2)
		XCTAssertFalse(info.removeTokens(OneWordTokens(token: "#")))
		XCTAssertEqual(info.simpleReturnTypeReplacements.count, 2)
		
		XCTAssertEqual(info.pluralGroups.count, 1)
		XCTAssertTrue(info.removeTokens(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">")))
		XCTAssertEqual(info.pluralGroups.count, 0)
		XCTAssertFalse(info.removeTokens(MultipleWordsTokens(leftToken: "<", interiorToken: ":", rightToken: ">")))
		XCTAssertEqual(info.pluralGroups.count, 0)
	}
	
}

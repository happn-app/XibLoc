/*
Copyright 2021 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import XCTest
@testable import XibLoc



@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
class AttributedStringUtilsTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testSetBoldOrItalic() {
		var baseattr = AttributeContainer()
		baseattr.font = .systemFont(ofSize: 12)
		var attrstr = AttributedString("abcdefghijklmnopqrstuvwxyz", attributes: baseattr)
		
		let abcRange = attrstr.range(of: "abc")!
		let defRange = attrstr.range(of: "def")!
		let abcdefRange = attrstr.range(of: "abcdef")!
		
		XCTAssertEqual(attrstr[abcRange].font?.isBold, false)
		XCTAssertEqual(attrstr[defRange].font?.isBold, false)
		XCTAssertEqual(attrstr[abcdefRange].font?.isBold, false)
		
		attrstr.setBoldOrItalic(bold: true, italic: nil, range: defRange)
		
		XCTAssertEqual(attrstr[abcRange].font?.isBold, false)
		XCTAssertEqual(attrstr[defRange].font?.isBold, true)
		XCTAssertEqual(attrstr[abcdefRange].font?.isBold, nil)
	}
	
}

#endif

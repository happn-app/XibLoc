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



class PluralityTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testPluralValueInitFailure() {
		XCTAssertNil(PluralValue(intPart: "", fractionPart: ""))
		XCTAssertNil(PluralValue(intPart: "1.", fractionPart: ""))
		XCTAssertNil(PluralValue(intPart: "01", fractionPart: ""))
	}
	
	func testPluralValueDecimalSeparator() {
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: nil)?.fullStringValue, "0")
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: "")?.fullStringValue, "0.")
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: "0")?.fullStringValue, "0.0")
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: "0")?.fractionPartNoTrailingZeros, "")
		XCTAssertNil(PluralValue(intPart: "0", fractionPart: nil)?.fractionPartNoTrailingZeros)
		XCTAssertEqual(
			PluralValue(float: 0, format: PluralValue.NumberFormat(minFractionDigits: 1, maxFractionDigits: 2)).fullStringValue,
			"0.0"
		)
	}
	
	func testPluralValueNegative() {
		XCTAssertEqual(PluralValue(intPart: "-0", fractionPart: nil)?.fullStringValue, "-0")
		XCTAssertEqual(PluralValue(intPart: "-0", fractionPart: "")?.fullStringValue, "-0.")
		XCTAssertEqual(PluralValue(intPart: "-1", fractionPart: nil)?.fullStringValue, "-1")
		XCTAssertEqual(PluralValue(intPart: "-1", fractionPart: "")?.fullStringValue, "-1.")
		XCTAssertEqual(PluralValue(intPart: "-1", fractionPart: "42")?.fullStringValue, "-1.42")
		XCTAssertEqual(
			PluralValue(int: 0, format: PluralValue.NumberFormat(minFractionDigits: 1, maxFractionDigits: 2, forceDecimalSeparator: false, zeroIsNegative: true)).fullStringValue,
			"-0.0"
		)
	}
	
	func testPluralValueComparison() {
		let floatFormat02 = PluralValue.NumberFormat(minFractionDigits: 0, maxFractionDigits: 2)
		let floatFormat11 = PluralValue.NumberFormat(minFractionDigits: 1, maxFractionDigits: 1)
		let floatFormat22 = PluralValue.NumberFormat(minFractionDigits: 2, maxFractionDigits: 2)
		let floatFormat33 = PluralValue.NumberFormat(minFractionDigits: 3, maxFractionDigits: 3)
		XCTAssertTrue(PluralValue(int: -1) ≺ PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: 1) ≺ PluralValue(int: -1))
		XCTAssertFalse(PluralValue(int: 1) ≺ PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: 1) ≻ PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: -1) ≺ PluralValue(int: -1))
		XCTAssertFalse(PluralValue(int: -1) ≻ PluralValue(int: -1))
		XCTAssertTrue(PluralValue(int: 1) ≺ PluralValue(int: 2))
		XCTAssertFalse(PluralValue(int: 2) ≺ PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: -1) ≺ PluralValue(int: -2))
		XCTAssertTrue(PluralValue(int: -2) ≺ PluralValue(int: -1))
		XCTAssertTrue(PluralValue(int: 1) ≺ PluralValue(int: 12))
		XCTAssertFalse(PluralValue(int: 12) ≺ PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: -1) ≺ PluralValue(int: -12))
		XCTAssertTrue(PluralValue(int: -12) ≺ PluralValue(int: -1))
		XCTAssertFalse(PluralValue(float: -12.11, format: floatFormat11) ≺ PluralValue(float: -12.1, format: floatFormat22))
		XCTAssertTrue(PluralValue(float: -12.11, format: floatFormat22) ≺ PluralValue(float: -12.1, format: floatFormat22))
		XCTAssertTrue(PluralValue(float: -12.11, format: floatFormat33) ≺ PluralValue(float: -12.1, format: floatFormat22))
//		XCTAssertEqual(PluralValue(float: -12.11, format: floatFormat11), PluralValue(float: -12.1, format: floatFormat02))
//		XCTAssertTrue(PluralValue(intPart: "0", fractionPart: nil).get() !≺≻ PluralValue(intPart: "-0", fractionPart: nil).get())
//		XCTAssertNotEqual(PluralValue(intPart: "0", fractionPart: nil).get(), PluralValue(intPart: "-0", fractionPart: nil).get())
	}
	
	/* https://www.unicode.org/reports/tr35/tr35-numbers.html#Operands */
	func testPluralValueUnicodeOperand() throws {
		let pv1 = try PluralValue(string: "1").get()
		XCTAssertEqual(pv1.unicodeOperandI, "1")
		XCTAssertEqual(pv1.unicodeOperandV, 0)
		XCTAssertEqual(pv1.unicodeOperandW, 0)
		XCTAssertEqual(pv1.unicodeOperandF, "0")
		XCTAssertEqual(pv1.unicodeOperandT, "0")
		
		let pv2 = try PluralValue(string: "1.0").get()
		XCTAssertEqual(pv2.unicodeOperandI, "1")
		XCTAssertEqual(pv2.unicodeOperandV, 1)
		XCTAssertEqual(pv2.unicodeOperandW, 0)
		XCTAssertEqual(pv2.unicodeOperandF, "0")
		XCTAssertEqual(pv2.unicodeOperandT, "0")
		
		let pv3 = try PluralValue(string: "1.00").get()
		XCTAssertEqual(pv3.unicodeOperandI, "1")
		XCTAssertEqual(pv3.unicodeOperandV, 2)
		XCTAssertEqual(pv3.unicodeOperandW, 0)
		XCTAssertEqual(pv3.unicodeOperandF, "0")
		XCTAssertEqual(pv3.unicodeOperandT, "0")
		
		let pv4 = try PluralValue(string: "1.3").get()
		XCTAssertEqual(pv4.unicodeOperandI, "1")
		XCTAssertEqual(pv4.unicodeOperandV, 1)
		XCTAssertEqual(pv4.unicodeOperandW, 1)
		XCTAssertEqual(pv4.unicodeOperandF, "3")
		XCTAssertEqual(pv4.unicodeOperandT, "3")
		
		let pv5 = try PluralValue(string: "1.30").get()
		XCTAssertEqual(pv5.unicodeOperandI, "1")
		XCTAssertEqual(pv5.unicodeOperandV, 2)
		XCTAssertEqual(pv5.unicodeOperandW, 1)
		XCTAssertEqual(pv5.unicodeOperandF, "30")
		XCTAssertEqual(pv5.unicodeOperandT, "3")
		
		let pv6 = try PluralValue(string: "1.03").get()
		XCTAssertEqual(pv6.unicodeOperandI, "1")
		XCTAssertEqual(pv6.unicodeOperandV, 2)
		XCTAssertEqual(pv6.unicodeOperandW, 2)
		XCTAssertEqual(pv6.unicodeOperandF, "3")
		XCTAssertEqual(pv6.unicodeOperandT, "3")
		
		let pv7 = try PluralValue(string: "1.230").get()
		XCTAssertEqual(pv7.unicodeOperandI, "1")
		XCTAssertEqual(pv7.unicodeOperandV, 3)
		XCTAssertEqual(pv7.unicodeOperandW, 2)
		XCTAssertEqual(pv7.unicodeOperandF, "230")
		XCTAssertEqual(pv7.unicodeOperandT, "23")
		
	}
	
	func testPluralityDefinitionIntervalOfIntsParsing() {
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→3"))
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→-1"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→-3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "0-2→3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→3-"))
	}
	
	func testPluralityDefinitionIntervalOfFloatsParsing() {
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "]-2→3]"))
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.000]"))
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001]"))
		XCTAssertTrue(try PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001]").get().matches(pluralValue: PluralValue(string: "1.0001").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001[").get().matches(pluralValue: PluralValue(string: "1.0001").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001]").get().matches(pluralValue: PluralValue(string: "1.00011").get()))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2→-3["))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2→-3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "-2→-3["))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[0-2→3]"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "]-2→3-]"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "]-2→3..]"))
	}
	
}

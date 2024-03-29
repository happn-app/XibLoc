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



final class PluralityTests : XCTestCase {
	
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
		XCTAssertEqual(PluralValue(string: "0")?.fullStringValue, "0")
	}
	
	func testPluralValueDecimalSeparator() {
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: nil)?.fullStringValue, "0")
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: "")?.fullStringValue, "0.")
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: "0")?.fullStringValue, "0.0")
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: "0")?.fractionPartNoTrailingZeros, "")
		XCTAssertEqual(PluralValue(string: "0.0")?.fullStringValue, "0.0")
		XCTAssertEqual(PluralValue(string: "0.")?.fullStringValue, "0.")
		XCTAssertEqual(PluralValue(double: 0, format: PluralValue.NumberFormat(minFractionDigits: 0, maxFractionDigits: 0, forceDecimalSeparator: true, zeroIsNegative: false)).fullStringValue, "0.")
		XCTAssertEqual(PluralValue(double: 0, format: PluralValue.NumberFormat(minFractionDigits: 0, maxFractionDigits: 42, forceDecimalSeparator: true, zeroIsNegative: false)).fullStringValue, "0.")
		XCTAssertEqual(PluralValue(double: 0, format: PluralValue.NumberFormat(minFractionDigits: 0, maxFractionDigits: 42, forceDecimalSeparator: false, zeroIsNegative: false)).fullStringValue, "0")
		XCTAssertEqual(PluralValue(double: 0.1, format: PluralValue.NumberFormat(minFractionDigits: 0, maxFractionDigits: 0, forceDecimalSeparator: true, zeroIsNegative: false)).fullStringValue, "0.")
		XCTAssertEqual(PluralValue(double: 0.7, format: PluralValue.NumberFormat(minFractionDigits: 0, maxFractionDigits: 0, forceDecimalSeparator: true, zeroIsNegative: false)).fullStringValue, "1.")
		XCTAssertEqual(PluralValue(double: 0.7, format: PluralValue.NumberFormat(minFractionDigits: 0, maxFractionDigits: 1, forceDecimalSeparator: true, zeroIsNegative: false)).fullStringValue, "0.7")
		XCTAssertNil(PluralValue(intPart: "0", fractionPart: nil)?.fractionPartNoTrailingZeros)
		XCTAssertEqual(
			PluralValue(float: 0, format: PluralValue.NumberFormat(minFractionDigits: 1, maxFractionDigits: 2)).fullStringValue,
			"0.0"
		)
	}
	
	func testPluralValuePositive() {
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: nil)?.fullStringValue, "0")
		XCTAssertEqual(PluralValue(intPart: "0", fractionPart: "")?.fullStringValue, "0.")
		XCTAssertEqual(PluralValue(intPart: "1", fractionPart: nil)?.fullStringValue, "1")
		XCTAssertEqual(PluralValue(intPart: "1", fractionPart: "")?.fullStringValue, "1.")
		XCTAssertEqual(PluralValue(intPart: "1", fractionPart: "42")?.fullStringValue, "1.42")
		XCTAssertNil(PluralValue(intPart: "01", fractionPart: "42")?.fullStringValue, "1.42")
		XCTAssertNil(PluralValue(intPart: "+0", fractionPart: nil))
		XCTAssertNil(PluralValue(string: "+0."))
		XCTAssertNil(PluralValue(string: "000."))
		XCTAssertNil(PluralValue(intPart: "+1", fractionPart: nil))
		XCTAssertNil(PluralValue(intPart: "+1", fractionPart: ""))
		XCTAssertNil(PluralValue(intPart: "+1", fractionPart: "42"))
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
		XCTAssertTrue(PluralValue(int: -1) < PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: 1) < PluralValue(int: -1))
		XCTAssertFalse(PluralValue(int: 1) < PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: 1) > PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: -1) < PluralValue(int: -1))
		XCTAssertFalse(PluralValue(int: -1) > PluralValue(int: -1))
		XCTAssertTrue(PluralValue(int: 1) < PluralValue(int: 2))
		XCTAssertFalse(PluralValue(int: 2) < PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: -1) < PluralValue(int: -2))
		XCTAssertTrue(PluralValue(int: -2) < PluralValue(int: -1))
		XCTAssertTrue(PluralValue(int: 1) < PluralValue(int: 12))
		XCTAssertFalse(PluralValue(int: 12) < PluralValue(int: 1))
		XCTAssertFalse(PluralValue(int: -1) < PluralValue(int: -12))
		XCTAssertTrue(PluralValue(int: -12) < PluralValue(int: -1))
		XCTAssertFalse(PluralValue(float: -12.11, format: floatFormat11) < PluralValue(float: -12.1, format: floatFormat22))
		XCTAssertTrue(PluralValue(float: -12.11, format: floatFormat22) < PluralValue(float: -12.1, format: floatFormat22))
		XCTAssertTrue(PluralValue(float: -12.11, format: floatFormat33) < PluralValue(float: -12.1, format: floatFormat22))
		XCTAssertTrue(PluralValue(float: -12.11, format: floatFormat11) == PluralValue(float: -12.1, format: floatFormat02))
		XCTAssertTrue(try PluralValue(intPart: "0", fractionPart: nil).get() == PluralValue(intPart: "-0", fractionPart: nil).get())
		XCTAssertNotEqual(try PluralValue(intPart: "0", fractionPart: nil).get().fullStringValue, try PluralValue(intPart: "-0", fractionPart: nil).get().fullStringValue)
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
	
	func testPluralityDefinitionSingleNumber() {
		XCTAssertNotNil(PluralityDefinitionZoneValueNumber(string: "-2"))
		XCTAssertNotNil(PluralityDefinitionZoneValueNumber(string: "-2."))
		XCTAssertNotNil(PluralityDefinitionZoneValueNumber(string: "0"))
		XCTAssertNotNil(PluralityDefinitionZoneValueNumber(string: "-0"))
		XCTAssertNotNil(PluralityDefinitionZoneValueNumber(string: "2."))
		XCTAssertNotNil(PluralityDefinitionZoneValueNumber(string: "2.0"))
		XCTAssertNotNil(PluralityDefinitionZoneValueNumber(string: "2.000"))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "+0"))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "-"))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "-1.."))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "."))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "--0"))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "1-0"))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "00"))
		XCTAssertNil(PluralityDefinitionZoneValueNumber(string: "01"))
		XCTAssertTrue(try PluralityDefinitionZoneValueNumber(string: "-0").get().matches(pluralValue: PluralValue(string: "0").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueNumber(string: "-0").get().matches(pluralValue: PluralValue(string: "0.000").get()))
		XCTAssertTrue(try PluralityDefinitionZoneValueNumber(string: "-0.").get().matches(pluralValue: PluralValue(string: "0").get()))
		XCTAssertTrue(try PluralityDefinitionZoneValueNumber(string: "-0.").get().matches(pluralValue: PluralValue(string: "0.000").get()))
	}
	
	func testPluralityDefinitionIntervalOfIntsParsing() {
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→3"))
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→-1"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→+3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "+2→+3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→-3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "0-2→3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfInts(string: "-2→3-"))
	}
	
	func testPluralityDefinitionIntervalOfFloats() {
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "]-2→3]"))
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.000]"))
		XCTAssertNotNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001]"))
		XCTAssertTrue(try PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001]").get().matches(pluralValue: PluralValue(string: "1.0001").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001[").get().matches(pluralValue: PluralValue(string: "1.0001").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→1.0001]").get().matches(pluralValue: PluralValue(string: "1.00011").get()))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2.→+1.0001]"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[+2.→+3.0001]"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[2→+3.0001]"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2→-3["))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[-2→-3"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "-2→-3["))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "[0-2→3]"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "]-2→3-]"))
		XCTAssertNil(PluralityDefinitionZoneValueIntervalOfFloats(string: "]-2→3..]"))
	}
	
	func testPluralityDefinitionGlob() {
		XCTAssertNotNil(PluralityDefinitionZoneValueGlob(string: "^-42$"))
		XCTAssertTrue(try PluralityDefinitionZoneValueGlob(string: "^-42$").get().matches(pluralValue: PluralValue(string: "-42").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueGlob(string: "^-42$").get().matches(pluralValue: PluralValue(string: "-42.").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueGlob(string: "^-42$").get().matches(pluralValue: PluralValue(string: "42").get()))
		XCTAssertTrue(try PluralityDefinitionZoneValueGlob(string: "^-42.*$").get().matches(pluralValue: PluralValue(string: "-42.").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueGlob(string: "^-42.*$").get().matches(pluralValue: PluralValue(string: "-42").get()))
		XCTAssertTrue(try PluralityDefinitionZoneValueGlob(string: "^-42{.*}$").get().matches(pluralValue: PluralValue(string: "-42").get()))
		XCTAssertTrue(try PluralityDefinitionZoneValueGlob(string: "^42{.*}$").get().matches(pluralValue: PluralValue(string: "-42").get()))
		XCTAssertFalse(try PluralityDefinitionZoneValueGlob(string: "^+42{.*}$").get().matches(pluralValue: PluralValue(string: "-42").get()))
	}
	
	func testMoreVersionsThanZones() {
		let plurality = PluralityDefinition(string: "(1:^*[^1]1$)(2→4:^*[^1][2→4]$)?(*)")
		let resolvingInfos = (0..<9).map{ v in
			Str2StrXibLocInfo(defaultPluralityDefinition: plurality, pluralGroups: [(MultipleWordsTokens(shortTokensForm: "<:>")!, PluralValue(int: v))], identityReplacement: { $0 })
		}
		let str = "<one:few:many:other>"
		XCTAssertEqual(str.applying(xibLocInfo: resolvingInfos[4]!), "few")
		XCTAssertEqual(str.applying(xibLocInfo: resolvingInfos[5]!), "many")
		XCTAssertEqual(str.applying(xibLocInfo: resolvingInfos[6]!), "many")
	}
	
	func testEmptyPluralityDefinition() {
		XCTAssertEqual(PluralityDefinition(string: "").zones.count, 0)
		XCTAssertEqual(PluralityDefinition(matchingNothing: ()).zones.count, 0)
		XCTAssertEqual(try PluralityDefinition(matchingNothing: ()).indexOfVersionToUse(forValue: PluralValue(string: "0").get(), numberOfVersions: 5), 4)
	}
	
	func testZoneMatchingNothing() {
		let plurality = PluralityDefinition(string: "()")
		XCTAssertEqual(plurality.zones.count, 1)
		XCTAssertEqual(try plurality.indexOfVersionToUse(forValue: PluralValue(string: "0").get(), numberOfVersions: 5), 4)
	}
	
}

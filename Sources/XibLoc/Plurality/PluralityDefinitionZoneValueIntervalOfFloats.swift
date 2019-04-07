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



struct PluralityDefinitionZoneValueIntervalOfFloats : PluralityDefinitionZoneValue {
	
	init?(string: String) {
		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = CharacterSet()
		scanner.locale = nil
		
		let bracketsCharset = CharacterSet(charactersIn: "[]")
		
		var f: Float = 0
		
		guard let bracket1 = scanner.scanCharactersFromSet(bracketsCharset), bracket1.count == 1 else {return nil}
		assert(bracket1 == "[" || bracket1 == "]")
		
		start = scanner.scanFloat(&f) ? (value: f, included: bracket1 == "[") : nil
		
		guard scanner.scanString("→", into: nil) else {return nil}
		
		let hasEnd = scanner.scanFloat(&f)
		
		guard let bracket2 = scanner.scanCharactersFromSet(bracketsCharset), bracket2.count == 1 else {return nil}
		assert(bracket2 == "[" || bracket2 == "]")
		
		guard scanner.isAtEnd else {return nil}
		
		end = hasEnd ? (value: f, included: bracket2 == "]") : nil
		
		guard start != nil || end != nil else {return nil}
		if let start = start, let end = end, start.value > end.value {return nil}
	}
	
	func matches(int: Int) -> Bool {
		return matches(float: Float(int), characteristics: .init(precision: 0))
	}
	
	func matches(float: Float, characteristics: PluralValue.FloatCharacteristics) -> Bool {
		assert(start != nil || end != nil)
		assert(characteristics.precision >= 0)
		
		if let start = start {
			guard (start.included && float - start.value >= -characteristics.precision) || (!start.included && float - start.value > -characteristics.precision) else {
				return false
			}
		}
		
		if let end = end {
			guard (end.included && float - end.value <= characteristics.precision) || (!end.included && float - end.value < characteristics.precision) else {
				return false
			}
		}
		
		return true
	}
	
	var debugDescription: String {
		var ret = "PluralityDefinitionZoneValueIntervalOfFloats: "
		if let start = start          {ret.append("start = \(start.value) (\(start.included ? "incl." : "excl.")")}
		if start != nil && end != nil {ret.append(", ")}
		if let end = end              {ret.append("end = \(end.value) (\(end.included ? "incl." : "excl.")")}
		return ret
	}
	
	private let start, end: (value: Float, included: Bool)?
	
}

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
		let floatCharSet = CharacterSet(charactersIn: "+-.0123456789")
		
		guard let bracket1 = scanner.scanCharactersFromSet(bracketsCharset), bracket1.count == 1 else {return nil}
		assert(bracket1 == "[" || bracket1 == "]")
		
		let loc1 = scanner.scanLocation
		start = scanner.scanCharactersFromSet(floatCharSet)
			.flatMap{ PluralValue(string: $0) }
			.flatMap{ (value: $0, included: bracket1 == "[") }
		guard start != nil || scanner.scanLocation == loc1 else {return nil}
		
		guard scanner.scanString("→", into: nil) else {return nil}
		
		let loc2 = scanner.scanLocation
		let endValue = scanner.scanCharactersFromSet(floatCharSet).flatMap{ PluralValue(string: $0) }
		guard endValue != nil || scanner.scanLocation == loc2 else {return nil}
		
		guard let bracket2 = scanner.scanCharactersFromSet(bracketsCharset), bracket2.count == 1 else {return nil}
		assert(bracket2 == "[" || bracket2 == "]")
		
		guard scanner.isAtEnd else {return nil}
		
		end = endValue.flatMap{ (value: $0, included: bracket2 == "]") }
		
		guard start != nil || end != nil else {return nil}
		if let start = start, let end = end, start.value > end.value {return nil}
	}
	
	func matches(pluralValue f: PluralValue) -> Bool {
		assert(start != nil || end != nil)
		if let start = start {
			guard (start.included && f >= start.value) || (!start.included && f > start.value) else {
				return false
			}
		}
		if let end = end {
			guard (end.included && f <= end.value) || (!end.included && f < end.value) else {
				return false
			}
		}
		return true
	}
	
	var debugDescription: String {
		var ret = "PluralityDefinitionZoneValueIntervalOfFloats: "
		if let start = start          {ret.append("start = \(start.value.fullStringValue) (\(start.included ? "incl." : "excl.")")}
		if start != nil && end != nil {ret.append(", ")}
		if let end = end              {ret.append("end = \(end.value.fullStringValue) (\(end.included ? "incl." : "excl.")")}
		return ret
	}
	
	private let start, end: (value: PluralValue, included: Bool)?
	
}

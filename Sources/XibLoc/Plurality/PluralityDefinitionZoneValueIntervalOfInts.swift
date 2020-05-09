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



struct PluralityDefinitionZoneValueIntervalOfInts : PluralityDefinitionZoneValue {
	
	init?(string: String) {
		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = CharacterSet()
		scanner.locale = nil
		
		let intCharSet = CharacterSet(charactersIn: "-0123456789")
		
		let loc1 = scanner.scanLocation
		startValue = scanner.scanCharactersFromSet(intCharSet).flatMap{ PluralValue(string: $0) }
		guard startValue != nil || scanner.scanLocation == loc1 else {return nil}
		
		guard scanner.scanString("→", into: nil) else {return nil}
		
		let loc2 = scanner.scanLocation
		endValue = scanner.scanCharactersFromSet(intCharSet).flatMap{ PluralValue(string: $0) }
		guard endValue != nil || scanner.scanLocation == loc2 else {return nil}
		
		assert(startValue?.isInt ?? true)
		assert(endValue?.isInt ?? true)
		
		guard scanner.isAtEnd else {return nil}
		guard startValue != nil || endValue != nil else {return nil}
		if let start = startValue, let end = endValue, start ≻ end {return nil}
	}
	
	func matches(pluralValue n: PluralValue) -> Bool {
		assert(startValue != nil || endValue != nil)
		guard n.isInt else {return false}
		if let endValue   = endValue   {guard n ≼ endValue   else {return false}}
		if let startValue = startValue {guard n ≽ startValue else {return false}}
		return true
	}
	
	var debugDescription: String {
		var ret = "PluralityDefinitionZoneValueIntervalOfInts: "
		if let startValue = startValue          {ret.append("start = \(startValue.fullStringValue)")}
		if startValue != nil && endValue != nil {ret.append(", ")}
		if let endValue = endValue              {ret.append("end = \(endValue.fullStringValue)")}
		return ret
	}
	
	private let startValue, endValue: PluralValue?
	
}

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



struct PluralityDefinitionZoneValueNumber : PluralityDefinitionZoneValue {
	
	init?(string: String) {
		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = CharacterSet()
		scanner.locale = nil /* Doc says it's the default. Let's make sure we have a nil locale. */
		
		var n: Int = 0
		let intSuccess = scanner.scanInt(&n)
		if intSuccess && scanner.isAtEnd {
			value = .int(n)
			return
		}
		
		/* If we can't parse an int, we won't be able to parse a double either. */
		guard intSuccess else {return nil}
		
		var f: Float = 0
		scanner.scanLocation = 0
		if scanner.scanFloat(&f) && scanner.isAtEnd {
			value = .float(f)
			return
		}
		
		return nil
	}
	
	func matches(int: Int) -> Bool {
		switch value {
		case .int(let i): return i == int
		case .float:      return false
		}
	}
	
	func matches(float: Float, characteristics: PluralValue.FloatCharacteristics) -> Bool {
		assert(characteristics.precision >= 0)
		
		let cmp: Float
		switch value {
		case .int(let i): cmp = Float(i)
		case .float(let f): cmp = f
		}
		return abs(cmp - float) <= characteristics.precision
	}
	
	var debugDescription: String {
		switch value {
		case .int(let i):   return "HCPluralityDefinitionZoneValueNumber: isInt = true, value = \(i)"
		case .float(let f): return "HCPluralityDefinitionZoneValueNumber: isInt = false, value = \(f)"
		}
	}
	
	private enum IntOrFloat {
		case int(Int)
		case float(Float)
	}
	
	private let value: IntOrFloat
	
}

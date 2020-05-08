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

import Foundation



#warning("TODO: Some floats are acutally ints depending on their characteristics! And some ints are floats depending on the formatter (which cannot even be specified at the moment…)")
public enum PluralValue {
	
	public struct FloatCharacteristics {
		
		/** The precision to use when comparing floats numerically
		(`abs(float1 - float2) <= precision`). */
		public var precision: Float
		public var minFractionDigits: Int
		public var maxFractionDigits: Int
		
		public init(precision p: Float, minFractionDigits minD: Int = 0, maxFractionDigits maxD: Int = 3) {
			assert(minD >= 0 && maxD >= minD)
			
			precision = p
			minFractionDigits = minD
			maxFractionDigits = maxD
		}
		
	}
	
	case int(Int)
	case float(Float)
	case floatCustomCharacteristics(value: Float, characteristics: FloatCharacteristics)
	
	public func asNumber() -> NSNumber {
		switch self {
			case .int(let i):                           return NSNumber(value: i)
			case .float(let f):                         return NSNumber(value: f)
			case .floatCustomCharacteristics(let f, _): return NSNumber(value: f)
		}
	}
	
}

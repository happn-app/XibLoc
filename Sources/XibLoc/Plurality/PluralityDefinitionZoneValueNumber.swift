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
		guard let pluralValue = PluralValue(string: string) else {
			return nil
		}
		refValue = pluralValue
	}
	
	func matches(pluralValue: PluralValue) -> Bool {
		#warning("TODO: Use !<>")
		/* First we check whether both have the same sign. */
		guard pluralValue.isNegativeNonZero == refValue.isNegativeNonZero else {
			return false
		}
		/* Then we check the int part of the given value. */
		guard pluralValue.intPart == refValue.intPart else {
			return false
		}
		/* If the given value doesn’t have a decimal separator (is int), we need
		 * the ref value to also be an int. However, if the given value is a
		 * float, it can match an int.
		 * Note: The requirement of an int being able to match only an int is a
		 *       bit weird and might be dropped at some point. It is left for the
		 *       time being to keep the previous behavior before PluralValue was
		 *       changed.
		 *       Theorically dropping the requirement can be done by simply
		 *       removing the guard below. */
		guard pluralValue.isFloat || refValue.isInt else {
			return false
		}
		/* Now, let’s check the fraction part of the given value. As we check for
		 * a numeric value equality (as opposed to a strict string equality), we
		 * remove the trailing zeros from the fraction parts we check. */
		guard (pluralValue.fractionPartNoTrailingZeros ?? "") == (refValue.fractionPartNoTrailingZeros ?? "") else {
			return false
		}
		return true
	}
	
	var debugDescription: String {
		return "HCPluralityDefinitionZoneValueNumber: value = \(refValue)"
	}
	
	private let refValue: PluralValue
	
}

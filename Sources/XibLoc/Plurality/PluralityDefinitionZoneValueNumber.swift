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
		/* If the ref value doesn’t have a decimal separator (is int), we need the given value to also be an int.
		 * However, if the ref value is a float, it can match an int.
		 *
		 * This matches the behavior of the interval of ints zone matching only ints while the interval of floats can match ints too.
		 *
		 * Note: Before the `PluralValue` rewrite, this zone did not behave like that:
		 *       if the ref value was a float it required the matched value to be a float too.
		 *       But it was not a correct behavior (and was very probably a bug actually). */
		guard refValue.isFloat || pluralValue.isInt else {
			return false
		}
		return pluralValue == refValue
	}
	
	var debugDescription: String {
		return "HCPluralityDefinitionZoneValueNumber: value = \(refValue)"
	}
	
	private let refValue: PluralValue
	
}

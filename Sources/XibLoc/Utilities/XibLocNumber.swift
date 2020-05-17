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



/**
Contains a PluralValue to resolve a plurality, and the localized string
representation of said plural value.

Interestingly, it is not possible to retrieve the original value of the number
from this struct (without parsing the string values available, which I would
definitely do not recommend)! */
public struct XibLocNumber {
	
	public static var defaultNumberFormatterInt: NumberFormatter = {
		let f = NumberFormatter()
		f.numberStyle = .none
		return f
	}()
	
	public static var defaultNumberFormatterFloat: NumberFormatter = {
		let f = NumberFormatter()
		f.numberStyle = .decimal
		return f
	}()
	
	public let localizedString: String
	public let pluralValue: PluralValue
	
	public init(_ i: Int, formatter: NumberFormatter = XibLocNumber.defaultNumberFormatterInt) {
		/* After looking at the code of the string(from:) function, it should
		 * never return `nil` in our use case. To be extra thorough and not crash
		 * in any circumstances, we do not force-unwrap but instead use the non-
		 * localized string version of the int in case the formatter returns nil. */
		localizedString = formatter.string(from: NSNumber(value: i)) ?? String(i)
		pluralValue = PluralValue(int: i, format: PluralValue.NumberFormat(numberFormatter: formatter))
	}
	
	public init(_ f: Float, formatter: NumberFormatter = XibLocNumber.defaultNumberFormatterFloat) {
		/* See comment in Int init for formatter comment, and in Float init of
		 * PluralValue for %f comment. */
		localizedString = formatter.string(from: NSNumber(value: f)) ?? String(format: "%f", locale: nil, f)
		pluralValue = PluralValue(float: f, format: PluralValue.NumberFormat(numberFormatter: formatter))
	}
	
	public init(localizedString str: String, pluralValue v: PluralValue) {
		localizedString = str
		pluralValue = v
	}
	
}

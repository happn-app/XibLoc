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
	
	public let localizedString: String
	public let pluralValue: PluralValue
	
	public init(_ i: Int, formatter: NumberFormatter = XibLocConfig.defaultNumberFormatterForInts) {
		localizedString = formatter.xl_string(from: NSNumber(value: i))
		pluralValue = PluralValue(int: i, format: PluralValue.NumberFormat(numberFormatter: formatter))
	}
	
	public init(_ f: Float, formatter: NumberFormatter = XibLocConfig.defaultNumberFormatterForFloats) {
		localizedString = formatter.xl_string(from: NSNumber(value: f))
		pluralValue = PluralValue(float: f, format: PluralValue.NumberFormat(numberFormatter: formatter))
	}
	
	public init(_ d: Double, formatter: NumberFormatter = XibLocConfig.defaultNumberFormatterForFloats) {
		localizedString = formatter.xl_string(from: NSNumber(value: d))
		pluralValue = PluralValue(double: d, format: PluralValue.NumberFormat(numberFormatter: formatter))
	}
	
	public init(localizedString str: String, pluralValue v: PluralValue) {
		localizedString = str
		pluralValue = v
	}
	
}

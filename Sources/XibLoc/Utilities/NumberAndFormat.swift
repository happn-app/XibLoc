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



public struct NumberAndFormat {
	
	public static let defaultNumberFormatterInt: NumberFormatter = {
		let f = NumberFormatter()
		f.numberStyle = .none
		return f
	}()
	
	public static let defaultNumberFormatterFloat: NumberFormatter = {
		let f = NumberFormatter()
		f.numberStyle = .decimal
		return f
	}()
	
	public var number: PluralValue
	public var formatter: NumberFormatter
	
	public init(_ i: Int, formatter fmt: NumberFormatter = NumberAndFormat.defaultNumberFormatterInt) {
		number = .int(i)
		formatter = fmt
	}
	
	public init(_ f: Float, pluralityPrecision: Float? = nil, formatter fmt: NumberFormatter = NumberAndFormat.defaultNumberFormatterFloat) {
		if let p = pluralityPrecision {number = .floatCustomPrecision(value: f, precision: p)}
		else                          {number = .float(f)}
		formatter = fmt
	}
	
	public func asString() -> String {
		return formatter.string(from: number.asNumber()) ?? ""
	}
	
}

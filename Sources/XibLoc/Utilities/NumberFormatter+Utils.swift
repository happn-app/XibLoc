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



public extension NumberFormatter {
	
	/**
	An alternative to `string(from:)` which does not return an optional value.
	
	In theory, after looking at the implementation of the formatter, it should
	never ever return `nil` when using “normal” numbers. However, the method
	returns an optional, so we propose this alternative to simplify using a
	`NumberFormatter` safely.
	
	The fallback in case the formatter returns `nil` uses a “`%*.f`” format, with
	the number of decimals set to minimumFractionDigits.
	
	- Note: About the naming, I thought about naming the method `string(from:)`
	like the one it enhances, however we can get an ambiguity when using the
	method, so I opted into prefixing the method with `xl` (for XibLoc). */
	func xl_string(from number: NSNumber) -> String {
		return string(from: number) ?? String(format: "%*.f", locale: Locale.current, minimumFractionDigits, number.doubleValue)
	}
	
}

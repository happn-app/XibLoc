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



/* This is a class instead of an enum (or struct) to be able to use self as an Object type. */
class Utils {
	
	static func localized(_ key: String) -> String {
#if HPN_XCODE_BUILD
		let testBundle = Bundle(for: self.self)
#else
		let testBundle = Bundle.module
#endif
		return NSLocalizedString(key, bundle: testBundle, comment: "Crash test")
	}
	
}


extension Optional {
	
	struct NoValue : Error {}
	
	func get() throws -> Wrapped {
		guard let v = self else {
			throw NoValue()
		}
		return v
	}
	
}

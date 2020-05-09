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
#if canImport(os)
	import os.log
#endif

#if !canImport(os) && canImport(DummyLinuxOSLog)
	import DummyLinuxOSLog
#endif



struct PluralityDefinitionZoneValueGlob : PluralityDefinitionZoneValue {
	
	/** Returns an “any number” glob match zone value (matches any number, either
	ints or floats). Equivalent of `init(string: "*")!`. An argument is required
	because we can't create an init method that has no argument and a name... */
	init(forAnyNumber: Void) {
		value = .anyNumber
	}
	
	/** Returns an “any float” glob match zone value (matches 1.0 but not 1).
	Equivalent of `init(string: "*.")!`. An argument is required because we can't
	create an init method that has no argument and a name... */
	init(forAnyFloat: Void) {
		value = .anyFloat
	}
	
	init?(string: String) {
		switch string {
		case "*", "^*{.*}$": value = .anyNumber
		case "*.", "^*.*$":  value = .anyFloat
			
		default:
			guard string.hasPrefix("^") && string.hasSuffix("$") else {return nil}
			
			var transformedString = string
				.replacingOccurrences(of: ".", with: "\\.")
				.replacingOccurrences(of: "?", with: "[0-9]")
				.replacingOccurrences(of: "*", with: "[0-9]*")
				.replacingOccurrences(of: "→", with: "-")
				.replacingOccurrences(of: "{", with: "(")
				.replacingOccurrences(of: "}", with: ")?")
			
			if       transformedString.hasPrefix("^+") {transformedString.remove(at: transformedString.index(after: transformedString.startIndex))} /* We remove the "+" */
			else if !transformedString.hasPrefix("^-") {transformedString.insert(contentsOf: "-?+", at: transformedString.index(after: transformedString.startIndex))}
//			#if canImport(os)
//				if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Glob language to regex conversion: “%@” --> “%@”", log: $0, type: .debug, string, transformedString) }}
//				else                                                          {NSLog("Glob language to regex conversion: “%@” --> “%@”", string, transformedString)}
//			#else
//				NSLogString("Glob language to regex conversion: “\(string)” --> “\(transformedString)”", log: di.log)
//			#endif
			
			do {value = .regex(try NSRegularExpression(pattern: string, options: []))}
			catch {
				#if canImport(os)
					if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Cannot create regular expression from string “%@” (original was “%@”); got error %@", log: $0, type: .info, transformedString, string, String(describing: error)) }}
					else                                                          {NSLog("Cannot create regular expression from string “%@” (original was “%@”); got error %@", transformedString, string, String(describing: error))}
				#else
					NSLogString("Cannot create regular expression from string “\(transformedString)” (original was “\(string)”); got error \(String(describing: error))", log: di.log)
				#endif
				return nil
			}
		}
	}
	
	func matches(pluralValue: PluralValue) -> Bool {
		switch value {
		case .anyNumber: return true
		case .anyFloat:  return pluralValue.isFloat
			
		case .regex(let regexp):
			let stringValue = pluralValue.fullStringValue
			guard let r = regexp.firstMatch(in: stringValue, options: [], range: NSRange(location: 0, length: (stringValue as NSString).length)) else {return false}
			guard r.range.location != NSNotFound else {return false} /* Not sure if needed, but better safe than sorry... */
			return true
		}
	}
	
	var debugDescription: String {
		return "HCPluralityDefinitionZoneValueGlob: value = \(value)"
	}
	
	private enum ValueType {
		case anyNumber
		case anyFloat
		case regex(NSRegularExpression)
	}
	
	private let value: ValueType
	
}

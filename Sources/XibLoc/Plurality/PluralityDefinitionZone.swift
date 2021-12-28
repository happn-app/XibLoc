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

import Logging



struct PluralityDefinitionZone : CustomDebugStringConvertible {
	
	let zoneValues: [PluralityDefinitionZoneValue]
	
	let index: Int
	let optionalityLevel: Int /* 0 is non-optional */
	let priorityDecreaseLevel: Int /* 0 is standard priority; higher is lower priority */
	
	/** Returns a zone that matches anything and have the given index. */
	init(index i: Int = 0, optionalityLevel o: Int = 0, priorityDecreaseLevel p: Int = 0) {
		index = i
		optionalityLevel = o
		priorityDecreaseLevel = p
		zoneValues = [PluralityDefinitionZoneValueGlob(forAnyNumber: ())]
	}
	
	init?(string: String, index i: Int) {
		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = CharacterSet()
		
		guard scanner.xl_scanString("(") != nil else {return nil}
		
		guard let zoneContent = scanner.xl_scanUpToString(")") else {return nil}
		guard scanner.xl_scanString(")") != nil else {return nil}
		
		let priorityDecreases = scanner.xl_scanCharacters(from: CharacterSet(charactersIn: "↓"))
		let optionalities     = scanner.xl_scanCharacters(from: CharacterSet(charactersIn: "?"))

		if !scanner.isAtEnd {
			#if canImport(os)
			if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
				Conf.oslog.flatMap{ os_log("Got garbage after end of plurality definition zone string: %@", log: $0, type: .info, (scanner.string as NSString).substring(from: scanner.scanLocation)) }}
			#endif
			Conf.logger?.warning("Got garbage after end of plurality definition zone string: \((scanner.string as NSString).substring(from: scanner.scanLocation))")
		}
		
		index = i
		optionalityLevel = optionalities?.count ?? 0
		priorityDecreaseLevel = priorityDecreases?.count ?? 0
		
		zoneValues = zoneContent.components(separatedBy: ":").compactMap{
			let ret: PluralityDefinitionZoneValue?
			if      let v = PluralityDefinitionZoneValueNumber(string: $0)           {ret = v}
			else if let v = PluralityDefinitionZoneValueIntervalOfInts(string: $0)   {ret = v}
			else if let v = PluralityDefinitionZoneValueIntervalOfFloats(string: $0) {ret = v}
			else if let v = PluralityDefinitionZoneValueGlob(string: $0)             {ret = v}
			else                                                                     {ret = nil}
			if ret == nil {
				let v = $0
				#if canImport(os)
				if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
					Conf.oslog.flatMap{ l in os_log("Cannot parse zone value string “%@”. Skipping...", log: l, type: .info, v) }}
				#endif
				Conf.logger?.warning("Cannot parse zone value string “\(v)”. Skipping...")
			}
			return ret
		}
	}
	
	func matches(pluralValue: PluralValue) -> Bool {
		return zoneValues.first{ $0.matches(pluralValue: pluralValue) } != nil
	}
	
	var debugDescription: String {
		var ret = "PluralityDefinitionZone (optionality \(optionalityLevel), priority decrease \(priorityDecreaseLevel), zone idx \(index): (\n"
		zoneValues.forEach{ ret.append("      \($0)\n") }
		ret.append("   )")
		return ret
	}
	
}

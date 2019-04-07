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

public struct PluralityDefinition : CustomDebugStringConvertible {
	
	let zones: [PluralityDefinitionZone]
	
	/** Returns an empty plurality definition, which will always return the
	latest plural version  */
	public init() {
		zones = []
	}
	
	/** Returns a plurality definition that contains one zone that matches
	anything. Will always return the first plural version. */
	public init(matchingAnything: Void) {
		zones = [PluralityDefinitionZone()]
	}
	
	/* Parses the plurality string to create a plurality definition. The parsing
	 * is forgiving: messages are printed in the logs if there are syntax errors. */
	public init(string: String) {
		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = CharacterSet()
		
		var idx = 0
		var zonesBuilding = [PluralityDefinitionZone]()
		repeat {
			if let garbage = scanner.scanUpToString("(") {
				#if canImport(os)
					if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Got garbage (%@) while parsing plurality definition string “%@”. Ignoring...", log: $0, type: .info, garbage, string) }}
					else                                                          {NSLog("Got garbage (%@) while parsing plurality definition string “%@”. Ignoring...", garbage, string)}
				#else
					NSLogString("Got garbage (\(garbage)) while parsing plurality definition string “\(string)”. Ignoring...", log: di.log)
				#endif
			}
			
			guard scanner.scanString("(", into: nil) else {break}
			
			guard let curZoneStrMinusOpeningParenthesis = scanner.scanUpToString("(") else {
				#if canImport(os)
					if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Got malformed plurality definition string “%@”. Attempting to continue anyway...", log: $0, type: .info, string) }}
					else                                                          {NSLog("Got malformed plurality definition string “%@”. Attempting to continue anyway...", string)}
				#else
					NSLogString("Got malformed plurality definition string “\(string)”. Attempting to continue anyway...", log: di.log)
				#endif
				continue
			}
			
			if let curZone = PluralityDefinitionZone(string: "(" + curZoneStrMinusOpeningParenthesis, index: idx) {
				zonesBuilding.append(curZone)
				idx += 1
			} else {
				#if canImport(os)
					if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Got zone str (%@), which I cannot parse into a zone", log: $0, type: .info, curZoneStrMinusOpeningParenthesis) }}
					else                                                          {NSLog("Got zone str (%@), which I cannot parse into a zone", curZoneStrMinusOpeningParenthesis)}
				#else
					NSLogString("Got zone str (\(curZoneStrMinusOpeningParenthesis)), which I cannot parse into a zone", log: di.log)
				#endif
			}
		} while !scanner.isAtEnd
		
		/* We sort the zones in order to optimize the removal of zones if needed
		 * when computing the version index to use for a given value. */
		zones = zonesBuilding.reversed().stableSorted{ (obj1, obj2) -> Bool? in
			if obj1.optionalityLevel > obj2.optionalityLevel {return true}
			if obj1.optionalityLevel < obj2.optionalityLevel {return false}
			return nil
		}
	}
	
	func indexOfVersionToUse(forValue value: PluralValue, defaultFloatCharacteristics: PluralValue.FloatCharacteristics = .init(precision: 0.00001), numberOfVersions: Int) -> Int {
		switch value {
		case .int(let int):                                               return indexOfVersionToUse(matchingZonePredicate: { $0.matches(int: int) }, numberOfVersions: numberOfVersions)
		case .float(let float):                                           return indexOfVersionToUse(matchingZonePredicate: { $0.matches(float: float, characteristics: defaultFloatCharacteristics) }, numberOfVersions: numberOfVersions)
		case .floatCustomCharacteristics(let float, let characteristics): return indexOfVersionToUse(matchingZonePredicate: { $0.matches(float: float, characteristics: characteristics) }, numberOfVersions: numberOfVersions)
		}
	}
	
	func indexOfVersionToUse(forValue int: Int, numberOfVersions: Int) -> Int {
		return indexOfVersionToUse(matchingZonePredicate: { $0.matches(int: int) }, numberOfVersions: numberOfVersions)
	}
	
	func indexOfVersionToUse(forValue float: Float, characteristics: PluralValue.FloatCharacteristics, numberOfVersions: Int) -> Int {
		return indexOfVersionToUse(matchingZonePredicate: { $0.matches(float: float, characteristics: characteristics) }, numberOfVersions: numberOfVersions)
	}
	
	public var debugDescription: String {
		var ret = "PluralityDefinition: (\n"
		zones.forEach{ ret.append("   \($0)\n") }
		ret.append(")")
		return ret
	}
	
	private func indexOfVersionToUse(matchingZonePredicate: (PluralityDefinitionZone) -> Bool, numberOfVersions: Int) -> Int {
		assert(numberOfVersions > 0)
		
		let matchingZones = zonesToTest(for: numberOfVersions).filter(matchingZonePredicate)
		
		if matchingZones.isEmpty {
//			#if canImport(os)
//				if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("No zones matched for given predicate in plurality definition %{public}@. Returning latest version.", log: $0, String(describing: self)) }}
//				else                                                          {NSLog("No zones matched for given predicate in plurality definition %@. Returning latest version.", String(describing: self))}
//			#else
//				NSLogString("No zones matched for given predicate in plurality definition \(String(describing: self)). Returning latest version.", log: di.log)
//			#endif
			return numberOfVersions-1
		}
		
		return adjust(zoneIndex: bestMatchingZone(from: matchingZones).index, fromRemovalsDueToNumberOfVersions: numberOfVersions)
	}
	
	private func zonesToTest(for numberOfVersions: Int) -> [PluralityDefinitionZone] {
		guard zones.count > numberOfVersions else {return zones}
		
		/* The zones are already sorted in a way that we can do the trick below. */
		let sepIdx = zones.count - numberOfVersions
		if zones[sepIdx-1].optionalityLevel == 0 {
			#if canImport(os)
				if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Had to remove at least one non-optional zone in plurality definition %@ in order to get version idx for %d version(s).", log: $0, type: .info, String(describing: self), numberOfVersions) }}
				else                                                          {NSLog("Had to remove at least one non-optional zone in plurality definition %@ in order to get version idx for %d version(s).", String(describing: self), numberOfVersions)}
			#else
				NSLogString("Had to remove at least one non-optional zone in plurality definition \(String(describing: self)) in order to get version idx for \(numberOfVersions) version(s).", log: di.log)
			#endif
		}
		return Array(zones[sepIdx..<zones.endIndex])
	}
	
	private func adjust(zoneIndex: Int, fromRemovalsDueToNumberOfVersions nVersions: Int) -> Int {
		guard zones.count > nVersions else {return zoneIndex}
		
		let sepIdx = zones.count - nVersions
		return zones[0..<sepIdx].reduce(zoneIndex){ (curIdx, zone) -> Int in
			if zone.index < zoneIndex {return curIdx - 1}
			return curIdx
		}
	}
	
	private func bestMatchingZone(from matchingZones: [PluralityDefinitionZone]) -> PluralityDefinitionZone {
		return matchingZones.sorted{ (obj1, obj2) -> Bool in
			if obj1.priorityDecreaseLevel < obj2.priorityDecreaseLevel {return true}
			if obj1.priorityDecreaseLevel > obj2.priorityDecreaseLevel {return false}
			if obj1.index < obj2.index {return true}
			if obj1.index > obj2.index {return false}
			fatalError("***** INTERNAL ERROR: Got two matching zones with the same index (\(obj1) and \(obj2) in plurality description \(self). This should not be possible!")
		}.first!
	}
	
}

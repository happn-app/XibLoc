/*
 * PluralityDefinitionZone.swift
 * XibLoc
 *
 * Created by François Lamboley on 8/26/17.
 * Copyright © 2017 happn. All rights reserved.
 */

import Foundation
import os.log



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
		
		guard scanner.scanString("(", into: nil) else {return nil}
		
		var zoneContent: NSString?
		guard scanner.scanUpTo(")", into: &zoneContent) else {return nil}
		guard scanner.scanString(")", into: nil) else {return nil}
		
		var optionalities: NSString?
		var priorityDecreases: NSString?
		scanner.scanCharacters(from: CharacterSet(charactersIn: "↓"), into: &priorityDecreases)
		scanner.scanCharacters(from: CharacterSet(charactersIn: "?"), into: &optionalities)
		
		if !scanner.isAtEnd {
			if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ os_log("Got garbage after end of plurality definition zone string: %@", log: $0, type: .info, (scanner.string as NSString).substring(from: scanner.scanLocation)) }}
			else                                                          {NSLog("Got garbage after end of plurality definition zone string: %@", (scanner.string as NSString).substring(from: scanner.scanLocation))}
		}
		
		index = i
		optionalityLevel = optionalities?.length ?? 0
		priorityDecreaseLevel = priorityDecreases?.length ?? 0
		
		zoneValues = zoneContent!.components(separatedBy: ":").compactMap{
			let ret: PluralityDefinitionZoneValue?
			if      let v = PluralityDefinitionZoneValueNumber(string: $0)           {ret = v}
			else if let v = PluralityDefinitionZoneValueIntervalOfInts(string: $0)   {ret = v}
			else if let v = PluralityDefinitionZoneValueIntervalOfFloats(string: $0) {ret = v}
			else if let v = PluralityDefinitionZoneValueGlob(string: $0)             {ret = v}
			else                                                                     {ret = nil}
			if ret == nil {
				let v = $0
				if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {di.log.flatMap{ l in os_log("Cannot parse zone value string “%@”. Skipping...", log: l, type: .info, v) }}
				else                                                          {NSLog("Cannot parse zone value string “%@”. Skipping...", v)}
			}
			return ret
		}
	}
	
	func matches(int: Int) -> Bool {
		return zoneValues.first{ $0.matches(int: int) } != nil
	}
	
	func matches(float: Float, precision: Float) -> Bool {
		return zoneValues.first{ $0.matches(float: float, precision: precision) } != nil
	}
	
	var debugDescription: String {
		var ret = "PluralityDefinitionZone (optionality \(optionalityLevel), priority decrease \(priorityDecreaseLevel), zone idx \(index): (\n"
		zoneValues.forEach{ ret.append("      \($0)\n") }
		ret.append("   )")
		return ret
	}
	
}

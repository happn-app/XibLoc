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

#if canImport(Logging)
	import Logging
#endif



/** The Plurality definition defines which version of the "`<v1:v2:v3>`" plural
strings to use depending on the PluralValue it is given.

Here are the rules that are used:
- Each possible version should be represented by a “zone;”
- A zone is as follow: “`(zone_content)↓??`” where “zone_content” is defined
  later and the number of “`?`” and “`↓`” ∈ ℕ (`↓`s must be before `?`s);
- A plurality definition is a list of zones (concatenated zones);
- In a zone, there is a list of values, separated by a colon. Values can be:
   - A single number (int or float, no leading + or 0 allowed). If the number is
     an int, only ints will match, otherwise ints and floats can match;
   - An interval of ints, with this syntax: `n→m`, where `n` and `m` are ints.
     Only ints can match;
   - An continuous interval (can match ints and floats), with this syntax:
     `[n→m]`, where:
      - `n` and `m` are floats (the decimal separator can be omitted);
      - the opening and closing separator regions can be either opening
        or closing square brackets (to include or exclude the value)
   - A custom “globbing” expression:
      - Must start with “`^`”, and end with “`$`”;
      - Match is done on given plural value’s `fullStringValue`;
      - By default, the glob will match positive and negative numbers (the sign
        is ignored). To force positive or negative matching, you must add a
        “`+`” or “`-`” resp. after the “`^`”;
      - Wildcards (both versions match only digits; not the decimal separator):
         - “`*`” to match any number of digits (including none);
         - “`?`” to match exactly one digit
      - Range (same semantics as standard regex’s `[]` where `-` is replaced by
        `→`. “`→`” is specifically reserved for a “digit to digit” use. The
        decimal separator is NOT allowed in brackets.):
         - “`[135]`” or “`[1→57]`” to match resp. 1, 3 or 5 and 1 to 5 or 7;
         - “`[^135]`” or “`[^1→57]`” to match any digit except the above
      - Optional: “`{1}`” to match what’s inside the curly brackets—or not;
      - No other characters than the one with meaning in regard to the above
        rules are allowed in a globbing expression. To summarize:
         - The following is mandatory resp. at beginning and end:
              “`^`” and “`$`”
         - Right after the “`^`”, is allowed: “`-`” and “`+`”
         - The following is allowed inside:
            - any digits, “`.`”, “`*`”, “`?`”, “`[`”, “`]`”, “`{`”, “`}`”
            - and “`^`” and “`→`” inside a “`[]`” block
      - Example: “`^*3$`” matches all ints ending with 3
      - Example: “`^*3.*$`” matches all floats whose int value ends with 3
      - Example: “`^*3{.*}$`” matches all floats or int whose int value ends
                              with 3
      - Example: “`^{*.}*3$`” matches any number (int or float) ending with 3
                              (13, 1.53, etc.)
      - Example: “`^*[3→5]$`” matches all ints ending with 3, 4 or 5
      - Example: “`^-*3$`” matches all negative ints ending with 3
      - Example: “`^+*3$`” matches all positive ints ending with 3
      - Example: “`^*.*$`” matches all floats, but not ints
      - Example: “`^*.$`” matches all integral floats, but not ints
      - Example: “`^*$`” matches all ints, but not floats
      - Example: “`^*{.*}$`” matches any number
   - The string “`*.`”: it is an alias to “`^*.*$`”
   - The string “`*`”: it is an alias to “`^*{.*}$`”

If the number of zones does not match the number of versions, the following
algorithm will be used in order to match a version:
   - If the number of version is greater than the number of zones a warning will
     be printed in the logs. The first matching zone will be used.
   - If the number of versions is smaller than the number of zones, some zones
     will be removed until the number of zones equal the number of versions
     using the following algorithm:
      - The zones with the more question marks are removed first;
      - If two zones have the same number of question marks, the **LAST** one is
        removed first.
      - A warning is printed in the logs if a non-question-marked zone have to
        be removed.

If more than one zone match, the first that matches and has the lowest number
of `↓` is used.
If no zone matches, the **LAST** version will be used and an info message will
be logged.

---
**Examples**:
   - Standard plural (0 is plural):
     ```text
     “(1)(*)” or “(1)” (generic case is implicit)
        -> Versions are defined with <singular:plural>
     ```

   - Standard plural (0 is singular):
     ```text
     “(0:1)(*)” or “(0→1)(*)” or “(0:1)” etc.
        -> Versions are defined with <singular:plural>
     ```

   - Standard plural with optional dual (0 is plural):
     ```text
     “(1)(2)?(*)”
        -> Versions are defined with <singular:plural> or <singular:dual:plural>
     ```

   - Standard plural with optional dual and trial (0 is plural):
     ```text
     “(1)(2)?(3)??(*)” or “(1)(2)?(3)?(*)” (both are equivalent)
        -> Versions are defined with <singular:plural>, <singular:dual:plural> or <singular:dual:trial:plural>
     ```

   - Singular (0 and 1), optional few (2 to 5), plural (the rest):
     ```text
     “(0→1)(2→5)?(*)”
        -> Versions are defined with <singular:few:plural> or <singular:plural>
     ```

   - Number ending with 1, number ending with 2, 3 or 4, the rest:
     ```text
     “(^*1$)(^*[2→4]$)(*)”
        -> Versions are defined with <ones:two_to_four:rest>
     ```

   - Custom plural for 1, then 2, 5, 6.3 and anything (including floats) between
     6.4 (excluded) and 8 (included), then ints from 6 to 9:
     ```text
     “(1)(2:5:6.3:]6.4→8])(6→9)”
     ```
     - Note: As there is no `(*)` zone, the latest one (6 to 9) will match for
       non-matching numbers.

       With `<zone1:zone2:zone3>`:
        - For 1, the value will be zone1
        - For 2, the value will be zone2
        - For 6.3, the value will be zone2
        - For 6.4, the value will be zone3 (6.4 does not match any zone, so it
          matches the latest)
        - For 6.31, the value will be zone3 (6.31 does not match any zone, so it
          matches the latest)
        - For 6.41, the value will be zone2
        - For 8, the value will be zone2 (both zone2 and zone3 matches, but the
          first one is used)

   - Custom plural for 1, 2, 3 then 2 to 5 (floats too) then any int below 7
     then the rest:
     ```text
     “(1→3)([2→5[)(→6)(*)”
     ```

   - Custom plural for 1, 2, 3 then 2.5 to 5 (floats too) then any int above 5
     with star zones at the beginning:
     ```text
     “(*)↓↓(*.)↓(1→3)([2.5→5])(6→)”
     ```
     With `<zone1:zone2:zone3:zone4:zone5>`:
      - For 1, the value will be zone3. zone1 matches first, but has a lower
        priority than zone3. */
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
					if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
						XibLocConfig.oslog.flatMap{ os_log("Got garbage (%@) while parsing plurality definition string “%@”. Ignoring...", log: $0, type: .info, garbage, string) }
					}
				#endif
				#if canImport(Logging)
					XibLocConfig.logger?.warning("Got garbage (\(garbage)) while parsing plurality definition string “\(string)”. Ignoring...")
				#endif
			}
			
			guard scanner.scanString("(", into: nil) else {break}
			
			guard let curZoneStrMinusOpeningParenthesis = scanner.scanUpToString("(") else {
				#if canImport(os)
					if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
						XibLocConfig.oslog.flatMap{ os_log("Got malformed plurality definition string “%@”. Attempting to continue anyway...", log: $0, type: .info, string) }
					}
				#endif
				#if canImport(Logging)
					XibLocConfig.logger?.warning("Got malformed plurality definition string “\(string)”. Attempting to continue anyway...")
				#endif
				continue
			}
			
			if let curZone = PluralityDefinitionZone(string: "(" + curZoneStrMinusOpeningParenthesis, index: idx) {
				zonesBuilding.append(curZone)
				idx += 1
			} else {
				#if canImport(os)
					if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
						XibLocConfig.oslog.flatMap{ os_log("Got zone str (%@), which I cannot parse into a zone", log: $0, type: .info, curZoneStrMinusOpeningParenthesis) }
					}
				#endif
				#if canImport(Logging)
					XibLocConfig.logger?.warning("Got zone str (\(curZoneStrMinusOpeningParenthesis)), which I cannot parse into a zone")
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
	
	func indexOfVersionToUse(forValue value: PluralValue, numberOfVersions: Int) -> Int {
		assert(numberOfVersions > 0)
		
		let matchingZones = zonesToTest(for: numberOfVersions).filter{ $0.matches(pluralValue: value) }
		
		if matchingZones.isEmpty {
			#if canImport(os)
				if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
					XibLocConfig.oslog.flatMap{ os_log("No zones matched for given predicate in plurality definition %{public}@. Returning latest version.", log: $0, type: .info, String(describing: self)) }
				}
			#endif
			#if canImport(Logging)
				XibLocConfig.logger?.warning("No zones matched for given predicate in plurality definition \(String(describing: self)). Returning latest version.")
			#endif
			return numberOfVersions-1
		}
		
		return adjust(zoneIndex: bestMatchingZone(from: matchingZones).index, fromRemovalsDueToNumberOfVersions: numberOfVersions)
	}
	
	public var debugDescription: String {
		var ret = "PluralityDefinition: (\n"
		zones.forEach{ ret.append("   \($0)\n") }
		ret.append(")")
		return ret
	}
	
	private func zonesToTest(for numberOfVersions: Int) -> [PluralityDefinitionZone] {
		guard zones.count > numberOfVersions else {return zones}
		
		/* The zones are already sorted in a way that we can do the trick below. */
		let sepIdx = zones.count - numberOfVersions
		if zones[sepIdx-1].optionalityLevel == 0 {
			#if canImport(os)
				if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
					XibLocConfig.oslog.flatMap{ os_log("Had to remove at least one non-optional zone in plurality definition %@ in order to get version idx for %d version(s).", log: $0, type: .info, String(describing: self), numberOfVersions) }
				}
			#endif
			#if canImport(Logging)
				XibLocConfig.logger?.warning("Had to remove at least one non-optional zone in plurality definition \(String(describing: self)) in order to get version idx for \(numberOfVersions) version(s).")
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

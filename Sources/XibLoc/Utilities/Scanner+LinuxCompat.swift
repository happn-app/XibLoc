/*
 * Scanner+LinuxCompat.swift
 * XibLoc
 *
 * Created by François Lamboley on 15/09/2018.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



#if !os(Linux)

extension Scanner {
	
	func scanUpToString(_ string: String) -> String? {
		var result: NSString?
		guard scanUpTo(string, into: &result) else {return nil}
		return result! as String
	}
	
	func scanCharactersFromSet(_ set: CharacterSet) -> String? {
		var result: NSString?
		guard scanCharacters(from: set, into: &result) else {return nil}
		return result! as String
	}
	
}

#endif

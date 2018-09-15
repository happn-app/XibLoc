/*
 * Scanner+LinuxCompat.swift
 * XibLoc
 *
 * Created by François Lamboley on 15/09/2018.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



#if os(Linux)

extension Scanner {
	
	func scanUpTo(_ string: String, into result: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
		let r = scanUpToString("(")
		result?.pointee = r as NSString?
		return (r != nil)
	}
	
	func scanCharacters(from set: CharacterSet, into result: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
		let r = scanCharactersFromSet(set)
		result?.pointee = r as NSString?
		return (r != nil)
	}
	
}

#endif

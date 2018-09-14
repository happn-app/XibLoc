/*
 * DependencyInjection.swift
 * XibLoc
 *
 * Created by François Lamboley on 1/22/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation
#if canImport(os)
	import os.log
#endif

#if !canImport(os) && canImport(DummyLinuxOSLog)
	import DummyLinuxOSLog
#endif



public struct DependencyInjection {
	
	init() {
		#if canImport(os)
			if #available(OSX 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {log = .default}
			else                                                          {log = nil}
		#else
			log = nil
		#endif
	}
	
	public var log: OSLog?
	
	public var defaultEscapeToken: String? = nil
	public var defaultPluralityDefinition = PluralityDefinition()
	
	#if !os(Linux)
	public var defaultStr2AttrStrAttributes: [NSAttributedString.Key: Any]? = nil
	#endif
	
}

public var di = DependencyInjection()

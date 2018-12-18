/*
 * NumberAndFormat.swift
 * XibLoc
 *
 * Created by François Lamboley on 4/16/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



public struct NumberAndFormat {
	
	public var number: PluralValue
	public var formatter: NumberFormatter
	
	public init(_ i: Int, formatter fmt: NumberFormatter? = nil) {
		number = .int(i)
		if let nFormatter = fmt {
			formatter = nFormatter
		} else {
			let nFormatter = NumberFormatter()
			/* `none` currently is the default type but, in order to be sure, we
			 * manually define the value. */
			nFormatter.numberStyle = .none
			formatter = nFormatter
		}
	}
	
	public init(_ f: Float, pluralityPrecision: Float? = nil, formatter fmt: NumberFormatter? = nil) {
		if let p = pluralityPrecision {number = .floatCustomPrecision(value: f, precision: p)}
		else                          {number = .float(f)}
		if let nFormatter = fmt {
			formatter = nFormatter
		} else {
			let nFormatter = NumberFormatter()
			/* `none` currently is the default type but, in order to be sure, we
			 * manually define the value. */
			nFormatter.numberStyle = .decimal
			formatter = nFormatter
		}
	}
	
	public func asString() -> String {
		return formatter.string(from: number.asNumber()) ?? ""
	}
	
}

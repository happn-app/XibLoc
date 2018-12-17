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
	
	public init(_ i: Int, formatter fmt: NumberFormatter = NumberFormatter()) {
		number = .int(i)
		fmt.locale = NSLocale.current
		/* `none` currently is the default type but, in order to be sure, we
		 * manually define the value. */
		fmt.numberStyle = .none
		formatter = fmt
	}
	
	public init(_ f: Float, pluralityPrecision: Float? = nil, formatter fmt: NumberFormatter = NumberFormatter()) {
		if let p = pluralityPrecision {number = .floatCustomPrecision(value: f, precision: p)}
		else                          {number = .float(f)}
		fmt.locale = NSLocale.current
		fmt.numberStyle = .decimal
		formatter = fmt
	}
	
	public func asString() -> String {
		return formatter.string(from: number.asNumber()) ?? ""
	}
	
}

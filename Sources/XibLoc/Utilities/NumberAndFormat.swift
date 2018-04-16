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
	public var format: NumberFormatter.Style
	
	public init(_ i: Int, format fmt: NumberFormatter.Style = .none) {
		number = .int(i)
		format = fmt
	}
	
	public init(_ f: Float, pluralityPrecision: Float? = nil, format fmt: NumberFormatter.Style = .decimal) {
		if let p = pluralityPrecision {number = .floatCustomPrecision(value: f, precision: p)}
		else                          {number = .float(f)}
		format = fmt
	}
	
	public func asString() -> String {
		return NumberFormatter.localizedString(from: number.asNumber(), number: format)
	}
	
}

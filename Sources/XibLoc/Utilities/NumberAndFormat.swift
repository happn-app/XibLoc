/*
 * NumberAndFormat.swift
 * XibLoc
 *
 * Created by François Lamboley on 4/16/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



public struct NumberAndFormat {
	
	public static let defaultNumberFormatterInt: NumberFormatter = {
		let f = NumberFormatter()
		f.numberStyle = .none
		return f
	}()
	
	public static let defaultNumberFormatterFloat: NumberFormatter = {
		let f = NumberFormatter()
		f.numberStyle = .decimal
		return f
	}()
	
	public var number: PluralValue
	public var formatter: NumberFormatter
	
	public init(_ i: Int, formatter fmt: NumberFormatter = NumberAndFormat.defaultNumberFormatterInt) {
		number = .int(i)
		formatter = fmt
	}
	
	public init(_ f: Float, pluralityPrecision: Float? = nil, formatter fmt: NumberFormatter = NumberAndFormat.defaultNumberFormatterFloat) {
		if let p = pluralityPrecision {number = .floatCustomPrecision(value: f, precision: p)}
		else                          {number = .float(f)}
		formatter = fmt
	}
	
	public func asString() -> String {
		return formatter.string(from: number.asNumber()) ?? ""
	}
	
}

/*
Copyright 2020 happn

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



/**
 Defines a “plural value,” which is used when resolving a plurality definition, to choose the correct zone index to show.
 
 Resolving a plural requires to have much information about said plural.
 For instance, depending on the language, the plural can be different for the same number, whether it is a float or an int!
 We can cite the case of the Asturian language in which, providing I undestood Unicode’s specs correctly, a value is singular for `1`, and 1 _only_: a value of `1.0` would be plural.
 
 The `PluralValue` contains all the required information to correctly resolve the plural.
 
 - Important: `PluralValue` does **not** conform to `Comparable` nor `Equatable` but still implement the `==`, `<` and other comparison operators on `PluralValue`.
 These implementation compare the _numeric_ values represented by the `PluralValue`, which mean you can have two `PluralValue`s that are equal when using the `==` operator,
 but do not have the same string representation.
 If you want to check for full equality, compare the `fullStringValue`s of your `PluralValue`s.
 See the note below for a rationale.
 
 - Note: This is important for people working on XibLoc:
 `PluralValue` cannot conform to `Comparable` (or `Equatable`) because two PluralValue can represent the same number,
 in which case we could have `!(pv1 < pv2)` and `!(pv1 > pv2)` but `pv1 != pv2` (e.g. with `pv1 = "1"` and `pv2 = 1.0`) and this is forbidden by the `Comparable` protocol.
 See [the doc](https://developer.apple.com/documentation/swift/comparable) for more info about the `Comparable` protocol.
 
 We still implement the `==`, `<` and other comparison operators on `PluralValue` just not using the `Comparable` protocol. */
public struct PluralValue {
	
	public struct NumberFormat {
		
		var minFractionDigits: Int
		var maxFractionDigits: Int
		
		var forceDecimalSeparator: Bool
		var zeroIsNegative: Bool
		
		public init(minFractionDigits min: Int, maxFractionDigits max: Int, forceDecimalSeparator forceSep: Bool = false, zeroIsNegative negativeZero: Bool = false) {
			assert(max >= min && min >= 0)
			minFractionDigits = min
			maxFractionDigits = max
			
			forceDecimalSeparator = forceSep
			zeroIsNegative = negativeZero
		}
		
		public init(numberFormatter: NumberFormatter) {
			self.init(
				minFractionDigits: max(0, numberFormatter.minimumFractionDigits),
				maxFractionDigits: max(0, max(numberFormatter.minimumFractionDigits, numberFormatter.maximumFractionDigits)),
				forceDecimalSeparator: numberFormatter.alwaysShowsDecimalSeparator,
				zeroIsNegative: numberFormatter.zeroSymbol?.contains(numberFormatter.minusSign) ?? false /* Closest thing I could find to mean this */
			)
		}
		
	}
	
	public static func compare(_ lhs: PluralValue, _ rhs: PluralValue) -> ComparisonResult {
		let lhsNegative = lhs.isNegativeNonZero
		let rhsNegative = rhs.isNegativeNonZero
		
		/* First let’s compare negativity */
		if  lhsNegative && !rhsNegative {return .orderedAscending}
		if !lhsNegative &&  rhsNegative {return .orderedDescending}
		
		/* Now we know both values have the same sign.
		 * We will thus compare the values as if they were positive.
		 * If we’re negative, we’ll simply invert the result. */
		assert(lhsNegative == rhsNegative)
		let resultHandler = { (r: ComparisonResult) -> ComparisonResult in
			switch r {
				case .orderedSame:       return .orderedSame
				case .orderedAscending:  return lhsNegative ? .orderedDescending : .orderedAscending
				case .orderedDescending: return lhsNegative ? .orderedAscending  : .orderedDescending
			}
		}
		
		/* If the int part of one side is bigger than the other, we know that part is greater than the other (leading 0s are not allowed). */
		if lhs.intPart.count < rhs.intPart.count {return resultHandler(.orderedAscending)}
		if lhs.intPart.count > rhs.intPart.count {return resultHandler(.orderedDescending)}
		
		let lhsFractionPartNoTrailingZeros = (lhs.fractionPartNoTrailingZeros ?? "")
		let rhsFractionPartNoTrailingZeros = (rhs.fractionPartNoTrailingZeros ?? "")
		
		/* Now we know both int parts have the same number of characters.
		 * Let’s compare these characters.
		 *
		 * Funny thing is we can directly add the fraction part to the int part and zip on those two sequences.
		 * zip will return a sequence of the length of the shortest sequence.
		 *
		 * To have a visual example, consider the comparison of
		 *    (1.25 <-> 1.26) and (12.5 <-> 12.65) and (125 <-> 126)
		 * For either couple, comparing the int part first, then the fraction part is exactly the same as comparing the int part with a concatenation of the fraction part
		 * (because remember, the int part has the same number of digits for both numbers in each couple). */
		for (lhsChar, rhsChar) in zip(lhs.intPart + lhsFractionPartNoTrailingZeros, rhs.intPart + rhsFractionPartNoTrailingZeros) {
			let lhsDigit = PluralValue.characterToDigit[lhsChar]!
			let rhsDigit = PluralValue.characterToDigit[rhsChar]!
			if lhsDigit < rhsDigit {return resultHandler(.orderedAscending)}
			if lhsDigit > rhsDigit {return resultHandler(.orderedDescending)}
		}
		
		/* Now we know both values have the same int part and have a common fraction part prefix.
		 * The one that has the longest fraction part is the bigger because we use the fraction part without trailing zeros (`1.25 < 1.251`). */
		if lhsFractionPartNoTrailingZeros.count < rhsFractionPartNoTrailingZeros.count {return resultHandler(.orderedAscending)}
		if lhsFractionPartNoTrailingZeros.count > rhsFractionPartNoTrailingZeros.count {return resultHandler(.orderedDescending)}
		
		return .orderedSame
	}
	
	public static func ==(lhs: PluralValue, rhs: PluralValue) -> Bool {
		return PluralValue.compare(lhs, rhs) == .orderedSame
	}
	
	public static func <(lhs: PluralValue, rhs: PluralValue) -> Bool {
		return PluralValue.compare(lhs, rhs) == .orderedAscending
	}
	
	public static func <=(lhs: PluralValue, rhs: PluralValue) -> Bool {
		let c = PluralValue.compare(lhs, rhs)
		return (c == .orderedAscending || c == .orderedSame)
	}
	
	public static func >(lhs: PluralValue, rhs: PluralValue) -> Bool {
		return PluralValue.compare(lhs, rhs) == .orderedDescending
	}
	
	public static func >=(lhs: PluralValue, rhs: PluralValue) -> Bool {
		let c = PluralValue.compare(lhs, rhs)
		return (c == .orderedDescending || c == .orderedSame)
	}
	
	/** Is the plural value negative? */
	public let isNegative: Bool
	/** The int part of the plural value. Will never have leading 0s. */
	public let intPart: String
	/**
	 The fraction part of the plural value.
	 
	 If `nil`, the value is an int.
	 
	 Can be empty, in which case the value is of the form `9.` (a float with no fraction part). */
	public let fractionPart: String?
	
	public var isZero: Bool {PluralValue.isZero(intPart: intPart, fractionPart: fractionPart ?? "")}
	public var isNegativeNonZero: Bool {isNegative && !isZero}
	
	public var isInt: Bool {fractionPart == nil}
	public var isFloat: Bool {fractionPart != nil}
	public var fullStringValue: String {(isNegative ? "-" : "") + fullStringAbsoluteValue}
	public var fullStringAbsoluteValue: String {intPart + (fractionPart.flatMap{ "." + $0 } ?? "")}
	public var fractionPartNoTrailingZeros: String? {(fractionPart?.reversed().drop(while: { $0 == "0" }).reversed()).flatMap(String.init)}
	
	/** n from https://www.unicode.org/reports/tr35/tr35-numbers.html#Operands */
	public var unicodeOperandN: String {fullStringAbsoluteValue}
	/** i from https://www.unicode.org/reports/tr35/tr35-numbers.html#Operands */
	public var unicodeOperandI: String {intPart}
	/** v from https://www.unicode.org/reports/tr35/tr35-numbers.html#Operands */
	public var unicodeOperandV: Int {fractionPart?.count ?? 0}
	/** w from https://www.unicode.org/reports/tr35/tr35-numbers.html#Operands */
	public var unicodeOperandW: Int {fractionPartNoTrailingZeros?.count ?? 0}
	/** f from https://www.unicode.org/reports/tr35/tr35-numbers.html#Operands */
	public var unicodeOperandF: String {(fractionPart?.drop(while: { $0 == "0" })).flatMap(String.init).flatMap{ !$0.isEmpty ? $0 : "0" } ?? "0"}
	/** t from https://www.unicode.org/reports/tr35/tr35-numbers.html#Operands */
	public var unicodeOperandT: String {(fractionPartNoTrailingZeros?.drop(while: { $0 == "0" })).flatMap(String.init).flatMap{ !$0.isEmpty ? $0 : "0" } ?? "0"}
	
	public init(int: Int, format: NumberFormat = NumberFormat(minFractionDigits: 0, maxFractionDigits: 0)) {
		let str = String(int, radix: 10)
		self.init(intPart: str, fractionPart: String(repeating: "0", count: format.minFractionDigits), forceDecimalSeparator: format.forceDecimalSeparator, forceNegativeZero: format.zeroIsNegative)!
	}
	
	public init(float: Float, format: NumberFormat) {
		self.init(double: Double(float), format: format)
	}
	
	public init(double: Double, format: NumberFormat) {
		/* Doc of `NSString` for init with format and locale says if we specify a `nil` locale, we get the system locale.
		 * The system locale, says the doc, is the locale to use when we don’t want any localizations, which is exactly what we want!
		 *
		 * The format `%.*f` will take the double it is given and output exactly the given number fraction digits.
		 *
		 * The `%f` format work for floats and doubles.
		 * So as long as Swift does not represent floats or doubles using `long double` internally, we will be good passing them to String(format:). */
		let stringValue = String(format: "%.*f", locale: nil, format.maxFractionDigits, double)
		let components = stringValue.split(separator: ".", omittingEmptySubsequences: false)
		assert(components.count == 2 || components.count == 1)
		
		let intPart = String(components[components.startIndex])
		var fractionPart = components.elementIndex(forOffset: 1).flatMap{ String(components[$0]) } ?? ""
		assert(fractionPart.count == format.maxFractionDigits)
		while fractionPart.hasSuffix("0") && fractionPart.count > format.minFractionDigits {
			fractionPart.removeLast()
		}
		
		self.init(intPart: intPart, fractionPart: fractionPart, forceDecimalSeparator: format.forceDecimalSeparator, forceNegativeZero: format.zeroIsNegative)!
	}
	
	public init?(string: String) {
		let components = string.split(separator: ".", omittingEmptySubsequences: false)
		guard components.count == 1 || components.count == 2 else {return nil}
		self.init(
			intPart: String(components[components.startIndex]),
			fractionPart: components.elementIndex(forOffset: 1).flatMap{ String(components[$0]) } ?? nil
		)
	}
	
	public init?(intPart i: String, fractionPart f: String?) {
		let negative = (i.first == "-")
		let i = (negative ? String(i.dropFirst()) : i)
		self.init(
			intPart: i,
			fractionPart: f,
			isNegative: negative
		)
	}
	
	/**
	 Init a PluralValue directly with its parts.
	 
	 Init fails if either:
	 - The int or fraction part contains a non-numeric (base-10) character;
	 - The int part has a 0 prefix (and is not equal to 0);
	 - The int part is empty. */
	public init?(intPart i: String, fractionPart f: String?, isNegative n: Bool) {
		guard
			!i.isEmpty,
			(!i.hasPrefix("0") || i == "0"),
			i.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789").inverted, options: [.literal]) == nil,
			f?.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789").inverted, options: [.literal]) == nil
		else {
			return nil
		}
		
		isNegative = n
		intPart = i
		fractionPart = f
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private static let characterToDigit: [Character: Int] = [
		"0": 0,
		"1": 1, "2": 2, "3": 3,
		"4": 4, "5": 5, "6": 6,
		"7": 7, "8": 8, "9": 9
	]
	
	private static func isZero(intPart i: String, fractionPart f: String) -> Bool {
		return (i == "0" && !f.contains(where: { $0 != "0" }))
	}
	
	private init?(intPart i: String, fractionPart f: String, forceDecimalSeparator: Bool, forceNegativeZero: Bool) {
		let addMinusSign = (forceNegativeZero && PluralValue.isZero(intPart: i, fractionPart: f))
		self.init(
			intPart: (addMinusSign ? "-" : "") + i,
			fractionPart: (!f.isEmpty || forceDecimalSeparator) ? f : nil
		)
	}
	
}

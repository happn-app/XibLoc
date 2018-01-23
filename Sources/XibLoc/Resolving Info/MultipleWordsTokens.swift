/*
 * MultipleWordsTokens.swift
 * XibLoc
 *
 * Created by François Lamboley on 1/23/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



public struct MultipleWordsTokens : Hashable {
	
	public let leftToken: String
	public let interiorToken: String
	public let rightToken: String
	
	public init(exteriorToken: String, interiorToken: String) {
		self.init(leftToken: exteriorToken, interiorToken: interiorToken, rightToken: exteriorToken)
	}
	
	public init(leftToken lt: String, interiorToken it: String, rightToken rt: String) {
		leftToken = lt
		interiorToken = it
		rightToken = rt
		hashValue = (leftToken + interiorToken + rightToken).hashValue
	}
	
	public var hashValue: Int
	public static func ==(lhs: MultipleWordsTokens, rhs: MultipleWordsTokens) -> Bool {
		return lhs.leftToken == rhs.leftToken && lhs.interiorToken == rhs.interiorToken && lhs.rightToken == rhs.rightToken
	}
	
}

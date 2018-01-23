/*
 * OneWordTokens.swift
 * XibLoc
 *
 * Created by François Lamboley on 1/23/18.
 * Copyright © 2018 happn. All rights reserved.
 */

import Foundation



public struct OneWordTokens : Hashable {
	
	public let leftToken: String
	public let rightToken: String
	
	public init(token: String) {
		self.init(leftToken: token, rightToken: token)
	}
	
	public init(leftToken lt: String, rightToken rt: String) {
		leftToken = lt
		rightToken = rt
		hashValue = (leftToken + rightToken).hashValue
	}
	
	public var hashValue: Int
	public static func ==(lhs: OneWordTokens, rhs: OneWordTokens) -> Bool {
		return lhs.leftToken == rhs.leftToken && lhs.rightToken == rhs.rightToken
	}
	
}

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



/* Straight out of https://forums.swift.org/t/safe-random-access-collection-element/36509/22 */
extension Collection {
	
	/**
	Returns the index corresponding to the given offset from the start of the
	collection, if that position exists.
	
	Note that when `offset` equals `count`, `endIndex` is returned instead of
	`nil`.
	
	- Parameter offset: The position to seek, given as the number of positions
	after `startIndex`.
	- Returns: `index(startIndex, offsetBy: offset)` if the result will be in
	range; otherwise, `nil`.
	
	- Complexity: O(1) if the collection conforms to `RandomAccessCollection`;
	otherwise, O(*k*), where *k* is `offset`. */
	func index<T: BinaryInteger>(forOffset offset: T) -> Index? {
		guard let offset = Int(exactly: offset), offset >= 0 else { return nil }
		
		return index(startIndex, offsetBy: offset, limitedBy: endIndex)
	}
	
	/**
	Returns the index corresponding to the given offset from the start of the
	collection, if that position exists and can be dereferenced.
	
	Note that when `offset` equals `count`, `nil` is returned (instead of
	`endIndex`).
	
	- Parameter offset: The position to seek, given as the number of positions
	after `startIndex`.
	- Returns: `index(startIndex, offsetBy: offset)` if the result will be in
	range; otherwise, `nil`.
	
	- Complexity: O(1) if the collection conforms to `RandomAccessCollection`;
	otherwise, O(*k*), where *k* is `offset`. */
	func elementIndex<T: BinaryInteger>(forOffset offset: T) -> Index? {
		let result = index(forOffset: offset)
		return result != endIndex ? result : nil
	}
	
}

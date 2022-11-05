/*
Copyright 2019 happn

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



extension RandomAccessCollection {
	
	/**
	 Return a sorted collection with a stable sort algorithm.
	 
	 Retrieved from [StackOverflow](https://stackoverflow.com/a/45585365)
	 
	 - Parameter areInIncreasingOrder: Return `nil` when two element are equal.
	 - Returns: The sorted collection */
	func stableSorted(by areInIncreasingOrder: (_ obj1: Iterator.Element, _ obj2: Iterator.Element) -> Bool?) -> [Iterator.Element] {
		let sorted = enumerated().sorted{ (one, another) -> Bool in
			if let result = areInIncreasingOrder(one.element, another.element) {return result}
			else                                                               {return one.offset < another.offset}
		}
		return sorted.map{ $0.element }
	}
}

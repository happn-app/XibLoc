/*
Copyright 2022 happn

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



extension Range where Bound : Comparable {
	
	/**
	 Same as ``Range/overlaps(_:)`` but if either range is empty, we check whether it is empty inside the other. */
	func overlapsWithEmpty(_ other: Range<Bound>) -> Bool {
		switch (isEmpty, other.isEmpty) {
			case (false, false):                                               return overlaps(other)
			case (false, true):  assert(other.lowerBound == other.upperBound); return other.lowerBound >=       lowerBound && other.lowerBound <       upperBound
			case (true,  false): assert(      lowerBound ==       upperBound); return       lowerBound >= other.lowerBound &&       lowerBound < other.upperBound
			case (true,  true):                                                return self == other
		}
	}
	
}

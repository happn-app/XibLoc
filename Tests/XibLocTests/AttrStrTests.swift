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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import XCTest



@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
final class AttrStrTests : XCTestCase {
	
	/* FB11756205 and https://cohost.org/Frizlab/post/200059-to-whomever-it-may-c */
	func testAttrStrRangeExtract() {
		let baseAttributes = {
			var res = AttributeContainer()
			res.font = .systemFont(ofSize: 14)
			res.foregroundColor = .black
			return res
		}()
		
		var attrStr = AttributedString("yolo^+1 result<:s>^", attributes: baseAttributes)
		attrStr.replaceSubrange(attrStr.range(of: "<:s>")!, with: AttributedString(""))
		attrStr[attrStr.range(of: "1 result")!].font = .preferredFont(forTextStyle: .caption1)
		
		let range = attrStr.range(of: "+1 result")!
		XCTAssertEqual(String(describing: attrStr[range]), String(describing: AttributedString(attrStr[range])))
	}
	
}

#endif

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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation

#if os(macOS)
	import AppKit
	public typealias XibLocFont = NSFont
	public typealias XibLocColor = NSColor
#else
	import UIKit
	public typealias XibLocFont = UIFont
	public typealias XibLocColor = UIColor
#endif



public struct StringAttributesChangesDescription {
	
	/* IF the NSMutableAttributedString had been modified to be Swifty, we would have used the declaration below... */
//	public typealias ChangeApplicationHandler = (_ modified: inout AttributedString, _ range: Range<AttributedString.Index>) -> Void
	public typealias ChangeApplicationHandler = (_ modified: NSMutableAttributedString, _ range: NSRange /* An ObjC range */) -> Void
	
	public enum StringAttributesChangeDescription {
		
		case setBold
		case removeBold
		
		case setItalic
		case removeItalic
		
		case addStraightUnderline
		case removeUnderline
		
		case setFgColor(XibLocColor)
		case setBgColor(XibLocColor)
		
		case changeFont(newFont: XibLocFont, preserveSizes: Bool, preserveBold: Bool, preserveItalic: Bool)
		
		case addLink(URL)
		
		var handlerToApplyChange: ChangeApplicationHandler {
			switch self {
			case .setBold: return { attrStr, range in attrStr.setBoldOrItalic(bold: true, italic: nil, range: range) }
			case .removeBold: return { attrStr, range in attrStr.setBoldOrItalic(bold: false, italic: nil, range: range) }
				
			case .setItalic: return { attrStr, range in attrStr.setBoldOrItalic(bold: nil, italic: true, range: range) }
			case .removeItalic: return { attrStr, range in attrStr.setBoldOrItalic(bold: nil, italic: false, range: range) }
				
			case .addStraightUnderline: return { attrStr, range in attrStr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single, range: range) }
			case .removeUnderline: return { attrStr, range in attrStr.addAttribute(.underlineStyle, value: NSUnderlineStyle(), range: range) }
				
			case .setFgColor(let color): return { attrStr, range in attrStr.setTextColor(color, range: range) }
			case .setBgColor(let color): return { attrStr, range in attrStr.setBackgroundColor(color, range: range) }
				
			case .changeFont(newFont: let font, preserveSizes: let preserveSizes, preserveBold: let preserveBold, preserveItalic: let preserveItalic):
				return { attrStr, range in attrStr.setFont(font, keepOriginalSize: preserveSizes, keepOriginalIsBold: preserveBold, keepOriginalIsItalic: preserveItalic, range: range) }
				
			case .addLink(let url): return { attrStr, range in attrStr.addAttribute(.link, value: url, range: range) }
			}
		}
		
	}
	
	public var changes: [ChangeApplicationHandler]
	
	public init(changes c: [StringAttributesChangeDescription]) {
		changes = c.map{ $0.handlerToApplyChange }
	}
	
	/* IF the NSMutableAttributedString had been modified to be Swifty, we would have used the declaration below... */
//	func apply(to attributedString: inout AttributedString, range: Range<AttributedString.Index>) {
	func apply(to attributedString: NSMutableAttributedString, range: NSRange /* An ObjC range */) {
		for h in changes {h(attributedString, range)}
	}
	
}

#endif

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

#if !os(Linux)

import CoreGraphics /* CGFloat */
import Foundation
#if canImport(os)
	import os.log
#endif

#if !canImport(os) && canImport(DummyLinuxOSLog)
	import DummyLinuxOSLog
#endif



extension XibLocFont {
	
	var isBold: Bool {
		#if !os(OSX)
			return fontDescriptor.symbolicTraits.contains(.traitBold)
		#else
			return fontDescriptor.symbolicTraits.contains(.bold)
		#endif
	}
	
	var isItalic: Bool {
		#if !os(OSX)
			return fontDescriptor.symbolicTraits.contains(.traitItalic)
		#else
			return fontDescriptor.symbolicTraits.contains(.italic)
		#endif
	}
	
}

extension NSMutableAttributedString {
	
	func getFont(at index: Int, effectiveRange: inout NSRange) -> XibLocFont? {
		let attr = attribute(.font, at: index, effectiveRange: &effectiveRange)
		return attr as? XibLocFont
	}
	
	func isTextBold(at index: Int, effectiveRange: inout NSRange) -> Bool {
		let font = getFont(at: index, effectiveRange: &effectiveRange)
		return font?.isBold ?? false
	}
	
	func isTextItalic(at index: Int, effectiveRange: inout NSRange) -> Bool {
		let font = getFont(at: index, effectiveRange: &effectiveRange)
		return font?.isItalic ?? false
	}
	
	func setFont(_ font: XibLocFont, range: NSRange? = nil) {
		let range = range ?? NSRange(location: 0, length: length)
		removeAttribute(.font, range: range) /* Work around an Apple leak (according to OHAttributedLabel) */
		addAttribute(.font, value: font, range: range)
	}
	
	func setFont(_ font: XibLocFont, keepOriginalSize: Bool = false, keepOriginalIsBold: Bool = false, keepOriginalIsItalic: Bool = false, range: NSRange? = nil) {
		let range = range ?? NSRange(location: 0, length: length)
		guard range.length > 0 else {return}
		
		var curPos = range.location
		var outRange = NSRange(location: 0, length: 0)
		
		repeat {
			let f = getFont(at: curPos, effectiveRange: &outRange)
			outRange = NSIntersectionRange(outRange, range)
			
			let (b, i, s) = (f?.isBold, f?.isItalic, f?.pointSize)
			setFontFrom(font, newSize: keepOriginalSize ? s : nil, newIsBold: keepOriginalIsBold ? b : nil, newIsItalic: keepOriginalIsItalic ? i : nil, range: outRange)
			
			curPos = outRange.upperBound
		} while curPos < range.upperBound
	}
	
	func setFontFrom(_ font: XibLocFont, newSize: CGFloat?, newIsBold: Bool?, newIsItalic: Bool?, range: NSRange? = nil) {
		var fontDesc = font.fontDescriptor
		
		if let bold = newIsBold {
			#if !os(OSX)
				if bold {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.union(.traitBold))}
				else    {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.subtracting(.traitBold))}
			#else
				if bold {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.union(.bold))}
				else    {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.subtracting(.bold))}
			#endif
		}
		
		if let italic = newIsItalic {
			#if !os(OSX)
				if italic {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.union(.traitItalic))}
				else      {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.subtracting(.traitItalic))}
			#else
				if italic {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.union(.italic))}
				else      {fontDesc = fontDesc.withSymbolicTraits(fontDesc.symbolicTraits.subtracting(.italic))}
			#endif
		}
		
		#if !os(OSX)
			setFont(XibLocFont(descriptor: fontDesc, size: newSize ?? fontDesc.pointSize),  range: range)
		#else
			setFont(XibLocFont(descriptor: fontDesc, size: newSize ?? fontDesc.pointSize)!, range: range)
		#endif
	}
	
	/** - Warning: If no font is defined in the given range, the method will use
	the preferred font for the “body” style (on iOS, watchOS and tvOS) or the
	system font of “system” size. */
	func setBoldOrItalic(bold: Bool?, italic: Bool?, range: NSRange? = nil) {
		let range = range ?? NSRange(location: 0, length: length)
		guard bold != nil || italic != nil else {return}
		guard range.length > 0 else {return}
		
		var curPos = range.location
		var outRange = NSRange(location: 0, length: 0)
		
		repeat {
			#if !os(OSX)
				let f = getFont(at: curPos, effectiveRange: &outRange) ?? XibLocFont.preferredFont(forTextStyle: .body)
			#else
				let f = getFont(at: curPos, effectiveRange: &outRange) ?? XibLocFont.systemFont(ofSize: XibLocFont.systemFontSize)
			#endif
			outRange = NSIntersectionRange(outRange, range)
			
			setFontFrom(f, newSize: f.pointSize, newIsBold: bold, newIsItalic: italic, range: outRange)
			
			curPos = outRange.upperBound
		} while curPos < range.upperBound
	}
	
	func setTextColor(_ color: XibLocColor, range: NSRange? = nil) {
		let range = range ?? NSRange(location: 0, length: length)
		removeAttribute(.foregroundColor, range: range) /* Work around an Apple leak (according to OHAttributedLabel) */
		addAttribute(.foregroundColor, value: color, range: range)
	}
	
	func setBackgroundColor(_ color: XibLocColor, range: NSRange? = nil) {
		let range = range ?? NSRange(location: 0, length: length)
		removeAttribute(.backgroundColor, range: range) /* Work around an Apple leak (according to OHAttributedLabel) */
		addAttribute(.backgroundColor, value: color, range: range)
	}
	
}

#endif

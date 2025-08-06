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

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension AttributedString {

	/**
	 - Warning: If no font is defined in the given range, the method will use the preferred font for the “body” style (on iOS, watchOS and tvOS) or the system font of “system” size. */
	mutating func setBoldOrItalic(bold: Bool?, italic: Bool?, range: Range<Self.Index>? = nil) {
		guard bold != nil || italic != nil else {return}

		let range = range ?? startIndex..<endIndex
		guard !range.isEmpty else {return}

		let runs = self[range].runs
		for r in runs {
//			let font = r.uiKit.font ?? XibLocFont.xl_preferredFont
			let font = XibLocFont.xl_preferredFont
			self[r.range].font = font.fontBySetting(size: nil, isBold: bold, isItalic: italic)
		}
	}

	mutating func setFont(
		_ font: XibLocFont,
		keepOriginalSize: Bool = false,
		keepOriginalIsBold: Bool = false,
		keepOriginalIsItalic: Bool = false,
		range: Range<Self.Index>? = nil
	) {
		let range = range ?? startIndex..<endIndex
		guard !range.isEmpty else {return}

		let runs = self[range].runs
		for r in runs {
//			let f = r.uiKit.font
//			let (b, i, s) = (f?.isBold, f?.isItalic, f?.pointSize)
			let f = XibLocFont.xl_preferredFont
			let (b, i, s) = (f.isBold, f.isItalic, f.pointSize)
			self[r.range].font = font.fontBySetting(size: keepOriginalSize ? s : nil, isBold: keepOriginalIsBold ? b : nil, isItalic: keepOriginalIsItalic ? i : nil)
		}
	}

}

#endif

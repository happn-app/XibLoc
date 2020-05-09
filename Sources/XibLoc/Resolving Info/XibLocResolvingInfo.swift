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



/* Supported configurations & Required Constraints:
 *   - See ParsedXibLoc private init for constraints on the tokens;
 *   - Supported overlaps:
 *      - Config: "*" is a left and right token for an attributes modification
 *      - Config: "_" is a left and right token for an attributes modification
 *      - Config: "|" is a left and right token for a simple replacement
 *      - Config: "<" ":" ">" are resp. a left, interior and right tokens for an ordered replacement
 *      - Supported: "This text will be *bold _and italic_ too*!"
 *      - Supported: "This text will be *bold _and italic too*_!"
 *      - Supported: "This text will be *bold _and italic too_*!"
 *      - Supported: "This text will be *bold _and* italic too_!"
 *      - Supported: "Let's replace |*some text*|"
 *           Note: Useless, but supported. If the simple replacement is a source
 *                 type replacement, the content will never be checked and the
 *                 attributes will never be set. If the replacement is a return
 *                 type replacement, the attributes of the content will be
 *                 modified, but then replaced by the replacement…
 *      - Supported: "Let's replace *|some text|*"
 *           Note: Only useful for a source type replacement (attributes would
 *                 be overwritten with a return type replacement).
 *      - Supported: "Let's replace with either <*this* is chosen:nope> or <nope:_that_>"
 *      - Supported: "Let's replace with either *<this is chosen:_nope_> or <_nope_:that>*"
 *      - Unsupported: "Let's replace *|some* text|"
 *      - Supported: "Let's replace <*multiple*:*choices*:stuff>"
 *      - Unsupported: "Let's replace *<multiple:choices*:stuff>"
 *      - Unsupported: "Let's replace <*multiple:choices*:stuff>" */
public struct XibLocResolvingInfo<SourceType, ReturnType> {
	
	public let defaultPluralityDefinition: PluralityDefinition
	
	public let escapeToken: String?
	
	/* Value for a simple type replacement is a handler, so you can have access
	 * to the original value being replaced. It used to be a constant. */
	public let simpleSourceTypeReplacements: [OneWordTokens: (_ originalValue: SourceType) -> SourceType]
	public let orderedReplacements: [MultipleWordsTokens: Int]
	/* Plural groups are ordered because of the possibility of plurality
	 * definition overrides. */
	public let pluralGroups: [(MultipleWordsTokens, PluralValue)]
	
	public let attributesModifications: [OneWordTokens: (_ modified: inout ReturnType, _ strRange: Range<String.Index>, _ refStr: String) -> Void] /* The handler must NOT modify the string representation of the given argument. */
	/* Value for a simple type replacement is a handler, so you can have access
	 * to the original value being replaced. It used to be a constant. */
	public let simpleReturnTypeReplacements: [OneWordTokens: (_ originalValue: ReturnType) -> ReturnType]
	
	public let identityReplacement: (_ source: SourceType) -> ReturnType
	
	public init(
		defaultPluralityDefinition dpd: PluralityDefinition = di.defaultPluralityDefinition, escapeToken et: String? = di.defaultEscapeToken,
		simpleSourceTypeReplacements sstr: [OneWordTokens: (_ originalValue: SourceType) -> SourceType] = [:],
		orderedReplacements or: [MultipleWordsTokens: Int] = [:],
		pluralGroups pg: [(MultipleWordsTokens, PluralValue)] = [],
		attributesModifications am: [OneWordTokens: (_ modified: inout ReturnType, _ strRange: Range<String.Index>, _ refStr: String) -> Void] = [:],
		simpleReturnTypeReplacements srtr: [OneWordTokens: (_ originalValue: ReturnType) -> ReturnType] = [:],
		identityReplacement ir: @escaping (_ source: SourceType) -> ReturnType
	) {
		defaultPluralityDefinition = dpd
		escapeToken = et
		simpleSourceTypeReplacements = sstr
		orderedReplacements = or
		pluralGroups = pg
		attributesModifications = am
		simpleReturnTypeReplacements = srtr
		identityReplacement = ir
	}
	
}

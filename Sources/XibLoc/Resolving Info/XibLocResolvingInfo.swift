/*
 * XibLocResolvingInfo.swift
 * XibLoc
 *
 * Created by François Lamboley on 8/26/17.
 * Copyright © 2017 happn. All rights reserved.
 */

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
 *      - Supported: "Let's replace <*multiple*:*choice*:stuff>"
 *      - Unsupported: "Let's replace *<multiple:choice*:stuff>"
 *      - Unsupported: "Let's replace <*multiple:choice*:stuff>" */
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
	
	/* Format: "@[id|key1:val1|key2:val2¦default replacement]".
	 * Examples of use:
	 *    - loc_string_en = "Hello @[plural|one:dude¦dudes]"
	 *    - loc_string_ru = "Hello in russian @[plural|one:russian word for dude|few:russian word for a few dudes¦russian word for dudes]"
	 *      When you have one guy to greet, the dictionary will contain
	 *      ["plural": "one"].
	 *      When you have a few guys to greet: ["plural": "few"]
	 *      Etc.
	 * The id can be used more than once in the same string, the replacements
	 * will be done for each dictionary with the same id.
	 *
	 * If a dictionary tag is found in the input but the id does not match any of
	 * the keys in this property, the tag won't be replaced at all.
	 *
	 * If dictionaryReplacements is nil, no dictionary parsing will be done at
	 * all.
	 *
	 * To escape a dictionary, just place the escape token before the @ as you
	 * would normally do with another token.
	 * For instance, assuming the escape token is "\\" (one backslash), to escape
	 * "@[plural|one:dude¦dudes]", use this string: "\\@[plural|one:dude¦dudes]".
	 * Placing the escape token between the "@" and the "[" works too:
	 * "@\\[plural|one:dude¦dudes]".
	 * Inside a dictionary, to escape a special character, just escape it with
	 * the escape token as expected (eg. "@[escaped|colon\\::and\\|pipe]"). */
	public let dictionaryReplacements: [String: String?]?
	
	public let identityReplacement: (_ source: SourceType) -> ReturnType
	
	public init(
		defaultPluralityDefinition dpd: PluralityDefinition, escapeToken et: String? = di.defaultEscapeToken,
		simpleSourceTypeReplacements sstr: [OneWordTokens: (_ originalValue: SourceType) -> SourceType] = [:],
		orderedReplacements or: [MultipleWordsTokens: Int] = [:],
		pluralGroups pg: [(MultipleWordsTokens, PluralValue)] = [],
		attributesModifications am: [OneWordTokens: (_ modified: inout ReturnType, _ strRange: Range<String.Index>, _ refStr: String) -> Void] = [:],
		simpleReturnTypeReplacements srtr: [OneWordTokens: (_ originalValue: ReturnType) -> ReturnType] = [:],
		dictionaryReplacements dr: [String: String?]? = nil,
		identityReplacement ir: @escaping (_ source: SourceType) -> ReturnType
	) {
		defaultPluralityDefinition = dpd
		escapeToken = et
		simpleSourceTypeReplacements = sstr
		orderedReplacements = or
		pluralGroups = pg
		attributesModifications = am
		simpleReturnTypeReplacements = srtr
		dictionaryReplacements = dr
		identityReplacement = ir
	}
	
}

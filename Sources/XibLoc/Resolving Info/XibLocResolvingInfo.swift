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
#if canImport(os)
	import os.log
#endif

import Logging



/**
Supported configurations & Required Constraints:
- See `validateTokens` in `XibLocParsingInfo` private init for constraints on
the tokens;
- Supported overlaps:
   - Config: “`*`” is a left and right token for an attributes modification
   - Config: “`_`” is a left and right token for an attributes modification
   - Config: “`|`” is a left and right token for a simple replacement
   - Config: “`<`” “`:`” “`>`” are resp. a left, interior and right tokens for
     an ordered replacement
   - Supported: “`This text will be *bold _and italic_ too*!`”
   - Supported: “`This text will be *bold _and italic too*_!`”
   - Supported: “`This text will be *bold _and italic too_*!`”
   - Supported: “`This text will be *bold _and* italic too_!`”
   - Supported: “`Let’s replace |*some text*|`”
      - Note: Useless, but supported. If the simple replacement is a source
              type replacement, the content will never be checked and the
              attributes will never be set. If the replacement is a return
              type replacement, the attributes of the content will be
              modified, but then replaced by the replacement…
   - Supported: “`Let’s replace *|some text|*`”
      - Note: Only useful for a source type replacement (attributes would
              be overwritten with a return type replacement).
   - Supported: “`Let’s replace with either <*this* is chosen:nope> or <nope:_that_>`”
   - Supported: “`Let’s replace with either *<this is chosen:_nope_> or <_nope_:that>*`”
   - Unsupported: “`Let’s replace *|some* text|`”
   - Supported: “`Let’s replace <*multiple*:*choices*:stuff>`”
   - Unsupported: “`Let’s replace *<multiple:choices*:stuff>`”
   - Unsupported: “`Let’s replace <*multiple:choices*:stuff>`”

(This § is here because Xcode does not know how to parse comments and does
weird sh*t… Thanks Xcode, go home, you’re drunk.)

- Important: If you write a custom init of this struct, you **must** validate
the token by calling `initParsingInfo` at the end of your init and fail the init
if the method returns `false`. You can also call another init which does said
validation. */
public struct XibLocResolvingInfo<SourceType, ReturnType> {
	
	public var defaultPluralityDefinition: PluralityDefinition
	
	public private(set) var escapeToken: String?
	
	/* Value for a simple type replacement is a handler, so you can have access
	 * to the original value being replaced. It used to be a constant. */
	public private(set) var simpleSourceTypeReplacements: [OneWordTokens: (_ originalValue: SourceType) -> SourceType]
	public private(set) var orderedReplacements: [MultipleWordsTokens: Int]
	/* Plural groups are ordered because of the possibility of plurality
	 * definition overrides. */
	public private(set) var pluralGroups: [(MultipleWordsTokens, PluralValue)]
	
	public private(set) var attributesModifications: [OneWordTokens: (_ modified: inout ReturnType, _ strRange: Range<String.Index>, _ refStr: String) -> Void] /* The handler must NOT modify the string representation of the given argument. */
	/* Value for a simple type replacement is a handler, so you can have access
	 * to the original value being replaced. It used to be a constant. */
	public private(set) var simpleReturnTypeReplacements: [OneWordTokens: (_ originalValue: ReturnType) -> ReturnType]
	
	public var identityReplacement: (_ source: SourceType) -> ReturnType
	
	private var _parsingInfo: XibLocParsingInfo?
	var parsingInfo: XibLocParsingInfo {
		/* Warning: Thread-safety issue if we care about thread-safety one day… */
		if let pi = _parsingInfo {return pi}
		
		assertionFailure("initParsingInfo() must be call in all the inits of XibLocParsingInfo, and the init must be failed if the method returns false.")
		return XibLocParsingInfo(resolvingInfo: self)!
	}
	
	/**
	Call this function at the end of any init of XibLocResolvingInfo, and fail
	your init if the method returns false. */
	public mutating func initParsingInfo() -> Bool {
		_parsingInfo = XibLocParsingInfo(resolvingInfo: self)
		return _parsingInfo != nil
	}
	
	public init?(
		defaultPluralityDefinition dpd: PluralityDefinition = XibLocConfig.defaultPluralityDefinition, escapeToken et: String? = XibLocConfig.defaultEscapeToken,
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
		
		guard initParsingInfo() else {
			return nil
		}
	}
	
	public init(identityReplacement ir: @escaping (_ source: SourceType) -> ReturnType) {
		self.init(identityReplacement: ir)!
	}
	
	@discardableResult
	public mutating func changeEscapeToken(to newEscapeToken: String?) -> Bool {
		let savedEscapeToken = escapeToken
		escapeToken = newEscapeToken
		
		guard let newParsingInfo = XibLocParsingInfo(resolvingInfo: self) else {
			escapeToken = savedEscapeToken
			return false
		}
		_parsingInfo = newParsingInfo
		
		return true
	}
	
	public func changingEscapeToken(to newEscapeToken: String?) -> Self? {
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: newEscapeToken,
			simpleSourceTypeReplacements: simpleSourceTypeReplacements,
			orderedReplacements: orderedReplacements,
			pluralGroups: pluralGroups,
			attributesModifications: attributesModifications,
			simpleReturnTypeReplacements: simpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)
	}
	
	@discardableResult
	public mutating func removeTokens(_ tokens: OneWordTokens) -> Bool {
		/* Only one of these three variables can contain the given token, so if
		 * any has the value and removes it, we can stop. */
		let changed = (
			     (attributesModifications.removeValue(forKey: tokens) != nil) ||
			(simpleReturnTypeReplacements.removeValue(forKey: tokens) != nil) ||
			(simpleSourceTypeReplacements.removeValue(forKey: tokens) != nil)
		)
		
		if changed {_parsingInfo = XibLocParsingInfo(resolvingInfo: self)! /* Force unwrapped because removing a token will not make the tokens be invalid in the resolving info. */}
		return changed
	}
	
	public func removingTokens(_ tokens: OneWordTokens) -> Self {
		var newAttributesModifications = attributesModifications
		var newSimpleReturnTypeReplacements = simpleReturnTypeReplacements
		var newSimpleSourceTypeReplacements = simpleSourceTypeReplacements
		
		newAttributesModifications.removeValue(forKey: tokens)
		newSimpleReturnTypeReplacements.removeValue(forKey: tokens)
		newSimpleSourceTypeReplacements.removeValue(forKey: tokens)
		
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: escapeToken,
			simpleSourceTypeReplacements: newSimpleSourceTypeReplacements,
			orderedReplacements: orderedReplacements,
			pluralGroups: pluralGroups,
			attributesModifications: newAttributesModifications,
			simpleReturnTypeReplacements: newSimpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)! /* Force unwrapped because removing a token will not make the tokens be invalid in the resolving info. */
	}
	
	@discardableResult
	public mutating func removeTokens(_ tokens: MultipleWordsTokens) -> Bool {
		/* The tokens can be used only once in a valid resolving info, so we can
		 * stop as soon as we have removed the token from anywhere. */
		let changed = (
			(orderedReplacements.removeValue(forKey: tokens) != nil) ||
			(pluralGroups.firstIndex(where: { $0.0 == tokens }).flatMap{ pluralGroups.remove(at: $0) } != nil)
		)
		
		if changed {_parsingInfo = XibLocParsingInfo(resolvingInfo: self)! /* Force unwrapped because removing a token will not make the tokens be invalid in the resolving info. */}
		return changed
	}
	
	public func removingTokens(_ tokens: MultipleWordsTokens) -> Self {
		var newPluralGroups = pluralGroups
		var newOrderedReplacements = orderedReplacements
		
		newOrderedReplacements.removeValue(forKey: tokens)
		_ = newPluralGroups.firstIndex(where: { $0.0 == tokens }).flatMap{ newPluralGroups.remove(at: $0) }
		
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: escapeToken,
			simpleSourceTypeReplacements: simpleSourceTypeReplacements,
			orderedReplacements: newOrderedReplacements,
			pluralGroups: newPluralGroups,
			attributesModifications: attributesModifications,
			simpleReturnTypeReplacements: simpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)! /* Force unwrapped because removing a token will not make the tokens be invalid in the resolving info. */
	}
	
	@discardableResult
	public mutating func addSimpleSourceTypeReplacement(tokens: OneWordTokens, replacement: @escaping (_ originalValue: SourceType) -> SourceType, allowReplace: Bool = false) -> Bool {
		guard allowReplace || simpleSourceTypeReplacements[tokens] == nil else {return false}
		
		let savedSimpleSourceTypeReplacements = simpleSourceTypeReplacements
		simpleSourceTypeReplacements[tokens] = replacement
		
		guard let newParsingInfo = XibLocParsingInfo(resolvingInfo: self) else {
			simpleSourceTypeReplacements = savedSimpleSourceTypeReplacements
			return false
		}
		_parsingInfo = newParsingInfo
		
		return true
	}
	
	public func addingSimpleSourceTypeReplacement(tokens: OneWordTokens, replacement: @escaping (_ originalValue: SourceType) -> SourceType, allowReplace: Bool = false) -> Self? {
		guard allowReplace || simpleSourceTypeReplacements[tokens] == nil else {return nil}
		var newSimpleSourceTypeReplacements = simpleSourceTypeReplacements
		newSimpleSourceTypeReplacements[tokens] = replacement
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: escapeToken,
			simpleSourceTypeReplacements: newSimpleSourceTypeReplacements,
			orderedReplacements: orderedReplacements,
			pluralGroups: pluralGroups,
			attributesModifications: attributesModifications,
			simpleReturnTypeReplacements: simpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)
	}
	
	@discardableResult
	public mutating func addOrderedReplacement(tokens: MultipleWordsTokens, value: Int, allowReplace: Bool = false) -> Bool {
		guard allowReplace || orderedReplacements[tokens] == nil else {return false}
		
		let savedOrderedReplacements = orderedReplacements
		orderedReplacements[tokens] = value
		
		guard let newParsingInfo = XibLocParsingInfo(resolvingInfo: self) else {
			orderedReplacements = savedOrderedReplacements
			return false
		}
		_parsingInfo = newParsingInfo
		
		return true
	}
	
	public func addingOrderedReplacement(tokens: MultipleWordsTokens, value: Int, allowReplace: Bool = false) -> Self? {
		guard allowReplace || orderedReplacements[tokens] == nil else {return nil}
		var newOrderedReplacements = orderedReplacements
		newOrderedReplacements[tokens] = value
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: escapeToken,
			simpleSourceTypeReplacements: simpleSourceTypeReplacements,
			orderedReplacements: newOrderedReplacements,
			pluralGroups: pluralGroups,
			attributesModifications: attributesModifications,
			simpleReturnTypeReplacements: simpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)
	}
	
	@discardableResult
	public mutating func addPluralGroup(atIndex insertIdx: Int? = nil, tokens: MultipleWordsTokens, value: PluralValue, allowReplace: Bool = false) -> Bool {
		let currentIndex = pluralGroups.firstIndex(where: { $0.0 == tokens })
		guard allowReplace || currentIndex == nil else {return false}
		
		let savedPluralGroups = pluralGroups
		if let index = currentIndex {
			if insertIdx != nil {
				#if canImport(os)
				if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
					Conf.oslog.flatMap{ os_log("Asked to insert a plural group at a specific index but a plural group with the given token was already present, so we just replaced it instead.", log: $0, type: .info) }}
				#endif
				Conf.logger?.notice("Asked to insert a plural group at a specific index but a plural group with the given token was already present, so we just replaced it instead.")
			}
			pluralGroups[index].1 = value
		} else {
			if let insertIdx = insertIdx {pluralGroups.insert((tokens, value), at: insertIdx)}
			else                         {pluralGroups.append((tokens, value))}
		}
		
		guard let newParsingInfo = XibLocParsingInfo(resolvingInfo: self) else {
			pluralGroups = savedPluralGroups
			return false
		}
		_parsingInfo = newParsingInfo
		
		return true
	}
	
	public func addingPluralGroup(atIndex insertIdx: Int? = nil, tokens: MultipleWordsTokens, value: PluralValue, allowReplace: Bool = false) -> Self? {
		let currentIndex = pluralGroups.firstIndex(where: { $0.0 == tokens })
		guard allowReplace || currentIndex == nil else {return nil}
		
		var newPluralGroups = pluralGroups
		if let index = currentIndex {
			if insertIdx != nil {
				#if canImport(os)
				if #available(macOS 10.12, tvOS 10.0, iOS 10.0, watchOS 3.0, *) {
					Conf.oslog.flatMap{ os_log("Asked to add a plural group at a specific index but a plural group with the given tokens was already present, so we just replaced it instead.", log: $0, type: .info) }}
				#endif
				Conf.logger?.notice("Asked to add a plural group at a specific index but a plural group with the given tokens was already present, so we just replaced it instead.")
			}
			newPluralGroups[index].1 = value
		} else {
			if let insertIdx = insertIdx {newPluralGroups.insert((tokens, value), at: insertIdx)}
			else                         {newPluralGroups.append((tokens, value))}
		}
		
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: escapeToken,
			simpleSourceTypeReplacements: simpleSourceTypeReplacements,
			orderedReplacements: orderedReplacements,
			pluralGroups: newPluralGroups,
			attributesModifications: attributesModifications,
			simpleReturnTypeReplacements: simpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)
	}
	
	@discardableResult
	public mutating func addAttributesModification(tokens: OneWordTokens, attributesModification: @escaping (_ modified: inout ReturnType, _ strRange: Range<String.Index>, _ refStr: String) -> Void, allowReplace: Bool = false) -> Bool {
		guard allowReplace || attributesModifications[tokens] == nil else {return false}
		
		let savedAttributesModifications = attributesModifications
		attributesModifications[tokens] = attributesModification
		
		guard let newParsingInfo = XibLocParsingInfo(resolvingInfo: self) else {
			attributesModifications = savedAttributesModifications
			return false
		}
		_parsingInfo = newParsingInfo
		
		return true
	}
	
	public func addingAttributesModification(tokens: OneWordTokens, attributesModification: @escaping (_ modified: inout ReturnType, _ strRange: Range<String.Index>, _ refStr: String) -> Void, allowReplace: Bool = false) -> Self? {
		guard allowReplace || attributesModifications[tokens] == nil else {return nil}
		var newAttributesModifications = attributesModifications
		newAttributesModifications[tokens] = attributesModification
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: escapeToken,
			simpleSourceTypeReplacements: simpleSourceTypeReplacements,
			orderedReplacements: orderedReplacements,
			pluralGroups: pluralGroups,
			attributesModifications: newAttributesModifications,
			simpleReturnTypeReplacements: simpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)
	}
	
	@discardableResult
	public mutating func addSimpleReturnTypeReplacement(tokens: OneWordTokens, replacement: @escaping (_ originalValue: ReturnType) -> ReturnType, allowReplace: Bool = false) -> Bool {
		guard allowReplace || simpleReturnTypeReplacements[tokens] == nil else {return false}
		
		let savedSimpleReturnTypeReplacements = simpleReturnTypeReplacements
		simpleReturnTypeReplacements[tokens] = replacement
		
		guard let newParsingInfo = XibLocParsingInfo(resolvingInfo: self) else {
			simpleReturnTypeReplacements = savedSimpleReturnTypeReplacements
			return false
		}
		_parsingInfo = newParsingInfo
		
		return true
	}
	
	public func addingSimpleReturnTypeReplacement(tokens: OneWordTokens, replacement: @escaping (_ originalValue: ReturnType) -> ReturnType, allowReplace: Bool = false) -> Self? {
		guard allowReplace || simpleReturnTypeReplacements[tokens] == nil else {return nil}
		var newSimpleReturnTypeReplacements = simpleReturnTypeReplacements
		newSimpleReturnTypeReplacements[tokens] = replacement
		return Self.init(
			defaultPluralityDefinition: defaultPluralityDefinition, escapeToken: escapeToken,
			simpleSourceTypeReplacements: simpleSourceTypeReplacements,
			orderedReplacements: orderedReplacements,
			pluralGroups: pluralGroups,
			attributesModifications: attributesModifications,
			simpleReturnTypeReplacements: newSimpleReturnTypeReplacements,
			identityReplacement: identityReplacement
		)
	}
	
}

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



extension ParsedXibLoc where SourceTypeHelper.ParsedType : Hashable {
	
	public static func cachedOrNewParsedXibLoc<DestinationType>(source: SourceType, parserHelper: SourceTypeHelper.Type, forXibLocResolvingInfo xibLocResolvingInfo: XibLocResolvingInfo<SourceType, DestinationType>) -> ParsedXibLoc<SourceTypeHelper> {
		return cachedOrNewParsedXibLoc(source: source, parserHelper: parserHelper, parsingInfo: xibLocResolvingInfo.parsingInfo)
	}
	
	static func cachedOrNewParsedXibLoc(source: SourceType, parserHelper: SourceTypeHelper.Type, parsingInfo: XibLocParsingInfo) -> ParsedXibLoc<SourceTypeHelper> {
		if let cache = Conf.cache {
			let initInfo = ErasedParsedXibLocInitInfoWrapper(ErasedParsedXibLocInitInfo(source: source, parserHelperTypeId: ObjectIdentifier(parserHelper), parsingInfo: parsingInfo))
			
			CacheLock.lock.lock()
			defer {CacheLock.lock.unlock()}
			let cachedParsedXibLoc = cache.object(forKey: initInfo)
			
			if let parsedXibLoc = cachedParsedXibLoc?.parsedXibLoc as? Self {
				return parsedXibLoc
			} else {
				let ret = self.init(source: source, parserHelper: parserHelper, parsingInfo: parsingInfo)
				cache.setObject(ParsedXibLocWrapper(ret), forKey: initInfo)
				return ret
			}
		}
		return self.init(source: source, parserHelper: parserHelper, parsingInfo: parsingInfo)
	}
	
}


private struct ErasedParsedXibLocInitInfo : Hashable {
	
	var source: AnyHashable
	var parserHelperTypeId: ObjectIdentifier
	var parsingInfo: XibLocParsingInfo
	
}



/* ************************
   MARK: - NSCache Wrappers
   ************************ */
/* NSCache does not support caching non-objc objects or non-objc keys.
 * We need to erase the ParsedXibLoc anyway, so it’s not that bad. */


/** Public because the cache property in XibLoc config is public. */
public class ErasedParsedXibLocInitInfoWrapper : NSObject {
	
	private let initInfo: ErasedParsedXibLocInitInfo
	
	fileprivate init(_ info: ErasedParsedXibLocInitInfo) {
		initInfo = info
	}
	
	public override var hash: Int {
		return initInfo.hashValue
	}
	
	public override func isEqual(_ other: Any?) -> Bool {
		guard let other = other as? ErasedParsedXibLocInitInfoWrapper else {
			return false
		}
		return initInfo == other.initInfo
	}
	
}


/** Public because the cache property in XibLoc config is public. */
public class ParsedXibLocWrapper : NSObject {
	
	/** The wrapped ParsedXibLoc, erased. */
	fileprivate let parsedXibLoc: Any
	
	fileprivate init<SourceTypeHelper : ParserHelper>(_ p: ParsedXibLoc<SourceTypeHelper>) {
		parsedXibLoc = p
	}
	
}

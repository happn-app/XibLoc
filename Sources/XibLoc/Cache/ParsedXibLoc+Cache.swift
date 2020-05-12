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
		#warning("TODO")
		return self.init(source: source, parserHelper: parserHelper, parsingInfo: parsingInfo)
	}
	
}

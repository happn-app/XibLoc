import XCTest

extension XibLocTests {
    static let __allTests = [
        ("testEmbeddedSimpleReplacements", testEmbeddedSimpleReplacements),
        ("testEmojiGender", testEmojiGender),
        ("testEmojiGenderBis", testEmojiGenderBis),
        ("testEscapedSimpleReplacement", testEscapedSimpleReplacement),
        ("testInvalidOverlappingReplacements", testInvalidOverlappingReplacements),
        ("testNonEscapedButPrecededByEscapeTokenSimpleReplacement", testNonEscapedButPrecededByEscapeTokenSimpleReplacement),
        ("testOneOrderedReplacement1", testOneOrderedReplacement1),
        ("testOneOrderedReplacement2", testOneOrderedReplacement2),
        ("testOneOrderedReplacementAboveMax", testOneOrderedReplacementAboveMax),
        ("testOneOrderedReplacementAndSimpleReplacement1", testOneOrderedReplacementAndSimpleReplacement1),
        ("testOneOrderedReplacementAndSimpleReplacement2", testOneOrderedReplacementAndSimpleReplacement2),
        ("testOneOrderedReplacementTwice", testOneOrderedReplacementTwice),
        ("testOnePluralReplacement", testOnePluralReplacement),
        ("testOnePluralReplacementMissingOneZone", testOnePluralReplacementMissingOneZone),
        ("testOneSimpleReplacement", testOneSimpleReplacement),
        ("testThaiGender", testThaiGender),
        ("testTwoVariablesChangesAndGenderInOrderedReplacementGroup", testTwoVariablesChangesAndGenderInOrderedReplacementGroup),
        ("testTwoVariablesChangesInOrderedReplacementGroup", testTwoVariablesChangesInOrderedReplacementGroup),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(XibLocTests.__allTests),
    ]
}
#endif

/*
 * XibLocTestsObjC.m
 * XibLocTests
 *
 * Created by François Lamboley on 18/03/2019.
 * Copyright © 2019 happn. All rights reserved.
 */

@import XCTest;

@import XibLoc;

#import "XibLocTests-Swift.h"



@interface XibLocTestsObjC : XCTestCase
@end


@implementation XibLocTestsObjC

- (void)testOneSimpleReplacementObjC
{
	NSString *tested = [ObjCXibLoc objc_applyingXibLocSimpleReplacementLocStringWithBase:@"the |replaced|" replacement:@"replacement"];
	XCTAssertEqualObjects(tested, @"the replacement");
}

#if TARGET_OS_OSX

/* Same as testFromHappn1SeptiesObjC, but was the original issue raised when
 * migrating happn to Xcode 10.2 (w/ the Swift 5 runtime). The equivalent test
 * has been added afterwards. */
- (void)testFromHappn2ObjC
{
	NSColor *baseColor = NSColor.blackColor;
	NSFont *baseFont = [NSFont systemFontOfSize:12];
	
	NSMutableAttributedString *tested = [ObjCXibLoc objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPluralWithBase:@"   *Play CrushTime* and see if you can guess who Liked you!"
																																							 baseFont:baseFont baseColor:baseColor
																																						 replacement:@"" pluralValue:0 genderMeIsMale:YES genderOtherIsMale:YES];
	
	NSMutableAttributedString *ref = [[NSMutableAttributedString alloc] initWithString:@"   Play CrushTime and see if you can guess who Liked you!" attributes:@{NSFontAttributeName: baseFont, NSForegroundColorAttributeName: baseColor}];
	[ObjCXibLoc setBoldOrItalicIn:ref bold:1 italic:-1 range:NSMakeRange(3, 14)];
	
	XCTAssertEqualObjects(tested, ref);
}

#pragma mark - From Swift Tests

/* Copied from Swift tests. */
- (void)testFromHappn1ObjC
{
	NSString *str = @"{*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!₋*CrushTime खेलें* और देखें कि क्या आप अनुमान लगा सकती हैं कि आपको किसने पसंद किया!}";
	NSColor *baseColor = NSColor.blackColor;
	NSFont *baseFont = [NSFont systemFontOfSize:12];
	
	NSMutableAttributedString *tested = [ObjCXibLoc objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPluralWithBase:str
																																							 baseFont:baseFont baseColor:baseColor
																																						 replacement:@"" pluralValue:0 genderMeIsMale:YES genderOtherIsMale:YES];
	
	NSString *resultStr = @"CrushTime खेलें और देखें कि क्या आप अनुमान लगा सकते हैं कि आपको किसने पसंद किया!";
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:resultStr attributes:@{NSFontAttributeName: baseFont, NSForegroundColorAttributeName: baseColor}];
	[ObjCXibLoc setBoldOrItalicIn:result bold:1 italic:-1 range:NSMakeRange(0, 15)];
	
	XCTAssertEqualObjects(tested, result);
}

/* Copied from Swift tests. */
- (void)testFromHappn1TerObjC
{
	NSString *str = @"*लें*";
	NSColor *baseColor = NSColor.blackColor;
	NSFont *baseFont = [NSFont systemFontOfSize:12];
	
	NSMutableAttributedString *tested = [ObjCXibLoc objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPluralWithBase:str
																																							 baseFont:baseFont baseColor:baseColor
																																						 replacement:@"" pluralValue:0 genderMeIsMale:YES genderOtherIsMale:YES];
	
	NSString *resultStr = @"लें";
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:resultStr attributes:@{NSFontAttributeName: baseFont, NSForegroundColorAttributeName: baseColor}];
	[ObjCXibLoc setBoldOrItalicIn:result bold:1 italic:-1 range:NSMakeRange(0, result.string.length)];
	
	XCTAssertEqualObjects(tested, result);
}

/* Copied from Swift tests. */
- (void)testFromHappn1SexiesObjC
{
	NSString *str = @"🧒🏻👳🏿‍♀️🧒🏻";
	NSColor *baseColor = NSColor.blackColor;
	NSFont *baseFont = [NSFont systemFontOfSize:12];
	
	NSMutableAttributedString *tested = [ObjCXibLoc objc_applyingXibLocTransformForCustomBoldWithBase:str baseFont:baseFont baseColor:baseColor boldToken:@"🧒🏻"];
	
	NSString *resultStr = @"👳🏿‍♀️";
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:resultStr attributes:@{NSFontAttributeName: baseFont, NSForegroundColorAttributeName: baseColor}];
	[ObjCXibLoc setBoldOrItalicIn:result bold:1 italic:-1 range:NSMakeRange(0, result.string.length)];
	
	XCTAssertEqualObjects(tested, result);
}

/* Also exists in Swift */
- (void)testFromHappn1SeptiesObjC
{
	NSString *str = @"🧔🏻*🧒🏻*";
	NSColor *baseColor = NSColor.blackColor;
	NSFont *baseFont = [NSFont systemFontOfSize:12];
	
	NSMutableAttributedString *tested = [ObjCXibLoc objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPluralWithBase:str
																																							 baseFont:baseFont baseColor:baseColor
																																						 replacement:@"" pluralValue:0 genderMeIsMale:YES genderOtherIsMale:YES];
	
	NSString *resultStr = @"🧔🏻🧒🏻";
	NSInteger start = @"🧔🏻".length;
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:resultStr attributes:@{NSFontAttributeName: baseFont, NSForegroundColorAttributeName: baseColor}];
	[ObjCXibLoc setBoldOrItalicIn:result bold:1 italic:-1 range:NSMakeRange(start, result.string.length - start)];
	
	XCTAssertEqualObjects(tested, result);
}

/* Also exists in Swift */
- (void)testFromHappn1OctiesObjC
{
	NSString *str = @"🧔🏻*a*";
	NSColor *baseColor = NSColor.blackColor;
	NSFont *baseFont = [NSFont systemFontOfSize:12];
	
	NSMutableAttributedString *tested = [ObjCXibLoc objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPluralWithBase:str
																																							 baseFont:baseFont baseColor:baseColor
																																						 replacement:@"" pluralValue:0 genderMeIsMale:YES genderOtherIsMale:YES];
	
	NSString *resultStr = @"🧔🏻a";
	NSInteger start = @"🧔🏻".length;
	NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:resultStr attributes:@{NSFontAttributeName: baseFont, NSForegroundColorAttributeName: baseColor}];
	[ObjCXibLoc setBoldOrItalicIn:result bold:1 italic:-1 range:NSMakeRange(start, result.string.length - start)];
	
	XCTAssertEqualObjects(tested, result);
}

#endif

@end

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

- (void)testHappnCrashObjC
{
	NSColor *baseColor = NSColor.blackColor;
	NSFont *baseFont = [NSFont systemFontOfSize:12];
	
	NSMutableAttributedString *tested = [ObjCXibLoc objc_applyingXibLocTransformForSystemBoldReplacementGenderAndPluralWithBase:@"   *Play CrushTime* and see if you can guess who Liked you!"
																																							 baseFont:baseFont baseColor:baseColor
																																						 replacement:@"" pluralValue:0 genderMeIsMale:YES genderOtherIsMale:YES];
	
	NSMutableAttributedString *ref = [[NSMutableAttributedString alloc] initWithString:@"   Play CrushTime and see if you can guess who Liked you!" attributes:@{NSFontAttributeName: baseFont, NSForegroundColorAttributeName: baseColor}];
	[ref setAttributes:@{NSFontAttributeName: [NSFont boldSystemFontOfSize:12]} range:NSMakeRange(3, 14)];
	
	XCTAssertEqualObjects(tested, ref);
}

#endif

@end

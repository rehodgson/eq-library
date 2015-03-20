//
//  EQRenderDataTest.m
//  eq-library
//
//  Created by Raymond Hodgson on 10/09/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
//
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <XCTest/XCTest.h>
#import "EQRenderData.h"
#import "EQTextPosition.h"
#import "EQTextRange.h"
#import "EQRenderFracStem.h"

@interface EQRenderDataTest : XCTestCase
{
    EQRenderData *testRenderData;
}
@end

@implementation EQRenderDataTest

- (void)setUp
{
    [super setUp];
    testRenderData = [[EQRenderData alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void) testThatEQRenderDataExists
{
    XCTAssertNotNil(testRenderData, @"Should be able to create an EQRenderData instance");
}

- (void)testThatDataEQRenderDataConformsToNSCodingProtocol
{
    XCTAssertTrue([testRenderData conformsToProtocol:@protocol(NSCoding)], @"Data source must conform to NSCoding");
}

- (void) testBaselineOriginProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(baselineOrigin)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setBaselineOrigin:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setBaselineOrigin:CGPointMake(40.0, 40.0)], @"Should not throw when setting origin.");
    XCTAssertNoThrow([testRenderData baselineOrigin], @"Should not throw when getting origin.");
    XCTAssertTrue(CGPointEqualToPoint([testRenderData baselineOrigin], CGPointMake(40.0, 40.0)), @"Input should match output.");
}

- (void) testDrawOriginProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(drawOrigin)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setDrawOrigin:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setDrawOrigin:CGPointMake(30.0, 30.0)], @"Should not throw when setting origin.");
    XCTAssertNoThrow([testRenderData drawOrigin], @"Should not throw when getting origin.");
    XCTAssertTrue(CGPointEqualToPoint([testRenderData drawOrigin], CGPointMake(30.0, 30.0)), @"Input should match output.");
}

- (void) testDrawSizeProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(drawSize)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setDrawSize:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setDrawSize:CGSizeMake(30.0, 30.0)], @"Should not throw when setting size.");
    XCTAssertNoThrow([testRenderData drawSize], @"Should not throw when getting size.");
    XCTAssertTrue(CGSizeEqualToSize([testRenderData drawSize], CGSizeMake(30.0, 30.0)), @"Input should match output.");
}

- (void) testBoundingRectTypographicProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(boundingRectTypographic)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setBoundingRectTypographic:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setBoundingRectTypographic:CGRectMake(0.0, 0.0, 60.0, 60.0)], @"Should not throw when setting bounding rect.");
    XCTAssertNoThrow([testRenderData boundingRectTypographic], @"Should not throw when getting bounding rect.");
    XCTAssertTrue(CGRectEqualToRect([testRenderData boundingRectTypographic], CGRectMake(0.0, 0.0, 60.0, 60.0)), @"Input should match output.");
}

- (void) testBoundingRectImageProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(boundingRectImage)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setBoundingRectImage:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setBoundingRectImage:CGRectMake(0.0, 0.0, 60.0, 60.0)], @"Should not throw when setting bounding rect.");
    XCTAssertNoThrow([testRenderData boundingRectImage], @"Should not throw when getting bounding rect.");
    XCTAssertTrue(CGRectEqualToRect([testRenderData boundingRectImage], CGRectMake(0.0, 0.0, 60.0, 60.0)), @"Input should match output.");
}

- (void) testNeedsRedrawnProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(needsRedrawn)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setNeedsRedrawn:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setNeedsRedrawn:NO], @"Should not throw when setting redrawn.");
    XCTAssertNoThrow([testRenderData needsRedrawn], @"Should not throw when getting redrawn value.");
    XCTAssertTrue([testRenderData needsRedrawn] == NO, @"Input should match output.");
}

- (void) testContainsSelectionProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(containsSelection)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setContainsSelection:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setContainsSelection:YES], @"Should not throw when setting redrawn.");
    XCTAssertNoThrow([testRenderData containsSelection], @"Should not throw when getting redrawn value.");
    XCTAssertTrue([testRenderData containsSelection] == YES, @"Input should match output.");
}

- (void) testParentStemProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(parentStem)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setParentStem:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testRenderData setParentStem:nil], @"Should not throw when setting to nil.");
    XCTAssertNil([testRenderData parentStem], @"Should be nil if you set it to nil.");
}

- (void) testHasStretchyCharacterDataProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(hasStretchyCharacterData)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setHasStretchyCharacterData:)], @"Should respond to set: method.");
    XCTAssertTrue(testRenderData.hasStretchyCharacterData == NO, @"Should initialize to NO.");
    XCTAssertNoThrow(testRenderData.hasStretchyCharacterData = YES, @"Should not throw when setting.");
    XCTAssertTrue(testRenderData.hasStretchyCharacterData == YES, @"Input should match output.");
}

- (void) testHasStretchyDescenderPointProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(hasStretchyDescenderPoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setHasStretchyDescenderPoint:)], @"Should respond to set: method.");
    XCTAssertTrue(testRenderData.hasStretchyDescenderPoint == NO, @"Should initialize to NO.");
    XCTAssertNoThrow(testRenderData.hasStretchyDescenderPoint = YES, @"Should not throw when setting.");
    XCTAssertTrue(testRenderData.hasStretchyDescenderPoint == YES, @"Input should match output.");
}

- (void) testStretchyDescenderPointProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(stretchyDescenderPoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setStretchyDescenderPoint:)], @"Should respond to set method.");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, testRenderData.stretchyDescenderPoint), @"Should initialize to pointZero.");
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    XCTAssertNoThrow(testRenderData.stretchyDescenderPoint = testPoint, @"Should not throw when setting.");
    XCTAssertTrue(CGPointEqualToPoint(testPoint, testRenderData.stretchyDescenderPoint), @"Input should match output.");
}

- (void) testStoredKernProperty
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(storedKern)], @"Should respond to accessor method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(setStoredKern:)], @"Should respond to set method.");
    XCTAssertTrue(testRenderData.storedKern == 0.0, @"Should initialize to 0.0");
    CGFloat testKern = 42.0;
    XCTAssertNoThrow(testRenderData.storedKern = testKern, @"Should not throw when setting.");
    XCTAssertTrue(testRenderData.storedKern == testKern, @"Input should match output.");
}

- (void) testInitWithString
{
    testRenderData = [[EQRenderData alloc] initWithString:@""];
    XCTAssertNotNil(testRenderData, @"Should be able to create an EQRenderData instance with a string");
    XCTAssertNotNil(testRenderData.renderString, @"Should create a string as well.");
    NSInteger testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 0, @"Should have created an empty string.");
}

- (void) testInitWithAttributedString
{
    NSMutableAttributedString *testStr = [[NSMutableAttributedString alloc] initWithString:@""];
    testRenderData = [[EQRenderData alloc] initWithAttributedString:testStr];
    XCTAssertNotNil(testRenderData, @"Should be able to create an EQRenderData instance with an attributed string.");
    XCTAssertNotNil(testRenderData.renderString, @"Should have a renderString as well.");
    XCTAssertNotEqual(testStr, testRenderData.renderString, @"Should have created a new copy instead of just using directly.");
    NSInteger testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 0, @"Should have created an empty string.");
}

- (void) testAppendString
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(appendString:)], @"Should respond to method call.");
    testRenderData = [[EQRenderData alloc] initWithString:@""];
    NSInteger testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 0, @"Should have created an empty string.");

    XCTAssertNoThrow([testRenderData appendString:@"Q"], @"Should append string okay.");
    testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 1, @"Should have only added 1 character.");
}

- (void) testInsertAtPosition
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(insertText:atPosition:)], @"Should respond to method call.");
    testRenderData = [[EQRenderData alloc] initWithString:@""];
    NSInteger testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 0, @"Should have created an empty string.");

    EQTextPosition *startPosition = [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData insertText:@"Q" atPosition:startPosition], @"Should insert text at start position okay.");
    testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 1, @"Should have only added 1 character.");

    XCTAssertNoThrow([testRenderData insertText:@"E" atPosition:startPosition], @"Should insert text at start position okay.");
    testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 2, @"Should have only added 1 character.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"EQ"], @"Should have inserted text in the correct order.");

    EQTextPosition *secondPosition = [EQTextPosition textPositionWithIndex:1 andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData insertText:@"D" atPosition:secondPosition], @"Should insert text at second position okay.");
    testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 3, @"Should have only added 1 character.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"EDQ"], @"Should have inserted text in the correct order.");

    EQTextPosition *lastPosition = [EQTextPosition textPositionWithIndex:testRenderData.renderString.length andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData insertText:@"3" atPosition:lastPosition], @"Should insert text at last position okay.");
    testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 4, @"Should have only added 1 character.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"EDQ3"], @"Should have inserted text in the correct order.");
}

- (void) testDeleteCharactersInRange
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(deleteCharactersInRange:)], @"Should respond to method call.");
    testRenderData = [[EQRenderData alloc] initWithString:@"ABCD"];
    NSInteger testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 4, @"Should have created a string.");

    EQTextRange *notFoundRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];

    XCTAssertNoThrow([testRenderData deleteCharactersInRange:notFoundRange], @"Should accept not found range without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"ABCD"], @"Should not change the string for not found range.");

    EQTextRange *emptyRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData deleteCharactersInRange:emptyRange], @"Should accept empty range without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"ABCD"], @"Should not change the string for empty range.");

    EQTextRange *startRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData deleteCharactersInRange:startRange], @"Should accept start range without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"BCD"], @"Should only delete first for start range.");

    EQTextRange *midRange = [EQTextRange textRangeWithRange:NSMakeRange(1, 1) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData deleteCharactersInRange:midRange], @"Should accept mid range without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"BD"], @"Should only delete 2nd for mid range.");

    XCTAssertNoThrow([testRenderData deleteCharactersInRange:midRange], @"Should accept last range without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"B"], @"Should only delete 2nd for last range.");

    XCTAssertNoThrow([testRenderData deleteCharactersInRange:startRange], @"Should accept start range without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@""], @"Should only delete 1st for start range.");

    XCTAssertNoThrow([testRenderData deleteCharactersInRange:startRange], @"Should accept delete for empty string without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@""], @"Should still be empty after delete of empty string.");

    testRenderData = [[EQRenderData alloc] initWithString:@"ABCD"];
    testLength = testRenderData.renderString.length;
    XCTAssertEqual(testLength, 4, @"Should have created a string.");

    EQTextRange *badRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 5) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData deleteCharactersInRange:badRange], @"Should accept bad range without error.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"ABCD"], @"Should not change the string for bad range.");
}

- (void) testReplaceCharactersInRange
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(replaceCharactersInRange:withText:)], @"Should respond to method call.");
    testRenderData = [[EQRenderData alloc] initWithString:@"ABCD"];
    EQTextRange *notFoundRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData replaceCharactersInRange:notFoundRange withText:@"A"], @"Should not throw for NSNotFound");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"ABCD"], @"Should not change the string for not found range.");

    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(5, 1) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData replaceCharactersInRange:testRange withText:@"1"], @"Should not throw for out of bounds range.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"ABCD"], @"Should not change the string for out of bounds range.");

    testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 5) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData replaceCharactersInRange:testRange withText:@"1"], @"Should not throw for out of bounds range.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"ABCD"], @"Should not change the string for out of bounds range.");

    testRenderData = [[EQRenderData alloc] initWithString:@""];
    testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData replaceCharactersInRange:testRange withText:@"1"], @"Should not throw for empty string.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@""], @"Should not change the string for empty string replace.");

    testRenderData = [[EQRenderData alloc] initWithString:@"ABCD"];
    testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData replaceCharactersInRange:testRange withText:nil], @"Should not throw for nil string.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"ABCD"], @"Should not change the string for nil string.");

    testRenderData = [[EQRenderData alloc] initWithString:@"ABCD"];
    testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData replaceCharactersInRange:testRange withText:@"1"], @"Should not throw for this string.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"1BCD"], @"Should change the string correctly.");

    testRenderData = [[EQRenderData alloc] initWithString:@"ABCD"];
    testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRenderData replaceCharactersInRange:testRange withText:@"1"], @"Should not throw for zero length range.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"1ABCD"], @"Should do insert for zero length range.");
}

- (void) testReplaceRenderStringWithNewString
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(replaceRenderStringWithNewString:)], @"Should respond to method call.");
    testRenderData.renderString = nil;
    XCTAssertNoThrow([testRenderData replaceRenderStringWithNewString:@"foo"], @"Should not throw for nil renderString.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"foo"], @"Should replace nil data with new data.");

    XCTAssertNoThrow([testRenderData replaceRenderStringWithNewString:nil], @"Should not throw for nil input.");
    XCTAssertTrue([testRenderData.renderString.string isEqualToString:@"foo"], @"Should not change current data for nil input.");
}

// Calls library methods, so just test no throw.
- (void) testImageBoundsInContext
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(imageBoundsInContext:)], @"Should respond to method call.");
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100.0, 100.0), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    XCTAssertNoThrow([testRenderData imageBoundsInContext:context], @"Should not throw after method call.");
    UIGraphicsEndImageContext();
}

// Calls library methods, so just test no throw.
- (void)testImageBounds
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(imageBounds)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData imageBounds], @"Should not throw after method call.");
}

// Calls library methods, so just test no throw.
- (void)testTypographicBounds
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(typographicBounds)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData typographicBounds], @"Should not throw after method call.");
}

- (void)testTypographicBoundsWithStretchyData
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(typographicBoundsWithStretchyData)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData typographicBoundsWithStretchyData], @"Should not throw after method call.");
}

- (void)testCursorRectForStringIndex
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(cursorRectForStringIndex:)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData cursorRectForStringIndex:0], @"Should not throw with empty data.");
    XCTAssertTrue(CGRectIsEmpty([testRenderData cursorRectForStringIndex:0]), @"Should return RectZero for empty data.");

    testRenderData = [[EQRenderData alloc] initWithString:@"A"];
    XCTAssertNoThrow([testRenderData cursorRectForStringIndex:5], @"Should not throw for out of bounds index.");
    XCTAssertFalse(CGRectIsEmpty([testRenderData cursorRectForStringIndex:5]), @"Should return last character (so non-empty) for out of bounds.");

    XCTAssertNoThrow([testRenderData cursorRectForStringIndex:0], @"Should not throw for out of bounds index.");
    XCTAssertFalse(CGRectIsEmpty([testRenderData cursorRectForStringIndex:0]), @"Should return first character (so non-empty) for first character.");
}

- (void)testShouldUseSmaller
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(shouldUseSmaller)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData shouldUseSmaller], @"Should not throw for no parent.");
    XCTAssertFalse([testRenderData shouldUseSmaller], @"Should return false for no parent.");
}

- (void)testGetFractionBarParent
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(getFractionBarParent)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData getFractionBarParent], @"Should not throw for no parent.");
    XCTAssertNil([testRenderData getFractionBarParent], @"Should return nil for no parent.");

    EQRenderStem *testParent1 = [[EQRenderStem alloc] init];
    [testParent1 appendChild:testRenderData];
    XCTAssertNil([testRenderData getFractionBarParent], @"Should return nil for non-fraction parent.");
    [testParent1 removeChild:testRenderData];

    EQRenderFracStem *testFracParent = [[EQRenderFracStem alloc] init];
    [testFracParent appendChild:testRenderData];
    XCTAssertEqual(testFracParent, [testRenderData getFractionBarParent], @"Should return parent when parent is a fraction.");
    [testFracParent removeChild:testRenderData];

    testParent1.stemType = stemTypeRow;
    [testParent1 appendChild:testRenderData];
    XCTAssertNil([testRenderData getFractionBarParent], @"Should return nil for non-fraction parent.");

    EQRenderStem *testParent2 = [[EQRenderStem alloc] init];
    testParent2.stemType = stemTypeFraction;
    [testParent2 appendChild:testParent1];
    XCTAssertEqual(testParent2, [testRenderData getFractionBarParent], @"Should return parent of parent when parent is mrow in num or denom.");

    testParent2.stemType = stemTypeRow;
    XCTAssertNil([testRenderData getFractionBarParent], @"Should return nil if ancestor does not have a fraction.");

    EQRenderFracStem *testParent3 = [[EQRenderFracStem alloc] initWithObject:testParent2];
    XCTAssertEqual(testParent3, [testRenderData getFractionBarParent], @"Should return ancestor when ancestor is fraction and parents are rows.");
}

- (void)testGetNRootParent
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(getNRootParent)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData getNRootParent], @"Should not throw for no parent.");
    XCTAssertNil([testRenderData getNRootParent], @"Should return nil for no parent.");

    EQRenderStem *testParent1 = [[EQRenderStem alloc] init];
    [testParent1 appendChild:testRenderData];
    XCTAssertNil([testRenderData getNRootParent], @"Should return nil for non-root parent.");
    [testParent1 removeChild:testRenderData];

    EQRenderStem *testRootParent = [[EQRenderStem alloc] initWithObject:testRenderData andStemType:stemTypeSqRoot];
    XCTAssertEqual(testRootParent, [testRenderData getNRootParent], @"Should return parent when parent is a sqroot.");

    testRootParent.stemType = stemTypeNRoot;
    XCTAssertEqual(testRootParent, [testRenderData getNRootParent], @"Should return parent when parent is a nroot.");
    [testRootParent removeChild:testRenderData];

    EQRenderStem *testRowParent = [[EQRenderStem alloc] initWithObject:testRenderData andStemType:stemTypeRow];
    XCTAssertEqual(testRenderData.parentStem, testRowParent, @"Should have set the parent to be the new row.");
    XCTAssertNil([testRenderData getNRootParent], @"Should return nil for non-root parent.");

    [testRootParent appendChild:testRowParent];
    XCTAssertNotNil([testRenderData getNRootParent], @"Should not return nil if ancestor is root.");
    XCTAssertEqual([testRenderData getNRootParent], testRootParent, @"Should return root parent since that is the ancestor root.");

    testRootParent.stemType = stemTypeSqRoot;
    XCTAssertNotNil([testRenderData getNRootParent], @"Should not return nil if ancestor is root.");
    XCTAssertEqual([testRenderData getNRootParent], testRootParent, @"Should return root parent since that is the ancestor root.");

    testRootParent.stemType = stemTypeRow;
    XCTAssertNil([testRenderData getNRootParent], @"Should return nil if ancestor is not a root type.");
}

- (void) testResetStretchyCharacterData
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(resetStretchyCharacterData)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData resetStretchyCharacterData], @"Should not throw when resetting on initial data.");

    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo)"];
    XCTAssertNoThrow([testRenderData resetStretchyCharacterData], @"Should not throw when resetting on initial data.");

    testRenderData.hasStretchyCharacterData = YES;
    CGFloat testKern = 42.0;
    testRenderData.storedKern = testKern;

    EQRenderData *testCharacterData = [[EQRenderData alloc] initWithString:@"("];
    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    testCharacterData.hasStretchyDescenderPoint = YES;
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    testCharacterData.stretchyDescenderPoint = testPoint;
    [testRenderData addStretchyCharacterData:testCharacterData forTextRange:testRange];

    XCTAssertTrue([testRenderData containsStretchyDescenders], @"Should have added the data correctly.");
    XCTAssertNotNil([testRenderData getStretchyDescenders], @"Should have added the data correctly.");
    XCTAssertTrue([testRenderData getStretchyDescenders].count == 1, @"Should have only added the single descender.");
    XCTAssertTrue(testRenderData.hasStretchyCharacterData == YES, @"Input should match output.");
    XCTAssertTrue(testRenderData.storedKern == testKern, @"Input should match output.");

    XCTAssertNoThrow([testRenderData resetStretchyCharacterData], @"Should not throw when resetting characters.");
    XCTAssertFalse([testRenderData containsStretchyDescenders], @"Should have cleared the data.");
    XCTAssertNil([testRenderData getStretchyDescenders], @"Should have cleared the data.");
    XCTAssertFalse(testRenderData.hasStretchyCharacterData, @"Should have reset this property.");
    XCTAssertTrue(testRenderData.storedKern == 0.0, @"Should have reset the kern property.");
}

- (void)testAddStretchyCharacterData
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(addStretchyCharacterData:forTextRange:)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:nil forTextRange:nil], @"Should not throw when passing nil arguments on empty renderData.");
    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo)"];
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:nil forTextRange:nil], @"Should not throw when passing nil arguments on non-empty renderData.");
    XCTAssertNil([testRenderData getStretchyDescenders], @"Should still be nil.");
    XCTAssertTrue([testRenderData containsStretchyDescenders] == NO, @"Should not return TRUE here.");

    EQRenderData *testCharacterData = [[EQRenderData alloc] initWithString:@"("];
    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    testCharacterData.hasStretchyDescenderPoint = YES;
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    testCharacterData.stretchyDescenderPoint = testPoint;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterData forTextRange:testRange], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    XCTAssertTrue([testRenderData containsStretchyDescenders] == YES, @"Should have return true now.");
    NSArray *testArray = [testRenderData getStretchyDescenders];
    XCTAssertNotNil(testArray, @"Should not be nil.");
    XCTAssertTrue(testArray.count == 1, @"Should have added only the single descender.");
    XCTAssertEqual(testCharacterData, testArray[0], @"Input should match output.");
}

- (void)testRenderStringWithStretchyCharacters
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(renderStringWithStretchyCharacters)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData renderStringWithStretchyCharacters], @"Should not throw when calling with empty data.");
    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo)"];
    NSMutableAttributedString *testStr = testRenderData.renderString;
    XCTAssertTrue(testRenderData.hasStretchyCharacterData == NO, @"Should return NO on initialize.");
    XCTAssertEqual(testStr, testRenderData.renderStringWithStretchyCharacters, @"Should return original characters when there is no stretchy data.");

    NSString *testBracerStr = @"[";
    EQRenderData *testCharacterData = [[EQRenderData alloc] initWithString:testBracerStr];
    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    testCharacterData.hasStretchyDescenderPoint = YES;
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    testCharacterData.stretchyDescenderPoint = testPoint;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterData forTextRange:testRange], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    NSAttributedString *returnStr;
    XCTAssertNoThrow(returnStr = testRenderData.renderStringWithStretchyCharacters, @"Should not throw with valid data.");
    XCTAssertNotEqual(returnStr, testStr, @"Should not return original string when there is stretchy data.");
    // Note: the method typically has matching strings with different attributed values, but this is easier to test
    // and the results should still be valid.
    XCTAssertFalse([returnStr.string isEqualToString:testStr.string], @"Should not match original character data in this case.");

    NSString *testReturnBracer = [returnStr.string substringWithRange:testRange.range];
    XCTAssertTrue([testBracerStr isEqualToString:testReturnBracer], @"Should have replaced the original character data with the stretchy data.");
}

- (void)testAdjustKernForTextPosition
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(adjustKernForTextPosition:)], @"Should respond to method call.");

    CGFloat testResult;
    XCTAssertNoThrow(testResult = [testRenderData adjustKernForTextPosition:nil], @"Should not throw when calling on empty data with nil text position.");
    XCTAssertTrue(testResult == 0.0, @"Should return 0.0 in this case.");

    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo) + 2"];
    XCTAssertNoThrow(testResult = [testRenderData adjustKernForTextPosition:nil], @"Should not throw when calling with nil arguments on non-empty data.");
    XCTAssertTrue(testResult == 0.0, @"Should return 0.0 in this case.");

    EQRenderData *testCharacterData = [[EQRenderData alloc] initWithString:@")"];
    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(4, 1) andLocation:0 andEquationLoc:0];
    testCharacterData.hasStretchyDescenderPoint = YES;
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    testCharacterData.stretchyDescenderPoint = testPoint;
    CGFloat testKern = 42.0;
    testCharacterData.storedKern = testKern;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterData forTextRange:testRange], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    EQTextPosition *testPosition = [EQTextPosition textPositionWithIndex:42 andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow(testResult = [testRenderData adjustKernForTextPosition:testPosition], @"Should not throw when calling with out of bounds position.");
    XCTAssertTrue(testResult == 0.0, @"Should return 0.0 in this case.");

    testPosition = [EQTextPosition textPositionWithIndex:3 andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow(testResult = [testRenderData adjustKernForTextPosition:testPosition], @"Should not throw when calling with in bounds position.");
    XCTAssertTrue(testResult == 0.0, @"Should return 0.0 in this case, as no stretchy kerning matches.");

    testPosition = [EQTextPosition textPositionWithIndex:4 andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow(testResult = [testRenderData adjustKernForTextPosition:testPosition], @"Should not throw when calling with in bounds position.");
    XCTAssertTrue(testResult == 0.0, @"Should return 0.0 in this case, as it is in the same location (and not after).");

    testPosition = [EQTextPosition textPositionWithIndex:5 andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow(testResult = [testRenderData adjustKernForTextPosition:testPosition], @"Should not throw when calling with in bounds position.");
    XCTAssertTrue(testResult == 42.0, @"Should return 42.0 in this case, as it is located after the bracer.");
}

- (void)testGetClearStretchyCharacter
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(getClearStretchyCharacter)], @"Should respond to method.");
    XCTAssertTrue(testRenderData.renderString.length == 0, @"Should initialize as empty.");
    XCTAssertNoThrow([testRenderData getClearStretchyCharacter], @"Should not throw with empty data.");
    XCTAssertNil([testRenderData getClearStretchyCharacter], @"Should return nil with empty data.");

    testRenderData = [[EQRenderData alloc] initWithString:@"Foo"];
    XCTAssertNoThrow([testRenderData getClearStretchyCharacter], @"Should not throw with valid data.");
    XCTAssertNotNil([testRenderData getClearStretchyCharacter], @"Should not return nil with valid data.");
    // Could also test that it actually applied the clear color to the result, but what's the point?
}

- (void)testContainsStretchyDescenders
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(containsStretchyDescenders)], @"Should respond to method.");
    XCTAssertTrue([testRenderData respondsToSelector:@selector(getStretchyDescenders)], @"Should respond to method.");

    XCTAssertNoThrow([testRenderData containsStretchyDescenders], @"Should not throw with empty data.");
    XCTAssertFalse([testRenderData containsStretchyDescenders], @"Should initialize to false.");

    XCTAssertNoThrow([testRenderData getStretchyDescenders], @"Should not throw with empty data.");
    XCTAssertFalse([testRenderData getStretchyDescenders], @"Should initialize to false.");

    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo)"];

    EQRenderData *testCharacterDataNoDescender = [[EQRenderData alloc] initWithString:@"("];
    EQTextRange *testRangeNoDescender = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    testCharacterDataNoDescender.hasStretchyDescenderPoint = NO;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterDataNoDescender forTextRange:testRangeNoDescender], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    XCTAssertNoThrow([testRenderData containsStretchyDescenders], @"Should not throw here.");
    XCTAssertFalse([testRenderData containsStretchyDescenders], @"Should be false as it does not contain the stretchy descenders.");

    XCTAssertNoThrow([testRenderData getStretchyDescenders], @"Should not throw here.");
    XCTAssertNil([testRenderData getStretchyDescenders], @"Should return nil as there are no stretchy descenders.");

    EQRenderData *testCharacterData = [[EQRenderData alloc] initWithString:@")"];
    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(4, 1) andLocation:0 andEquationLoc:0];
    testCharacterData.hasStretchyDescenderPoint = YES;
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    testCharacterData.stretchyDescenderPoint = testPoint;
    CGFloat testKern = 42.0;
    testCharacterData.storedKern = testKern;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterData forTextRange:testRange], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    XCTAssertNoThrow([testRenderData containsStretchyDescenders], @"Should not throw here.");
    XCTAssertTrue([testRenderData containsStretchyDescenders], @"Should be true as it does contain the stretchy descenders.");

    NSArray *testReturn;
    XCTAssertNoThrow(testReturn = [testRenderData getStretchyDescenders], @"Should not throw here.");
    XCTAssertNotNil(testReturn, @"Should not be nil as it does contain stretchy descenders.");
    XCTAssertTrue(testReturn.count == 1, @"Should only have one object.");
    XCTAssertEqual(testCharacterData, testReturn[0], @"Input should match output.");
}

- (void)testGetStretchyRanges
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(getStretchyRanges)], @"Should respond to method call.");

    NSArray *testArray = @[];
    XCTAssertNotNil(testArray, @"Should not be nil when initialized as empty.");
    XCTAssertNoThrow(testArray = [testRenderData getStretchyRanges], @"Should not throw with empty data.");
    XCTAssertNil(testArray, @"Should have returned nil with empty data.");

    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo)"];
    testArray = @[];
    XCTAssertNotNil(testArray, @"Should not be nil when initialized as empty.");
    XCTAssertNoThrow(testArray = [testRenderData getStretchyRanges], @"Should not throw with no stretchy data.");
    XCTAssertNil(testArray, @"Should have returned nil with no stretchy data.");

    EQRenderData *testCharacterData = [[EQRenderData alloc] initWithString:@"("];
    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0];
    testCharacterData.hasStretchyDescenderPoint = YES;
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    testCharacterData.stretchyDescenderPoint = testPoint;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterData forTextRange:testRange], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    XCTAssertTrue([testRenderData containsStretchyDescenders] == YES, @"Should have return true now.");
    testArray = @[];
    XCTAssertNotNil(testArray, @"Should not be nil when initialized as empty.");
    XCTAssertNoThrow(testArray = [testRenderData getStretchyRanges], @"Should not throw with no stretchy data.");
    XCTAssertNotNil(testArray, @"Should have returned a valid array with stretchy data.");
    XCTAssertTrue(testArray.count == 1, @"Should have exactly one stretchy object.");

    NSValue *testValue = testArray[0];
    NSRange testDataRange = testValue.rangeValue;
    XCTAssertTrue(testDataRange.location == 0, @"Input should match output.");
    XCTAssertTrue(testDataRange.length == 1, @"Input should match output.");

    EQRenderData *testCharacterData2 = [[EQRenderData alloc] initWithString:@")"];
    EQTextRange *testRange2 = [EQTextRange textRangeWithRange:NSMakeRange(4, 1) andLocation:0 andEquationLoc:0];
    testCharacterData2.hasStretchyDescenderPoint = YES;
    CGPoint testPoint2 = CGPointMake(42.0, 42.0);
    testCharacterData2.stretchyDescenderPoint = testPoint2;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterData2 forTextRange:testRange2], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    XCTAssertTrue([testRenderData containsStretchyDescenders] == YES, @"Should have return true now.");
    testArray = @[];
    XCTAssertNotNil(testArray, @"Should not be nil when initialized as empty.");
    XCTAssertNoThrow(testArray = [testRenderData getStretchyRanges], @"Should not throw with no stretchy data.");
    XCTAssertNotNil(testArray, @"Should have returned a valid array with stretchy data.");
    XCTAssertTrue(testArray.count == 2, @"Should have exactly two stretchy objects.");

    testValue = testArray[0];
    testDataRange = testValue.rangeValue;

    NSValue *testValue2 = testArray[1];
    NSRange testDataRange2 = testValue2.rangeValue;

    XCTAssertTrue(testDataRange.location == 0, @"Input should match output.");
    XCTAssertTrue(testDataRange.length == 1, @"Input should match output.");
    XCTAssertTrue(testDataRange2.location == 4, @"Input should match output.");
    XCTAssertTrue(testDataRange2.length == 1, @"Input should match output.");
}

- (void)testShiftLayoutHorizontally
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(shiftLayoutHorizontally:)], @"Should respond to method call.");
    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo)"];
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    testRenderData.drawOrigin = testPoint;

    XCTAssertNoThrow([testRenderData shiftLayoutHorizontally:0.0], @"Should not throw here.");
    CGPoint returnPoint = testRenderData.drawOrigin;
    XCTAssertTrue(CGPointEqualToPoint(returnPoint, testPoint), @"Should be equal when passed 0.0");

    testRenderData.hasStretchyDescenderPoint = YES;
    CGPoint descenderPoint = CGPointMake(42.0, 42.0);
    testRenderData.stretchyDescenderPoint = descenderPoint;

    XCTAssertNoThrow([testRenderData shiftLayoutHorizontally:3.0], @"Should not throw here.");
    testPoint = CGPointMake(45.0, 42.0);
    returnPoint = testRenderData.drawOrigin;
    XCTAssertTrue(CGPointEqualToPoint(returnPoint, testPoint), @"Should have shifted by 3.0 when passed 3.0");

    descenderPoint = testRenderData.stretchyDescenderPoint;
    XCTAssertTrue(CGPointEqualToPoint(descenderPoint, testPoint), @"Should have shifted by 3.0 when passed 3.0");

    testRenderData = [[EQRenderData alloc] initWithString:@"(Foo)"];

    EQRenderData *testCharacterData = [[EQRenderData alloc] initWithString:@")"];
    EQTextRange *testRange = [EQTextRange textRangeWithRange:NSMakeRange(4, 1) andLocation:0 andEquationLoc:0];
    testCharacterData.drawOrigin = CGPointMake(5.0, 5.0);
    testCharacterData.hasStretchyDescenderPoint = YES;
    testCharacterData.stretchyDescenderPoint = CGPointMake(11.0, 10.0);
    CGFloat testKern = 42.0;
    testCharacterData.storedKern = testKern;
    XCTAssertNoThrow([testRenderData addStretchyCharacterData:testCharacterData forTextRange:testRange], @"Should not throw when adding data.");
    testRenderData.hasStretchyCharacterData = YES;

    testRenderData.drawOrigin = CGPointMake(3.0, 3.0);
    testRenderData.hasStretchyDescenderPoint = NO;
    testRenderData.stretchyDescenderPoint = CGPointZero;

    XCTAssertNoThrow([testRenderData shiftLayoutHorizontally:3.0], @"Should not throw here.");
    CGPoint testOrigin = testRenderData.drawOrigin;
    CGPoint testDescenderOrigin = testCharacterData.drawOrigin;
    CGPoint testDescenderStretchyOrigin = testCharacterData.stretchyDescenderPoint;
    CGPoint testDescenderPoint = testRenderData.stretchyDescenderPoint;

    XCTAssertTrue(CGPointEqualToPoint(testOrigin, CGPointMake(6.0, 3.0)), @"Should have shifted origin by 3.0");
    XCTAssertTrue(CGPointEqualToPoint(testDescenderOrigin, CGPointMake(8.0, 5.0)), @"Should have shifted descender origin by 3.0");
    XCTAssertTrue(CGPointEqualToPoint(testDescenderStretchyOrigin, CGPointMake(14.0, 10.0)), @"Should have shifted descender stretchy origin by 3.0");
    XCTAssertTrue(CGPointEqualToPoint(testDescenderPoint, CGPointZero), @"Should not have changed descender as it was flagged as not existing.");
}

// Mostly seems useless to test this, since it just merges to attributed strings.
// Leaving placeholder for now.
- (void)testMergeWithRenderData
{
    XCTAssertTrue([testRenderData respondsToSelector:@selector(mergeWithRenderData:)], @"Should respond to method call.");
    XCTAssertNoThrow([testRenderData mergeWithRenderData:nil], @"Should no throw with nil data.");
}

@end

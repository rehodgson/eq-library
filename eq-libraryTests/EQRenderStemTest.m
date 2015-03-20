//
//  EQRenderStemTest.m
//  eq-library
//
//  Created by Raymond Hodgson on 10/11/13.
//  Copyright (c) 20132015 Raymond Hodgson. All rights reserved.
//
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <XCTest/XCTest.h>
#import "EQRenderStem.h"
#import "EQRenderData.h"
#import "EQRenderFracStem.h"
#import "EQRenderMatrixStem.h"

@interface EQRenderStemTest : XCTestCase
{
    EQRenderStem *testStem;
}

@end

@implementation EQRenderStemTest

- (void)setUp
{
    [super setUp];

    testStem = [[EQRenderStem alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatRenderStemExists
{
    XCTAssertNotNil(testStem, @"Should be able to create EQRenderStem.");
}

- (void)testThatRenderStemConformsToNSCodingProtocol
{
    XCTAssertTrue([testStem conformsToProtocol:@protocol(NSCoding)], @"Data source must conform to NSCoding");
}

- (void)testDrawOriginProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(drawOrigin)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setDrawOrigin:)], @"Should respond to set: method.");

    XCTAssertNoThrow([testStem setDrawOrigin:CGPointMake(40.0, 40.0)], @"Should not throw when setting origin.");
    XCTAssertNoThrow([testStem drawOrigin], @"Should not throw when getting origin.");
    XCTAssertTrue(CGPointEqualToPoint([testStem drawOrigin], CGPointMake(40.0, 40.0)), @"Input should match output.");
}

- (void)testDrawSizeProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(drawSize)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setDrawSize:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testStem setDrawSize:CGSizeMake(30.0, 30.0)], @"Should not throw when setting size.");
    XCTAssertNoThrow([testStem drawSize], @"Should not throw when getting size.");
    XCTAssertTrue(CGSizeEqualToSize([testStem drawSize], CGSizeMake(30.0, 30.0)), @"Input should match output.");
}

- (void)testDrawBoundsProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(drawBounds)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setDrawBounds:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testStem setDrawBounds:CGRectMake(0.0, 0.0, 60.0, 60.0)], @"Should not throw when setting bounding rect.");
    XCTAssertNoThrow([testStem drawBounds], @"Should not throw when getting bounding rect.");
    XCTAssertTrue(CGRectEqualToRect([testStem drawBounds], CGRectMake(0.0, 0.0, 60.0, 60.0)), @"Input should match output.");
}

- (void)testRenderArrayProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(renderArray)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setRenderArray:)], @"Should respond to set: method.");

    XCTAssertNotNil([testStem renderArray], @"Should not initialize with nil.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should initialize empty.");

    XCTAssertNoThrow([testStem.renderArray addObject:@"Q"], @"Should allow you to add object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should no longer be empty.");

    XCTAssertNoThrow([testStem.renderArray removeObjectAtIndex:0], @"Should allow you to remove object.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should be empty again.");
}

- (void) testParentStemProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(parentStem)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setParentStem:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testStem setParentStem:nil], @"Should not throw when setting to nil.");
    XCTAssertNil([testStem parentStem], @"Should be nil if you set it to nil.");
}

- (void)testStemTypeProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(stemType)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setStemType:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.stemType == stemTypeUnassigned, @"Should initialize to unassigned.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should allow you to set stem type.");
    XCTAssertTrue(testStem.stemType == stemTypeRoot, @"Input should match output.");

    XCTAssertNoThrow(testStem.stemType = stemTypeUnassigned, @"Should allow you to set stem type.");
    XCTAssertTrue(testStem.stemType == stemTypeUnassigned, @"Input should match output.");
}

- (void)testHasLargeOpProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(hasLargeOp)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setHasLargeOp:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.hasLargeOp == FALSE, @"Should initialize to false.");
    XCTAssertNoThrow(testStem.hasLargeOp = TRUE, @"Should allow you to set hasLargeOp.");
    XCTAssertTrue(testStem.hasLargeOp == TRUE, @"Input should match output.");

    XCTAssertNoThrow(testStem.hasLargeOp = FALSE, @"Should allow you to set hasLargeOp.");
    XCTAssertTrue(testStem.hasLargeOp == FALSE, @"Input should match output.");
}

- (void)testHasSupplementaryDataProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(hasSupplementaryData)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setHasSupplementaryData:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.hasSupplementaryData == FALSE, @"Should initialize to false.");
    XCTAssertNoThrow(testStem.hasSupplementaryData = TRUE, @"Should allow you to set hasSupplementaryData.");
    XCTAssertTrue(testStem.hasSupplementaryData == TRUE, @"Input should match output.");

    XCTAssertNoThrow(testStem.hasSupplementaryData = FALSE, @"Should allow you to set hasSupplementaryData.");
    XCTAssertTrue(testStem.hasSupplementaryData == FALSE, @"Input should match output.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@" "];
    testStem = [[EQRenderStem alloc] initWithObject:testData andStemType:stemTypeSqRoot];
    XCTAssertTrue(testStem.hasSupplementaryData == TRUE, @"Should initialize sqroot with TRUE.");

    [testStem removeChild:testData];

    testStem = [[EQRenderStem alloc] initWithObject:testData andStemType:stemTypeNRoot];
    XCTAssertTrue(testStem.hasSupplementaryData == TRUE, @"Should initialize nRoot with TRUE.");
}

- (void)testSupplementaryDataObjectProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(supplementaryData)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setSupplementaryData:)], @"Should respond to set: method.");

    XCTAssertNil(testStem.supplementaryData, @"Should initialize to nil.");
    EQRenderData *testSupplementaryData = [[EQRenderData alloc] initWithString:@" "];
    XCTAssertNoThrow(testStem.supplementaryData = testSupplementaryData, @"Should not throw when setting.");

    XCTAssertNoThrow(testStem.supplementaryData = nil, @"Should not throw when setting to nil.");
    XCTAssertNil(testStem.supplementaryData, @"Input should match output.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@" "];
    testStem = [[EQRenderStem alloc] initWithObject:testData andStemType:stemTypeSqRoot];
    XCTAssertNotNil(testStem.supplementaryData, @"Should initialize the data with sqroot type.");

    [testStem removeChild:testData];

    testStem = [[EQRenderStem alloc] initWithObject:testData andStemType:stemTypeNRoot];
    XCTAssertNotNil(testStem.supplementaryData, @"Should initialize the data with nroot type.");
}

- (void)testHasOverlineProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(hasOverline)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setHasOverline:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.hasOverline == FALSE, @"Should initialize to false.");
    XCTAssertNoThrow(testStem.hasOverline = TRUE, @"Should allow you to set hasOverline.");
    XCTAssertTrue(testStem.hasOverline == TRUE, @"Input should match output.");

    XCTAssertNoThrow(testStem.hasOverline = FALSE, @"Should allow you to set hasOverline.");
    XCTAssertTrue(testStem.hasOverline == FALSE, @"Input should match output.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@" "];
    testStem = [[EQRenderStem alloc] initWithObject:testData andStemType:stemTypeSqRoot];
    XCTAssertTrue(testStem.hasOverline == TRUE, @"Should initialize sqroot with TRUE.");

    [testStem removeChild:testData];

    testStem = [[EQRenderStem alloc] initWithObject:testData andStemType:stemTypeNRoot];
    XCTAssertTrue(testStem.hasOverline == TRUE, @"Should initialize nRoot with TRUE.");
}

- (void)testOverlineStartPointProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(overlineStartPoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setOverlineStartPoint:)], @"Should respond to set: method.");

    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, testStem.overlineStartPoint), @"Should initialize to pointZero.");
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    XCTAssertNoThrow(testStem.overlineStartPoint = testPoint, @"Should allow you to set overlineStartPoint.");
    XCTAssertTrue(CGPointEqualToPoint(testPoint, testStem.overlineStartPoint), @"Input should match output.");
}

- (void)testOverlineEndPointProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(overlineEndPoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setOverlineEndPoint:)], @"Should respond to set: method.");

    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, testStem.overlineEndPoint), @"Should initialize to pointZero.");
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    XCTAssertNoThrow(testStem.overlineEndPoint = testPoint, @"Should allow you to set overlineEndPoint.");
    XCTAssertTrue(CGPointEqualToPoint(testPoint, testStem.overlineEndPoint), @"Input should match output.");
}

- (void)testHasStoredCharacterDataProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(hasStoredCharacterData)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setHasStoredCharacterData:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.hasStoredCharacterData == FALSE, @"Should initialize to false.");
    XCTAssertNoThrow(testStem.hasStoredCharacterData = TRUE, @"Should allow you to set hasStoredCharacterData.");
    XCTAssertTrue(testStem.hasStoredCharacterData == TRUE, @"Input should match output.");

    XCTAssertNoThrow(testStem.hasStoredCharacterData = FALSE, @"Should allow you to set hasStoredCharacterData.");
    XCTAssertTrue(testStem.hasStoredCharacterData == FALSE, @"Input should match output.");
}

- (void)testStoredCharacterDataProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(storedCharacterData)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setStoredCharacterData:)], @"Should respond to set: method.");

    XCTAssertNil(testStem.storedCharacterData, @"Should initialize to nil.");
    NSString *testStr = @" ";
    XCTAssertNoThrow(testStem.storedCharacterData = testStr, @"Should not throw when setting.");
    XCTAssertEqual(testStem.storedCharacterData, testStr, @"Should assign the new value instead of copying.");

    XCTAssertNoThrow(testStem.storedCharacterData = nil, @"Should not throw when setting to nil.");
    XCTAssertNil(testStem.storedCharacterData, @"Input should match output.");
}

- (void)testUseAlignProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(useAlign)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setUseAlign:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.useAlign == viewAlignAuto, @"Should intitialize to auto.");
    XCTAssertNoThrow(testStem.useAlign = viewAlignLeft, @"Should not throw for set.");
    XCTAssertTrue(testStem.useAlign == viewAlignLeft, @"Input should match output.");
}

- (void)testHasAccentCharacterProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(hasAccentCharacter)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setHasAccentCharacter:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.hasAccentCharacter == NO, @"Should initialize to NO.");
    XCTAssertNoThrow(testStem.hasAccentCharacter = YES, @"Should not throw when setting.");
    XCTAssertTrue(testStem.hasAccentCharacter == YES, @"Input should match output.");
}

// May need to expand these if we use this for anything other than n-roots.
- (void)testUpdateSupplementaryData
{
    EQRenderData *testData = [[EQRenderData alloc] initWithString:@" "];
    testStem = [[EQRenderStem alloc] initWithObject:testData andStemType:stemTypeNRoot];

    XCTAssertTrue(testStem.hasStoredCharacterData == NO, @"Should initialize to false.");
    XCTAssertNil(testStem.storedCharacterData, @"Should initialize to nil.");
    XCTAssertTrue(testStem.hasSupplementaryData, @"Should have supplementary data for n-root stems.");
    XCTAssertNotNil(testStem.supplementaryData, @"Should not initialize to nil for n-root stems.");
    EQRenderData *testSuppleData1 = testStem.supplementaryData;
    NSString *testCharStr1 = testSuppleData1.renderString.string;

    testStem.hasStoredCharacterData = YES;
    testStem.storedCharacterData = @"3";
    [testStem updateSupplementaryData];
    XCTAssertTrue(testStem.hasSupplementaryData, @"Should still have supplementary data for updated n-root stems.");
    XCTAssertNotNil(testStem.supplementaryData, @"Should not be nil for updated n-root stems.");
    EQRenderData *testSuppleData2 = testStem.supplementaryData;
    NSString *testCharStr2 = testSuppleData2.renderString.string;
    XCTAssertFalse([testCharStr1 isEqualToString:testCharStr2], @"Should have a different stem type after updating.");

    testStem.hasStoredCharacterData = YES;
    testStem.storedCharacterData = @"4";
    [testStem updateSupplementaryData];
    XCTAssertTrue(testStem.hasSupplementaryData, @"Should still have supplementary data for updated n-root stems.");
    XCTAssertNotNil(testStem.supplementaryData, @"Should not be nil for updated n-root stems.");
    EQRenderData *testSuppleData3 = testStem.supplementaryData;
    NSString *testCharStr3 = testSuppleData3.renderString.string;
    XCTAssertFalse([testCharStr1 isEqualToString:testCharStr3], @"Should have a different stem type after updating.");
    XCTAssertFalse([testCharStr2 isEqualToString:testCharStr3], @"Should have a different stem type after updating.");

    testStem.hasStoredCharacterData = YES;
    testStem.storedCharacterData = @"n";
    [testStem updateSupplementaryData];
    XCTAssertTrue(testStem.hasSupplementaryData, @"Should still have supplementary data for updated n-root stems.");
    XCTAssertNotNil(testStem.supplementaryData, @"Should not be nil for updated n-root stems.");
    EQRenderData *testSuppleData4 = testStem.supplementaryData;
    NSString *testCharStr4 = testSuppleData4.renderString.string;
    XCTAssertTrue([testCharStr1 isEqualToString:testCharStr4], @"Should have the original stem type after updating.");
    XCTAssertFalse([testCharStr2 isEqualToString:testCharStr4], @"Should have a different stem type after updating.");
    XCTAssertFalse([testCharStr3 isEqualToString:testCharStr4], @"Should have a different stem type after updating.");
}

- (void)testInit
{
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.stemType == stemTypeUnassigned, @"Should have unassigned stem type.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");
}

- (void)testInitWithObject
{
    XCTAssertTrue([testStem respondsToSelector:@selector(initWithObject:)], @"Should respond to initWithObject.");

    XCTAssertThrows(testStem = [[EQRenderStem alloc] initWithObject:nil], @"Should throw with nil initializer.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q"], @"Should perform init with any object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should include initialized object in array.");
}

- (void)testInitWithObjectAndStemType
{
    XCTAssertTrue([testStem respondsToSelector:@selector(initWithObject:andStemType:)], @"Should respond to initWithObjectAndStemType.");

    XCTAssertThrows(testStem = [[EQRenderStem alloc] initWithObject:nil andStemType:stemTypeUnassigned], @"Should throw with nil object.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q" andStemType:stemTypeUnassigned], @"Should not throw with any object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should include initialized object in array.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q" andStemType:stemTypeUnassigned], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeUnassigned, @"Input should match output.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q" andStemType:stemTypeRoot], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeRoot, @"Input should match output.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q" andStemType:stemTypeRow], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeRow, @"Input should match output.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q" andStemType:stemTypeSub], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeSub, @"Input should match output.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q" andStemType:stemTypeSup], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeSup, @"Input should match output.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] initWithObject:@"Q" andStemType:stemTypeFraction], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Input should match output.");
}

- (void)testAppendChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(appendChild:)], @"Should respond to appendChild:");
    XCTAssertThrowsSpecific([testStem appendChild:testStem], NSException, @"Should throw when using self as object.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should not add when attempting to append nil.");

    XCTAssertNoThrow([testStem appendChild:nil], @"Should not throw for nil object.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should not add when attempting to append nil.");

    XCTAssertNoThrow([testStem appendChild:@"Q"], @"Should not throw for any object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should include initialized object in array.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should add object.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@""];
    XCTAssertNoThrow([testStem appendChild:testData], @"Should not throw for addObject.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should add object.");
    XCTAssertEqual(testData, [testStem.renderArray objectAtIndex:0], @"Input should match output.");
    XCTAssertEqual(testStem, testData.parentStem, @"Should automatically set parent.");
}

- (void)testInsertChildAtLoc
{
    XCTAssertTrue([testStem respondsToSelector:@selector(insertChild:atLoc:)], @"Should respond to insertChild:atLoc:");
    XCTAssertThrowsSpecific([testStem appendChild:testStem], NSException, @"Should throw when using self as object.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem insertChild:nil atLoc:0], @"Should not throw for nil object.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should not add when attempting to insert nil.");

    XCTAssertNoThrow([testStem insertChild:@"Q" atLoc:0], @"Should not throw for any object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should add object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should include initialized object in array.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@""];
    XCTAssertNoThrow([testStem insertChild:testData atLoc:0], @"Should not throw for insert object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should add object.");
    XCTAssertEqual(testData, [testStem.renderArray objectAtIndex:0], @"Input should match output.");
    XCTAssertEqual(testStem, testData.parentStem, @"Should automatically set parent.");

    EQRenderData *testData2 = [[EQRenderData alloc] initWithString:@"2"];
    XCTAssertNoThrow([testStem insertChild:testData2 atLoc:42], @"Should not throw for insert object out of bounds.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should add object.");
    XCTAssertEqual(testData2, [testStem.renderArray objectAtIndex:1], @"Should have appended instead.");
    XCTAssertEqual(testStem, testData2.parentStem, @"Should automatically set parent.");
}

- (void)testSetChildAtLoc
{
    XCTAssertTrue([testStem respondsToSelector:@selector(setChild:atLoc:)], @"Should respond to setChild:atLoc:");
    XCTAssertThrowsSpecific([testStem appendChild:testStem], NSException, @"Should throw when using self as object.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem insertChild:@"Q" atLoc:0], @"Should not throw for any object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should add object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should include initialized object in array.");

    XCTAssertNoThrow([testStem setChild:nil atLoc:0], @"Should not throw for nil object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should not add object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should not have changed object at location.");

    XCTAssertNoThrow([testStem setChild:@"R" atLoc:1], @"Should not throw for location == array count.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should add object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should not have changed object at location 0.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:1] isEqualToString:@"R"], @"Input should match output.");

    XCTAssertNoThrow([testStem setChild:@"S" atLoc:42], @"Should not throw for location > array count.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should not add object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should not have changed object at location 0.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:1] isEqualToString:@"R"], @"Should not have changed object at location 1.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@""];
    XCTAssertNoThrow([testStem setChild:testData atLoc:0], @"Should not throw for insert object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should not add object.");
    XCTAssertEqual(testData, [testStem.renderArray objectAtIndex:0], @"Input should match output.");
    XCTAssertEqual(testStem, testData.parentStem, @"Should automatically set parent.");
}

- (void)testRemoveChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(removeChild:)], @"Should respond to removeChild:");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem removeChild:@"Q"], @"Should not throw for empty array.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should not have changed array.");

    NSString *testStr = @"Q";
    XCTAssertNoThrow([testStem appendChild:testStr], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem removeChild:nil], @"Should not throw for nil object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should not have changed array count.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have not changed array value.");

    NSString *testStr2 = @"R";
    XCTAssertNoThrow([testStem removeChild:testStr2], @"Should not throw for missing object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should not have changed array count.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have not changed array value.");

    XCTAssertNoThrow([testStem appendChild:testStr2], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have not changed array loc 0.");
    XCTAssertTrue([testStr2 isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem removeChild:testStr], @"Should not throw for valid object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have removed object.");
    XCTAssertTrue([testStr2 isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have changed array loc.");
}

- (void)testGetLocForChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getLocForChild:)], @"Should respond to getLocForChild:");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    NSString *testStr = @"Q";
    XCTAssertNoThrow([testStem getLocForChild:testStr], @"Should not throw with empty array.");
    XCTAssertTrue(NSNotFound == [testStem getLocForChild:testStr], @"Should return not found for empty array.");

    XCTAssertNoThrow([testStem appendChild:testStr], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem getLocForChild:testStr], @"Should not throw with valid object.");
    XCTAssertTrue(0 == [testStem getLocForChild:testStr], @"Should return correct location.");

    XCTAssertNoThrow([testStem getLocForChild:nil], @"Should not throw with nil object.");
    XCTAssertTrue(NSNotFound == [testStem getLocForChild:nil], @"Should return not found for nil object.");

    NSString *testStr2 = @"R";
    XCTAssertNoThrow([testStem getLocForChild:testStr2], @"Should not throw with missing object.");
    XCTAssertTrue(NSNotFound == [testStem getLocForChild:testStr2], @"Should return not found for missing object.");
}

- (void)testGetFirstChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getFirstChild)], @"Should respond to getFirstChild");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem getFirstChild], @"Should not throw for empty array.");
    XCTAssertTrue(nil == [testStem getFirstChild], @"Should return nil for empty array.");

    NSString *testStr = @"Q";
    XCTAssertNoThrow([testStem appendChild:testStr], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");
    XCTAssertTrue([testStr isEqual:[testStem getFirstChild]], @"Should return the correct object.");

    NSString *testStr2 = @"R";
    XCTAssertNoThrow([testStem appendChild:testStr2], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testStr2 isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");
    XCTAssertTrue([testStr isEqual:[testStem getFirstChild]], @"Should return the correct object.");
}

- (void)testGetLastChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getLastChild)], @"Should respond to getLastChild");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem getLastChild], @"Should not throw for empty array.");
    XCTAssertTrue(nil == [testStem getLastChild], @"Should return nil for empty array.");

    NSString *testStr = @"Q";
    XCTAssertNoThrow([testStem appendChild:testStr], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");
    XCTAssertTrue([testStr isEqual:[testStem getLastChild]], @"Should return the correct object.");

    NSString *testStr2 = @"R";
    XCTAssertNoThrow([testStem appendChild:testStr2], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testStr2 isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");
    XCTAssertTrue([testStr2 isEqual:[testStem getLastChild]], @"Should return the correct object.");
}

- (void)testGetPrevSiblingForChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getPreviousSiblingForChild:)], @"Should respond to getPrevSiblingForChild:");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    NSString *testStr = @"Q";
    XCTAssertNoThrow([testStem getPreviousSiblingForChild:testStr], @"Should not throw for empty array.");
    XCTAssertNil([testStem getPreviousSiblingForChild:testStr], @"Should return nil for empty array.");

    XCTAssertNoThrow([testStem appendChild:testStr], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem getPreviousSiblingForChild:testStr], @"Should not throw for first object.");
    XCTAssertNil([testStem getPreviousSiblingForChild:testStr], @"Should return nil for first Object.");

    NSString *testStr2 = @"R";
    XCTAssertNoThrow([testStem getPreviousSiblingForChild:testStr2], @"Should not throw for missing object.");
    XCTAssertNil([testStem getPreviousSiblingForChild:testStr2], @"Should return nil for missing Object.");

    XCTAssertNoThrow([testStem appendChild:testStr2], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testStr2 isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem getPreviousSiblingForChild:testStr2], @"Should not throw for second object.");
    XCTAssertNotNil([testStem getPreviousSiblingForChild:testStr2], @"Should not return nil for second Object.");
    XCTAssertEqual(testStr, [testStem getPreviousSiblingForChild:testStr2], @"Should return correct object.");
}

- (void)testGetNextSiblingForChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getNextSiblingForChild:)], @"Should respond to getNextSiblingForChild:");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    NSString *testStr = @"Q";
    XCTAssertNoThrow([testStem getNextSiblingForChild:testStr], @"Should not throw for empty array.");
    XCTAssertNil([testStem getNextSiblingForChild:testStr], @"Should return nil for empty array.");

    XCTAssertNoThrow([testStem appendChild:testStr], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem getNextSiblingForChild:testStr], @"Should not throw for last object.");
    XCTAssertNil([testStem getNextSiblingForChild:testStr], @"Should return nil for last Object.");

    NSString *testStr2 = @"R";
    XCTAssertNoThrow([testStem getNextSiblingForChild:testStr2], @"Should not throw for missing object.");
    XCTAssertNil([testStem getNextSiblingForChild:testStr2], @"Should return nil for missing Object.");

    XCTAssertNoThrow([testStem appendChild:testStr2], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testStr2 isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem getNextSiblingForChild:testStr], @"Should not throw for first object.");
    XCTAssertNotNil([testStem getNextSiblingForChild:testStr], @"Should not return nil for first Object.");
    XCTAssertEqual(testStr2, [testStem getNextSiblingForChild:testStr], @"Should return correct object.");
}

- (void)testGetLastDescendent
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getLastDescendent)], @"Should respond to getLastDescendent.");

    testStem.renderArray = nil;
    id testDescendent;
    XCTAssertNoThrow(testDescendent = [testStem getLastDescendent], @"Should not throw for nil renderArray.");
    XCTAssertNil(testDescendent, @"Should return nil for nil renderArray.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow(testDescendent = [testStem getLastDescendent], @"Should not throw for empty array.");
    XCTAssertNil(testDescendent, @"Should return nil for empty descendent.");

    EQRenderData *renderData1 = [[EQRenderData alloc] initWithString:@"Foo"];
    [testStem appendChild:renderData1];
    XCTAssertNoThrow(testDescendent = [testStem getLastDescendent], @"Should not throw for valid renderArray.");
    XCTAssertEqual(testDescendent, renderData1, @"Input should match output.");

    EQRenderData *renderData2 = [[EQRenderData alloc] initWithString:@"Bar"];
    [testStem appendChild:renderData2];
    XCTAssertNoThrow(testDescendent = [testStem getLastDescendent], @"Should not throw for valid renderArray.");
    XCTAssertEqual(testDescendent, renderData2, @"Input should match output.");

    EQRenderStem *renderStem = [[EQRenderStem alloc] init];
    renderStem.stemType = stemTypeSup;
    EQRenderData *firstChild = [[EQRenderData alloc] initWithString:@"x"];
    EQRenderData *secondChild = [[EQRenderData alloc] initWithString:@"2"];
    [renderStem appendChild:firstChild];
    [renderStem appendChild:secondChild];
    [testStem appendChild:renderStem];
    XCTAssertNoThrow(testDescendent = [testStem getLastDescendent], @"Should not throw for valid renderArray.");
    XCTAssertEqual(testDescendent, secondChild, @"Input should match output.");
}

- (void)testLayoutChildren
{
    XCTAssertTrue([testStem respondsToSelector:@selector(layoutChildren)], @"Should respond to layoutChildren");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");
    XCTAssertNoThrow([testStem layoutChildren], @"Should not throw for empty renderArray.");

    NSString *testStr = @"Q";
    XCTAssertNoThrow([testStem appendChild:testStr], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testStr isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem layoutChildren], @"Should not throw with no valid draw objects.");
    CGRect defaultRect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    XCTAssertTrue(CGRectEqualToRect(defaultRect, testStem.drawBounds), @"Should have default size with no valid draw objects.");

    XCTAssertNoThrow([testStem removeChild:testStr], @"Should not throw for valid object.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@"QWERTY UIOP"];
    XCTAssertNoThrow([testStem appendChild:testData], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testData isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");
    testData.boundingRectImage = [testData imageBounds];
    testData.boundingRectTypographic = [testData typographicBounds];

    XCTAssertTrue(CGRectEqualToRect(defaultRect, testStem.drawBounds), @"Should have default size with no layout performed.");
    XCTAssertNoThrow([testStem layoutChildren], @"Should not throw for valid renderArray.");
    XCTAssertFalse(CGRectEqualToRect(defaultRect, testStem.drawBounds), @"Should not have default size after layout is performed.");
    XCTAssertTrue(CGRectEqualToRect(testData.boundingRectTypographic, testStem.drawBounds), @"Should match the typographic bounds in this case.");

    EQRenderStem *testChildStem = [[EQRenderStem alloc] init];
    testChildStem.stemType = stemTypeSup;

    EQRenderData *testBaseData = [[EQRenderData alloc] initWithString:@"x"];
    testBaseData.boundingRectImage = [testBaseData imageBounds];
    testBaseData.boundingRectTypographic = [testBaseData typographicBounds];
    [testChildStem appendChild:testBaseData];

    EQRenderData *testSupData = [[EQRenderData alloc] initWithString:@"2"];
    testSupData.boundingRectImage = [testSupData imageBounds];
    testSupData.boundingRectTypographic = [testSupData typographicBounds];
    [testChildStem appendChild:testSupData];

    XCTAssertNoThrow([testStem appendChild:testChildStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testChildStem isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");

    // Test subsup as well.
    EQRenderStem *testChildSubSupStem = [[EQRenderStem alloc] init];
    testChildSubSupStem.stemType = stemTypeSubSup;

    EQRenderData *testBaseData2 = [[EQRenderData alloc] initWithString:@"x"];
    testBaseData2.boundingRectImage = [testBaseData2 imageBounds];
    testBaseData2.boundingRectTypographic = [testBaseData2 typographicBounds];
    [testChildSubSupStem appendChild:testBaseData2];

    EQRenderData *testSupData2 = [[EQRenderData alloc] initWithString:@"2"];
    testSupData2.boundingRectImage = [testSupData imageBounds];
    testSupData2.boundingRectTypographic = [testSupData typographicBounds];
    [testChildSubSupStem appendChild:testSupData2];

    EQRenderData *testSubData = [[EQRenderData alloc] initWithString:@"1"];
    testSubData.boundingRectImage = [testSubData imageBounds];
    testSubData.boundingRectTypographic = [testSubData typographicBounds];
    [testChildSubSupStem appendChild:testSubData];

    XCTAssertNoThrow([testStem appendChild:testChildSubSupStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 3, @"Should have added object to array.");
    XCTAssertTrue([testChildSubSupStem isEqual:[testStem.renderArray objectAtIndex:2]], @"Should have inserted the same object.");

    // Test under with large op.
    EQRenderStem *testChildUnderStem = [[EQRenderStem alloc] init];
    testChildUnderStem.stemType = stemTypeUnder;

    EQRenderData *testUnderBase1 = [[EQRenderData alloc] initWithString:@"∑"];
    testUnderBase1.boundingRectImage = [testUnderBase1 imageBounds];
    testUnderBase1.boundingRectTypographic = [testUnderBase1 typographicBounds];
    [testChildUnderStem appendChild:testUnderBase1];
    testChildUnderStem.hasLargeOp = YES;

    EQRenderData *testUnderSub1 = [[EQRenderData alloc] initWithString:@"i = 0"];
    testUnderSub1.boundingRectImage = [testUnderSub1 imageBounds];
    testUnderSub1.boundingRectTypographic = [testUnderSub1 typographicBounds];
    [testChildUnderStem appendChild:testUnderSub1];

    XCTAssertNoThrow([testStem appendChild:testChildUnderStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 4, @"Should have added object to array.");
    XCTAssertTrue([testChildUnderStem isEqual:[testStem.renderArray objectAtIndex:3]], @"Should have inserted the same object.");

    // Test over with large op.
    EQRenderStem *testChildOverStem = [[EQRenderStem alloc] init];
    testChildOverStem.stemType = stemTypeOver;

    EQRenderData *testOverBase1 = [[EQRenderData alloc] initWithString:@"∑"];
    testOverBase1.boundingRectImage = [testOverBase1 imageBounds];
    testOverBase1.boundingRectTypographic = [testOverBase1 typographicBounds];
    [testChildOverStem appendChild:testOverBase1];
    testChildOverStem.hasLargeOp = YES;

    EQRenderData *testOverSub1 = [[EQRenderData alloc] initWithString:@"i = 0"];
    testOverSub1.boundingRectImage = [testOverSub1 imageBounds];
    testOverSub1.boundingRectTypographic = [testOverSub1 typographicBounds];
    [testChildOverStem appendChild:testOverSub1];

    XCTAssertNoThrow([testStem appendChild:testChildOverStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 5, @"Should have added object to array.");
    XCTAssertTrue([testChildOverStem isEqual:[testStem.renderArray objectAtIndex:4]], @"Should have inserted the same object.");

    // Test underover with large op.
    EQRenderStem *testChildUnderOverStem = [[EQRenderStem alloc] init];
    testChildUnderOverStem.stemType = stemTypeUnderOver;

    EQRenderData *testUnderOverBase1 = [[EQRenderData alloc] initWithString:@"∑"];
    testUnderOverBase1.boundingRectImage = [testUnderOverBase1 imageBounds];
    testUnderOverBase1.boundingRectTypographic = [testUnderOverBase1 typographicBounds];
    [testChildUnderOverStem appendChild:testUnderOverBase1];
    testChildUnderOverStem.hasLargeOp = YES;

    EQRenderData *testUnderOverSub1 = [[EQRenderData alloc] initWithString:@"i = 0"];
    testUnderOverSub1.boundingRectImage = [testUnderOverSub1 imageBounds];
    testUnderOverSub1.boundingRectTypographic = [testUnderOverSub1 typographicBounds];
    [testChildUnderOverStem appendChild:testUnderOverSub1];

    EQRenderData *testUnderOverSub2 = [[EQRenderData alloc] initWithString:@"n"];
    testUnderOverSub2.boundingRectImage = [testUnderOverSub2 imageBounds];
    testUnderOverSub2.boundingRectTypographic = [testUnderOverSub2 typographicBounds];
    [testChildUnderOverStem appendChild:testUnderOverSub2];

    XCTAssertNoThrow([testStem appendChild:testChildUnderOverStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 6, @"Should have added object to array.");
    XCTAssertTrue([testChildUnderOverStem isEqual:[testStem.renderArray objectAtIndex:5]], @"Should have inserted the same object.");

    // Test the whole shebang at once.
    XCTAssertTrue(CGRectEqualToRect(testData.boundingRectTypographic, testStem.drawBounds), @"Should match the previous bounds before new layout.");
    XCTAssertNoThrow([testStem layoutChildren], @"Should not throw for valid renderArray.");
    XCTAssertFalse(CGRectEqualToRect(defaultRect, testStem.drawBounds), @"Should not have default size after layout is performed.");
    XCTAssertFalse(CGRectEqualToRect(testData.boundingRectTypographic, testStem.drawBounds), @"Should not match the typographic bounds in this case.");
}

- (void)testUseSmallFontForChild
{
    XCTAssertTrue([testStem respondsToSelector:@selector(useSmallFontForChild:)], @"Should respond to useSmallFontForChild: method.");

    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeSup, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    EQRenderData *testBase = [[EQRenderData alloc] initWithString:@"Q"];
    XCTAssertNoThrow([testStem useSmallFontForChild:testBase], @"Should not throw for empty renderArray.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testBase], @"Should return NO for empty renderArray.");

    XCTAssertNoThrow([testStem appendChild:testBase], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testBase isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem useSmallFontForChild:nil], @"Should not throw for nil object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:nil], @"Should return NO for nil object.");

    XCTAssertNoThrow([testStem useSmallFontForChild:@"R"], @"Should not throw for missing object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:@"R"], @"Should return NO for missing object.");

    XCTAssertNoThrow([testStem useSmallFontForChild:testBase], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testBase], @"Should return NO for base object.");

    // Test for sup stem.
    EQRenderData *testSup = [[EQRenderData alloc] initWithString:@"2"];
    XCTAssertNoThrow([testStem appendChild:testSup], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testSup isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");

    XCTAssertNoThrow([testStem useSmallFontForChild:testSup], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testStem useSmallFontForChild:testSup], @"Should return YES for sup object.");

    XCTAssertNoThrow(testStem.stemType = stemTypeSub, @"Should not throw for setStemType:");
    XCTAssertNoThrow([testStem useSmallFontForChild:testBase], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testBase], @"Should return NO for base object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testSup], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testStem useSmallFontForChild:testSup], @"Should return YES for sup object.");

    // Test for root type change.
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertNoThrow([testStem useSmallFontForChild:testBase], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testBase], @"Should return NO for base object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testSup], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testSup], @"Should return NO for sup object.");

    // Test for subsup stem.
    EQRenderData *testSub = [[EQRenderData alloc] initWithString:@"z"];
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeSubSup, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    // Build and test the subsup object.
    XCTAssertNoThrow([testStem insertChild:testBase atLoc:0], @"Should not throw for insertChild:AtLoc:");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testBase isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");
    XCTAssertNoThrow([testStem insertChild:testSub atLoc:1], @"Should not throw for insertChild:AtLoc:");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testSub isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");
    XCTAssertNoThrow([testStem insertChild:testSup atLoc:2], @"Should not throw for insertChild:AtLoc:");
    XCTAssertTrue(testStem.renderArray.count == 3, @"Should have added object to array.");
    XCTAssertTrue([testSup isEqual:[testStem.renderArray objectAtIndex:2]], @"Should have inserted the same object.");

    // Test the results.
    XCTAssertNoThrow([testStem useSmallFontForChild:testBase], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testBase], @"Should return NO for base object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testSup], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testStem useSmallFontForChild:testSup], @"Should return YES for sup object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testSub], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testStem useSmallFontForChild:testSub], @"Should return YES for sub object.");

    // Nest the stem in another sup
    EQRenderStem *parentStem = [[EQRenderStem alloc] init];
    parentStem.stemType = stemTypeSup;
    EQRenderData *testBase2 = [[EQRenderData alloc] initWithString:@"A"];
    XCTAssertNoThrow([parentStem appendChild:testBase2], @"Should not throw for valid object.");
    XCTAssertTrue(parentStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testBase2 isEqual:[parentStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");
    XCTAssertNoThrow([parentStem appendChild:testStem], @"Should not throw for valid object.");
    XCTAssertTrue(parentStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testStem isEqual:[parentStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");

    // Test the results.
    XCTAssertNoThrow([parentStem useSmallFontForChild:testBase2], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [parentStem useSmallFontForChild:testBase2], @"Should return NO for base object.");
    XCTAssertNoThrow([parentStem useSmallFontForChild:testStem], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [parentStem useSmallFontForChild:testStem], @"Should return YES for sup object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testBase], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testStem useSmallFontForChild:testBase], @"Should return YES for base object in nested stem.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testSup], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testStem useSmallFontForChild:testSup], @"Should return YES for sup object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testSub], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testStem useSmallFontForChild:testSub], @"Should return YES for sub object.");
}

- (void)testUseSmallFontUnderOver
{
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    // Test under with large op.
    EQRenderStem *testChildUnderStem = [[EQRenderStem alloc] init];
    testChildUnderStem.stemType = stemTypeUnder;

    EQRenderData *testUnderBase1 = [[EQRenderData alloc] initWithString:@"∑"];
    [testChildUnderStem appendChild:testUnderBase1];
    testChildUnderStem.hasLargeOp = YES;

    EQRenderData *testUnderSub1 = [[EQRenderData alloc] initWithString:@"i = 0"];
    [testChildUnderStem appendChild:testUnderSub1];

    XCTAssertNoThrow([testStem appendChild:testChildUnderStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have added object to array.");
    XCTAssertTrue([testChildUnderStem isEqual:[testStem.renderArray objectAtIndex:0]], @"Should have inserted the same object.");

    // Test small font for under stem.
    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should return NO for base object.");
    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should return YES for stem object.");

    // Test over with large op.
    EQRenderStem *testChildOverStem = [[EQRenderStem alloc] init];
    testChildOverStem.stemType = stemTypeOver;

    EQRenderData *testOverBase1 = [[EQRenderData alloc] initWithString:@"∑"];
    [testChildOverStem appendChild:testOverBase1];
    testChildOverStem.hasLargeOp = YES;

    EQRenderData *testOverSub1 = [[EQRenderData alloc] initWithString:@"i = 0"];
    [testChildOverStem appendChild:testOverSub1];

    XCTAssertNoThrow([testStem appendChild:testChildOverStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should have added object to array.");
    XCTAssertTrue([testChildOverStem isEqual:[testStem.renderArray objectAtIndex:1]], @"Should have inserted the same object.");

    // Test small font for over stem.
    XCTAssertNoThrow([testChildOverStem useSmallFontForChild:testOverBase1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildOverStem useSmallFontForChild:testOverBase1], @"Should return NO for base object.");
    XCTAssertNoThrow([testChildOverStem useSmallFontForChild:testOverSub1], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testChildOverStem useSmallFontForChild:testOverSub1], @"Should return YES for stem object.");

    // Test underover with large op.
    EQRenderStem *testChildUnderOverStem = [[EQRenderStem alloc] init];
    testChildUnderOverStem.stemType = stemTypeUnderOver;

    EQRenderData *testUnderOverBase1 = [[EQRenderData alloc] initWithString:@"∑"];
    [testChildUnderOverStem appendChild:testUnderOverBase1];
    testChildUnderOverStem.hasLargeOp = YES;

    EQRenderData *testUnderOverSub1 = [[EQRenderData alloc] initWithString:@"i = 0"];
    [testChildUnderOverStem appendChild:testUnderOverSub1];

    EQRenderData *testUnderOverSub2 = [[EQRenderData alloc] initWithString:@"n"];
    [testChildUnderOverStem appendChild:testUnderOverSub2];

    XCTAssertNoThrow([testStem appendChild:testChildUnderOverStem], @"Should not throw for append object.");
    XCTAssertTrue(testStem.renderArray.count == 3, @"Should have added object to array.");
    XCTAssertTrue([testChildUnderOverStem isEqual:[testStem.renderArray objectAtIndex:2]], @"Should have inserted the same object.");

    // Test small font for underover stem.
    XCTAssertNoThrow([testChildUnderOverStem useSmallFontForChild:testUnderOverBase1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderOverStem useSmallFontForChild:testUnderOverBase1], @"Should return NO for base object.");
    XCTAssertNoThrow([testChildUnderOverStem useSmallFontForChild:testUnderOverSub1], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testChildUnderOverStem useSmallFontForChild:testUnderOverSub1], @"Should return YES for stem object.");
    XCTAssertNoThrow([testChildUnderOverStem useSmallFontForChild:testUnderOverSub2], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testChildUnderOverStem useSmallFontForChild:testUnderOverSub2], @"Should return YES for stem object.");

    // Test the root as well.
    XCTAssertNoThrow([testStem useSmallFontForChild:testChildUnderStem], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testChildUnderStem], @"Should return NO for stem object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testChildOverStem], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testChildOverStem], @"Should return NO for stem object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testChildUnderOverStem], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testChildUnderOverStem], @"Should return NO for stem object.");

    // Test nested stems.
    EQRenderStem *testSup = [[EQRenderStem alloc] init];
    testSup.stemType = stemTypeSup;
    EQRenderData *testSupBase = [[EQRenderData alloc] initWithString:@"x"];
    EQRenderData *testSupChild = [[EQRenderData alloc] initWithString:@"2"];
    [testSup appendChild:testSupBase];
    [testSup appendChild:testSupChild];
    XCTAssertTrue(testSup.renderArray.count == 2, @"Should have added 2 children.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupBase], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testSup useSmallFontForChild:testSupBase], @"Should return NO for base object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupChild], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupChild], @"Should return YES for stem object.");

    // Add test stem to row.
    // Test that it doesn't use small yet.
    EQRenderStem *testRow = [[EQRenderStem alloc] init];
    testRow.stemType = stemTypeRow;
    [testRow appendChild:testSup];
    XCTAssertTrue(testRow.renderArray.count == 1, @"Should have added 1 child.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupBase], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testSup useSmallFontForChild:testSupBase], @"Should return NO for base object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupChild], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupChild], @"Should return YES for stem object.");

    // Test that under stem is still the same as it was.
    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should return NO for base object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testChildUnderStem], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testChildUnderStem], @"Should return NO for stem object.");
    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should return YES for stem object.");

    [testChildUnderStem setChild:testRow atLoc:1];

    // Test that should use small font has been updated to reflect new layout.
    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should return NO for base object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testChildUnderStem], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testChildUnderStem], @"Should return NO for stem object.");

    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should return NO for updated stem object.");
    XCTAssertTrue(YES == [testChildUnderStem useSmallFontForChild:testRow], @"Should return YES for stem object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupBase], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupBase], @"Should return YES for updated stem object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupChild], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupChild], @"Should return YES for stem object.");

    // Change the stem types rather than rebuilding the whole thing.
    // Over type should behave the same as under type.
    testChildUnderStem.stemType = stemTypeOver;
    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should return NO for base object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testChildUnderStem], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testChildUnderStem], @"Should return NO for stem object.");

    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should return NO for updated stem object.");
    XCTAssertTrue(YES == [testChildUnderStem useSmallFontForChild:testRow], @"Should return YES for stem object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupBase], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupBase], @"Should return YES for updated stem object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupChild], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupChild], @"Should return YES for stem object.");

    // Change the stem types rather than rebuilding the whole thing.
    // UnderOver type should behave the same as under type.
    testChildUnderStem.stemType = stemTypeUnderOver;
    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderBase1], @"Should return NO for base object.");
    XCTAssertNoThrow([testStem useSmallFontForChild:testChildUnderStem], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testStem useSmallFontForChild:testChildUnderStem], @"Should return NO for stem object.");

    XCTAssertNoThrow([testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should not throw for valid object.");
    XCTAssertTrue(NO == [testChildUnderStem useSmallFontForChild:testUnderSub1], @"Should return NO for updated stem object.");
    XCTAssertTrue(YES == [testChildUnderStem useSmallFontForChild:testRow], @"Should return YES for stem object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupBase], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupBase], @"Should return YES for updated stem object.");
    XCTAssertNoThrow([testSup useSmallFontForChild:testSupChild], @"Should not throw for valid object.");
    XCTAssertTrue(YES == [testSup useSmallFontForChild:testSupChild], @"Should return YES for stem object.");
}

- (void)testIsRowStemType
{
    XCTAssertTrue([testStem respondsToSelector:@selector(isRowStemType)], @"Should respond to isRowStemType method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow(testStem.stemType = stemTypeUnassigned, @"Should not throw for setStemType:");
    XCTAssertFalse([testStem isRowStemType], @"Should be false for unassigned stem type.");

    XCTAssertNoThrow(testStem.stemType = stemTypeRow, @"Should not throw for setStemType:");
    XCTAssertTrue([testStem isRowStemType], @"Should be true for row stem type.");

    XCTAssertNoThrow(testStem.stemType = stemTypeRoot, @"Should not throw for setStemType:");
    XCTAssertTrue([testStem isRowStemType], @"Should be true for root stem type.");
}

- (void)testGetInitialCursorLoc
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getInitialCursorLoc)], @"Should respond to getInitialCursorLoc method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertTrue(0 == [testStem getInitialCursorLoc], @"Should return 0 for unassigned stem.");

    testStem.stemType = stemTypeSup;
    XCTAssertTrue(1 == [testStem getInitialCursorLoc], @"Should return 1 for sup stem.");

    testStem.stemType = stemTypeSub;
    XCTAssertTrue(1 == [testStem getInitialCursorLoc], @"Should return 1 for sub stem.");

    testStem.stemType = stemTypeFraction;
    XCTAssertTrue(0 == [testStem getInitialCursorLoc], @"Should return 0 for frac stem.");
}

- (void)testGetLastCursorLoc
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getLastCursorLoc)], @"Should respond to getLastCursorLoc method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertTrue(NSNotFound == [testStem getLastCursorLoc], @"Should return not found for empty data.");
    [testStem appendChild:@"foo"];

    XCTAssertTrue(0 == [testStem getLastCursorLoc], @"Should return 0 for unassigned stem if element count is 1.");

    testStem.stemType = stemTypeSup;
    XCTAssertTrue(0 == [testStem getLastCursorLoc], @"Should return 0 for sup stem if element count is 1.");

    testStem.stemType = stemTypeSub;
    XCTAssertTrue(0 == [testStem getLastCursorLoc], @"Should return 0 for sub stem if element count is 1.");

    testStem.stemType = stemTypeFraction;
    XCTAssertTrue(0 == [testStem getLastCursorLoc], @"Should return 0 for frac stem if element count is 1.");

    [testStem appendChild:@"foo1"];

    XCTAssertTrue(1 == [testStem getLastCursorLoc], @"Should return 1 for unassigned stem if element count is 2.");

    testStem.stemType = stemTypeSup;
    XCTAssertTrue(1 == [testStem getLastCursorLoc], @"Should return 1 for sup stem if element count is 2.");

    testStem.stemType = stemTypeSub;
    XCTAssertTrue(1 == [testStem getLastCursorLoc], @"Should return 1 for sub stem if element count is 2.");

    testStem.stemType = stemTypeFraction;
    XCTAssertTrue(1 == [testStem getLastCursorLoc], @"Should return 1 for frac stem if element count is 2.");
}

// updateBounds is called by layout children, so is already covered by those tests.
- (void)testUpdateBounds
{
    XCTAssertTrue([testStem respondsToSelector:@selector(updateBounds)], @"Should respond to updateBounds method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem updateBounds], @"Should not throw for empty stem.");
    XCTAssertTrue(CGRectEqualToRect(testStem.drawBounds, CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)), @"Should return default rect size for empty render.");
    XCTAssertTrue(CGSizeEqualToSize(testStem.drawSize, CGSizeMake(20.0f, 20.0f)), @"Should return default size for empty render.");
}

- (void)testGetFractionBarParent
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getFractionBarParent)], @"Should respond to getFractionBarParent method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    EQRenderFracStem *testFracParent = [[EQRenderFracStem alloc] init];
    [testFracParent appendChild:testStem];
    XCTAssertEqual(testFracParent, [testStem getFractionBarParent], @"Should return parent when parent is a fraction.");
    [testFracParent removeChild:testStem];

    EQRenderStem *testParent1 = [[EQRenderStem alloc] init];
    testParent1.stemType = stemTypeRow;
    [testParent1 appendChild:testStem];
    XCTAssertNil([testStem getFractionBarParent], @"Should return nil for non-fraction parent.");

    EQRenderStem *testParent2 = [[EQRenderStem alloc] init];
    testParent2.stemType = stemTypeFraction;
    [testParent2 appendChild:testParent1];
    XCTAssertEqual(testParent2, [testStem getFractionBarParent], @"Should return parent of parent when parent is mrow in num or denom.");

    testParent2.stemType = stemTypeRow;
    XCTAssertNil([testStem getFractionBarParent], @"Should return nil if ancestor does not have a fraction.");

    EQRenderFracStem *testParent3 = [[EQRenderFracStem alloc] initWithObject:testParent2];
    XCTAssertEqual(testParent3, [testStem getFractionBarParent], @"Should return ancestor when ancestor is fraction and parents are rows.");
}

- (void)testShouldUseSmaller
{
    XCTAssertTrue([testStem respondsToSelector:@selector(shouldUseSmaller)], @"Should respond to shouldUseSmaller method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertTrue(testStem.parentStem == nil, @"Should have a nil parent on init.");
    XCTAssertTrue(testStem.shouldUseSmaller == NO, @"Should return NO if parent is nil.");

    EQRenderStem *testStem2;
    XCTAssertNoThrow(testStem2 = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem2.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem2 appendChild:testStem], @"Should not throw when adding child.");
    XCTAssertFalse(testStem.parentStem == nil, @"Should have set parent stem.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have no children set.");
    XCTAssertTrue(testStem.shouldUseSmaller == NO, @"Should return no, if no children are set.");

    // Remaining tests are done by testUseSmallFontForChild as this method calls that.
}

- (void)testShouldUseSmallest
{
    XCTAssertTrue([testStem respondsToSelector:@selector(shouldUseSmallest)], @"Should respond to shouldUseSmallest method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertTrue(testStem.parentStem == nil, @"Should have a nil parent on init.");
    XCTAssertTrue(testStem.shouldUseSmallest == NO, @"Should return NO if parent is nil.");

    EQRenderStem *testStem2;
    XCTAssertNoThrow(testStem2 = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem2.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem2 appendChild:testStem], @"Should not throw when adding child.");
    XCTAssertFalse(testStem.parentStem == nil, @"Should have set parent stem.");
    XCTAssertTrue(testStem.parentStem.parentStem == nil, @"Should not have set parent of parent stem.");
    XCTAssertTrue(testStem.shouldUseSmallest == NO, @"Should return no, if no parent of parent is set.");

    EQRenderStem *testStem3;
    XCTAssertNoThrow(testStem3 = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem3.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem3 appendChild:testStem2], @"Should not throw when adding child.");
    XCTAssertFalse(testStem.parentStem == nil, @"Should have set parent stem.");
    XCTAssertFalse(testStem.parentStem.parentStem == nil, @"Should have set parent of parent stem.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have no children set.");
    XCTAssertTrue(testStem.shouldUseSmallest == NO, @"Should return no, if no children are set.");

    // Remaining tests are done by testUseSmallFontForChild as this method calls that.
}

- (void)testHasChildType
{
    XCTAssertTrue([testStem respondsToSelector:@selector(hasChildType:)], @"Should respond to hasChildType: method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertFalse([testStem hasChildType:stemTypeUnassigned], @"Should return FALSE when array is empty.");

    EQRenderStem *testStem2 = [[EQRenderStem alloc] init];
    XCTAssertNoThrow([testStem appendChild:testStem2], @"Should not throw when adding child.");
    XCTAssertTrue([testStem hasChildType:testStem2.stemType], @"Should find type of added stem child.");
    testStem2.stemType = stemTypeRow;
    XCTAssertFalse([testStem hasChildType:stemTypeUnassigned], @"Should return FALSE if stem type does not match.");
    XCTAssertTrue([testStem hasChildType:stemTypeRow], @"Should return TRUE if stem type matches child.");

    EQRenderStem *testStem3 = [[EQRenderStem alloc] init];
    XCTAssertNoThrow([testStem2 appendChild:testStem3], @"Should not throw when adding child.");
    XCTAssertTrue([testStem hasChildType:stemTypeUnassigned], @"Should return TRUE if stem type matches child of row.");

    testStem3.stemType = stemTypeSup;
    XCTAssertFalse([testStem hasChildType:stemTypeUnassigned], @"Should return FALSE if stem type does not match.");
}

- (void)testShouldIgnoreDescent
{
    XCTAssertTrue([testStem respondsToSelector:@selector(shouldIgnoreDescent)], @"Should respond to shouldIgnoreDescent method.");
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertFalse([testStem shouldIgnoreDescent], @"Should return FALSE for unassigned type.");

    // Only valid for nested sups and subsups with level > 2.
    testStem.stemType = stemTypeSup;
    XCTAssertFalse([testStem shouldIgnoreDescent], @"Should return FALSE for stemTypeSup.");

    testStem.stemType = stemTypeRow;
    XCTAssertFalse([testStem shouldIgnoreDescent], @"Should return FALSE for row type if it has no children.");

    // Only valid for nested sups and subsups with level > 2.
    EQRenderStem *testStem2 = [[EQRenderStem alloc] init];
    testStem2.stemType = stemTypeSup;
    XCTAssertNoThrow([testStem appendChild:testStem2], @"Should not throw when adding child.");
    XCTAssertFalse([testStem shouldIgnoreDescent], @"Should return FALSE for row type if it has sup children.");
}

- (void)testThatEmptySupsDoNotCauseException
{
    XCTAssertNoThrow(testStem = [[EQRenderStem alloc] init], @"Should not throw for empty init.");
    XCTAssertNoThrow(testStem.stemType = stemTypeSup, @"Should not throw for setStemType:");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have zero children to start.");

    EQRenderData *baseChild = [[EQRenderData alloc] initWithString:@""];
    EQRenderData *supChild = [[EQRenderData alloc] initWithString:@"2"];

    XCTAssertNoThrow([testStem appendChild:baseChild], @"Should not throw when adding child.");
    XCTAssertNoThrow([testStem appendChild:supChild], @"Should not throw when adding child.");
    XCTAssertNoThrow([testStem layoutChildren], @"Should not throw when laying out base child with empty string.");
}

// Testing for basic support as this sort of thing is only used in a few methods.

- (void)testHasSupplementalLineProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(hasSupplementalLine)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setHasSupplementalLine:)], @"Should respond to set: method.");

    XCTAssertTrue(testStem.hasSupplementalLine == FALSE, @"Should initialize to false.");
    XCTAssertNoThrow(testStem.hasSupplementalLine = TRUE, @"Should allow you to set hasSupplementalLine.");
    XCTAssertTrue(testStem.hasSupplementalLine == TRUE, @"Input should match output.");

    XCTAssertNoThrow(testStem.hasSupplementalLine = FALSE, @"Should allow you to set hasSupplementalLine.");
    XCTAssertTrue(testStem.hasSupplementalLine == FALSE, @"Input should match output.");
}

- (void)testSupplementalLineStartPointProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(supplementalLineStartPoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setSupplementalLineStartPoint:)], @"Should respond to set: method.");

    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, testStem.supplementalLineStartPoint), @"Should initialize to pointZero.");
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    XCTAssertNoThrow(testStem.supplementalLineStartPoint = testPoint, @"Should allow you to set supplementalLineStartPoint.");
    XCTAssertTrue(CGPointEqualToPoint(testPoint, testStem.supplementalLineStartPoint), @"Input should match output.");
}

- (void)testSupplementalLineEndPointProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(supplementalLineEndPoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setSupplementalLineEndPoint:)], @"Should respond to set: method.");

    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, testStem.supplementalLineEndPoint), @"Should initialize to pointZero.");
    CGPoint testPoint = CGPointMake(42.0, 42.0);
    XCTAssertNoThrow(testStem.supplementalLineEndPoint = testPoint, @"Should allow you to set supplementalLineEndPoint.");
    XCTAssertTrue(CGPointEqualToPoint(testPoint, testStem.supplementalLineEndPoint), @"Input should match output.");
}

- (void)testShiftLayoutHorizontally
{
    XCTAssertTrue([testStem respondsToSelector:@selector(shiftLayoutHorizontally:)], @"Should respond to selector.");
    EQRenderData *baseChild = [[EQRenderData alloc] initWithString:@"x"];
    EQRenderData *supChild = [[EQRenderData alloc] initWithString:@"2"];
    testStem.stemType = stemTypeSup;
    [testStem appendChild:baseChild];
    [testStem appendChild:supChild];

    CGPoint testOrigin = CGPointMake(40.0, 40.0);
    testStem.drawOrigin = testOrigin;
    [testStem layoutChildren];
    CGPoint baseTestOrigin = baseChild.drawOrigin;
    CGPoint supTestOrigin = supChild.drawOrigin;
    CGFloat xAdjust = 4.0;

    XCTAssertNoThrow([testStem shiftLayoutHorizontally:xAdjust], @"Should not throw when calling method.");
    XCTAssertFalse(CGPointEqualToPoint(testOrigin, testStem.drawOrigin), @"Should have moved the stem origin.");
    XCTAssertFalse(CGPointEqualToPoint(baseTestOrigin, baseChild.drawOrigin), @"Should have moved base child origin.");
    XCTAssertFalse(CGPointEqualToPoint(supTestOrigin, supChild.drawOrigin), @"Should have moved sup child origin.");

    XCTAssertTrue((testOrigin.x + xAdjust) == testStem.drawOrigin.x, @"Should have moved by the xAdjust amount.");
    XCTAssertTrue(testOrigin.y == testStem.drawOrigin.y, @"Should not have moved the yOrigin point.");

    XCTAssertTrue((baseTestOrigin.x + xAdjust) == baseChild.drawOrigin.x, @"Should have moved by the xAdjust amount.");
    XCTAssertTrue(baseTestOrigin.y == baseChild.drawOrigin.y, @"Should not have moved the yOrigin point.");

    XCTAssertTrue((supTestOrigin.x + xAdjust) == supChild.drawOrigin.x, @"Should have moved by the xAdjust amount.");
    XCTAssertTrue(supTestOrigin.y == supChild.drawOrigin.y, @"Should not have moved the yOrigin point.");
}

- (void)testShiftChildrenHorizontally
{
    XCTAssertTrue([testStem respondsToSelector:@selector(shiftChildrenHorizontally:)], @"Should respond to selector.");

    EQRenderData *baseChild = [[EQRenderData alloc] initWithString:@"x"];
    EQRenderData *supChild = [[EQRenderData alloc] initWithString:@"2"];
    testStem.stemType = stemTypeSup;
    [testStem appendChild:baseChild];
    [testStem appendChild:supChild];

    CGPoint testOrigin = CGPointMake(40.0, 40.0);
    testStem.drawOrigin = testOrigin;
    [testStem layoutChildren];
    CGPoint baseTestOrigin = baseChild.drawOrigin;
    CGPoint supTestOrigin = supChild.drawOrigin;
    CGFloat xAdjust = 4.0;

    XCTAssertNoThrow([testStem shiftChildrenHorizontally:xAdjust], @"Should not throw when calling method.");
    XCTAssertTrue(CGPointEqualToPoint(testOrigin, testStem.drawOrigin), @"Should not have moved the stem origin.");
    XCTAssertFalse(CGPointEqualToPoint(baseTestOrigin, baseChild.drawOrigin), @"Should have moved base child origin.");
    XCTAssertFalse(CGPointEqualToPoint(supTestOrigin, supChild.drawOrigin), @"Should have moved sup child origin.");

    XCTAssertTrue(testOrigin.x == testStem.drawOrigin.x, @"Should not have moved by the xAdjust amount.");
    XCTAssertTrue(testOrigin.y == testStem.drawOrigin.y, @"Should not have moved the yOrigin point.");

    XCTAssertTrue((baseTestOrigin.x + xAdjust) == baseChild.drawOrigin.x, @"Should have moved by the xAdjust amount.");
    XCTAssertTrue(baseTestOrigin.y == baseChild.drawOrigin.y, @"Should not have moved the yOrigin point.");

    XCTAssertTrue((supTestOrigin.x + xAdjust) == supChild.drawOrigin.x, @"Should have moved by the xAdjust amount.");
    XCTAssertTrue(supTestOrigin.y == supChild.drawOrigin.y, @"Should not have moved the yOrigin point.");
}

- (void)testComputeLeftAdjustment
{
    XCTAssertTrue([testStem respondsToSelector:@selector(computeLeftAdjustment)], @"Should respond to method call.");
    CGFloat testAdjust;
    XCTAssertNoThrow(testAdjust = [testStem computeLeftAdjustment], @"Should not throw with empty data.");
    XCTAssertTrue(testAdjust == 0.0, @"Should return 0.0 with empty data.");

    EQRenderData *baseChild = [[EQRenderData alloc] initWithString:@"m"];
    EQRenderData *supChild = [[EQRenderData alloc] initWithString:@"2"];
    testStem.stemType = stemTypeSup;
    [testStem appendChild:baseChild];
    [testStem appendChild:supChild];

    XCTAssertNoThrow(testAdjust = [testStem computeLeftAdjustment], @"Should not throw with empty data.");
    XCTAssertTrue(testAdjust == 0.0, @"Should return 0.0 with base m data.");

    EQRenderData *newBaseChild = [[EQRenderData alloc] initWithString:@"a"];
    [testStem setChild:newBaseChild atLoc:0];

    XCTAssertNoThrow(testAdjust = [testStem computeLeftAdjustment], @"Should not throw with empty data.");
    XCTAssertTrue(testAdjust != 0.0, @"Should not return 0.0 with base a data.");
}

- (void)testIsStemWithDescender
{
    XCTAssertTrue([testStem respondsToSelector:@selector(isStemWithDescender)], @"Should respond to method call.");
    XCTAssertNoThrow([testStem isStemWithDescender], @"Should not throw with empty data.");
    XCTAssertFalse(testStem.isStemWithDescender, @"Should be false with initial stem type.");

    testStem.stemType = stemTypeSub;
    XCTAssertFalse(testStem.isStemWithDescender, @"Should be false for this stem type.");

    testStem.stemType = stemTypeSubSup;
    XCTAssertFalse(testStem.isStemWithDescender, @"Should be false for this stem type.");

    testStem.stemType = stemTypeFraction;
    XCTAssertTrue(testStem.isStemWithDescender, @"Should be true for this stem type.");

    testStem.stemType = stemTypeUnder;
    XCTAssertTrue(testStem.isStemWithDescender, @"Should be true for this stem type.");

    testStem.stemType = stemTypeUnderOver;
    XCTAssertTrue(testStem.isStemWithDescender, @"Should be true for this stem type.");
}

- (void)testNestedStretchyBracerCheck
{
    XCTAssertTrue([testStem respondsToSelector:@selector(nestedStretchyBracerCheck)], @"Should respond to method call.");
    XCTAssertTrue([testStem respondsToSelector:@selector(nestedAttributedStretchyBracerCheck)], @"Should respond to method call.");
    NSString *returnStr = @"foo";
    NSAttributedString *returnAttrStr = [[NSAttributedString alloc] initWithString:returnStr];

    XCTAssertNoThrow(returnStr = [testStem nestedStretchyBracerCheck], @"Should not throw with empty data and unassigned stem.");
    XCTAssertNil(returnStr, @"Should return nil with empty data and unassigned stem.");
    XCTAssertNoThrow(returnAttrStr = [testStem nestedAttributedStretchyBracerCheck], @"Should not throw with empty data and unassigned stem.");
    XCTAssertNil(returnAttrStr, @"Should return nil with empty data and unassigned stem.");

    testStem.stemType = stemTypeSup;
    XCTAssertNoThrow(returnStr = [testStem nestedStretchyBracerCheck], @"Should not throw with empty data and valid stem.");
    XCTAssertNil(returnStr, @"Should return nil with empty data and valid stem.");
    XCTAssertNoThrow(returnAttrStr = [testStem nestedAttributedStretchyBracerCheck], @"Should not throw with empty data and valid stem.");
    XCTAssertNil(returnAttrStr, @"Should return nil with empty data and valid stem.");

    NSString *baseStr = @")";
    EQRenderData *baseChild = [[EQRenderData alloc] initWithString:baseStr];
    EQRenderData *supChild = [[EQRenderData alloc] initWithString:@"2"];
    testStem.stemType = stemTypeUnassigned;
    [testStem appendChild:baseChild];
    [testStem appendChild:supChild];

    XCTAssertNoThrow(returnStr = [testStem nestedStretchyBracerCheck], @"Should not throw with valid data and unasssigned stem.");
    XCTAssertNil(returnStr, @"Should return nil with valid data and unassigned stem.");
    XCTAssertNoThrow(returnAttrStr = [testStem nestedAttributedStretchyBracerCheck], @"Should not throw with valid data and unasssigned stem.");
    XCTAssertNil(returnAttrStr, @"Should return nil with valid data and unassigned stem.");

    testStem.stemType = stemTypeSup;
    XCTAssertNoThrow(returnStr = [testStem nestedStretchyBracerCheck], @"Should not throw with valid data and valid stem.");
    XCTAssertNotNil(returnStr, @"Should not return nil with valid data and valid stem.");
    XCTAssertTrue([returnStr isEqualToString:baseStr], @"Should match input string.");
    XCTAssertNoThrow(returnAttrStr = [testStem nestedAttributedStretchyBracerCheck], @"Should not throw with valid data and valid stem.");
    XCTAssertNotNil(returnAttrStr, @"Should not return nil with valid data and valid stem.");
    XCTAssertTrue([returnAttrStr.string isEqualToString:baseStr], @"Should match input string.");

    testStem.stemType = stemTypeSub;
    XCTAssertNoThrow(returnStr = [testStem nestedStretchyBracerCheck], @"Should not throw with valid data and valid stem.");
    XCTAssertNotNil(returnStr, @"Should not return nil with valid data and valid stem.");
    XCTAssertTrue([returnStr isEqualToString:baseStr], @"Should match input string.");
    XCTAssertNoThrow(returnAttrStr = [testStem nestedAttributedStretchyBracerCheck], @"Should not throw with valid data and valid stem.");
    XCTAssertNotNil(returnAttrStr, @"Should not return nil with valid data and valid stem.");
    XCTAssertTrue([returnAttrStr.string isEqualToString:baseStr], @"Should match input string.");

    testStem.stemType = stemTypeSubSup;
    XCTAssertNoThrow(returnStr = [testStem nestedStretchyBracerCheck], @"Should not throw with valid data and valid stem.");
    XCTAssertNotNil(returnStr, @"Should not return nil with valid data and valid stem.");
    XCTAssertTrue([returnStr isEqualToString:baseStr], @"Should match input string.");
    XCTAssertNoThrow(returnAttrStr = [testStem nestedAttributedStretchyBracerCheck], @"Should not throw with valid data and valid stem.");
    XCTAssertNotNil(returnAttrStr, @"Should not return nil with valid data and valid stem.");
    XCTAssertTrue([returnAttrStr.string isEqualToString:baseStr], @"Should match input string.");

    EQRenderData *newBaseChild = [[EQRenderData alloc] initWithString:@"x"];
    [testStem setChild:newBaseChild atLoc:0];

    XCTAssertNoThrow(returnStr = [testStem nestedStretchyBracerCheck], @"Should not throw with no bracer data and valid stem.");
    XCTAssertNil(returnStr, @"Should return nil with not bracer data and valid stem.");
    XCTAssertNoThrow(returnAttrStr = [testStem nestedAttributedStretchyBracerCheck], @"Should not throw with valid data and unasssigned stem.");
    XCTAssertNil(returnAttrStr, @"Should return nil with valid data and unassigned stem.");
}

// Tested already by the renderData unit tests.
- (void)testResetNestedStretchyData
{
    XCTAssertTrue([testStem respondsToSelector:@selector(resetNestedStretchyData)], @"Should respond to method call.");
}

// Should ignore this as it is mostly just technical adjustments that only show up when viewing the draw code.
- (void)testAdjustLayoutForNestedStretchyDataWithBracerData
{
    XCTAssertTrue([testStem respondsToSelector:@selector(adjustLayoutForNestedStretchyDataWithBracerData:)], @"Should respond to method call.");
}

// Mostly tested by shift children horizontally.
// Just starts at a particular child location then calls that method.
- (void)testShiftChildrenAfter
{
    XCTAssertTrue([testStem respondsToSelector:@selector(shiftChildrenAfter:horizontally:)], @"Should respond to method call.");
}

- (void)testComputeTypographicalLayout
{
    XCTAssertTrue([testStem respondsToSelector:@selector(computeTypographicalLayout)], @"Should respond to method call.");
    CGRect testRect = CGRectMake(0.0, 0.0, 42.0, 42.0);
    XCTAssertNoThrow(testRect = [testStem computeTypographicalLayout], @"Should not throw with empty data.");
    XCTAssertTrue(CGRectIsEmpty(testRect), @"Should return zero rect in this case.");
    EQRenderMatrixStem *matrixTestStem = [[EQRenderMatrixStem alloc] initWithStoredCharacterData:@"2x2"];
    XCTAssertNoThrow(testRect = [matrixTestStem computeTypographicalLayout], @"Should not throw with a new matrix.");
    XCTAssertFalse(CGRectIsEmpty(testRect), @"Should not return zero rect for a new matrix stem.");
}

- (void)testIsBinomialStemType
{
    XCTAssertTrue([testStem respondsToSelector:@selector(isBinomialStemType)], @"Should respond to method all.");
    XCTAssertFalse([testStem isBinomialStemType], @"Should be false for initialized stem.");

    EQRenderFracStem *testFracStem = [[EQRenderFracStem alloc] init];
    XCTAssertTrue(testFracStem.stemType == stemTypeFraction, @"Should be initialized as fraction.");
    XCTAssertFalse([testFracStem isBinomialStemType], @"Should still be non-binomial stem.");
    testFracStem.lineThickness = 0.0;
    XCTAssertTrue([testFracStem isBinomialStemType], @"Should now be binomial stem.");

}

// No real unit tests as it just does an add in a special way.
- (void)testAddChildDataToRenderArray
{
    XCTAssertTrue([testStem respondsToSelector:@selector(addChildDataToRenderArray:)], @"Should respond to method call.");
}

// No real unit tests as it just does a remove in a special way.
- (void)testRemoveChildDataFromRenderArray
{
    XCTAssertTrue([testStem respondsToSelector:@selector(removeChildDataFromRenderArray:)], @"Should respond to method call.");
}


@end

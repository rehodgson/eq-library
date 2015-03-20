//
//  EQRenderLayoutTest.m
//  eq-library
//
//  Created by Raymond Hodgson on 10/11/13.
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
#import "EQRenderLayout.h"
#import "EQRenderStem.h"
#import "EQRenderData.h"

@interface EQRenderLayoutTest : XCTestCase

@end

@implementation EQRenderLayoutTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testLayoutDataForStemType
{
    XCTAssertNoThrow([EQRenderLayout layoutData:nil forStemType:stemTypeUnassigned atPoint:CGPointZero forLocation:0], @"Should not throw with empty data.");
    XCTAssertNil([EQRenderLayout layoutData:nil forStemType:stemTypeUnassigned atPoint:CGPointZero forLocation:0], @"Should return input with unmatched stem.");

    XCTAssertNoThrow([EQRenderLayout layoutData:nil forStemType:stemTypeSup atPoint:CGPointZero forLocation:0], @"Should not throw with empty data and matching stem.");
    XCTAssertNil([EQRenderLayout layoutData:nil forStemType:stemTypeSup atPoint:CGPointZero forLocation:0], @"Should return input with matching stem.");
}

- (void)testCursorRectWithData
{
    XCTAssertNoThrow([EQRenderLayout cursorRectWithData:nil forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO], @"Should not throw with empty data.");
    XCTAssertTrue(CGRectIsNull([EQRenderLayout cursorRectWithData:nil forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO]), @"Should return rectNull with empty data.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@""];
    XCTAssertNoThrow([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO],
                     @"Should not throw with empty string data and unassigned stem.");
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, [EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO]),
                   @"Should not return zero rect for non-nil data.");
    XCTAssertFalse(CGRectIsNull([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO]),
                   @"Should not return null for non-nil rect.");
    XCTAssertFalse(CGRectIsEmpty([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO]),
                  @"Should not return empty rect with empty data.");
    
    XCTAssertNoThrow([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO],
                     @"Should not throw with empty string data and matching stem.");
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, [EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO]),
                   @"Should not return zero rect for non-nil data.");
    XCTAssertFalse(CGRectIsNull([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO]),
                   @"Should not return null for non-nil rect.");
    XCTAssertFalse(CGRectIsEmpty([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO]),
                  @"Should not return empty rect with empty data and sup stem type.");

    testData = [[EQRenderData alloc] initWithString:@"Q"];
    XCTAssertNoThrow([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO],
                     @"Should not throw with empty string data and unassigned stem.");
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, [EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO]),
                   @"Should not return zero rect for non-nil data.");
    XCTAssertFalse(CGRectIsNull([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO]),
                   @"Should not return null for non-nil rect.");
    XCTAssertFalse(CGRectIsEmpty([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeUnassigned forLocation:0 smallerBase:NO]),
                   @"Should not return empty rect with non-empty data.");
    
    XCTAssertNoThrow([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO],
                     @"Should not throw with empty string data and matching stem.");
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, [EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO]),
                   @"Should not return zero rect for non-nil data.");
    XCTAssertFalse(CGRectIsNull([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO]),
                   @"Should not return null for non-nil rect.");
    XCTAssertFalse(CGRectIsEmpty([EQRenderLayout cursorRectWithData:testData forStemType:stemTypeSup forLocation:0 smallerBase:NO]),
                   @"Should not return empty rect with non-empty data and sup stem type.");
}

- (void)testWidthForImageSize
{
    XCTAssertNoThrow([EQRenderLayout bestWidthForImageSize:CGSizeZero andTypographicSize:CGSizeZero], @"Should not throw for zero size.");
    XCTAssertTrue(0.0f == [EQRenderLayout bestWidthForImageSize:CGSizeZero andTypographicSize:CGSizeZero], @"Should return zero for zero size.");

    XCTAssertNoThrow([EQRenderLayout bestWidthForImageSize:CGSizeMake(3.0, 6.0) andTypographicSize:CGSizeMake(4.0, 6.0)], @"Should not throw for non-zero size.");
    XCTAssertFalse(0.0f == [EQRenderLayout bestWidthForImageSize:CGSizeMake(3.0, 6.0) andTypographicSize:CGSizeMake(4.0, 6.0)], @"Should not return zero for non-zero sizes.");
}

- (void)testAdjustStemDropHeight
{
    // Test sup stems
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSup usingData:nil], @"Should not throw for nil data.");
    XCTAssertTrue(0.0f == [EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSup usingData:nil], @"Input should match output for nil data.");

    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSup usingData:nil], @"Should not throw for nil data.");
    XCTAssertTrue(3.0f == [EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSup usingData:nil], @"Input should match output for nil data.");

    EQRenderData *testData = [[EQRenderData alloc] initWithString:@""];
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSup usingData:testData], @"Should not throw for empty data.");
    XCTAssertTrue(0.0f != [EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSup usingData:testData], @"Input should not match output for empty data.");
    
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSup usingData:testData], @"Should not throw for empty data.");
    XCTAssertTrue(3.0f != [EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSup usingData:testData], @"Input should match output for empty data.");
    
    testData = [[EQRenderData alloc] initWithString:@"Q"];
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSup usingData:testData], @"Should not throw for non-empty data.");
    XCTAssertTrue(0.0f != [EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSup usingData:testData], @"Input should not match output for non-empty data.");
    
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSup usingData:testData], @"Should not throw for non-empty data.");
    XCTAssertTrue(3.0f != [EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSup usingData:testData], @"Input should match output for non-empty data.");

    // Test sub stems
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSub usingData:nil], @"Should not throw for nil data.");
    XCTAssertTrue(0.0f == [EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSub usingData:nil], @"Input should match output for nil data.");

    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSub usingData:nil], @"Should not throw for nil data.");
    XCTAssertTrue(3.0f == [EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSub usingData:nil], @"Input should match output for nil data.");

    testData = [[EQRenderData alloc] initWithString:@""];
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSub usingData:testData], @"Should not throw for empty data.");
    XCTAssertTrue(0.0f != [EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSub usingData:testData], @"Input should not match output for empty data.");

    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSub usingData:testData], @"Should not throw for empty data.");
    XCTAssertTrue(3.0f != [EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSub usingData:testData], @"Input should match output for empty data.");

    testData = [[EQRenderData alloc] initWithString:@"Q"];
    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSub usingData:testData], @"Should not throw for non-empty data.");
    XCTAssertTrue(0.0f != [EQRenderLayout adjustDropHeight:0.0f forStemType:stemTypeSub usingData:testData], @"Input should not match output for non-empty data.");

    XCTAssertNoThrow([EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSub usingData:testData], @"Should not throw for non-empty data.");
    XCTAssertTrue(3.0f != [EQRenderLayout adjustDropHeight:3.0f forStemType:stemTypeSub usingData:testData], @"Input should match output for non-empty data.");
}

// Testing this can be annoying from a unit perspective.
// Just test the basic break test until you find out you need more.
- (void)testFindLowestChildOrigin
{
    XCTAssertNoThrow([EQRenderLayout findLowestChildOrigin:nil], @"Should not throw for nil.");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, [EQRenderLayout findLowestChildOrigin:nil]), @"Should return (0.0, 0.0) for nil input.");

    EQRenderStem *testStem = [[EQRenderStem alloc] init];
    XCTAssertNoThrow([EQRenderLayout findLowestChildOrigin:testStem], @"Should not throw for empty input.");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, [EQRenderLayout findLowestChildOrigin:testStem]), @"Should return (0.0, 0.0) for empty input.");

    testStem.renderArray = nil;
    XCTAssertNoThrow([EQRenderLayout findLowestChildOrigin:testStem], @"Should not throw for nil input.");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, [EQRenderLayout findLowestChildOrigin:testStem]), @"Should return (0.0, 0.0) for nil input.");
}

// Testing this can be annoying from a unit perspective.
// Just test the basic break test until you find out you need more.
- (void)testFindHighestChildOrigin
{
    XCTAssertNoThrow([EQRenderLayout findHighestChildOrigin:nil], @"Should not throw for nil.");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, [EQRenderLayout findHighestChildOrigin:nil]), @"Should return (0.0, 0.0) for nil input.");

    EQRenderStem *testStem = [[EQRenderStem alloc] init];
    XCTAssertNoThrow([EQRenderLayout findHighestChildOrigin:testStem], @"Should not throw for empty input.");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, [EQRenderLayout findHighestChildOrigin:testStem]), @"Should return (0.0, 0.0) for empty input.");

    testStem.renderArray = nil;
    XCTAssertNoThrow([EQRenderLayout findHighestChildOrigin:testStem], @"Should not throw for nil input.");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, [EQRenderLayout findHighestChildOrigin:testStem]), @"Should return (0.0, 0.0) for nil input.");
}


@end

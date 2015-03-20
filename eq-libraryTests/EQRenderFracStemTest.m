//
//  EQRenderFracStemTest.m
//  eq-library
//
//  Created by Raymond Hodgson on 11/9/13.
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
#import "EQRenderFracStem.h"
#import "EQRenderData.h"

@interface EQRenderFracStemTest : XCTestCase
{
    EQRenderFracStem *testStem;
}

@end

@implementation EQRenderFracStemTest

- (void)setUp
{
    [super setUp];

    testStem = [[EQRenderFracStem alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatRenderFracStemExists
{
    XCTAssertNotNil(testStem, @"Should be able to create EQRenderFracStem.");
}

- (void)testLineThicknessProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(lineThickness)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setLineThickness:)], @"Should respond to set: method.");

    XCTAssertNoThrow([testStem setLineThickness: 10.0], @"Should not throw when setting line thickness.");
    XCTAssertNoThrow([testStem lineThickness], @"Should not throw when getting line thickness.");
    XCTAssertTrue([testStem lineThickness] == 10.0, @"Input should match output.");
}

- (void)testStartLineProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(startLinePoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setStartLinePoint:)], @"Should respond to set: method.");

    XCTAssertNoThrow([testStem setStartLinePoint: CGPointMake(40.0, 40.0)], @"Should not throw when setting origin.");
    XCTAssertNoThrow([testStem startLinePoint], @"Should not throw when getting origin.");
    XCTAssertTrue(CGPointEqualToPoint([testStem startLinePoint], CGPointMake(40.0, 40.0)), @"Input should match output.");
}

- (void)testEndLineProperty
{
    XCTAssertTrue([testStem respondsToSelector:@selector(endLinePoint)], @"Should respond to accessor method.");
    XCTAssertTrue([testStem respondsToSelector:@selector(setEndLinePoint:)], @"Should respond to set: method.");

    XCTAssertNoThrow([testStem setEndLinePoint: CGPointMake(40.0, 40.0)], @"Should not throw when setting origin.");
    XCTAssertNoThrow([testStem endLinePoint], @"Should not throw when getting origin.");
    XCTAssertTrue(CGPointEqualToPoint([testStem endLinePoint], CGPointMake(40.0, 40.0)), @"Input should match output.");
}

- (void)testInit
{
    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");
}

- (void)testInitWithObject
{
    XCTAssertTrue([testStem respondsToSelector:@selector(initWithObject:)], @"Should respond to initWithObject.");

    XCTAssertThrows(testStem = [[EQRenderFracStem alloc] initWithObject:nil], @"Should throw with nil initializer.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q"], @"Should perform init with any object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should include initialized object in array.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");
}

- (void)testInitWithObjectAndStemType
{
    XCTAssertTrue([testStem respondsToSelector:@selector(initWithObject:andStemType:)], @"Should respond to initWithObjectAndStemType.");

    XCTAssertThrows(testStem = [[EQRenderFracStem alloc] initWithObject:nil andStemType:stemTypeUnassigned], @"Should throw with nil object.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:stemTypeUnassigned], @"Should not throw with any object.");
    XCTAssertTrue([[testStem.renderArray objectAtIndex:0] isEqualToString:@"Q"], @"Should include initialized object in array.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:(stemTypeUnassigned - 1)], @"Should not throw with any object and bad stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:stemTypeUnassigned], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:stemTypeRoot], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:stemTypeRow], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:(stemTypeFraction + 1)], @"Should not throw with any object and bad stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:stemTypeSub], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:stemTypeSup], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] initWithObject:@"Q" andStemType:stemTypeFraction], @"Should not throw with any object and good stemType.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");
}

- (void)testLayoutChildren
{
    XCTAssertTrue([testStem respondsToSelector:@selector(layoutChildren)], @"Should respond to layoutChildren");

    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.stemType == stemTypeFraction, @"Should have frac stem type.");
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
    CGRect testBounds = testStem.drawBounds;
    XCTAssertFalse(CGRectEqualToRect(defaultRect, testBounds), @"Should not have default size after layout is performed.");
    XCTAssertTrue(CGRectEqualToRect(testData.boundingRectTypographic, testBounds), @"Should match the typographic bounds + 6.0 width in this case.");
}

// updateBounds is called by layout children, so is already covered by those tests.
- (void)testUpdateBounds
{
    XCTAssertTrue([testStem respondsToSelector:@selector(updateBounds)], @"Should respond to updateBounds method.");
    XCTAssertNoThrow(testStem = [[EQRenderFracStem alloc] init], @"Should not throw for empty init.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have empty array.");

    XCTAssertNoThrow([testStem updateBounds], @"Should not throw for empty stem.");
    XCTAssertTrue(CGRectEqualToRect(testStem.drawBounds, CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)), @"Should return default rect size for empty render.");
    XCTAssertTrue(CGSizeEqualToSize(testStem.drawSize, CGSizeMake(20.0f, 20.0f)), @"Should return default size for empty render.");
}

@end

//
//  EQTextRangeTest.m
//  eq-library
//
//  Created by Raymond Hodgson on 14/09/13.
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
#import "EQTextRange.h"

@interface EQTextRangeTest : XCTestCase
{
    EQTextRange *testRange;
}

@end

@implementation EQTextRangeTest

- (void)setUp
{
    [super setUp];
    testRange = [[EQTextRange alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThatRangeExists
{
    XCTAssertNotNil(testRange, @"Should be able to create testRange.");
}

- (void)testThatRangeConformsToNSCodingProtocol
{
    XCTAssertTrue([testRange conformsToProtocol:@protocol(NSCoding)], @"Data source must conform to NSCoding");
}

- (void)testRangeProperty
{
    XCTAssertTrue([testRange respondsToSelector:@selector(range)], @"Should respond to accessor method.");
    XCTAssertTrue([testRange respondsToSelector:@selector(setRange:)], @"Should respond to set: method.");

    NSRange test = NSMakeRange(0, 0);
    XCTAssertNoThrow([testRange setRange:test], @"Should set to NSNotFound without throwing.");
    XCTAssertNoThrow([testRange range], @"Should be able to get range without throwing.");
    XCTAssertTrue([testRange range].location == test.location, @"Should be equal to input location.");
    XCTAssertTrue([testRange range].length == test.length, @"Should be equal to input length.");
}

- (void)testDataLocProperty
{
    XCTAssertTrue([testRange respondsToSelector:@selector(dataLoc)], @"Should respond to accessor method.");
    XCTAssertTrue([testRange respondsToSelector:@selector(setDataLoc:)], @"Should respond to set: method.");

    XCTAssertNoThrow([testRange setDataLoc:1], @"Should be able to set data loc without throwing.");
    XCTAssertNoThrow([testRange dataLoc], @"Should be able to get data without throwing.");
    XCTAssertTrue([testRange dataLoc] == 1, @"Should return the same as input data.");
}

- (void)testTextPositionProperty
{
    XCTAssertTrue([testRange respondsToSelector:@selector(textPosition)], @"Should respond to accessor method.");
    XCTAssertNoThrow([testRange textPosition], @"Should be able to get property without throwing.");
    EQTextPosition *testPos = testRange.textPosition;
    XCTAssertNotNil(testPos, @"Should not return nil when getting text position.");
    XCTAssertTrue([testPos isKindOfClass:[EQTextPosition class]], @"Should return the correct class.");
}

- (void)testEndPositionProperty
{
    XCTAssertTrue([testRange respondsToSelector:@selector(endPosition)], @"Should respond to accessor method.");
    XCTAssertNoThrow([testRange endPosition], @"Should be able to get property without throwing.");
    EQTextPosition *testPos = testRange.endPosition;
    XCTAssertNotNil(testPos, @"Should not return nil when getting text position.");
    XCTAssertTrue([testPos isKindOfClass:[EQTextPosition class]], @"Should return the correct class.");
}

- (void)testRangeWithRange
{
    NSRange test = NSMakeRange(0, 0);
    XCTAssertNoThrow([EQTextRange textRangeWithRange:test andLocation:0 andEquationLoc:0], @"Should not throw when creating using range.");
    EQTextRange *range = [EQTextRange textRangeWithRange:test andLocation:0 andEquationLoc:0];
    XCTAssertNotNil(range, @"Should be able to create a text range class.");
    XCTAssertTrue([range isKindOfClass:[EQTextRange class]], @"Should return the correct class type.");
}

- (void)testRangeWithPosition
{
    EQTextPosition *test = [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([EQTextRange textRangeWithPosition:test], @"Should not throw when creating using position.");
    EQTextRange *range = [EQTextRange textRangeWithPosition:test];
    XCTAssertNotNil(range, @"Should be able to create a text range class.");
    XCTAssertTrue([range isKindOfClass:[EQTextRange class]], @"Should return the correct class type.");
}

- (void)testCompareTextRange
{
    EQTextRange *range1 = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
    EQTextRange *range2 = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
    EQTextRange *range3 = [EQTextRange textRangeWithRange:NSMakeRange(1, 0) andLocation:0 andEquationLoc:0];

    XCTAssertNoThrow([EQTextRange compareTextRange:nil toRange:nil], @"Should not throw when comparing nil values.");
    XCTAssertNoThrow([EQTextRange compareTextRange:[EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0] toRange:range1],
                        @"Should not throw when comparing NSNotFound values.");
    XCTAssertNoThrow([EQTextRange compareTextRange:range1 toRange:range2], @"Should not throw when comparing normal values.");
    XCTAssertNoThrow([EQTextRange compareTextRange:range1 toRange:range3], @"Should not throw when comparing normal values.");

    XCTAssertTrue([EQTextRange compareTextRange:range1 toRange:range2] == NSOrderedSame, @"Should return ordered same here.");
    XCTAssertFalse([EQTextRange compareTextRange:range1 toRange:range3] == NSOrderedSame, @"Should not return ordered same here.");
    XCTAssertTrue([EQTextRange compareTextRange:range1 toRange:range3] == NSOrderedAscending, @"Should return ordered ascending here.");
    XCTAssertTrue([EQTextRange compareTextRange:range3 toRange:range1] == NSOrderedDescending, @"Should return ordered descending here.");

    range2.dataLoc = 1;
    XCTAssertFalse([EQTextRange compareTextRange:range1 toRange:range2] == NSOrderedSame, @"Should not return ordered same here.");
    XCTAssertFalse([EQTextRange compareTextRange:range1 toRange:range2] == NSOrderedDescending, @"Should return ordered descending here.");
    XCTAssertFalse([EQTextRange compareTextRange:range2 toRange:range1] == NSOrderedAscending, @"Should return ordered ascending here.");
    XCTAssertFalse([EQTextRange compareTextRange:range2 toRange:range3] == NSOrderedSame, @"Should not return ordered same here.");
    XCTAssertTrue([EQTextRange compareTextRange:range3 toRange:range2] == NSOrderedAscending, @"Should return ordered ascending here.");
    XCTAssertTrue([EQTextRange compareTextRange:range2 toRange:range3] == NSOrderedDescending, @"Should return ordered descending here.");
}

- (void)testStart
{
    testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 3) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRange start], @"Should not throw when getting start.");
    EQTextPosition *testPos = (EQTextPosition *)[testRange start];
    XCTAssertTrue(testPos.index == 0, @"Should return correct start value.");
}

- (void)testEnd
{
    testRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 3) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRange end], @"Should not throw when getting end.");
    EQTextPosition *testPos = (EQTextPosition *)[testRange end];
    XCTAssertTrue(testPos.index == 3, @"Should return correct end value.");
}

- (void)testEmpty
{
    testRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 3) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRange isEmpty], @"Should not throw for NSNotFound.");
    XCTAssertFalse([testRange isEmpty], @"Should return false if length > 0");

    testRange = [EQTextRange textRangeWithRange:NSMakeRange(1, 0) andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([testRange isEmpty], @"Should not throw for NSNotFound.");
    XCTAssertTrue([testRange isEmpty], @"Should return true if length = 0");
}

@end

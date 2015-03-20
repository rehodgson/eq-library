//
//  EQTextPositionTest.m
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
#import "EQTextPosition.h"

@interface EQTextPositionTest : XCTestCase
{
    EQTextPosition *testPosition;
}

@end

@implementation EQTextPositionTest

- (void)setUp
{
    [super setUp];
    testPosition = [[EQTextPosition alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThatTextPositionExists
{
    XCTAssertNotNil(testPosition, @"Should be able to create a test position.");
}

- (void)testThatTextPositionConformsToNSCodingProtocol
{
    XCTAssertTrue([testPosition conformsToProtocol:@protocol(NSCoding)], @"Data source must conform to NSCoding");
}

- (void)testIndexProperty
{
    XCTAssertTrue([testPosition respondsToSelector:@selector(index)], @"Should respond to accessor method.");
    XCTAssertTrue([testPosition respondsToSelector:@selector(setIndex:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testPosition setIndex:0], @"Should set index without throwing.");
    XCTAssertTrue(0 == [testPosition index], @"Should match the input value.");
}

- (void)testDataLocProperty
{
    XCTAssertTrue([testPosition respondsToSelector:@selector(dataLoc)], @"Should respond to accessor method.");
    XCTAssertTrue([testPosition respondsToSelector:@selector(setDataLoc:)], @"Should respond to set: method.");
    XCTAssertNoThrow([testPosition setDataLoc:0], @"Should set dataLoc without throwing.");
    XCTAssertTrue(0 == [testPosition dataLoc], @"Should match the input value.");
}

- (void)testTextPositionWithIndex
{
    XCTAssertNoThrow([EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0], @"Should not throw for init with index.");
    EQTextPosition *test = [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
    XCTAssertNotNil(test, @"Should be able to create text position with index.");
    XCTAssertTrue(test.index == 0, @"Should match the input value.");
}

- (void)testCompareTextPositionToPosition
{
    XCTAssertNoThrow([EQTextPosition compareTextPosition:nil toPosition:nil], @"Should not throw for nil comparison.");
    EQTextPosition *pos1 = [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
    EQTextPosition *pos2 = [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
    EQTextPosition *pos3 = [EQTextPosition textPositionWithIndex:1 andLocation:0 andEquationLoc:0];
    EQTextPosition *notFound = [EQTextPosition textPositionWithIndex:NSNotFound andLocation:0 andEquationLoc:0];
    XCTAssertNoThrow([EQTextPosition compareTextPosition:pos1 toPosition:notFound], @"Should not throw for not found comparison.");
    XCTAssertNoThrow([EQTextPosition compareTextPosition:pos1 toPosition:pos2], @"Should not throw for good comparison.");
    XCTAssertNoThrow([EQTextPosition compareTextPosition:pos1 toPosition:pos3], @"Should not throw for good comparison.");
    XCTAssertTrue(NSOrderedSame == [EQTextPosition compareTextPosition:pos1 toPosition:pos2], @"Should return same for same indexes.");
    XCTAssertFalse(NSOrderedSame == [EQTextPosition compareTextPosition:pos1 toPosition:pos3], @"Should not return same for different indexes.");
    XCTAssertTrue(NSOrderedAscending == [EQTextPosition compareTextPosition:pos1 toPosition:pos3], @"Should return ascending here.");
    XCTAssertTrue(NSOrderedDescending == [EQTextPosition compareTextPosition:pos3 toPosition:pos2], @"Should return descending here.");

    pos2.dataLoc = 1;
    XCTAssertNoThrow([EQTextPosition compareTextPosition:pos1 toPosition:pos2], @"Should not throw for good comparison.");
    XCTAssertNoThrow([EQTextPosition compareTextPosition:pos3 toPosition:pos2], @"Should not throw for good comparison.");
    XCTAssertFalse(NSOrderedSame == [EQTextPosition compareTextPosition:pos1 toPosition:pos2], @"Should not return same for different data locs.");
}

@end

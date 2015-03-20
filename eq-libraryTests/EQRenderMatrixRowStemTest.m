//
//  EQRenderMatrixRowStemTest.m
//  eq-library
//
//  Created by Raymond Hodgson on 05/14/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
//
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "EQRenderMatrixRowStem.h"

@interface EQRenderMatrixRowStemTest : XCTestCase
{
    EQRenderMatrixRowStem *testStem;
}

@end

@implementation EQRenderMatrixRowStemTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

    testStem = [[EQRenderMatrixRowStem alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatRenderFracStemExists
{
    XCTAssertNotNil(testStem);
    XCTAssertTrue([testStem isKindOfClass:[EQRenderMatrixRowStem class]], @"Should be the correct class.");
}

- (void)testInitWithStoredCharacterData
{
    XCTAssertTrue([testStem respondsToSelector:@selector(initWithColumns:)], @"Should respond to method call.");
    XCTAssertNoThrow(testStem = [[EQRenderMatrixRowStem alloc] initWithColumns:0], @"Should not throw with bad column number.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should have created zero columns.");
    XCTAssertTrue(testStem.stemType == stemTypeMatrixRow, @"Should have set the stem type to matrix row.");

    XCTAssertNoThrow(testStem = [[EQRenderMatrixRowStem alloc] initWithColumns:1], @"Should not throw with valid column number.");
    XCTAssertTrue(testStem.renderArray.count == 1, @"Should have created one column.");
    XCTAssertTrue(testStem.stemType == stemTypeMatrixRow, @"Should have set the stem type to matrix row.");

    XCTAssertNoThrow(testStem = [[EQRenderMatrixRowStem alloc] initWithColumns:10], @"Should not throw with valid column number.");
    XCTAssertTrue(testStem.renderArray.count == 10, @"Should have created ten columns.");
    XCTAssertTrue(testStem.stemType == stemTypeMatrixRow, @"Should have set the stem type to matrix row.");
}

// Not really much to test, just leave a placeholder for now.
- (void)testAddChildDataToRenderArray
{
    XCTAssertTrue([testStem respondsToSelector:@selector(addChildDataToRenderArray:)], @"Should respond to method call.");
}

- (void)testColumnRectsMethod
{
    XCTAssertTrue([testStem respondsToSelector:@selector(columnRects)], @"Should respond to method call.");

    NSMutableArray *testColumnRects = [[NSMutableArray alloc] initWithObjects:@"foo", nil];
    XCTAssertNoThrow(testColumnRects = [testStem columnRects], @"Should not throw with empty data.");
    XCTAssertNil(testColumnRects, @"Should return nil with empty data.");

    testColumnRects = nil;
    testStem = [[EQRenderMatrixRowStem alloc] initWithColumns:2];
    XCTAssertNoThrow(testColumnRects = [testStem columnRects], @"Should not throw with valid data.");
    XCTAssertNotNil(testColumnRects, @"Should have returned an array of values with valid data.");
    XCTAssertTrue(testColumnRects.count == 2, @"Should match the number of columns for the matrix row.");
}

// Mostly about testing the graphic output, so mostly testing unhappy cases.
- (void)testUpdateChildOriginsWithBoundsArray
{
    XCTAssertTrue([testStem respondsToSelector:@selector(updateChildOriginsWithBoundsArray:)], @"Should respond to method call.");
    XCTAssertNoThrow([testStem updateChildOriginsWithBoundsArray:nil], @"Should not throw with empty data and nil object.");
    NSArray *testArray = @[@"foo"];
    XCTAssertNoThrow([testStem updateChildOriginsWithBoundsArray:testArray], @"Should not throw with empty data and invalid object.");

    testStem = [[EQRenderMatrixRowStem alloc] initWithColumns:1];
    XCTAssertThrows([testStem updateChildOriginsWithBoundsArray:testArray], @"Should throw with array that contains invalid objects.");

    NSValue *testValue1 = [NSValue valueWithCGRect:CGRectZero];
    NSValue *testValue2 = [NSValue valueWithCGRect:CGRectZero];
    testArray = @[testValue1, testValue2];

    testStem = [[EQRenderMatrixRowStem alloc] initWithColumns:3];
    XCTAssertThrows([testStem updateChildOriginsWithBoundsArray:testArray], @"Should throw with data count > test array count.");

    testStem = [[EQRenderMatrixRowStem alloc] initWithColumns:2];
    XCTAssertNoThrow([testStem updateChildOriginsWithBoundsArray:testArray], @"Should not throw with valid number of correct objects.");
}

@end

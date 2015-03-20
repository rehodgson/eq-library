//
//  EQRenderMatrixStemTest.m
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

#import <XCTest/XCTest.h>
#import "EQRenderMatrixStem.h"
#import "EQRenderStem.h"
#import "EQRenderData.h"

@interface EQRenderMatrixStemTest : XCTestCase
{
    EQRenderMatrixStem *testStem;
}

@end

@implementation EQRenderMatrixStemTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    testStem = [[EQRenderMatrixStem alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testThatMatrixStemExists
{
    XCTAssertNotNil(testStem, @"Should have created the test stem.");
    XCTAssertTrue([testStem isKindOfClass:[EQRenderMatrixStem class]], @"Should have the correct object type.");
    XCTAssertTrue(testStem.stemType == stemTypeMatrix, @"Should have the correct stem type automatically.");
}

- (void)testInitWithStoredCharacterData
{
    XCTAssertTrue([testStem respondsToSelector:@selector(initWithStoredCharacterData:)], @"Should respond to method call.");
    XCTAssertTrue(testStem.renderArray.count == 0, @"Should initialize with no children.");

    XCTAssertNoThrow([testStem initWithStoredCharacterData:@"2x2"], @"Should not throw when calling init method.");
    XCTAssertTrue(testStem.renderArray.count == 2, @"Should create the correct number of rows.");
}

// Not really much to test, just leave a placeholder for now.
- (void)testAddChildDataToRenderArray
{
    XCTAssertTrue([testStem respondsToSelector:@selector(addChildDataToRenderArray:)], @"Should respond to method call.");
}

- (void)testGetFirstCellObj
{
    XCTAssertTrue([testStem respondsToSelector:@selector(getFirstCellObj)], @"Should respond to method call.");
    id testObj = @"foo";
    XCTAssertNoThrow(testObj = [testStem getFirstCellObj], @"Should not throw with empty data.");
    XCTAssertNil(testObj, @"Should return nil with empty data.");

    testStem = [[EQRenderMatrixStem alloc] initWithStoredCharacterData:@"2x2"];
    testObj = nil;
    XCTAssertNoThrow(testObj = [testStem getFirstCellObj], @"Should not throw with valid data.");
    XCTAssertNotNil(testObj, @"Should have returned a valid non-nil object.");
    XCTAssertTrue([testObj isKindOfClass:[EQRenderData class]], @"Should have returned an initialized renderData object.");
}

@end

//
//  EQRenderTypesetterTest.m
//  eq-library
//
//  Created by Raymond Hodgson on 09/25/13.
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
#import "EQRenderTypesetter.h"
#import "MockEquationViewDataSource.h"

@interface EQRenderTypesetterTest : XCTestCase
{
    EQRenderTypesetter *testTypesetter;
    MockEquationViewDataSource *testDelegate;
}

@end

@implementation EQRenderTypesetterTest

- (void)setUp
{
    [super setUp];
    testTypesetter = [[EQRenderTypesetter alloc] init];
    testDelegate = [[MockEquationViewDataSource alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThatTypesetterExists
{
    XCTAssertNotNil(testTypesetter, @"Should be able to create EQRenderTypesetter object.");
}

- (void)testThatTypesetterHasDelegateProperty
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(typesetterDelegate)], @"Should have typesetterDelegate property.");
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(setTypesetterDelegate:)], @"Should have typesetterDelegate property.");
}

- (void)testThatTypesetterDelegateCanBeNil
{
    XCTAssertNoThrow([testTypesetter setTypesetterDelegate:nil], @"Should not throw when setting to nil.");
}

- (void) testThatNonConformingObjectCanNotBeDataSource
{
    XCTAssertThrows(testTypesetter.typesetterDelegate = (id <EQTypesetterDelegate>)[NSNull null], @"Object should not allow non-conforming datasource");
}

- (void) testThatConformingObjectCanBeDataSource
{
    XCTAssertNoThrow(testTypesetter.typesetterDelegate = testDelegate, @"Object should allow conforming datasource");
}

- (void) testGetBinomialOperators
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getBinomialOperators)], @"Class should respond to getBinomialOperators");
    XCTAssertNotNil([EQRenderTypesetter getBinomialOperators], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getBinomialOperators] isKindOfClass:[NSDictionary class]], @"Method should return an NSDictionary.");
}

- (void) testGetUnaryOperators
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getUnaryOperators)], @"Class should respond to getUnaryOperators");
    XCTAssertNotNil([EQRenderTypesetter getUnaryOperators], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getUnaryOperators] isKindOfClass:[NSDictionary class]], @"Method should return an NSDictionary.");
}

- (void) testGetLeftBracketCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getLeftBracketCharacters)], @"Class should respond to getLeftBracketCharacters");
    XCTAssertNotNil([EQRenderTypesetter getLeftBracketCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getLeftBracketCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetRightBracketCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getRightBracketCharacters)], @"Class should respond to getRightBracketCharacters");
    XCTAssertNotNil([EQRenderTypesetter getRightBracketCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getRightBracketCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetTrailingCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getTrailingCharacters)], @"Class should respond to getTrailingCharacters");
    XCTAssertNotNil([EQRenderTypesetter getTrailingCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getTrailingCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetItalicAdjustCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getItalicAdjustCharacters)], @"Class should respond to getItalicAdjustCharacters");
    XCTAssertNotNil([EQRenderTypesetter getItalicAdjustCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getItalicAdjustCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetLeftTrailingCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getLeftTrailingCharacters)], @"Class should respond to getLeftTrailingCharacters");
    XCTAssertNotNil([EQRenderTypesetter getLeftTrailingCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getLeftTrailingCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetStretchyBracerCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getStretchyBracerCharacters)], @"Class should respond to getStretchyBracerCharacters");
    XCTAssertNotNil([EQRenderTypesetter getStretchyBracerCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getStretchyBracerCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetLeftStretchyBracerCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getLeftStretchyBracerCharacters)], @"Class should respond to getLeftStretchyBracerCharacters");
    XCTAssertNotNil([EQRenderTypesetter getLeftStretchyBracerCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getLeftStretchyBracerCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetRightStretchyBracerCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getRightStretchyBracerCharacters)], @"Class should respond to getRightStretchyBracerCharacters");
    XCTAssertNotNil([EQRenderTypesetter getRightStretchyBracerCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getRightStretchyBracerCharacters] isKindOfClass:[NSSet class]], @"Method should return an NSSet.");
}

- (void) testGetOperatorCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getOperatorCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getOperatorCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getOperatorCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetLargeOpCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getLargeOpCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getLargeOpCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getLargeOpCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetNumberCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getNumberCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getNumberCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getNumberCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetStretchyBracerSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getStretchyBracerSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getStretchyBracerSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getStretchyBracerSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetGreekCapCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getGreekCapCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getGreekCapCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getGreekCapCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetGreekLCCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getGreekLowerCaseCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getGreekLowerCaseCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getGreekLowerCaseCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetGreekCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getGreekCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getGreekCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getGreekCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetBracerCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getBracerCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getBracerCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getBracerCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetMiscIdentifierCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getMiscIdentifierCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getMiscIdentifierCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getMiscIdentifierCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetMiscNumericCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getMiscNumericCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getMiscNumericCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getMiscNumericCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetMiscOperatorCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getMiscOperatorCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getMiscOperatorCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getMiscOperatorCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetEqualityCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getEqualityCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getEqualityCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getEqualityCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetUncommonOperatorCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getUncommonOperatorCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getUncommonOperatorCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getUncommonOperatorCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetGeometryCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getGeometryCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getGeometryCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getGeometryCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetArrowCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getArrowCharacters)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getArrowCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getArrowCharacters] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetScriptCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getScriptCharacters)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getScriptCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getScriptCharacters] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetFrakturCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getFrakturCharacters)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getFrakturCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getFrakturCharacters] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetBlackboardCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getBlackboardCharacters)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getBlackboardCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getBlackboardCharacters] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetSumOpCharacterSet
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getSumOpCharacterSet)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getSumOpCharacterSet], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getSumOpCharacterSet] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

- (void) testGetAccentOpCharacters
{
    XCTAssertTrue([EQRenderTypesetter respondsToSelector:@selector(getAccentOpCharacters)], @"Class should respond to method.");
    XCTAssertNotNil([EQRenderTypesetter getAccentOpCharacters], @"Class should not return nil.");
    XCTAssertTrue([[EQRenderTypesetter getAccentOpCharacters] isKindOfClass:[NSCharacterSet class]], @"Method should return an NSCharacterSet.");
}

// Tests when it calls the delegate and when it throws. It doesn't test the output of the data.
- (void) testTypesetterAddDataMethod
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(addData:)], @"Object should respond to addData:");
    XCTAssertThrowsSpecific([testTypesetter addData:@"Q"], NSException, @"Should throw when delegate is uninitialized.");
    testTypesetter.typesetterDelegate = testDelegate;
    XCTAssertNoThrow([testTypesetter addData:nil], @"Should not throw when adding nil data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with nil data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 0, @"Should not call getSelected with nil data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 0, @"Should not call getRenderData with nil data.");

    XCTAssertNoThrow([testTypesetter addData:[NSNull null]], @"Should not throw for unsupported data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with unsupported data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 0, @"Should not call getSelected with unsupported data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 0, @"Should not call getRenderData with unsupported data.");

    XCTAssertNoThrow([testTypesetter addData:@""], @"Should not throw when adding empty string data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with empty data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 0, @"Should not call getSelected with empty data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 0, @"Should not call getRenderData with empty data.");

    XCTAssertNoThrow([testTypesetter addData:@"Q"], @"Should not throw when adding valid string data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 1, @"Should call getMarked with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 1, @"Should call getSelected with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 1, @"Should call getRenderData with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendUpdateMarkedTextRange:"] == 1, @"Should call updateMarked with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendUpdateSelectedTextRange:"] == 1, @"Should call updateSelected with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"updateRenderData:"] == 0, @"Should not call updateRenderData:");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendFinishedUpdating"] == 1, @"Should call sendFinishedUpdating.");
}

// Tests when it calls the delegate and when it throws. It doesn't test the output of the data.
- (void) testTypesetterReplaceDataMethod
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(replaceDataInRange:withData:)], @"Object should respond to replaceDataInRange:");
    XCTAssertThrowsSpecific([testTypesetter replaceDataInRange:nil withData:nil], NSException, @"Should throw when delegate is uninitialized.");
    testTypesetter.typesetterDelegate = testDelegate;
    XCTAssertNoThrow([testTypesetter replaceDataInRange:nil withData:nil], @"Should not throw for nil data.");
    XCTAssertNoThrow([testTypesetter replaceDataInRange:nil withData:@"Q"], @"Should not throw for nil data.");
    XCTAssertNoThrow([testTypesetter replaceDataInRange:[EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0] withData:nil],
                     @"Should not throw for nil data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with nil data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 0, @"Should not call getSelected with nil data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 0, @"Should not call getRenderData with nil data.");

    XCTAssertNoThrow([testTypesetter replaceDataInRange:[EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0] withData:[NSNull null]],
                     @"Should not throw for unsupported data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with unsupported data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 0, @"Should not call getSelected with unsupported data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 0, @"Should not call getRenderData with unsupported data.");

    [testDelegate addData:@"foo"];
    XCTAssertNoThrow([testTypesetter replaceDataInRange:[EQTextRange textRangeWithRange:NSMakeRange(0, 1) andLocation:0 andEquationLoc:0] withData:@"b"],
                     @"Should not throw for valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 1, @"Should call getSelected with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 1, @"Should call getRenderData with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"unmarkText"] == 1, @"Should call unmarkText with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendUpdateSelectedTextRange:"] == 1, @"Should call updateSelected with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"updateRenderData:"] == 0, @"Should call not updateRenderData:");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendFinishedUpdating"] == 1, @"Should call sendFinishedUpdating");

    XCTAssertNoThrow([testTypesetter replaceDataInRange:[EQTextRange textRangeWithRange:NSMakeRange(4, 1) andLocation:0 andEquationLoc:0] withData:@"b"],
                     @"Should not throw for out of bounds data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with out of bounds data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 1, @"Should not call getSelected with out of bounds data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 2, @"Should call getRenderData with out of bounds data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"unmarkText"] == 1, @"Should not call unmarkText with out of bounds data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendUpdateSelectedTextRange:"] == 1, @"Should not call updateSelected with out of bounds data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"updateRenderData:"] == 0, @"Should not call updateRenderData: with out of bounds data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendFinishedUpdating"] == 1, @"Should not call sendFinishedUpdating");
}

- (void) testDeleteBackwardMethod
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(deleteBackward)], @"Object should respond to deleteBackward");
    XCTAssertThrowsSpecific([testTypesetter deleteBackward], NSException, @"Should throw when delegate is uninitialized.");
    testTypesetter.typesetterDelegate = testDelegate;

    XCTAssertFalse([testDelegate hasData], @"Should be empty here.");
    XCTAssertNoThrow([testTypesetter deleteBackward], @"Should not throw when data is empty.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"hasData"] == 2, @"Should call hasData with empty data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 0, @"Should not call getRenderData with empty data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 0, @"Should not call getMarked with empty data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 0, @"Should not call getSelected with empty data.");

    [testDelegate addData:@"foo"];
    XCTAssertTrue([testDelegate hasData], @"Should not be empty here.");
    XCTAssertNoThrow([testTypesetter deleteBackward], @"Should not throw when data is not empty.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"hasData"] == 4, @"Should call hasData with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderData"] == 1, @"Should call getRenderData with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getMarkedTextRange"] == 1, @"Should call getMarked with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"getSelectedTextRange"] == 1, @"Should call getSelected with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendUpdateMarkedTextRange:"] == 1, @"Should call updateMarked with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendUpdateSelectedTextRange:"] == 1, @"Should call updateSelected with valid data.");
    XCTAssertTrue([testDelegate functionCallsForKey:@"updateRenderData:"] == 0, @"Should call updateRenderData:");
    XCTAssertTrue([testDelegate functionCallsForKey:@"sendFinishedUpdating"] == 1, @"Should call sendFinishedUpdating.");
}

// Tests bad data input. Doesn't test resulting changes to string.
- (void) testApplyMathStyleMethod
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(applyMathStyleToAttributedString:inRange:useSmaller:parentSmaller:)], @"Object should respond to apply math style");
    XCTAssertNoThrow([testTypesetter applyMathStyleToAttributedString:nil inRange:NSMakeRange(0, 1) useSmaller:NO parentSmaller:NO], @"Should not throw for nil data.");
    XCTAssertNoThrow([testTypesetter applyMathStyleToAttributedString:[[NSMutableAttributedString alloc]init] inRange:NSMakeRange(0, 1) useSmaller:NO parentSmaller:NO],
                     @"Should not throw for empty data.");
    XCTAssertNoThrow([testTypesetter applyMathStyleToAttributedString:[[NSMutableAttributedString alloc]init] inRange:NSMakeRange(0, 0) useSmaller:NO parentSmaller:NO],
                     @"Should not throw for empty range.");
    XCTAssertNoThrow([testTypesetter applyMathStyleToAttributedString:[[NSMutableAttributedString alloc]init] inRange:NSMakeRange(NSNotFound, 0) useSmaller:NO parentSmaller:NO],
                     @"Should not throw for not found range.");
    XCTAssertNoThrow([testTypesetter applyMathStyleToAttributedString:[[NSMutableAttributedString alloc]init] inRange:NSMakeRange(5, 1) useSmaller:NO parentSmaller:NO],
                     @"Should not throw for out of bounds range.");
    XCTAssertNoThrow([testTypesetter applyMathStyleToAttributedString:[[NSMutableAttributedString alloc]init] inRange:NSMakeRange(0, 5) useSmaller:NO parentSmaller:NO],
                     @"Should not throw for out of bounds range.");
}

// Doesn't test output, just tests responses to bad input.
- (void) testKernMathMethod
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(kernMathInAttributedString:)], @"Object should respond to kern method");
    XCTAssertNoThrow([testTypesetter kernMathInAttributedString:nil], @"Should not throw for nil data.");
    XCTAssertNoThrow([testTypesetter kernMathInAttributedString:[[NSMutableAttributedString alloc]init]], @"Should not throw for empty data.");
}

// Doesn't test output, just tests responses to bad input.
- (void) testParseTextForOperationMethod
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(parseTextForOperation:atSelectionLoc:inAttributedString:useSmaller:withData:)],
                  @"Object should respond to parse method.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:nil atSelectionLoc:NSMakeRange(0, 1) inAttributedString:nil useSmaller:NO withData:nil], @"Should not throw for nil data.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:@"+" atSelectionLoc:NSMakeRange(0, 1) inAttributedString:nil useSmaller:NO withData:nil], @"Should not throw for nil data.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:nil atSelectionLoc:NSMakeRange(0, 1) inAttributedString:
                      [[NSMutableAttributedString alloc]initWithString:@"Q"] useSmaller:NO withData:nil], @"Should not throw for nil data.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:@"" atSelectionLoc:NSMakeRange(0, 1) inAttributedString:
                      [[NSMutableAttributedString alloc]initWithString:@""] useSmaller:NO withData:nil], @"Should not throw for empty data.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:@"+" atSelectionLoc:NSMakeRange(0, 1) inAttributedString:
                      [[NSMutableAttributedString alloc]initWithString:@""] useSmaller:NO withData:nil], @"Should not throw for empty data.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:@"" atSelectionLoc:NSMakeRange(0, 1) inAttributedString:
                      [[NSMutableAttributedString alloc]initWithString:@"Q"] useSmaller:NO withData:nil], @"Should not throw for empty data.");

    XCTAssertNoThrow([testTypesetter parseTextForOperation:@"+" atSelectionLoc:NSMakeRange(5, 1) inAttributedString:
                      [[NSMutableAttributedString alloc]initWithString:@"Q"] useSmaller:NO withData:nil], @"Should not throw for out of bounds range.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:@"+" atSelectionLoc:NSMakeRange(NSNotFound, 1) inAttributedString:
                      [[NSMutableAttributedString alloc]initWithString:@"Q"] useSmaller:NO withData:nil], @"Should not throw for not found range.");
    XCTAssertNoThrow([testTypesetter parseTextForOperation:@"+" atSelectionLoc:NSMakeRange(1, 0) inAttributedString:
                      [[NSMutableAttributedString alloc]initWithString:@"Q"] useSmaller:NO withData:nil], @"Should not throw for empty range.");
}

- (void) testSizeRenderData
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(sizeRenderData:)], @"Should respond to sizeRenderData: method.");
    XCTAssertNoThrow([testTypesetter sizeRenderData:nil], @"Should not throw for nil renderData.");

    NSArray *testEmptyArray = @[];
    XCTAssertNoThrow([testTypesetter sizeRenderData:testEmptyArray], @"Should not throw for empty renderData.");

    NSArray *testBadArray = @[@"Q"];
    XCTAssertNoThrow([testTypesetter sizeRenderData:testBadArray], @"Should not throw for bad renderData.");

    EQRenderData *testRenderData = [[EQRenderData alloc] initWithString:@"Q"];
    CGRect testTypoRect = testRenderData.boundingRectTypographic;
    CGRect testImageRect = testRenderData.boundingRectImage;

    NSArray *testGoodArray = @[testRenderData];
    XCTAssertNoThrow([testTypesetter sizeRenderData:testGoodArray], @"Should not throw for good renderData.");
    XCTAssertFalse(CGRectEqualToRect(testTypoRect, testRenderData.boundingRectTypographic), @"Should have updated typographic bounds.");
    XCTAssertFalse(CGRectEqualToRect(testImageRect, testRenderData.boundingRectImage), @"Should have updated image bounds.");
}

- (void) testLayoutRenderStemsFromRoot
{
    XCTAssertNoThrow(testTypesetter.typesetterDelegate = testDelegate, @"Should not throw when setting typesetterDelegate.");
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(layoutRenderStemsFromRoot:)], @"Should respond to layoutRenderStemsFromRoot: method.");
    XCTAssertNoThrow([testTypesetter layoutRenderStemsFromRoot:nil], @"Should not throw for nil root stem.");
    XCTAssertNoThrow([testTypesetter layoutRenderStemsFromRoot:(EQRenderStem *)[NSNull null]], @"Should not throw for bad root stem.");

    EQRenderStem *testRootStem = [[EQRenderStem alloc] init];
    testRootStem.stemType = stemTypeRoot;
    XCTAssertNoThrow([testTypesetter layoutRenderStemsFromRoot:testRootStem], @"Should not throw for empty root stem.");

    // Remaining items are dependent upon putting other data into the typesetter delegate, which makes some things difficult.
    XCTAssertTrue([testDelegate functionCallsForKey:@"getRenderDataForRootStem:"] == 1, @"Should call getRenderDataForRootStem: with empty data.");
}

- (void) testGetSelectionStyle
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(getSelectionStyle)], @"Should respond to method call.");
    NSDictionary *testDict = @{};
    XCTAssertNoThrow(testDict = [testTypesetter getSelectionStyle], @"Should not throw with no delegate.");
    XCTAssertNil(testDict, @"Should return nil with no delegate.");

    testDict = @{};
    testTypesetter.typesetterDelegate = testDelegate;
    XCTAssertNoThrow(testDict = [testTypesetter getSelectionStyle], @"Should not throw with no data.");
    XCTAssertNil(testDict, @"Should return nil with no data.");

    [testDelegate addData:@"foo"];
    XCTAssertTrue([testDelegate hasData], @"Should not be empty here.");
    testDict = nil;
    XCTAssertNoThrow(testDict = [testTypesetter getSelectionStyle], @"Should not throw with no data.");
    XCTAssertNotNil(testDict, @"Should return not be nil with data.");
}

- (void) testApplyStyleToSelection
{
    XCTAssertTrue([testTypesetter respondsToSelector:@selector(applyStyleToSelection:)], @"Should respond to method call.");
    XCTAssertNoThrow([testTypesetter applyStyleToSelection:nil], @"Should not throw with nil input data.");
}

@end

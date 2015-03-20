//
//  MockEquationViewDataSource.m
//  eq-library
//
//  Created by Raymond Hodgson on 31/08/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
//
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "MockEquationViewDataSource.h"
#import "EQTextPosition.h"
#import "EQTextRange.h"
#import "EQRenderData.h"
#import "EQRenderStem.h"

@implementation MockEquationViewDataSource

- (id)init
{
    self = [super init];
    if (self)
    {
        self->dataString = [[NSMutableString alloc] init];
        self->functionDictionary = [[NSMutableDictionary alloc] init];
        self->markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
        self->selectedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
    }
    return self;
}

/*
    Internal methods for getting/setting data source.
*/

- (void) setDataEmpty
{
    dataString = [[NSMutableString alloc] init];
}

- (NSString *)getInternalDataString
{
    return [NSString stringWithString:dataString];
}

- (NSRange)getInternalMarkedRange
{
    return markedTextRange.range;
}

- (NSRange)getInternalSelectedRange
{
    return selectedTextRange.range;
}

/*
    Internal methods for tracking function calls.
*/

- (void)resetFunctionCalls
{
    self->functionDictionary = nil;
    self->functionDictionary = [[NSMutableDictionary alloc] init];
}

- (void)resetDataAndFunctionCalls
{
    [self setDataEmpty];
    [self resetFunctionCalls];
}

- (void)reportFunctionCalls
{
    NSLog(@"\n\nFunction calls for Data Source:\n");

    for (NSString *functionKey in self->functionDictionary)
    {
        NSNumber *functionValue = functionDictionary[functionKey];
        NSLog(@"\n\t'%@' : %i times\n", functionKey, [functionValue intValue]);
    }
    NSLog(@"\nEnd calls for Data Source\n\n");
}

- (NSInteger)functionCallsForKey: (NSString *)key
{
    NSNumber *count = functionDictionary[key];
    if (nil != count)
        return [count integerValue];

    return 0;
}


- (void)incrementCounterForKey: (NSString *)key
{
    NSAssert(nil != key, @"Passed nil string as key");
    NSAssert(![key isEqualToString:@""], @"Passed empty string as key");

    NSNumber *count = functionDictionary[key];
    NSInteger c = 0;

    if (nil != count)
    {
        c = [count integerValue];
    }

    c++;
    count = [NSNumber numberWithInteger:c];
    functionDictionary[key] = count;
}


/*
    Equation View DataSource protocol methods
*/

- (UIView *)currentView
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    UIView *emptyView = [[UIView alloc]init];
    return emptyView;
}

- (Boolean) hasData
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [dataString length];
}

- (void) addData: (id)newData
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    if ([newData isKindOfClass:[NSString class]])
    {
        [dataString appendString:(NSString *)newData];
    }
}

- (void) deleteBackward
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    if (dataString.length > 0)
        [dataString deleteCharactersInRange:NSMakeRange((dataString.length -1), 1)];
}

- (void) clearData
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    dataString = [[NSMutableString alloc]initWithString:@""];
}

- (EQTextPosition *)beginningOfDocument
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

- (EQTextPosition *)endOfDocument
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextPosition textPositionWithIndex:dataString.length andLocation:0 andEquationLoc:0];
}

- (EQTextRange *)getMarkedTextRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return self->markedTextRange;
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (EQTextRange *)getSelectedTextRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return self->selectedTextRange;
}

- (void)setSelectedTextRange: (EQTextRange *)textRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    self->selectedTextRange = textRange;
}

- (NSString *)textForRange: (EQTextRange *)textRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return @"";
}

- (EQTextPosition *)positionFromPosition:(EQTextPosition *)textPosition offset:(NSInteger)offset
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

- (EQTextPosition *)closestSafePositionFromPosition:(EQTextPosition *)textPosition offset:(NSInteger)offset
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

- (NSInteger)offsetFromPosition:(EQTextPosition *)from toPosition:(EQTextPosition *)toPosition
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return 0;
}

- (EQTextRange *)textRangeFromPosition:(EQTextPosition *)fromPosition toPosition:(EQTextPosition *)toPosition
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
}

- (EQTextRange *)textRangeByExtendingPosition: (EQTextPosition *) textPosition inDirection: (UITextLayoutDirection)direction
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
}

- (NSComparisonResult)compareTextPosition:(EQTextPosition *)position toPosition:(EQTextPosition *)other
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return NSOrderedSame;
}

- (EQTextPosition *)textPositionWithinRange:(EQTextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

// Selection methods. Not Yet Implemented.
- (CGRect)firstRectForRange: (EQTextRange *)range
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return CGRectMake(15, 15, 0, 0);
}

- (CGRect)getCursorRectForPosition: (EQTextPosition *)textPosition
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return CGRectMake(15, 15, 0, 0);
}

- (NSArray *)selectionRectsForRange:(EQTextRange *)range
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return nil;
}

- (EQTextRange *)characterRangeAtPoint: (CGPoint)point
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
}

- (EQTextPosition *)closestPositionToPoint: (CGPoint)point
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

- (EQTextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(EQTextRange *)range
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

- (NSDictionary *)textStylingAtPosition:(EQTextPosition *)position
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];

    // For now, assume all text is single-styled.
    return @{ NSFontAttributeName : [UIFont systemFontOfSize:12.0] };
}

- (void)unmarkText
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)replaceDataInRange: (EQTextRange *)textRange withData: (id)data
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)beginSelectionDrag
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)endSelectionDrag
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (CGPoint)currentCursorLoc
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return CGPointZero;
}

- (void)sendViewNeedsReloaded
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)sendEditingWillBegin
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)sendEditingDidBegin
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)sendEditingWillEnd
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)sendEditingDidEnd
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (EQTextRange *)getNearestWordOrSelectionAtPosition: (EQTextPosition *)textPosition;
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
}

//  ******************************
//  EQ Typesetter Delegate Methods
//  ******************************

// Naive method called by typesetter to send final reposition.
- (void)sendUpdateMarkedTextRange:(EQTextRange *)textRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    self->markedTextRange = textRange;
}

// Naive method called by typesetter to send final reposition.
- (void)sendUpdateSelectedTextRange:(EQTextRange *)textRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    self->selectedTextRange = textRange;
}

- (NSArray *) getRenderData
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    EQRenderData *newData = [[EQRenderData alloc]initWithString:dataString];
    newData.drawOrigin = CGPointMake(20.0f, 20.0f);
    CGRect imageBounds = [newData imageBounds];
    newData.boundingRectImage = imageBounds;
    newData.boundingRectTypographic = [newData typographicBounds];

    return [NSArray arrayWithObject:newData];
}

- (NSArray *)getRenderDataForRootStem: (EQRenderStem *)rootStem
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    EQRenderData *newData = [[EQRenderData alloc]initWithString:dataString];
    newData.drawOrigin = CGPointMake(20.0f, 20.0f);
    CGRect imageBounds = [newData imageBounds];
    newData.boundingRectImage = imageBounds;
    newData.boundingRectTypographic = [newData typographicBounds];

    return [NSArray arrayWithObject:newData];
}

- (void) updateRenderDataAddObject: (id)object
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void) updateRenderData: (id)object atLocation: (NSUInteger)location
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void) updateRenderData: (NSArray *)newRenderData
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (EQRenderStem *)getRootStem
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return nil;
}

- (void)replaceRootWithStem: (EQRenderStem *)newRootStem
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)sendFinishedUpdating
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)addNewEquationLine
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)handleDeleteBackwardOnEmptyEquation
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (NSString *)buildActiveXMLStringWithOptions: (NSDictionary *)options
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return nil;
}

- (UIImage *)buildActiveImageWithOptions: (NSDictionary *)options
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return nil;
}


/************************
 * Undo related methods *
 ************************/


- (void)setUndoForAddTextInRange: (EQTextRange *)textRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForAddTextInRange:(EQTextRange *)textRange withStoredAttrStr: (NSAttributedString *)storedAttrStr
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForDeleteText: (NSString *)text inRange: (EQTextRange *)textRange
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForDeleteStem: (EQRenderStem *)useStem fromParent: (EQRenderStem *)parentStem
                  atLocation: (NSUInteger)renderLoc forEquationLoc: (NSUInteger)equLoc
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForAddStem: (EQRenderStem *)useStem toParent: (EQRenderStem *)parentStem forEquationLoc: (NSUInteger)equLoc
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForReplaceData: (EQRenderData *)oldRenderData withNewStem: (EQRenderStem *)renderStem
                andParentStem: (EQRenderStem *)parentStem forEquationLoc: (NSUInteger)equLoc
        andUndoNewData: (EQRenderData *)newRenderData
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForDeleteDataAtLoc:(NSUInteger)dataLoc fromParent:(EQRenderStem *)parentStem
                       withString:(NSAttributedString *)saveString forEquationLoc:(NSUInteger)equationLoc
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForReplaceData:(EQRenderData *)oldRenderData oldString:(NSAttributedString *)oldString
                  withNewStem:(EQRenderStem *)renderStem andParentStem:(EQRenderStem *)parentStem
               forEquationLoc:(NSUInteger)equLoc andUndoNewData:(EQRenderData *)newRenderData
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForAddData:(EQRenderData *)newData toParent:(EQRenderStem *)parentStem forEquationLoc:(NSUInteger)equationLoc
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)setUndoForReplaceStem:(EQRenderStem *)oldStem atLoc:(NSUInteger)oldLoc withStem:(EQRenderStem *)newStem
                   andNewData:(EQRenderData *)newData inParent:(EQRenderStem *)parentStem forEquationLoc:(NSUInteger)equationLoc
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (NSUndoManager *)getUndoManager
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)canUndo
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return NO;
}

- (BOOL)canRedo
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return NO;
}

- (void)sendUndo
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (void)sendRedo
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

/*******************************
* Custom style related methods *
********************************/

- (void)sendUpdateStyle:(NSDictionary *)styleDictionary
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

- (NSDictionary *)activeStyle
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return nil;
}

- (NSDictionary *)storedStyle
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
    return nil;
}

- (void)sendUpdateActiveAlign:(RenderViewAlign)newAlignment
{
    [self incrementCounterForKey:NSStringFromSelector(_cmd)];
}

@end

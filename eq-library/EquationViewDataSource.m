//
//  EquationViewDataSource.m
//  EQ Editor
//
//  Created by Raymond Hodgson on 31/08/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "EquationViewDataSource.h"
#import "EQRenderData.h"
#import "EQStyleConstants.h"
#import "EQInputData.h"
#import "EQRenderFontDictionary.h"
#import "EQDataSourceState.h"

NSString* const kDEFAULT_CURSOR_FONT = @"STIXGeneral-Regular";
CGFloat const kDEFAULT_CURSOR_SIZE = 15.0;

NSString* const kDEFAULT_LABEL_FONT = @"STIXGeneral-Regular";
CGFloat const kDEFAULT_LABEL_SIZE = 24.0;

@interface EquationViewDataSource()

@property (nonatomic) StyleType selectedStyle;
@property (nonatomic) BOOL useBoldText;
@property (nonatomic) BOOL useItalicText;

- (void)sendViewUpdate;
- (void)sendUpdateAllViews;
- (EQRenderData *)dataContainingTextPosition: (EQTextPosition *)textPosition;
- (EQRenderData *)dataContainingTextRange: (EQTextRange *)textRange;
- (void)changeActiveEquationToLine: (NSUInteger)newEquationLine;
- (Boolean)currentEquationIsEmpty;

@end

@implementation EquationViewDataSource

- (id)init
{
    self = [super init];
    if (self)
    {
        self->markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
        self->selectedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
        self->equationLines = [[NSMutableArray alloc] init];
        self->renderData = [[NSMutableArray alloc] init];
        [equationLines addObject:renderData];
        self->activeEquationLine = [equationLines indexOfObject:renderData];
        self->rootRenderStem = [[EQRenderStem alloc] init];
        self->rootRenderStem.stemType = stemTypeRoot;
        self->rootRenderStem.drawOrigin = CGPointMake(40.0f, 40.0f);
        self->equationStems = [[NSMutableArray alloc] init];
        [equationStems addObject:rootRenderStem];
        self->_typesetter = nil;
        self->_selectedStyle = displayMathStyle;
        self->_useBoldText = NO;
        self->_useItalicText = NO;
    }

    return self;
}

/*
    Internal methods
*/

- (void)sendViewUpdate
{
    if (!self.hasData)
    {
        rootRenderStem = equationStems[activeEquationLine];
    }
    else
    {
        if (nil != self.typesetter)
        {
            [self.typesetter sizeRenderData:renderData];
            [self.typesetter layoutRenderStemsFromRoot:rootRenderStem];
        }
    }

    // Copy the current renderData back into the equation line.
    equationLines[activeEquationLine] = renderData;
    equationStems[activeEquationLine] = rootRenderStem;
}

// Tell the typesetter to layout all equation lines again.
- (void)sendUpdateAllViews
{
    [self sendUpdateViewsAfterLocation:0];
}

- (void)sendUpdateViewsAfterLocation: (NSUInteger)startLoc
{
    if (nil == self.typesetter)
        return;

    for (NSUInteger i = startLoc; i < self->equationStems.count; i ++)
    {
        EQRenderStem *rootStem = [self->equationStems objectAtIndex:i];
        NSArray *renderArray = [self->equationLines objectAtIndex:i];
        NSAssert(nil != renderArray, @"Missing required render array when updating views.");
        NSAssert(nil != rootStem, @"Missing required root stem when updating views.");

        [self.typesetter sizeRenderData:renderArray];
        [self.typesetter layoutRenderStemsFromRoot:rootStem];
    }
}


- (EQRenderData *)dataContainingTextPosition: (EQTextPosition *)textPosition
{
    NSUInteger equationIndex = textPosition.equationLoc;
    if (nil == equationLines || equationIndex >= equationLines.count)
    {
        return nil;
    }

    NSMutableArray *equationRenderArray = equationLines[equationIndex];

    if (nil == equationRenderArray || equationRenderArray.count == 0)
        return nil;

    if (nil == textPosition || textPosition.index == NSNotFound || textPosition.dataLoc >= equationRenderArray.count)
    {
        return nil;
    }

    EQRenderData *returnData = [equationRenderArray objectAtIndex:textPosition.dataLoc];
    if (textPosition.index > returnData.renderString.length)
        return nil;

    return returnData;
}

- (EQRenderData *)dataContainingTextRange: (EQTextRange *)textRange
{
    NSUInteger equationIndex = textRange.equationLoc;
    if (nil == equationLines || equationIndex >= equationLines.count)
    {
        return nil;
    }

    NSMutableArray *equationRenderArray = equationLines[equationIndex];

    if (nil == equationRenderArray || equationRenderArray.count == 0)
        return nil;

    if (nil == textRange || textRange.range.location == NSNotFound || textRange.dataLoc > equationRenderArray.count)
        return nil;

    EQRenderData *returnData = [equationRenderArray objectAtIndex:textRange.dataLoc];
    if (textRange.range.location > returnData.renderString.length
        || (textRange.range.location + textRange.range.length > returnData.renderString.length))
    {
        return nil;
    }

    return returnData;
}

/*
    Equation View Data Source protocol methods
*/

- (void)sendViewNeedsReloaded
{
    if (nil == self.typesetter)
    {
        self.typesetter = [[EQRenderTypesetter alloc] init];
        self.typesetter.typesetterDelegate = self;
    }
    [self sendUpdateAllViews];
}

- (void)sendEditingWillBegin
{
    if (nil == self.typesetter)
    {
        self.typesetter = [[EQRenderTypesetter alloc] init];
        self.typesetter.typesetterDelegate = self;
    }
}

- (void)sendEditingDidBegin
{
    [self sendViewUpdate];
}


- (void)sendEditingWillEnd
{
    self.typesetter.typesetterDelegate = nil;
    self.typesetter = nil;
}

- (void)sendEditingDidEnd
{
    // Reset the marked and selected locations.
    self->markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
    self->selectedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
}

- (Boolean) hasData
{
    if (nil == renderData || renderData.count == 0)
        return FALSE;
    if (renderData.count == 1 && equationLines.count == 1)
    {
        EQRenderData *testData = [renderData objectAtIndex:0];
        if (testData.renderString.length == 0)
            return FALSE;
    }
    return TRUE;
}

- (Boolean)currentEquationIsEmpty
{
    if (nil == renderData || renderData.count == 0)
        return TRUE;

    if (renderData.count == 1)
    {
        EQRenderData *testData = [renderData objectAtIndex:0];
        if (testData.renderString.length == 0 || [testData.renderString.string isEqualToString:@" "])
            return TRUE;
    }

    return FALSE;
}

- (void) addData: (id)newData
{
    NSAssert(nil != self.typesetter, @"Typesetter must be initialized before adding data.");

    if ([newData isKindOfClass:[NSString class]] && self.selectedStyle == textStyle)
    {
        EQInputData *addData = [[EQInputData alloc] initWithStemType:inputTypeText];
        addData.storedCharacterData = newData;
        [self.typesetter addData:addData];
    }
    else if ([newData isKindOfClass:[NSString class]])
    {
        newData = [self applyStyleToData:newData];
        [self.typesetter addData:newData];
    }
    else
    {
        [self.typesetter addData:newData];
    }
}

- (void)replaceDataInRange: (EQTextRange *)textRange withData: (id)data
{
    [self.typesetter replaceDataInRange:textRange withData:data];
}

- (void) clearData
{
    self->renderData = [[NSMutableArray alloc]init];
    self->rootRenderStem = nil;

    self->rootRenderStem = [[EQRenderStem alloc] init];
    self->rootRenderStem.stemType = stemTypeRoot;
    EQRenderData *newData = [[EQRenderData alloc] initWithString:@""];
    [rootRenderStem appendChild:newData];
    [renderData addObject:newData];

    markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
    selectedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:0];
    self->equationLines = [[NSMutableArray alloc] initWithObjects:renderData, nil];
    self->equationStems = [[NSMutableArray alloc] initWithObjects:rootRenderStem, nil];
    self->activeEquationLine = 0;
    [self sendViewUpdate];
}

- (void) deleteBackward
{
    [self.typesetter deleteBackward];
}

- (EQTextPosition *)beginningOfDocument
{
    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

- (EQTextPosition *)endOfDocument
{
    if (!self.hasData)
        return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];

    NSUInteger lastEquationLoc = equationStems.count - 1;
    EQRenderStem *lastStem = self->equationStems[lastEquationLoc];
    NSMutableArray *lastEquationLine = self->equationLines[lastEquationLoc];

    if (nil != lastStem && nil != lastEquationLine)
    {
        id lastObj = [lastStem getLastDescendent];
        if (nil != lastObj && [lastObj isKindOfClass:[EQRenderData class]])
        {
            NSUInteger lastDataLoc = [lastEquationLine indexOfObject:lastObj];
            if (lastDataLoc != NSNotFound)
            {
                NSUInteger usePos = [(EQRenderData *)lastObj renderString].length;
                return [EQTextPosition textPositionWithIndex:usePos andLocation:lastDataLoc andEquationLoc:lastEquationLoc];
            }
        }
    }

    return [EQTextPosition textPositionWithIndex:0 andLocation:0 andEquationLoc:0];
}

- (EQTextRange *)getMarkedTextRange
{
    EQTextRange *returnMarked = [self->markedTextRange copy];
    return returnMarked;
}

// Assume that you aren't changing the equation locations.
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    if (!self.hasData)
        return;

    EQRenderData *markedData = [self dataContainingTextRange:markedTextRange];
    EQRenderData *selectedData = [self dataContainingTextRange:selectedTextRange];
    NSRange selectedNSRange = selectedTextRange.range;
    NSRange markedNSTextRange = markedTextRange.range;
    NSUInteger markedLoc = markedTextRange.dataLoc;
    NSUInteger selectedLoc = selectedTextRange.dataLoc;
    NSUInteger markedEqLoc = markedTextRange.equationLoc;
    NSUInteger selectedEqLoc = selectedTextRange.equationLoc;

    if (nil != markedData)
    {
        if (!markedText)
            markedText = @"";
		// Replace characters in text storage and update markedText range length.
        [markedData replaceCharactersInRange:markedTextRange withText:markedText];
        markedNSTextRange.length = markedText.length;
    }
    else if (nil != selectedData)
    {
        if (selectedNSRange.length > 0)
        {
            // There currently isn't a marked text range, but there is a selected range,
            // so replace text storage at selected range and update markedTextRange.
            [selectedData replaceCharactersInRange:selectedTextRange withText:markedText];
            markedNSTextRange.location = selectedNSRange.location;
            markedNSTextRange.length = markedText.length;
        }
        else
        {
            // There currently isn't marked or selected text ranges, so just insert
            // given text into storage and update markedTextRange.
            [selectedData insertText:markedText atPosition:selectedTextRange.textPosition];
            markedNSTextRange.location = selectedNSRange.location;
            markedNSTextRange.length = markedText.length;
        }
    }

	// Updated selected text range and view.
    selectedNSRange = NSMakeRange(selectedRange.location + markedNSTextRange.location, selectedRange.length);

    markedTextRange = [EQTextRange textRangeWithRange:markedNSTextRange andLocation:markedLoc andEquationLoc:markedEqLoc];
    selectedTextRange = [EQTextRange textRangeWithRange:selectedNSRange andLocation:selectedLoc andEquationLoc:selectedEqLoc];
    [self sendViewUpdate];
}

- (EQTextRange *)getSelectedTextRange
{
    return [self->selectedTextRange copy];
}

- (void)setSelectedTextRange: (EQTextRange *)textRange
{
    // These errors happen because the data may not have been stored correctly.
    // Generally these will cause crashes unless checked out.
    NSAssert(nil != renderData, @"Should not have nil render data here.");
    NSAssert(renderData.count > 0, @"Should have at least one child item.");
    if (![self rangeExistsInEquation:textRange])
    {
        self->selectedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
        return;
    }

    if ([self rangeExistsInEquation:selectedTextRange])
    {
        // Order matters here, as sometimes you are changing the range within the same data location.
        EQRenderData *oldData = [self dataContainingTextRange:selectedTextRange];
        oldData.containsSelection = NO;
        oldData.needsRedrawn = YES;
    }

    // After updating the old location, you need to check and see if you are changing active equation or not.
    NSUInteger newEquationLoc = textRange.equationLoc;
    if (newEquationLoc != activeEquationLine)
    {
        [self changeActiveEquationToLine:newEquationLoc];
    }
    else
    {
        EQRenderData *updatedData = [renderData objectAtIndex:textRange.dataLoc];
        updatedData.containsSelection = YES;
        updatedData.needsRedrawn = YES;
    }

    self->selectedTextRange = textRange;
    [self sendViewUpdate];
}

- (NSString *)textForRange: (EQTextRange *)textRange
{
    EQRenderData *useData = [self dataContainingTextRange:textRange];
    if (nil == useData || textRange.range.location > useData.renderString.length)
        return @"";

    if (textRange.range.length == 0 || (textRange.range.location + textRange.range.length) > useData.renderString.length)
        return @"";
    
    return [useData.renderString.string substringWithRange:textRange.range];
}


// Computing and adjusting position and selections.
// Assume they are all in the same renderData for now.

// Used internally to prevent the next two repeating their code.
- (EQTextPosition *)computePositionFromPosition: (EQTextPosition *)textPosition offset: (NSInteger)offset useSafe: (BOOL)useSafe
{
    EQRenderData *useData = [self dataContainingTextPosition:textPosition];
    if (nil == useData || self.hasData == NO)
        return nil;

    NSInteger end = textPosition.index + offset;
    // useSafe == NO is the case required by the UITextInterface.
    // However, you may want to return a safe location if outside the accepted range in some internal cases.
    // the useSafe == YES branch does that instead.
    if (useSafe == NO)
    {
        if (useData.renderString.length == 0)
            return nil;

        if (end > useData.renderString.length || end < 0)
            return nil;
    }
    else
    {
        if (end > 0 && end > useData.renderString.length)
        {
            end = useData.renderString.length;
        }
        else if (end <= 0)
        {
            end = 0;
        }
    }

    return [EQTextPosition textPositionWithIndex:end andLocation:textPosition.dataLoc andEquationLoc:textPosition.equationLoc];
}
- (EQTextPosition *)positionFromPosition:(EQTextPosition *)textPosition offset:(NSInteger)offset
{
    return [self computePositionFromPosition:textPosition offset:offset useSafe:NO];
}

// Previous one is part of the UITextInterface, but you may just want it to return a safe location if it is outside the accepted range.
- (EQTextPosition *)closestSafePositionFromPosition: (EQTextPosition *)textPosition offset:(NSInteger)offset
{
    return [self computePositionFromPosition:textPosition offset:offset useSafe:YES];
}


- (NSInteger)offsetFromPosition:(EQTextPosition *)from toPosition:(EQTextPosition *)toPosition
{
    return (from.index - toPosition.index);
}

- (EQTextRange *)textRangeFromPosition:(EQTextPosition *)fromPosition toPosition:(EQTextPosition *)toPosition
{
    NSRange range = NSMakeRange(MIN(fromPosition.index, toPosition.index), ABS(toPosition.index - fromPosition.index));
    
    return [EQTextRange textRangeWithRange:range andLocation:toPosition.dataLoc andEquationLoc:toPosition.equationLoc];
}

// Assumes Right to Left direction, as it should.
- (EQTextRange *)textRangeByExtendingPosition: (EQTextPosition *) textPosition inDirection: (UITextLayoutDirection)direction
{
    if (self.hasData == NO)
        return [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:textPosition.dataLoc andEquationLoc:textPosition.equationLoc];

    EQRenderData *useData = [self dataContainingTextPosition:textPosition];
    if (nil == useData)
        return [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:textPosition.dataLoc andEquationLoc:textPosition.equationLoc];

    NSRange result;
    
    if (textPosition.index == 0 && (direction == UITextLayoutDirectionLeft || direction == UITextLayoutDirectionUp) )
    {
        return [EQTextRange textRangeWithRange:NSMakeRange(textPosition.index, 1) andLocation:textPosition.dataLoc andEquationLoc:textPosition.equationLoc];
    }
    if (textPosition.index == useData.renderString.length && (direction == UITextLayoutDirectionRight || direction == UITextLayoutDirectionDown) )
    {
        return [EQTextRange textRangeWithRange:NSMakeRange(useData.renderString.length - 1, 1) andLocation:textPosition.dataLoc andEquationLoc:textPosition.equationLoc];
    }

    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            result = NSMakeRange(textPosition.index - 1, 1);
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            result = NSMakeRange(textPosition.index, 1);
            break;
    }

    return [EQTextRange textRangeWithRange:result andLocation:textPosition.dataLoc andEquationLoc:textPosition.equationLoc];
}

- (NSComparisonResult)compareTextPosition:(EQTextPosition *)position toPosition:(EQTextPosition *)other
{
    return [EQTextPosition compareTextPosition:position toPosition:other];
}

- (EQTextPosition *)textPositionWithinRange:(EQTextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
    NSInteger position;
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            position = range.range.location;
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            position = range.range.location + range.range.length;
            break;
    }
    
	// Return text position using our UITextPosition implementation.
	// Note that position is not currently checked against document range.
    return [EQTextPosition textPositionWithIndex:position andLocation:range.dataLoc andEquationLoc:range.equationLoc];
}

/*
 *  Called by UITextInput protocol required method:
 *      - (NSArray *)selectionRectsForRange:(UITextRange *)range
 *
 *  Returns an array of UITextSelectionRects. Mainly used by system selection rect and loupe view.
 *  Unfortunately, you have to subclass UITextView to make those work.
 *  Might be useful for your own custom implementation anyway.
 */

- (NSDictionary *)textStylingAtPosition:(EQTextPosition *)position
{
    // For now, assume all text is single-styled.
    // Can expand this once we have more rendering in place.
    return @{ NSFontAttributeName : [UIFont fontWithName:kDEFAULT_LABEL_FONT size:kDEFAULT_LABEL_SIZE] };
}

- (void)unmarkText
{
    markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
}


// Custom methods used to help get selected words.
// Will look backwards to nearest word.
// If your character at textPosition is a whitespace, will look ahead to nearest instead.
// If your character at textPosition is not whitespace, and it is not contained by the position,
// it will just turn a range of length one containing the textPosition.

- (EQTextRange *)getNearestWordOrSelectionAtPosition: (EQTextPosition *)textPosition;
{
    EQTextRange *notFound = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:0];
    if (nil == textPosition || textPosition.index == NSNotFound)
        return notFound;

    EQRenderData *nearestData = [self dataContainingTextPosition:textPosition];
    if (nil == nearestData || textPosition.index > nearestData.renderString.length || nearestData.renderString.length == 0)
        return notFound;

    EQTextRange *characterRange = [self textRangeByExtendingPosition:textPosition inDirection:UITextLayoutDirectionLeft];
    if (characterRange.range.location == NSNotFound || characterRange.range.location > nearestData.renderString.length)
        return notFound;

    // Need to test and see if you have whitespace at the location.
    // If so, then set it to look for the next word rather than the previous word.
    NSString *characterStr = [nearestData.renderString.string substringWithRange:characterRange.range];
    NSRange testRange = [characterStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    Boolean hasWhitespace = (testRange.location != NSNotFound);
    NSInteger useEnumeration = NSStringEnumerationReverse;
    NSRange useRange = NSMakeRange(0, textPosition.index);
    if (hasWhitespace)
    {
        useEnumeration = 0;
        useRange = NSMakeRange(textPosition.index, nearestData.renderString.length - textPosition.index);
    }

    // Find the last or next word in the usable range.
    __block NSString *lastWord;
    __block NSRange lastWordRange;
    [nearestData.renderString.string enumerateSubstringsInRange:useRange options:(NSStringEnumerationByWords | useEnumeration)
                                        usingBlock: ^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop)
     {
         lastWord = subString;
         lastWordRange = subStringRange;
         *stop = YES;
     }];

    NSInteger useDirection = UITextLayoutDirectionLeft;
    if (nil == lastWord || lastWordRange.location == NSNotFound)
    {
        // If you're at the first location, and it is valid,
        // select rightward instead of leftward. Otherwise, return.
        if (textPosition.index == 0 && nearestData.renderString.length > 0)
        {
            useDirection = UITextLayoutDirectionRight;
        }
        // You may not have a recognized word character.
        else if (!hasWhitespace)
        {
            NSRange testLetterRange = [nearestData.renderString.string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
            if (testLetterRange.location == NSNotFound)
                useDirection = UITextLayoutDirectionLeft;
            else
                return notFound;
        }
        else
            return notFound;
    }

    // If the last word does not contain the character you want, then return an extension instead.
    if (lastWordRange.location > textPosition.index || lastWordRange.location + lastWordRange.length < textPosition.index)
        return [self textRangeByExtendingPosition:textPosition inDirection:useDirection];

    return [EQTextRange textRangeWithRange:lastWordRange andLocation:textPosition.dataLoc andEquationLoc:textPosition.equationLoc];
}



//  ******************************
//  EQ Typesetter Delegate Methods
//  ******************************

// Called by typesetter to send final reposition.
// Typesetter does not have access to the current equation location, so update that.
- (void)sendUpdateMarkedTextRange:(EQTextRange *)textRange
{
    textRange.equationLoc = activeEquationLine;
    self->markedTextRange = textRange;
}

// Called by typesetter to send final reposition.
// Typesetter does not have access to the current equation location, so update that.
- (void)sendUpdateSelectedTextRange:(EQTextRange *)textRange
{
    textRange.equationLoc = activeEquationLine;
    self->selectedTextRange = textRange;
}

- (NSMutableArray *) getRenderData
{
    return self->renderData;
}

- (NSMutableArray *) getRenderDataForRootStem: (EQRenderStem *)rootStem
{
    if (nil == rootStem)
        return nil;

    NSUInteger rootLoc = [self->equationStems indexOfObject:rootStem];
    if (rootLoc != NSNotFound && rootLoc < equationLines.count)
    {
        return [equationLines objectAtIndex:rootLoc];
    }
    return nil;
}


- (void) updateRenderDataAddObject: (id)object
{
    [renderData addObject:object];
    [self sendViewUpdate];
}

- (void) updateRenderData: (id)object atLocation: (NSUInteger)location
{
    [renderData setObject:object atIndexedSubscript:location];
    [self sendViewUpdate];
}

// This should be called only after also performing those same updates
// in the rootStem object referring to them.
// Or passing in a new rootStem that refers to the newRenderData.
- (void) updateRenderData: (NSArray *)newRenderData
{
    self->renderData = nil;
    self->renderData = [[NSMutableArray alloc] initWithArray:newRenderData];
    [self sendViewUpdate];
}

// Since we're working directly with the internals,
// you should just tell the delegate you are finished updating and can now redraw.
- (void) sendFinishedUpdating
{
    [self sendViewUpdate];
}


- (EQRenderStem *)getRootStem
{
    return self->rootRenderStem;
}

// This shouldn't be called often unless you're sure all the pointers
// in the new root match what existed in the old root.
// Or you just want to throw out the old root completely.
- (void)replaceRootWithStem: (EQRenderStem *)newRootStem
{
    self->rootRenderStem = nil;
    if (nil == newRootStem)
    {
        newRootStem = [[EQRenderStem alloc] init];
        newRootStem.stemType = stemTypeRoot;
    }
    self->rootRenderStem = newRootStem;
}

- (void)addNewEquationLine
{
    NSUInteger newEquationLoc = activeEquationLine + 1;

    // Create a new renderStem first.
    EQRenderStem *newRenderStem = [[EQRenderStem alloc] init];
    newRenderStem.stemType = stemTypeRoot;
    newRenderStem.drawOrigin = CGPointMake(40.0f, 40.0f);

    // Create a new renderData and add it to existing equation lines.
    // You will also have to add empty render data in this case
    // to both the stem and the renderArray.
    EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
    [newRenderStem appendChild:newData];

    NSMutableArray *newRenderArray = [[NSMutableArray alloc] init];
    [newRenderArray addObject:newData];
    EQDataSourceState *newState = [EQDataSourceState dataSourceStateWithEquationLoc:newEquationLoc
                                                                     rootRenderStem:newRenderStem renderData:newRenderArray];
    [self addDataWithState:newState];
    [self sendUpdateViewsAfterLocation:newEquationLoc];
}

// Called internally to prevent code repetition.
// I leave it to the calling method to handle updating the views.
- (void)changeActiveEquationToLine: (NSUInteger)newEquationLine
{
    if (newEquationLine >= self->equationLines.count)
        return;

    // Update the old equation data one last time.
    equationLines[activeEquationLine] = renderData;
    equationStems[activeEquationLine] = rootRenderStem;

    self->activeEquationLine = newEquationLine;
    self->renderData = equationLines[newEquationLine];
    self->rootRenderStem = equationStems[newEquationLine];

    markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:activeEquationLine];
    selectedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:activeEquationLine];
}

// Called by the typesetter delegate when you have an empty equation and the delete key is pressed.
// Should test to see if you want to delete the current equation line or not and then delete if needed.
- (void)handleDeleteBackwardOnEmptyEquation
{
    if (self->equationLines.count > 1)
    {
        // Will need to hook the separate delete function into the undo/redo methods to make it undoable.
        [self deleteCurrentActiveEquation];
    }
}


/****************************
 * NSCoding support methods *
 ****************************/


// Make encoding and decoding as transparent as possible.
// That way you can just unpack the data instead of worrying about building any missing data.

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(1.0) forKey:@"DataSourceVersionNumber"];

    [aCoder encodeObject:self->markedTextRange forKey:@"markedTextRange"];
    [aCoder encodeObject:self->selectedTextRange forKey:@"selectedTextRange"];

    // To work correctly, all values in these arrays must conform to NSCoding.
    [aCoder encodeObject:self->equationLines forKey:@"equationLines"];
    [aCoder encodeObject:self->equationStems forKey:@"equationStems"];

    [aCoder encodeObject:@(self->activeEquationLine) forKey:@"activeEquationLine"];
    [aCoder encodeObject:self->rootRenderStem forKey:@"rootRenderStem"];
    [aCoder encodeObject:self->renderData forKey:@"renderData"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self)
    {
        NSNumber *versionNumber = [aDecoder decodeObjectForKey:@"DataSourceVersionNumber"];
        if (nil != versionNumber && versionNumber.doubleValue >= 1.0 && versionNumber.doubleValue < 2.0)
        {
            self->markedTextRange = [aDecoder decodeObjectForKey:@"markedTextRange"];
            self->selectedTextRange = [aDecoder decodeObjectForKey:@"selectedTextRange"];

            self->equationLines = [aDecoder decodeObjectForKey:@"equationLines"];
            self->equationStems = [aDecoder decodeObjectForKey:@"equationStems"];

            self->activeEquationLine = [(NSNumber *)[aDecoder decodeObjectForKey:@"activeEquationLine"] unsignedIntegerValue];
            self->rootRenderStem = [aDecoder decodeObjectForKey:@"rootRenderStem"];
            self->renderData = [aDecoder decodeObjectForKey:@"renderData"];
        }
    }

    return self;
}

/*****************************
 * Undo/Redo support methods *
 *****************************/

- (id)getActiveState
{
    if (!self.hasData)
    {
        return nil;
    }

    return [EQDataSourceState dataSourceStateWithEquationLoc:activeEquationLine rootRenderStem:rootRenderStem renderData:renderData];
}

// Set the current equation to match the given state and also update the equation data at the given equations.
- (void)setActiveState: (id)stateValue
{
    if (nil != stateValue && [stateValue isKindOfClass:[EQDataSourceState class]])
    {
        EQDataSourceState *newState = (EQDataSourceState *)stateValue;
        self->activeEquationLine = newState.equationLoc;

        self->rootRenderStem = newState.rootRenderStem;
        equationStems[activeEquationLine] = newState.rootRenderStem;

        self->renderData = newState.renderData;
        equationLines[activeEquationLine] = newState.renderData;

        [self sendViewUpdate];
    }
}

// Add and delete will need to be handled differently to be undoable.
- (void)addDataWithState: (id)stateValue
{
    if (nil != stateValue && [stateValue isKindOfClass:[EQDataSourceState class]])
    {
        EQDataSourceState *newState = (EQDataSourceState *)stateValue;
        NSUInteger newEquationLoc = newState.equationLoc;
        NSAssert(newEquationLoc <= equationLines.count, @"New data is out of equation line bounds.");
        NSAssert(newEquationLoc <= equationStems.count, @"New data is out of stem data bounds.");

        self->rootRenderStem = newState.rootRenderStem;
        [self->equationStems insertObject:rootRenderStem atIndex:newEquationLoc];

        markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:newEquationLoc];
        selectedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(0, 0) andLocation:0 andEquationLoc:newEquationLoc];
        self->activeEquationLine = newEquationLoc;

        self->renderData = newState.renderData;
        [self->equationLines insertObject:renderData atIndex:newEquationLoc];
    }
}

// Returns the current active state if successful or nil.
- (id)deleteCurrentActiveEquation
{
    if (equationLines.count == 0 || equationStems.count == 0)
        return nil;

    id returnState = [self getActiveState];
    [self deleteEquationWithState:returnState];

    return returnState;
}

- (void)deleteEquationWithState: (id)stateValue
{
    if (nil == self->equationLines || equationLines.count == 0 || nil == self->equationStems || equationStems.count == 0)
        return;

    if (nil != stateValue && [stateValue isKindOfClass:[EQDataSourceState class]])
    {
        EQDataSourceState *oldState = (EQDataSourceState *)stateValue;

        NSUInteger stateLoc = oldState.equationLoc;
        NSAssert(stateLoc <= equationLines.count, @"Old data is out of equation line bounds.");
        NSAssert(stateLoc <= equationStems.count, @"Old data is out of stem data bounds.");

        NSUInteger newActiveEquationLine = 0;
        BOOL deleteFirst = NO;

        if (stateLoc > 0)
        {
            newActiveEquationLine = stateLoc - 1;
        }
        else
        {
            deleteFirst = YES;
        }
        [equationLines removeObjectAtIndex:stateLoc];
        [equationStems removeObjectAtIndex:stateLoc];

        self->activeEquationLine = newActiveEquationLine;
        self->renderData = equationLines[newActiveEquationLine];
        self->rootRenderStem = equationStems[newActiveEquationLine];

        // Clear the marked text range.
        markedTextRange = [EQTextRange textRangeWithRange:NSMakeRange(NSNotFound, 0) andLocation:0 andEquationLoc:activeEquationLine];

        // Should move the selected to the end of the previous equation line, if possible.
        NSUInteger useEqLoc = 0;
        NSRange useRange = NSMakeRange(0, 0);

        id lastChild = [rootRenderStem getLastDescendent];
        if (deleteFirst == NO && nil != lastChild && [lastChild isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *lastData = (EQRenderData *)lastChild;
            NSUInteger lastLoc = [renderData indexOfObject:lastData];
            if (lastLoc != NSNotFound)
            {
                useEqLoc = lastLoc;
                useRange = NSMakeRange(lastData.renderString.length, 0);
            }
        }
        selectedTextRange = [EQTextRange textRangeWithRange:useRange andLocation:useEqLoc andEquationLoc:activeEquationLine];
    }
}


- (BOOL)positionExistsInEquation: (EQTextPosition *)testPosition
{
    if (nil != testPosition)
    {
        NSUInteger testEquLoc = testPosition.equationLoc;
        if (testEquLoc != NSNotFound && testEquLoc < equationLines.count && testEquLoc < equationStems.count)
        {
            NSMutableArray *useEquationLine = equationLines[testEquLoc];
            NSUInteger testDataLoc = testPosition.dataLoc;
            if (nil != useEquationLine && testDataLoc != NSNotFound && testDataLoc < useEquationLine.count)
            {
                id testObj = useEquationLine[testDataLoc];
                if (nil != testObj)
                {
                    if ([testObj isKindOfClass:[EQRenderData class]])
                    {
                        EQRenderData *testData = (EQRenderData *)testObj;
                        NSUInteger testIndex = testPosition.index;
                        if (testIndex != NSNotFound && testIndex <= testData.renderString.length)
                        {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    return NO;
}

// Tests if range exists in the equation, adding an additional index if you are testing for delete.
- (BOOL)rangeExistsInEquation: (EQTextRange *)testRange testForDelete: (BOOL)testForDelete additionalLength: (NSInteger)addLength
{
    if (nil != testRange)
    {
        NSUInteger testEquLoc = testRange.equationLoc;
        if (testEquLoc != NSNotFound && testEquLoc < equationLines.count && testEquLoc < equationStems.count)
        {
            NSMutableArray *useEquationLine = equationLines[testEquLoc];
            NSUInteger testDataLoc = testRange.dataLoc;
            if (nil != useEquationLine && testDataLoc != NSNotFound && testDataLoc < useEquationLine.count)
            {
                id testObj = useEquationLine[testDataLoc];
                if (nil != testObj)
                {
                    if ([testObj isKindOfClass:[EQRenderData class]])
                    {
                        EQRenderData *testData = (EQRenderData *)testObj;
                        NSUInteger testIndex = testRange.range.location;
                        NSUInteger testLength = testRange.range.length;
                        NSUInteger renderLength = testData.renderString.length;
                        if (testForDelete == YES)
                        {
                            renderLength += addLength;
                        }
                        if (testIndex != NSNotFound && testIndex + testLength <= renderLength)
                        {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    return NO;
}

// Syntactic sugar that calls the previous method with testForDelete = NO.
- (BOOL)rangeExistsInEquation: (EQTextRange *)testRange
{
    return [self rangeExistsInEquation:testRange testForDelete:NO additionalLength:0];
}


// For this method, you give it the location you want the text to be inserted at.
// The typesetter will call the correct methods in the data source to manage an undo/redo stack when it adds the text.
// However, it can fail if the data is deleted and/or split somehow.
- (void)addText: (NSString *)text atPosition: (EQTextPosition *)textPosition
{
    if (nil != text && nil != textPosition && [self positionExistsInEquation:textPosition])
    {
        selectedTextRange = [EQTextRange textRangeWithPosition:textPosition];
        [self.typesetter addData:text];
    }
}

// This method gives the range of the text you want it to delete.
// The method then updates the selection and calls the typesetter.
// The typesetter will make sure and call the correct methods to update the undo/redo stack.
// However, it can fail if the data is deleted and/or split somehow.
- (void)deleteBackwardWithRange: (EQTextRange *)textRange
{
    if ([self rangeExistsInEquation:textRange])
    {
        selectedTextRange = textRange;
        [self.typesetter deleteBackward];
    }
}

// This method works similar to the previous method, except that it also inserts an attributed string
// containing the old data after performing the delete.
// However, it can fail if the data is deleted and/or split somehow.
- (void)deleteBackwardWithRange: (EQTextRange *)textRange andInsertAttrString: (NSAttributedString *)insertStr
{
    if ([self rangeExistsInEquation:textRange])
    {
        selectedTextRange = textRange;
        [self.typesetter deleteBackward];
        [self.typesetter addData:insertStr];
    }
}

- (void)addStem: (EQRenderStem *)newStem toParent: (EQRenderStem *)parentStem
     atLocation: (NSUInteger)renderLoc forEquationLoc: (NSUInteger)equLoc
{
    if (nil == newStem || nil == parentStem)
        return;

    if (equLoc == NSNotFound || equLoc >= self->equationLines.count || renderLoc > parentStem.renderArray.count)
        return;

    NSMutableArray *equationLine = equationLines[equLoc];

    if (parentStem.isRowStemType)
    {
        [parentStem insertChild:newStem atLoc:renderLoc];
    }
    else
    {
        id oldObj = [parentStem.renderArray objectAtIndex:renderLoc];

        if ([oldObj isKindOfClass:[EQRenderData class]])
        {
            [equationLine removeObject:oldObj];
        }
        else if ([oldObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)oldObj removeChildDataFromRenderArray:equationLine];
        }
        [parentStem setChild:newStem atLoc:renderLoc];
    }
    [newStem addChildDataToRenderArray:equationLine];

    // Try to move the cursor to the last child location.
    id newLastChildObj = [newStem getLastDescendent];
    if (nil != newLastChildObj && [newLastChildObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *newLastData = (EQRenderData *)newLastChildObj;
        NSUInteger newIndex = newLastData.renderString.length;
        NSUInteger newDataLoc = [equationLine indexOfObject:newLastData];
        EQTextPosition *newCursorPos = [EQTextPosition textPositionWithIndex:newIndex andLocation:newDataLoc andEquationLoc:equLoc];
        selectedTextRange = [EQTextRange textRangeWithPosition:newCursorPos];
    }

    [self sendUpdateAllViews];
}

- (void)deleteStem: (EQRenderStem *)oldStem fromParent: (EQRenderStem *)parentStem forEquationLoc: (NSUInteger)equLoc
{
    if (nil == oldStem || nil == parentStem || [parentStem.renderArray indexOfObject:oldStem] == NSNotFound)
        return;

    NSUInteger stemLoc = [parentStem getLocForChild:oldStem];

    if (equLoc == NSNotFound || equLoc >= self->equationLines.count || stemLoc == NSNotFound)
        return;

    NSMutableArray *equationLine = equationLines[equLoc];

    // Test to see if you need to merge the two siblings.
    id prevObj = [parentStem getPreviousSiblingForChild:oldStem];
    id nextObj = [parentStem getNextSiblingForChild:oldStem];
    if (nil != prevObj && nil != nextObj && [prevObj isKindOfClass:[EQRenderData class]] && [nextObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *nextData = (EQRenderData *)nextObj;
        if (nextData.renderString.length > 0 && ![nextData.renderString.string isEqualToString:@" "])
        {
            [(EQRenderData *)prevObj mergeWithRenderData:(EQRenderData *)nextObj];
        }
        [parentStem removeChild:nextObj];
        [equationLine removeObject:nextObj];
    }

    if (oldStem.parentStem == parentStem)
    {
        [oldStem removeChildDataFromRenderArray:equationLine];
    }

    if (parentStem.isRowStemType)
    {
        [parentStem removeChild:oldStem];
    }
    else
    {
        EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
        [parentStem setChild:newData atLoc:stemLoc];
        [equationLine addObject:newData];
    }

    // Try to move the cursor to the last child location.
    id newLastChildObj = [parentStem getLastDescendent];
    if (nil != newLastChildObj && [newLastChildObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *newLastData = (EQRenderData *)newLastChildObj;
        NSUInteger newIndex = newLastData.renderString.length;
        NSUInteger newDataLoc = [equationLine indexOfObject:newLastData];
        EQTextPosition *newCursorPos = [EQTextPosition textPositionWithIndex:newIndex andLocation:newDataLoc andEquationLoc:equLoc];
        selectedTextRange = [EQTextRange textRangeWithPosition:newCursorPos];
    }

    [self sendUpdateAllViews];
}

// Used for undo/redo when you add new data to the end of a row, generally by using the return key.
- (void)removeDataAtLoc: (NSUInteger)dataLoc fromParent: (EQRenderStem *)parentStem
         forEquationLoc: (NSUInteger)equationLoc
{
    if (nil == parentStem || dataLoc >= parentStem.renderArray.count || equationLoc >= equationLines.count)
    {
        return;
    }

    id dataObj = [parentStem.renderArray objectAtIndex:dataLoc];
    if ([dataObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *useRenderData = (EQRenderData *)dataObj;
        NSMutableArray *equationLine = equationLines[equationLoc];
        [parentStem removeChild:useRenderData];
        [equationLine removeObject:useRenderData];

        // Try to move the cursor to the last child location.
        id newLastChildObj = [parentStem getLastDescendent];
        if (nil != newLastChildObj && [newLastChildObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *newLastData = (EQRenderData *)newLastChildObj;
            NSUInteger newIndex = newLastData.renderString.length;
            NSUInteger newDataLoc = [equationLine indexOfObject:newLastData];
            EQTextPosition *newCursorPos = [EQTextPosition textPositionWithIndex:newIndex andLocation:newDataLoc andEquationLoc:equationLoc];
            selectedTextRange = [EQTextRange textRangeWithPosition:newCursorPos];
        }

        [self sendUpdateAllViews];
    }
}

// Used for undo/redo when you remove data from the end of a row, generally part of a redo of the previous method.
- (void)addNewDataAtLoc: (NSUInteger)dataLoc withString: (NSAttributedString *)string toParent: (EQRenderStem *)parentStem
         forEquationLoc: (NSUInteger)equationLoc
{
    if (nil == parentStem || dataLoc > parentStem.renderArray.count || equationLoc >= equationLines.count)
    {
        return;
    }

    NSMutableArray *equationLine = equationLines[equationLoc];
    EQRenderData *newRenderData = [[EQRenderData alloc] initWithAttributedString:string];
    if (dataLoc < parentStem.renderArray.count)
    {
        [parentStem insertChild:newRenderData atLoc:dataLoc];
    }
    else
    {
        [parentStem appendChild:newRenderData];
    }

    [equationLine addObject:newRenderData];

    NSUInteger newIndex = newRenderData.renderString.length;
    NSUInteger newDataLoc = [equationLine indexOfObject:newRenderData];
    EQTextPosition *newCursorPos = [EQTextPosition textPositionWithIndex:newIndex andLocation:newDataLoc andEquationLoc:equationLoc];
    selectedTextRange = [EQTextRange textRangeWithPosition:newCursorPos];

    [self sendUpdateAllViews];
}


/*
    Export data methods.
    Have removed most of the other exports as they aren't needed for this implementation.
 */

// Added to allow you to create a slim data object that knows how to draw an equation line.
- (EQRenderEquation *)buildRenderEquation
{
    if (nil == self->equationLines || nil == self->equationStems || equationLines.count == 0 || equationStems.count == 0)
        return nil;

    EQRenderEquation *returnEquation = [[EQRenderEquation alloc] initWithEquationLines:equationLines andEquationStems:equationStems];

    return returnEquation;
}


/*
    Equation Style related methods.
*/

- (void)sendUpdateStyle: (NSDictionary *)activeStyle
{
    if (self->selectedTextRange.range.length > 0)
    {
        [self.typesetter applyStyleToSelection:activeStyle];
        return;
    }

    NSNumber *styleValue = activeStyle[kSTYLE_TYPE_KEY];
    if (nil != styleValue)
    {
        self.selectedStyle = styleValue.intValue;
    }

    NSNumber *boldTextValue = activeStyle[kBOLD_TEXT_KEY];
    if (nil != boldTextValue)
    {
        self.useBoldText = boldTextValue.boolValue;
    }

    NSNumber *italicTextValue = activeStyle[kITALIC_TEXT_KEY];
    if (nil != italicTextValue)
    {
        self.useItalicText = italicTextValue.boolValue;
    }
}

- (NSDictionary *)activeStyle
{
    NSDictionary *activeStyle = @{kSTYLE_TYPE_KEY: @(self.selectedStyle),
                                   kBOLD_TEXT_KEY: @(self.useBoldText),
                                   kITALIC_TEXT_KEY: @(self.useItalicText)};

    // The selected equation style may not match the current style if the equation is empty.
    if (self.currentEquationIsEmpty)
    {
        return activeStyle;
    }

    NSDictionary *testStyle = [self.typesetter getSelectionStyle];
    if (nil != testStyle)
        return testStyle;

    return activeStyle;
}

- (NSDictionary *)storedStyle
{
    NSDictionary *storedStyle = @{kSTYLE_TYPE_KEY: @(self.selectedStyle),
                                  kBOLD_TEXT_KEY: @(self.useBoldText),
                                  kITALIC_TEXT_KEY: @(self.useItalicText)};

    return storedStyle;
}

- (RenderViewAlign)activeAlignment
{
    if (nil != rootRenderStem)
    {
        return rootRenderStem.useAlign;
    }

    return viewAlignAuto;
}

- (NSString *)applyStyleToData: (NSString *)data
{
    if (nil == data || ![data isKindOfClass:[NSString class]] || data.length == 0)
        return data;

    if (self.selectedStyle == displayMathStyle || self.selectedStyle == textStyle)
    {
        return data;
    }

    NSMutableString *returnData = [[NSMutableString alloc] initWithString:data];

    NSString *charKey = nil;
    if (self.selectedStyle == blackboardStyle)
    {
        charKey = kDOUBLE_STR_CHAR_DICTIONARY_KEY;
    }
    else if (self.selectedStyle == frakturStyle)
    {
        charKey = kFRAKTUR_CHAR_DICTIONARY_KEY;
    }
    else if (self.selectedStyle == scriptStyle)
    {
        charKey = kSCRIPT_CHAR_DICTIONARY_KEY;
    }

    if (nil != charKey)
    {
        NSDictionary *charDict = [EQRenderFontDictionary getCharDictionaryWithKey:charKey];
        if (nil == charDict)
            return nil;

        [data enumerateSubstringsInRange:NSMakeRange(0, data.length) options:NSStringEnumerationByComposedCharacterSequences
                              usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
        {
            NSString *testStr = charDict[substring];
            if (nil != testStr)
            {
                [returnData replaceCharactersInRange:substringRange withString:testStr];
            }
        }];
    }

    return returnData.copy;
}

@end

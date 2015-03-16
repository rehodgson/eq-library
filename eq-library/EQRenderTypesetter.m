//
//  EQRenderTypesetter.m
//  EQ Editor
//
//  Created by Raymond Hodgson on 16/09/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "EQRenderTypesetter.h"
#import "EQRenderFontDictionary.h"
#import "EQRenderFracStem.h"
#import "EQRenderMatrixStem.h"
#import "EQInputData.h"
#import "EQStyleConstants.h"
#import "EQUserDefaultConstants.h"

NSString* const kRENDER_TYPESETTER_WILL_CHANGE_MARKED_NOTIFICATION = @"EQTypesetter will change marked range.";
NSString* const kRENDER_TYPESETTER_DID_CHANGE_MARKED_NOTIFICATION = @"EQTypesetter did change marked range.";
NSString* const kRENDER_TYPESETTER_WILL_CHANGE_SELECTED_NOTIFICATION = @"EQTypesetter will change selected range.";
NSString* const kRENDER_TYPESETTER_DID_CHANGE_SELECTED_NOTIFICATION = @"EQTypesetter did change selected range.";
NSString* const kRENDER_TYPESETTER_WILL_CHANGE_TEXT_NOTIFICATION = @"EQTypesetter will change text data.";
NSString* const kRENDER_TYPESETTER_DID_CHANGE_TEXT_NOTIFICATION = @"EQTypesetter did change text data.";

@interface EQRenderTypesetter ()

// Used to manipulate renderStem data.
- (NSArray *)updateRenderData: (EQRenderData *)renderData
                     useRange: (EQTextRange *)textRange
          insertNewStemOfType: (EQRenderStemType)stemType
                shouldAddData: (BOOL)addDataToStem;

// Need a way to remove all of a renderStem's children from the renderData.
- (void)removeChildrenFromRenderDataForStem: (EQRenderStem *)renderStem;

// Separating some of the code into internal methods. May need to make them public later.
- (void)handleReturnCharacterWithData: (EQRenderData *)selectedData
                              inRange: (EQTextRange *)selectedTextRange
                      usingRenderData: (NSMutableArray *)renderData;

- (void)parseInputData: (EQInputData *)inputData
              withData: (EQRenderData *)selectedData
               inRange: (EQTextRange *)selectedTextRange
        withMarkedData: (EQRenderData *)markedData
               inRange: (EQTextRange *)markedTextRange
       usingRenderData: (NSMutableArray *)renderData;

- (void)addStemOfType: (EQRenderStemType)stemType
               ToData: (EQRenderData *)selectedData
        withInputData: (EQInputData *)inputData
              inRange: (EQTextRange *)selectedTextRange
      usingRenderData: (NSMutableArray *)renderData
        shouldAddData: (BOOL)addDataToStem;

   - (void)addText: (NSString *)text
withFontDictionary: (NSDictionary *)fontDictionary
withAttributedText: (NSAttributedString *)attributedText
          withData: (EQRenderData *)selectedData
           inRange: (EQTextRange *)selectedTextRange
    withMarkedData: (EQRenderData *)markedData
           inRange: (EQTextRange *)markedTextRange
   usingRenderData: (NSMutableArray *)renderData;

- (BOOL)shouldConvertParentToUnderOverWithData: (EQRenderData *)selectedData
                                         range: (EQTextRange *)selectedTextRange;

- (void)convertParentToUnderOverWithData: (EQRenderData *)selectedData
                                   range: (EQTextRange *)selectedTextRange
                           andRenderData: (NSMutableArray *)renderData;

- (BOOL)shouldConvertToSubSup: (EQRenderData *)selectedData
            withInputStemType: (EQRenderStemType)stemType
                withTextRange: (EQTextRange *)selectedTextRange;

- (BOOL)shouldUseUnderOverInput: (EQRenderData *)selectedData
                    inRange: (EQTextRange *)selectedTextRange;

- (NSString *)getTrailingStringForTextRange: (EQTextRange *)selectedTextRange withData: (EQRenderData *)selectedData;
- (BOOL)checkForTrailingString: (NSString *)suffixStr inTextRange: (EQTextRange *)selectedTextRange withData: (EQRenderData *)selectedData;

- (void)convertPreviousStemToSubSupWithData: (EQRenderData *)selectedData
                                      range: (EQTextRange *)selectedTextRange
                              andRenderData: (NSMutableArray *)renderData;

// Send notifications using these methods.
- (void)sendWillUpdateMarked;
- (void)sendDidUpdateMarked;
- (void)sendWillUpdateSelected;
- (void)sendDidUpdateSelected;
- (void)sendWillUpdateText;
- (void)sendDidUpdateText;
- (void)sendWillUpdateAll;
- (void)sendDidUpdateAll;

- (void)sendUpdatesAndResetSelectedRange: (EQTextRange *)selectedTextRange;

@end

@implementation EQRenderTypesetter

- (id) init
{
    self = [super init];

    if (self)
    {
        self->_typesetterDelegate = nil;
        self->binomialOperations = [EQRenderTypesetter getBinomialOperators];
        self->unaryOperations = [EQRenderTypesetter getUnaryOperators];
        self->leftBracketCharacters = [EQRenderTypesetter getLeftBracketCharacters];
        self->rightBracketCharacters = [EQRenderTypesetter getRightBracketCharacters];
        self->trailingCharacterSet = [EQRenderTypesetter getTrailingCharacters];
        self->binomialCharacterSet = [EQRenderTypesetter getBinomialOperatorSet];
        self->functionNames = [EQRenderTypesetter getFunctionNames];
        self->greekCharacterSet = [EQRenderTypesetter getGreekCharacterSet];
    }

    return self;
}

// Internal methods.
- (EQRenderData *)renderData: (NSArray *)renderData dataContainingTextPosition: (EQTextPosition *)textPosition
{
    if (nil == textPosition || textPosition.index == NSNotFound || textPosition.dataLoc > renderData.count)
    {
        return nil;
    }
    if (nil == renderData || renderData.count == 0)
        return nil;

    EQRenderData *returnData = [renderData objectAtIndex:textPosition.dataLoc];
    if (textPosition.index > returnData.renderString.length)
        return nil;

    return returnData;
}

- (EQRenderData *)renderData: (NSArray *)renderData dataContainingTextRange: (EQTextRange *)textRange
{
    if (nil == textRange || textRange.range.location == NSNotFound || textRange.dataLoc >= renderData.count)
        return nil;

    if (nil == renderData || renderData.count == 0)
        return nil;

    EQRenderData *returnData = [renderData objectAtIndex:textRange.dataLoc];
    if (textRange.range.location > returnData.renderString.length
        || (textRange.range.location + textRange.range.length > returnData.renderString.length))
    {
        return nil;
    }

    return [renderData objectAtIndex:textRange.dataLoc];
}

// End Internal Methods.

- (void)setTypesetterDelegate:(id)newTypesetterDelegate
{
    if(newTypesetterDelegate && ![newTypesetterDelegate conformsToProtocol:@protocol(EQTypesetterDelegate)])
    {
        [[NSException exceptionWithName: NSInvalidArgumentException reason: @"Delegate object does not conform to the delegate protocol"
                               userInfo: nil] raise];
    }

    self->_typesetterDelegate = newTypesetterDelegate;
}

- (void) addData: (id)newData
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    // Do extra checks to make sure the data is supported, before getting alot of data from other classes.
    if (nil == newData || !([newData isKindOfClass:[NSString class]] || [newData isKindOfClass:[NSAttributedString class]]
                            || [newData isKindOfClass:[EQInputData class]]))
        return;

    if ([newData respondsToSelector:@selector(length)])
    {
        if ([newData length] <= 0)
            return;
    }

    if ([newData respondsToSelector:@selector(stemType)])
    {
        if ([newData stemType] == stemTypeUnassigned)
            return;
    }

    NSMutableArray *renderData = [self.typesetterDelegate getRenderData];

    // If we have no data, create some.
    if (renderData.count == 0)
    {
        EQRenderData *data = [[EQRenderData alloc] initWithString:@""];
        [renderData addObject:data];
        EQRenderStem *rootStem = [self.typesetterDelegate getRootStem];
        if (rootStem.renderArray.count == 0)
        {
            [rootStem appendChild:data];
        }
        else
        {
            [rootStem setChild:data atLoc:0];
        }
    }

    EQTextRange *markedTextRange = [self.typesetterDelegate getMarkedTextRange];
    EQTextRange *selectedTextRange = [self.typesetterDelegate getSelectedTextRange];

    // Get the active data location for the selected and marked ranges.
    EQRenderData *markedData = [self renderData:renderData dataContainingTextRange:markedTextRange];
    EQRenderData *selectedData = [self renderData:renderData dataContainingTextRange:selectedTextRange];

    if ([newData isKindOfClass:[NSString class]])
    {
        [self addText:(NSString *)newData withFontDictionary:nil withAttributedText:nil withData:selectedData
              inRange:selectedTextRange withMarkedData:markedData inRange:markedTextRange usingRenderData:renderData];
        return;
    }
    else if ([newData isKindOfClass:[EQInputData class]])
    {
        [self parseInputData:(EQInputData *)newData withData:selectedData inRange:selectedTextRange
              withMarkedData:markedData inRange:markedTextRange usingRenderData:renderData];
        return;
    }
    else if ([newData isKindOfClass:[NSAttributedString class]])
    {
        NSAttributedString *newTextStr = (NSAttributedString *)newData;
        [self addText:newTextStr.string withFontDictionary:nil withAttributedText:newTextStr
             withData:selectedData inRange:selectedTextRange withMarkedData:markedData inRange:markedTextRange usingRenderData:renderData];
    }
}

- (void)replaceDataInRange:(EQTextRange *)textRange withData:(id)data
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    if (nil == textRange || nil == data)
        return;

    if ([data isKindOfClass:[NSString class]])
    {
        NSMutableArray *renderData = [self.typesetterDelegate getRenderData];
        EQRenderData *useData = [self renderData:renderData dataContainingTextRange:textRange];
        if (nil == useData)
            return;

        EQTextRange *selectedTextRange = [self.typesetterDelegate getSelectedTextRange];

        NSString *text = (NSString *)data;
        NSRange selectedNSRange = selectedTextRange.range;
        if ((textRange.range.location + textRange.range.length) <= selectedNSRange.location)
        {
            selectedNSRange.location -= (textRange.range.length - text.length);
        }
        else
        {
            // Test if ranges do not overlap.
            if (!(selectedNSRange.location + selectedNSRange.length < textRange.range.location))
            {
                // There is some kind of overlap.
                // Just move the start of the cursor to the start of the new range.
                selectedNSRange = textRange.range;
                selectedNSRange.length = 0;
            } // Otherwise, don't worry about adjusting selection.
        }
        [useData replaceCharactersInRange:textRange withText:text];
        if (selectedNSRange.location + selectedNSRange.length <= useData.renderString.length)
        {
            selectedTextRange = [EQTextRange textRangeWithRange:selectedNSRange andLocation:textRange.dataLoc andEquationLoc:textRange.equationLoc];
        }
        [self sendUpdatesAndResetSelectedRange:selectedTextRange];
    }
}

- (void)deleteBackward
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    if (![self.typesetterDelegate hasData])
    {
        // You should ask the delegate to handle deleting the current equation line if needed.
        [self.typesetterDelegate handleDeleteBackwardOnEmptyEquation];
        return;
    }

    NSMutableArray *renderData = [self.typesetterDelegate getRenderData];
    if (renderData.count == 0)
        return;

    // Get the active dataLoc for the selected and marked text ranges.
    EQTextRange *markedTextRange = [self.typesetterDelegate getMarkedTextRange];
    EQTextRange *selectedTextRange = [self.typesetterDelegate getSelectedTextRange];
    EQRenderData *markedData = [self renderData:renderData dataContainingTextRange:markedTextRange];
    EQRenderData *selectedData = [self renderData:renderData dataContainingTextRange:selectedTextRange];
    NSRange selectedNSRange = selectedTextRange.range;
    NSRange markedNSTextRange = markedTextRange.range;
    NSUInteger markedLoc = markedTextRange.dataLoc;
    NSUInteger selectedLoc = selectedTextRange.dataLoc;
    NSUInteger markedEqLoc = markedTextRange.equationLoc;
    NSUInteger selectedEqLoc = selectedTextRange.equationLoc;

    // Test to see if you are in a radical or not.
    BOOL isRadicalData = NO;
    if (nil != selectedData && nil != selectedData.parentStem && selectedData.parentStem.hasSupplementaryData
        && [selectedData.parentStem.supplementaryData isEqual:selectedData])
    {
        isRadicalData = YES;
        // Move it to the front of the supplemental data string.
        selectedNSRange.location = 0;
        selectedNSRange.length = 0;
        selectedTextRange.range = selectedNSRange;
    }

    // Test to see if you are in the root data for a large stem.
    BOOL isIntegralData = NO;
    if (nil != selectedData && nil != selectedData.parentStem && selectedData.parentStem.isLargeOpStemType && [selectedData.parentStem.getFirstChild isEqual:selectedData])
    {
        isIntegralData = YES;
        selectedNSRange.location = 0;
        selectedNSRange.length = 0;
        selectedTextRange.range = selectedNSRange;
    }

    if (nil != markedData)
    {
		// There is marked text, so delete it.
        // Not bothering with undo/redo as I'm not even sure what deleting marked text means in this context.
        [markedData deleteCharactersInRange:markedTextRange];
        selectedNSRange.location = markedNSTextRange.location;
        selectedNSRange.length = 0;
        markedNSTextRange = NSMakeRange(NSNotFound, 0);
        markedLoc = selectedLoc;
    }
    else if (nil != selectedData)
    {
        if (selectedNSRange.length > 1)
        {
            // Delete the selected text.
            [selectedData deleteCharactersInRange:selectedTextRange];
            selectedNSRange.length = 0;
        }
        // System updates the selection before deletion, even though it shouldn't.
        else if (selectedNSRange.length == 1)
        {
            // Test to see if you're deleting a binomial operator.
            // If so, you should delete an extra leading whitespace, if it exists.
            if (selectedNSRange.location >= 1)
            {
                NSRange testRange = selectedNSRange;
                testRange.location --;
                NSString *testStr = [selectedData.renderString.string substringWithRange:testRange];
                NSRange testWhiteSpaceRange = [testStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                if (testWhiteSpaceRange.location != NSNotFound)
                {
                    NSString *testStr2 = [selectedData.renderString.string substringWithRange:selectedNSRange];
                    if ([self stringHasBinomialOperator:testStr2])
                    {
                        selectedNSRange.location --;
                        selectedNSRange.length = 2;
                    }
                }
            }
            EQTextRange *useRange = [EQTextRange textRangeWithRange:selectedNSRange andLocation:selectedLoc andEquationLoc:selectedEqLoc];

            [selectedData deleteCharactersInRange:useRange];
            selectedNSRange.length = 0;
        }
        else
        {
            // Delete one char of text at the current insertion point.
            if (selectedNSRange.location > 0)
            {
                selectedNSRange.location--;
                selectedNSRange.length = 1;

                // Test to see if you're deleting a binomial operator.
                // If so, you should delete an extra leading whitespace, if it exists.
                if (selectedNSRange.location >= 1)
                {
                    NSRange testRange = selectedNSRange;
                    testRange.location --;
                    NSString *testStr = [selectedData.renderString.string substringWithRange:testRange];
                    NSRange testWhiteSpaceRange = [testStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (testWhiteSpaceRange.location != NSNotFound)
                    {
                        NSString *testStr2 = [selectedData.renderString.string substringWithRange:selectedNSRange];
                        // Only do this if you have a binomial, but not a unary operator.
                        if ([self stringHasBinomialOperator:testStr2])
                        {
                            selectedNSRange.location --;
                            selectedNSRange.length = 2;
                        }
                    }
                }
                EQTextRange *useRange = [EQTextRange textRangeWithRange:selectedNSRange andLocation:selectedLoc andEquationLoc:selectedEqLoc];

                [selectedData deleteCharactersInRange:useRange];
                selectedNSRange.length = 0;
            }
            else
            {
                // You're at the beginning of a text range,
                // Check to see if you should delete the previous stem instead.
                if (selectedData.parentStem != nil && ([selectedData.parentStem isRowStemType] || [selectedData.parentStem isRootStemType] || isIntegralData))
                {
                    id previousSiblingObj = [selectedData.parentStem getPreviousSiblingForChild:selectedData];
                    if ((isRadicalData || isIntegralData) && nil != selectedData.parentStem.parentStem)
                    {
                        EQRenderStem *parentOfParent = selectedData.parentStem.parentStem;
                        previousSiblingObj = [parentOfParent getPreviousSiblingForChild:selectedData.parentStem];
                    }
                    if (nil != previousSiblingObj)
                    {
                        // Two renderData are right next to each other.
                        if ([previousSiblingObj isKindOfClass:[EQRenderData class]])
                        {
                            EQRenderData *previousSiblingData = (EQRenderData *)previousSiblingObj;
                            NSMutableAttributedString *renderStr = previousSiblingData.renderString;

                            NSUInteger savedLoc = [renderData indexOfObject:previousSiblingData];

                            if (renderStr.length > 1)
                            {
                                NSRange useRange = NSMakeRange((renderStr.length - 1), 1);
                                [renderStr deleteCharactersInRange:useRange];
                            }
                            else
                            {
                                [selectedData.parentStem removeChild:previousSiblingData];
                                [renderData removeObject:previousSiblingData];
                                selectedLoc = [renderData indexOfObject:selectedData];
                            }
                            if (isRadicalData || isIntegralData)
                            {
                                selectedNSRange = NSMakeRange(previousSiblingData.renderString.string.length, 0);
                                selectedLoc = savedLoc;
                            }
                        }
                        else if ([previousSiblingObj isKindOfClass:[EQRenderStem class]])
                        {
                            EQRenderStem *previousSiblingStem = (EQRenderStem *)previousSiblingObj;

                            // Check the object preceeding the previous sibling stem.
                            // It may need to point to that location, and also remove the current data location if it is empty.

                            id previousPreviousObj = [previousSiblingStem.parentStem getPreviousSiblingForChild:previousSiblingStem];
                            if (nil != previousPreviousObj && [previousPreviousObj isKindOfClass:[EQRenderData class]] && (isRadicalData || isIntegralData) == NO
                                && [previousPreviousObj renderString].length > 0)
                            {
                                EQRenderData *previousPreviousData = (EQRenderData *)previousPreviousObj;
                                selectedNSRange = NSMakeRange(previousPreviousData.renderString.length, 0);

                                // If there is data to save, merge it first.
                                if (selectedData.renderString.length > 0)
                                {
                                    [previousPreviousData mergeWithRenderData:selectedData];
                                }

                                // Delete the previous selected data.
                                [selectedData.parentStem removeChild:selectedData];
                                [renderData removeObject:selectedData];
                                selectedData = previousPreviousData;
                            }

                            // Delete the previous stem.
                            // May need to update this if you have rows or multiple equations.
                            [previousSiblingStem.parentStem removeChild:previousSiblingStem];
                            [self removeChildrenFromRenderDataForStem:previousSiblingStem];
                            selectedLoc = [renderData indexOfObject:selectedData];
                            if ((isRadicalData || isIntegralData) && nil != previousPreviousObj && [previousPreviousObj isKindOfClass:[EQRenderData class]])
                            {
                                EQRenderData *previousPreviousData = (EQRenderData *)previousPreviousObj;
                                selectedNSRange = NSMakeRange(previousPreviousData.renderString.length, 0);
                                selectedLoc = [renderData indexOfObject:previousPreviousData];
                            }
                        }
                    } // End previous sibling is not nil
                    else
                    {
                        // Previous sibling is nil.
                        // Test if the data is empty so you should delete it.
                        if (selectedData.renderString.length == 0 && renderData.count == 1)
                        {
                            [self.typesetterDelegate handleDeleteBackwardOnEmptyEquation];
                            return;
                        }
                        // If it is not empty, it may be a single white space.
                        // Treat it the same as a delete with any other character.
                        if ([selectedData.renderString.string isEqualToString:@" "])
                        {
                            selectedNSRange = NSMakeRange(0, 1);
                            EQTextRange *useRange = [EQTextRange textRangeWithRange:selectedNSRange andLocation:selectedLoc andEquationLoc:selectedEqLoc];

                            [selectedData deleteCharactersInRange:useRange];
                            selectedNSRange.length = 0;
                        }
                    }
                }
            }
        }
    }

    markedTextRange = [EQTextRange textRangeWithRange:markedNSTextRange andLocation:markedLoc andEquationLoc:markedEqLoc];
    [self sendWillUpdateAll];
    [self.typesetterDelegate sendUpdateMarkedTextRange:markedTextRange];
    selectedTextRange = [EQTextRange textRangeWithRange:selectedNSRange andLocation:selectedLoc andEquationLoc:selectedEqLoc];
    [self.typesetterDelegate sendUpdateSelectedTextRange:selectedTextRange];
    [self.typesetterDelegate sendFinishedUpdating];
    [self sendDidUpdateAll];
}

/*
    Apply Style methods assumes all inputStrings have default dictionary already applied.
*/

- (void)applyMathStyleToAttributedString: (NSMutableAttributedString *)inputString inRange:(NSRange)useRange useSmaller:(Boolean)useSmaller
                           parentSmaller: (Boolean)parentSmaller
{
    if (nil == inputString || inputString.length == 0)
        return;

    if (useRange.location == NSNotFound || useRange.length == 0
        || useRange.location > inputString.length || useRange.location + useRange.length > inputString.length)
        return;

    CGFloat useSize = kDEFAULT_FONT_SIZE;
    if (parentSmaller == YES && useSmaller == YES)
    {
        useSize = kDEFAULT_FONT_SIZE_SMALLER;
    }
    else if (useSmaller == YES)
    {
        useSize = kDEFAULT_FONT_SIZE_SMALL;
    }

    // I've attempted it with a different font face for numbers and italic characters, and it doesn't look "right".
    // Still I may research this further and give the user some options to choose from later on.
    // The main thing is to preserve STIX for operations and other special characters, which can be done here.
//    NSDictionary *attribDictRegular = [EQRenderFontDictionary preferredFontBodyDictionaryWithSize:useSize];
//    NSDictionary *attribDictItalic = [EQRenderFontDictionary preferredFontBodyItalicDictionaryWithSize:useSize];

    NSDictionary *attribDictRegular = [EQRenderFontDictionary defaultFontDictionaryWithSize:useSize];
    NSDictionary *attribDictItalic = [EQRenderFontDictionary defaultItalicFontDictionaryWithSize:useSize];
    BOOL userDefinedRegular = NO;

    if (nil != self.typesetterDelegate)
    {
        NSDictionary *activeStyle = [self.typesetterDelegate storedStyle];
        if (nil != activeStyle)
        {
            attribDictRegular = [self applyStyle:activeStyle toAttributes:attribDictRegular];
            attribDictItalic = [self applyStyle:activeStyle toAttributes:attribDictItalic];

            NSNumber *regularCheck = attribDictRegular[kUSER_STYLED_TEXT];
            if (nil != regularCheck)
            {
                userDefinedRegular = regularCheck.boolValue;
            }
        }
    }
    // Apply normal styling to non-letter characters. This may need to be improved once we get the styling nailed down better.
    // The main reason you do this is to apply the correct sizing.
    // Also, if you have a bold font, you need to not apply it automatically, as it can apply the style to more than just the single character.
    [inputString.string enumerateSubstringsInRange:useRange options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        NSNumber *userDefinedCheck = [inputString attribute:kUSER_STYLED_TEXT atIndex:substringRange.location effectiveRange:nil];
        userDefinedCheck == nil ? userDefinedCheck = @(NO) : userDefinedCheck;
        NSNumber *plainTextCheck = [inputString attribute:kUSES_PLAIN_TEXT atIndex:substringRange.location effectiveRange:nil];
        plainTextCheck == nil ? plainTextCheck = @(NO) : plainTextCheck;
        if (userDefinedCheck.boolValue == YES || plainTextCheck.boolValue == YES)
            return;

        NSRange testRange = [substring rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
        if (testRange.location == NSNotFound && !userDefinedRegular)
        {
            // Should test that you aren't altering a previously established size or other attributes.
            // May need to expand this further later on.
            UIFont *testFont = [inputString attribute:NSFontAttributeName atIndex:substringRange.location effectiveRange:nil];
            if (testFont.pointSize <= kDEFAULT_FONT_SIZE)
            {
                [inputString addAttributes:attribDictRegular range:substringRange];
            }
        }
    }];

    // I've decided to go ahead and swap the base font for {} and | characters at default height.
    // STIX renders these bracers in a way that is difficult to read.
    [inputString.string enumerateSubstringsInRange:useRange options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        if ([substring isEqualToString:@"{"] || [substring isEqualToString:@"}"] || [substring isEqualToString:@"|"])
        {
            UIFont *testFont = [inputString attribute:NSFontAttributeName atIndex:substringRange.location effectiveRange:nil];
            NSNumber *kernValue = [inputString attribute:NSKernAttributeName atIndex:substringRange.location effectiveRange:nil];
            NSNumber *userDefinedCheck = [inputString attribute:kUSER_STYLED_TEXT atIndex:substringRange.location effectiveRange:nil];
            userDefinedCheck == nil ? userDefinedCheck = @(NO) : userDefinedCheck;
            NSNumber *plainTextCheck = [inputString attribute:kUSES_PLAIN_TEXT atIndex:substringRange.location effectiveRange:nil];
            plainTextCheck == nil ? plainTextCheck = @(NO) : plainTextCheck;
            if (userDefinedCheck.boolValue == YES || plainTextCheck.boolValue == YES)
                return;

            if ([testFont.fontName isEqualToString:kDEFAULT_FONT] && testFont.pointSize <= kDEFAULT_FONT_SIZE)
            {
                if ([substring isEqualToString:@"}"] && kernValue.floatValue == 0.0)
                {
                    kernValue = @(2.0);
                }
                NSDictionary *attribDictAlt = [EQRenderFontDictionary fontDictWithName:kALT_GLYPH_FONT size:testFont.pointSize kernValue:kernValue.floatValue];
                [inputString addAttributes:attribDictAlt range:substringRange];
            }
        }
    }];

    // Find the last word in the usable range.
    __block NSString *lastWord;
    __block NSRange lastWordRange;
    [inputString.string enumerateSubstringsInRange:useRange options:(NSStringEnumerationByWords | NSStringEnumerationReverse)
    usingBlock: ^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop)
    {
        lastWord = subString;
        lastWordRange = subStringRange;
        *stop = YES;
    }];

    if (nil == lastWord || lastWordRange.location == NSNotFound)
        return;

    // At this point, you would compare to see if the last word matches a function the dictionary.
    // You may also need a way to start at the selection instead of the end of the string, at some point.

    if ([self->functionNames containsObject:lastWord])
    {
        // If it has a "user defined" style, this overrides any auto styling.
        NSNumber *userDefinedCheck = [inputString attribute:kUSER_STYLED_TEXT atIndex:lastWordRange.location effectiveRange:nil];
        userDefinedCheck == nil ? userDefinedCheck = @(NO) : userDefinedCheck;
        NSNumber *plainTextCheck = [inputString attribute:kUSES_PLAIN_TEXT atIndex:lastWordRange.location effectiveRange:nil];
        plainTextCheck == nil ? plainTextCheck = @(NO) : plainTextCheck;
        if (userDefinedCheck.boolValue == YES || plainTextCheck.boolValue == YES)
            return;

        [inputString addAttributes:attribDictRegular range:lastWordRange];
        return;
    }

    // No match for a function name, so parse it like normal.
    // Need to track the previous character to see if you need to style the "d" correctly.
    __block BOOL prevWasVariable = NO;
    __block BOOL prevWasLeftBracket = NO;

    // Test for a trailing left bracket.
    // If it exists, you can add it to the range of the string you are testing.
    NSRange testRange = lastWordRange;
    testRange.length += 1;
    if (testRange.location + testRange.length <= inputString.string.length)
    {
        NSString *bracketTest = [inputString.string substringWithRange:testRange];
        bracketTest = [bracketTest substringFromIndex:(bracketTest.length - 1)];
        if ([leftBracketCharacters containsObject:bracketTest])
        {
            lastWordRange = testRange;
        }
    }

    [inputString.string enumerateSubstringsInRange:lastWordRange options:(NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse)
                                        usingBlock:
     ^(NSString *subString, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         // If it has a "user defined" style, this overrides any auto styling.
         NSNumber *userDefinedCheck = [inputString attribute:kUSER_STYLED_TEXT atIndex:substringRange.location effectiveRange:nil];
         userDefinedCheck == nil ? userDefinedCheck = @(NO) : userDefinedCheck;
         NSNumber *plainTextCheck = [inputString attribute:kUSES_PLAIN_TEXT atIndex:substringRange.location effectiveRange:nil];
         plainTextCheck == nil ? plainTextCheck = @(NO) : plainTextCheck;
         if (userDefinedCheck.boolValue == YES || plainTextCheck.boolValue == YES)
             return;

         BOOL curIsLeftBracket = [leftBracketCharacters containsObject:subString];
         // Check against the greek character set.
         // The decision to italicize or not should be set in preferences at some point.
         NSRange greekCharRange = [subString rangeOfCharacterFromSet:self->greekCharacterSet];
         NSNumber *useItalicGreeksNum = [[NSUserDefaults standardUserDefaults] valueForKey:kUSE_ITALIC_GREEKS_NAME];
         if (nil == useItalicGreeksNum)
         {
             useItalicGreeksNum = @NO;
         }
         NSNumber *useRomanDerivsNum = [[NSUserDefaults standardUserDefaults] valueForKeyPath:kUSE_ROMAN_DERIV_NAME];
         if (nil == useRomanDerivsNum)
         {
             useRomanDerivsNum = @YES;
         }

         if (substringRange.length > 1)
         {
             // We should automatically assume that multi-character composed sequences are non-italic.
             [inputString addAttributes:attribDictRegular range:substringRange];
             prevWasVariable = NO;
         }
         else if (greekCharRange.location != NSNotFound && useItalicGreeksNum.boolValue == NO)
         {
             [inputString addAttributes:attribDictRegular range:substringRange];
             prevWasVariable = YES;
         }
         else
         {
             // If the last word includes decimals, then it won't be a group of variables.

             NSMutableCharacterSet *nonItalicSet = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
             [nonItalicSet formUnionWithCharacterSet:[EQRenderTypesetter getBlackboardCharacters]];
             NSRange testRange = [subString rangeOfCharacterFromSet:nonItalicSet];
             if (testRange.location == NSNotFound)
             {
                 // Should try and remove italics from the "d" in "dx" as it acts as a function in this case.
                 // It determines this by checking to see if it is the first character in the last word and the word has more than one character.
                 // Also, if it is at this point, then they are all letters.
                 // This can be a preference as well.
                 if ([subString isEqualToString:@"d"] && (prevWasVariable == YES || prevWasLeftBracket) && useRomanDerivsNum.boolValue == YES)
                 {
                     [inputString addAttributes:attribDictRegular range:substringRange];
                     prevWasVariable = NO;
                 }
                 else if (curIsLeftBracket)
                 {
                     prevWasVariable = NO;
                 }
                 else
                 {
                     [inputString addAttributes:attribDictItalic range:substringRange];
                     if ([subString isEqualToString:@" "])
                     {
                         prevWasVariable = NO;
                     }
                     else
                     {
                         prevWasVariable = YES;
                     }
                 }
             }
         }

         // Check whether the subString is a leftBracket.
         // This helps you parse d(x) styling.
         prevWasLeftBracket = curIsLeftBracket;
     }];
}

- (NSDictionary *)applyStyle: (NSDictionary *)activeStyle toAttributes: (NSDictionary *)attributes
{
    return [self applyStyle:activeStyle toAttributes:attributes plainText:NO];
}

- (NSDictionary *)applyStyle: (NSDictionary *)activeStyle toAttributes: (NSDictionary *)attributes plainText: (BOOL)usesPlainText
{
    NSNumber *styleValue = activeStyle[kSTYLE_TYPE_KEY];
    StyleType useStyle = displayMathStyle;
    if (nil != styleValue)
    {
        useStyle = styleValue.intValue;
    }

    NSNumber *boldTextValue = activeStyle[kBOLD_TEXT_KEY];
    BOOL useBold = NO;
    if (nil != boldTextValue)
    {
        useBold = boldTextValue.boolValue;
    }

    NSNumber *italicTextValue = activeStyle[kITALIC_TEXT_KEY];
    BOOL useItalic = NO;
    if (nil != italicTextValue)
    {
        useItalic = italicTextValue.boolValue;
    }

    UIFont *useFont = attributes[NSFontAttributeName];
    BOOL isItalic = [useFont.fontName isEqualToString:kDEFAULT_ITALIC_FONT];
    CGFloat fontSize = useFont.pointSize;
    NSNumber *kernValue = attributes[NSKernAttributeName];
    float useKern = 0.0;
    kernValue != nil ? useKern = kernValue.floatValue : useKern;

    if (useStyle == displayMathStyle || useStyle == textStyle)
    {
        if (useItalic && useBold)
        {
            if (usesPlainText)
            {
                return [EQRenderFontDictionary plainTextFontDictWithName:kDEFAULT_BOLD_ITALIC_FONT size:fontSize kernValue:useKern];
            }
            else
            {
                return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_BOLD_ITALIC_FONT size:fontSize kernValue:useKern];
            }
        }

        if (useItalic)
        {
            if (usesPlainText)
            {
                return [EQRenderFontDictionary plainTextFontDictWithName:kDEFAULT_ITALIC_FONT size:fontSize kernValue:useKern];
            }
            else
            {
                return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_ITALIC_FONT size:fontSize kernValue:useKern];
            }
        }

        if (useBold)
        {
            if (usesPlainText)
            {
                return [EQRenderFontDictionary plainTextFontDictWithName:kDEFAULT_BOLD_FONT size:fontSize kernValue:useKern];
            }
            else
            {
                return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_BOLD_FONT size:fontSize kernValue:useKern];
            }
        }
    }
    // Glyphs do not exist in the italic font for most of the blackboard and other script types.
    else if (isItalic)
    {
        return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_FONT size:fontSize kernValue:useKern];
    }

    return attributes;
}

- (NSDictionary *)applySelectionStyle: (NSDictionary *)activeStyle toAttributes: (NSDictionary *)attributes
{
    NSNumber *styleValue = activeStyle[kSTYLE_TYPE_KEY];
    StyleType useStyle = displayMathStyle;
    if (nil != styleValue)
    {
        useStyle = styleValue.intValue;
    }

    NSNumber *boldTextValue = activeStyle[kBOLD_TEXT_KEY];
    BOOL useBold = NO;
    if (nil != boldTextValue)
    {
        useBold = boldTextValue.boolValue;
    }

    NSNumber *italicTextValue = activeStyle[kITALIC_TEXT_KEY];
    BOOL useItalic = NO;
    if (nil != italicTextValue)
    {
        useItalic = italicTextValue.boolValue;
    }

    UIFont *useFont = attributes[NSFontAttributeName];
    CGFloat fontSize = useFont.pointSize;
    NSNumber *kernValue = attributes[NSKernAttributeName];
    float useKern = 0.0;
    kernValue != nil ? useKern = kernValue.floatValue : useKern;

    BOOL isItalic = [useFont.fontName isEqualToString:kDEFAULT_ITALIC_FONT] || [useFont.fontName isEqualToString:kDEFAULT_BOLD_ITALIC_FONT];
    BOOL isBold = [useFont.fontName isEqualToString:kDEFAULT_BOLD_FONT] || [useFont.fontName isEqualToString:kDEFAULT_BOLD_ITALIC_FONT];

    if (useStyle != displayMathStyle && useStyle != textStyle)
    {
        return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_FONT size:fontSize kernValue:useKern];
    }

    // Find out which attribute has been updated.
    // Should just ignore styleValue for now.
    if (isItalic != useItalic)
    {
        if (useItalic && isBold)
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_BOLD_ITALIC_FONT size:fontSize kernValue:useKern];
        }
        else if (useItalic)
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_ITALIC_FONT size:fontSize kernValue:useKern];
        }
        else if (isBold)
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_BOLD_FONT size:fontSize kernValue:useKern];
        }
        else
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_FONT size:fontSize kernValue:useKern];
        }
    }
    else if (isBold != useBold)
    {
        if (useBold && isItalic)
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_BOLD_ITALIC_FONT size:fontSize kernValue:useKern];
        }
        else if (useBold)
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_BOLD_FONT size:fontSize kernValue:useKern];
        }
        else if (isItalic)
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_ITALIC_FONT size:fontSize kernValue:useKern];
        }
        else
        {
            return [EQRenderFontDictionary userStyledFontDictWithName:kDEFAULT_FONT size:fontSize kernValue:useKern];
        }
    }
    return attributes;
}

- (NSDictionary *)getSelectionStyle
{
    EQTextRange *selectedTextRange = [self.typesetterDelegate getSelectedTextRange];
    NSMutableArray *renderData = [self.typesetterDelegate getRenderData];
    if (nil == selectedTextRange || nil == renderData)
        return nil;

    EQRenderData *selectedData = [self renderData:renderData dataContainingTextRange:selectedTextRange];
    if (nil == selectedData || selectedTextRange.range.location >= selectedData.renderString.length)
        return nil;

    NSDictionary *fontAttributes = [selectedData.renderString attributesAtIndex:selectedTextRange.range.location effectiveRange:nil];

    UIFont *selectedFont = fontAttributes[NSFontAttributeName];
    BOOL isBold = NO;
    BOOL isItalic = NO;
    if ([selectedFont.fontName isEqualToString:kDEFAULT_BOLD_ITALIC_FONT])
    {
        isBold = YES;
        isItalic = YES;
    }
    else if ([selectedFont.fontName isEqualToString:kDEFAULT_BOLD_FONT])
    {
        isBold = YES;
    }
    else if ([selectedFont.fontName isEqualToString:kDEFAULT_ITALIC_FONT])
    {
        isItalic = YES;
    }

    StyleType useStyle = displayMathStyle;

    NSNumber *plainTextCheck = fontAttributes[kUSES_PLAIN_TEXT];
    plainTextCheck == nil ? plainTextCheck = @(NO) : plainTextCheck;
    if (plainTextCheck.boolValue == YES)
    {
        useStyle = textStyle;
    }
    else
    {
        NSArray *testStyles = @[[EQRenderTypesetter getScriptCharacters], [EQRenderTypesetter getBlackboardCharacters],
                                [EQRenderTypesetter getFrakturCharacters]];

        int counter = 0;
        for (NSCharacterSet *testSet in testStyles)
        {
            BOOL foundChar = [self testString:selectedData.renderString.string forCharactersInSet:testSet withRange:selectedTextRange.range];
            if (foundChar)
            {
                if (counter == 0)
                {
                    useStyle = scriptStyle;
                }
                else if (counter == 1)
                {
                    useStyle = blackboardStyle;
                }
                else if (counter == 2)
                {
                    useStyle = frakturStyle;
                }
                break;
            }
            counter ++;
        }
    }

    NSDictionary *activeStyle = @{kSTYLE_TYPE_KEY: @(useStyle), kBOLD_TEXT_KEY: @(isBold), kITALIC_TEXT_KEY: @(isItalic)};

    return activeStyle;
}

- (BOOL)testString: (NSString *)useString forCharactersInSet: (NSCharacterSet *)useCharSet withRange: (NSRange)useRange
{
    NSRange testRange = [useString rangeOfCharacterFromSet:useCharSet options:0 range:useRange];

    return (testRange.location != NSNotFound);
}

- (void)applyStyleToSelection: (NSDictionary *)applyStyle
{
    if (nil == applyStyle)
        return;

    EQTextRange *selectedTextRange = [self.typesetterDelegate getSelectedTextRange];
    NSMutableArray *renderData = [self.typesetterDelegate getRenderData];
    if (nil == selectedTextRange || nil == renderData)
        return;

    EQRenderData *selectedData = [self renderData:renderData dataContainingTextRange:selectedTextRange];
    if (nil == selectedData || selectedTextRange.range.location >= selectedData.renderString.length)
        return;

    NSDictionary *fontAttributes = [selectedData.renderString attributesAtIndex:selectedTextRange.range.location effectiveRange:nil];

    NSDictionary *newAttributes = [self applySelectionStyle:applyStyle toAttributes:fontAttributes];
    [selectedData.renderString addAttributes:newAttributes range:selectedTextRange.range];
    [self sendUpdatesAndResetSelectedRange:selectedTextRange];
}

// This method goes through the entire string and performs kerning depending upon whether it is a number, decimal, etc.
- (void)kernMathInAttributedString: (NSMutableAttributedString *)inputString
{
    if (nil == inputString || inputString.length == 0)
        return;

    __block BOOL previousWasDecimal = NO;
    __block BOOL previousWasNumeral = NO;
    __block BOOL previousWasWhitespace = NO;
    __block BOOL previousWasTrailingCharacter = NO;
    __block BOOL previousWasRightBracket = NO;
    __block BOOL previousWasDeriv = NO;
    [inputString.string enumerateSubstringsInRange:NSMakeRange(0, inputString.length)
                                           options:(NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse)
     usingBlock: ^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop)
     {
         BOOL currentIsNumeral = [subString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound;

         // If you have a plain text string, then just reset everything and move on.
         NSNumber *plainTextCheck = [inputString attribute:kUSES_PLAIN_TEXT atIndex:subStringRange.location effectiveRange:nil];
         plainTextCheck == nil ? plainTextCheck = @(NO) : plainTextCheck;
         if (plainTextCheck.boolValue == YES)
         {
             previousWasDecimal = NO;
             previousWasNumeral = NO;
             previousWasWhitespace = NO;
             previousWasTrailingCharacter = NO;
             previousWasRightBracket = NO;
             previousWasDeriv = NO;
             return;
         }
         if ([subString isEqualToString:@"."])
         {
             NSNumber *kernValue = [NSNumber numberWithFloat:3.0f];
             if (previousWasNumeral)
                 kernValue = [NSNumber numberWithFloat:0.0f];
             [inputString addAttribute:NSKernAttributeName value:kernValue range:subStringRange];
             previousWasDecimal = YES;
             previousWasDeriv = NO;
         }
         else if ([subString isEqualToString:@","] && !previousWasNumeral && !previousWasDecimal && !previousWasWhitespace)
         {
             NSNumber *kernValue = [NSNumber numberWithFloat:4.0f];
             [inputString addAttribute:NSKernAttributeName value:kernValue range:subStringRange];
             previousWasDecimal = NO;
             previousWasDeriv = NO;
         }
         else if ([self->unaryOperations objectForKey:subString] != nil)
         {
             if (!previousWasWhitespace)
                 [inputString addAttribute:NSKernAttributeName value:@(3.0f) range:subStringRange];
             previousWasDecimal = NO;
             previousWasDeriv = NO;
         }
         else if ([self->leftBracketCharacters containsObject:subString])
         {
             if (previousWasTrailingCharacter)
                 [inputString addAttribute:NSKernAttributeName value:@(6.0f) range:subStringRange];
             else if (!previousWasWhitespace)
                 [inputString addAttribute:NSKernAttributeName value:@(3.0f) range:subStringRange];

             previousWasDecimal = NO;
             previousWasDeriv = NO;
         }
         else if (currentIsNumeral)
         {
             NSNumber *kernValue = @(0.0f);
             if (previousWasDecimal)
             {
                 kernValue = @(2.0f);
             }
             else if (!previousWasNumeral)
             {
                 if (subStringRange.location >= (inputString.length - 1))
                 {
                     kernValue = @(1.5f);
                 }
                 else
                 {
                     kernValue = @(3.0f);
                 }
             }
             [inputString addAttribute:NSKernAttributeName value:kernValue range:subStringRange];
             previousWasDecimal = NO;
             previousWasDeriv = NO;
         }
         // Need to handle italic "f" differently.
         // May need to check that it *is* italic later on.
         else if ([subString isEqualToString:@"f"] && !previousWasWhitespace)
         {
             NSNumber *kernValue = [NSNumber numberWithFloat:3.0f];
             [inputString addAttribute:NSKernAttributeName value:kernValue range:subStringRange];
             previousWasDecimal = NO;
             previousWasDeriv = NO;
         }
         // May also do a preference check here.
         else if (previousWasDeriv)
         {
             NSNumber *kernValue = [NSNumber numberWithFloat:6.0f];
             [inputString addAttribute:NSKernAttributeName value:kernValue range:subStringRange];
             previousWasDecimal = NO;
             previousWasDeriv = NO;
         }
         else
         {
             // Should test that you aren't altering a previously established size or other attributes.
             // May need to expand this further later on.
             UIFont *testFont = [inputString attribute:NSFontAttributeName atIndex:subStringRange.location effectiveRange:nil];
             if (testFont.pointSize <= kDEFAULT_FONT_SIZE)
             {
                 NSNumber *kernValue = @(1.5f);
                 // Check if your character is near a right bracket (and is not one itself).
                 if (previousWasRightBracket && ![rightBracketCharacters containsObject:subString])
                 {
                     kernValue = @(3.0f);
                 }
                 [inputString addAttribute:NSKernAttributeName value:kernValue range:subStringRange];
                 previousWasDecimal = NO;
             }
             if (([subString isEqualToString:@"d"] || [subString isEqualToString:@"∂"]) && [testFont.fontName isEqualToString:kDEFAULT_FONT])
             {
                 previousWasDeriv = YES;
             }
             else
             {
                 previousWasDeriv = NO;
             }
         }
         previousWasNumeral = currentIsNumeral;
         previousWasWhitespace = [subString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound;
         previousWasTrailingCharacter = [self->trailingCharacterSet containsObject:subString];
         previousWasRightBracket = [self->rightBracketCharacters containsObject:subString];
     }];
}

// Currently doesn't do any processing, just compares the text against a dictionary and does a substitution.
- (NSString *)parseTextForOperation: (NSString *)text atSelectionLoc:(NSRange)selectionLoc inAttributedString:(NSMutableAttributedString *)inputString
                         useSmaller:(Boolean)useSmaller withData:(EQRenderData *)selectedData
{
    if (nil == text || text.length == 0 || nil == inputString)
        return text;

    if (NSNotFound == selectionLoc.location || selectionLoc.location > inputString.length || selectionLoc.location + selectionLoc.length > inputString.length)
        return text;

    NSString *parsedText = nil;
    if ([self->binomialOperations objectForKey:text] != nil)
    {
        parsedText = [binomialOperations objectForKey:text];
    }
    else if ([self stringHasBinomialOperator:text])
    {
        parsedText = [NSString stringWithFormat:@" %@ ", text];
    }
    // If the input string matches an operation name, insert a space.
    else if (![text isEqualToString:@" "] && [self functionNameExistsAtSelectionLoc:selectionLoc inAttributedString:inputString withText: (NSString *)text])
    {
        parsedText = [NSString stringWithFormat:@" %@", text];
        selectedData.hasAutoReplacedSpace = YES;
    }
    else if (text.length > 2 && [self->functionNames containsObject:text])
    {
        parsedText = [NSString stringWithFormat:@" %@", text];
        selectedData.hasAutoReplacedSpace = YES;
    }
    else
    {
        selectedData.hasAutoReplacedSpace = NO;
    }

    if (nil != parsedText)
    {
        // Sometimes you will need to treat it as a unary rather than a binomial operator.
        NSString *parsedUnaryText = [self->unaryOperations objectForKey:text];
        if (nil != parsedUnaryText)
        {
            // Test your insertion location.
            // If you are at location zero, you should assume it should is unary.
            if (selectionLoc.location != NSNotFound && selectionLoc.location == 0)
            {
                return parsedUnaryText;
            }
        }
        if (useSmaller == YES)
        {
            // Needed because you need to remove space, but there are some substitutions you want to keep.
            // E.g. * -> ⋅
            parsedText = [parsedText stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        return parsedText;
    }

    return text;
}

- (BOOL)functionNameExistsAtSelectionLoc: (NSRange)selectionLoc inAttributedString: (NSMutableAttributedString *)inputString
                                withText: (NSString *)text
{
    // Test for a space first.
    // If none exists, then test the entire string.
    NSRange spaceRange = [inputString.string rangeOfString:@" "];
    if (spaceRange.location == NSNotFound)
    {
        NSString *testStr = [inputString.string stringByAppendingString:text];
        // In this case, you want to ignore auto spacing as you are building a larger function name.
        if ([self->functionNames containsObject:testStr])
        {
            return NO;
        }

        if ([self->functionNames containsObject:inputString.string])
        {
            return YES;
        }
        if (text.length > 2 && [self->functionNames containsObject:text])
        {
            return YES;
        }
    }

    // Find the last location.
    // It's important to help you find where to mark the last word.
    NSRange lastSpaceRange = [inputString.string rangeOfString:@" " options:NSBackwardsSearch];
    if (lastSpaceRange.location == NSNotFound || lastSpaceRange.location >= selectionLoc.location)
        return NO;

    NSInteger deltaLoc = selectionLoc.location - lastSpaceRange.location;
    NSInteger testLoc = selectionLoc.location - deltaLoc;
    if (testLoc < 0)
        return NO;

    NSRange useRange = selectionLoc;
    useRange.location -= deltaLoc;
    useRange.length += deltaLoc;

    __block NSString *lastWord;
    __block NSRange lastWordRange;
    [inputString.string enumerateSubstringsInRange:useRange options:(NSStringEnumerationByWords | NSStringEnumerationReverse)
                                        usingBlock: ^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop)
     {
         lastWord = subString;
         lastWordRange = subStringRange;
         *stop = YES;
     }];

    if (nil == lastWord || lastWordRange.location == NSNotFound)
        return NO;

    NSString *testWord = [lastWord stringByAppendingString:text];
    if ([self->functionNames containsObject:testWord])
    {
        return NO;
    }

    if ([self->functionNames containsObject:lastWord])
    {
        return YES;
    }

    return NO;
}


// External methods used to size and layout given data.
// Both of these may need to adjust themselves automatically based on the final size.

- (void)sizeRenderData: (NSArray *)renderData
{
    // Will have a typesetter pick the draw data origins later on.
    for (EQRenderData *drawData in renderData)
    {
        if ([drawData isKindOfClass:[EQRenderData class]])
        {
            CGRect imageBounds = [drawData imageBounds];
            drawData.boundingRectImage = imageBounds;
            drawData.boundingRectTypographic = [drawData typographicBounds];
        }
    }
}

// Method calls on the rootRenderStem to size any children.
// It then takes the resulting size and uses that to adjust the draw origin and bounds
// so that the entire drawing will be inside the subview.
- (void)layoutRenderStemsFromRoot: (EQRenderStem *)rootRenderStem
{
    if (nil == rootRenderStem || ![rootRenderStem isKindOfClass:[EQRenderStem class]])
        return;

    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    [rootRenderStem layoutChildren];

    // Need to adjust the layout vertically as your height increases.
    CGSize testSize = rootRenderStem.drawSize;
    CGPoint rootOrigin = rootRenderStem.drawOrigin;
    CGFloat testAdjust = rootOrigin.y - testSize.height;
    if (testAdjust < 0.0f)
    {
        NSMutableArray *renderData = [self.typesetterDelegate getRenderDataForRootStem:rootRenderStem];
        if (nil == renderData)
            return;

        for (EQRenderData *drawData in renderData)
        {
            if ([drawData isKindOfClass:[EQRenderData class]])
            {
                CGPoint drawOrigin = drawData.drawOrigin;
                drawOrigin.y -= testAdjust;
                drawData.drawOrigin = drawOrigin;
            }
        }
        rootOrigin.y -= testAdjust;
        rootRenderStem.drawOrigin = rootOrigin;
    }
}

/*
    Internal methods used to add text to a given renderData.
    Moved here as it will need to be called by big op, but in a slightly different way.
*/

    - (void)addText: (NSString *)text
 withFontDictionary: (NSDictionary *)fontDictionary
 withAttributedText: (NSAttributedString *)attributedText
           withData: (EQRenderData *)selectedData
            inRange: (EQTextRange *)selectedTextRange
     withMarkedData: (EQRenderData *)markedData
            inRange: (EQTextRange *)markedTextRange
    usingRenderData: (NSMutableArray *)renderData
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    // Sanity check.
    if (nil == text || text.length == 0 || nil == selectedData || nil == selectedTextRange || nil == renderData)
    {
        return;
    }

    NSUInteger markedLoc = markedTextRange.dataLoc;
    NSUInteger selectedLoc = selectedTextRange.dataLoc;

    NSUInteger markedEqLoc = markedTextRange.equationLoc;
    NSUInteger selectedEqLoc = selectedTextRange.equationLoc;

    NSRange markedTextNSRange = markedTextRange.range;
    NSRange selectedNSRange = selectedTextRange.range;

    EQTextRange *storedRange = nil;

    // Look for characters that have a special meaning first.

    // We are sent an enter string. This currently signals to end a sup/sub/subsup stem.
    // Should be refactored to include adding an equation line later.
    if ([text isEqualToString:@"\n"])
    {
        [self handleReturnCharacterWithData:selectedData inRange:selectedTextRange usingRenderData:renderData];
        return;
    }
    else if ([text isEqualToString:@"^"])
    {
        EQInputData *newInput = [[EQInputData alloc] initWithStemType:inputTypeSup];
        [self parseInputData:newInput withData:selectedData inRange:selectedTextRange
              withMarkedData:markedData inRange:markedTextRange usingRenderData:renderData];
        return;
    }
    else if ([text isEqualToString:@"_"])
    {
        EQInputData *newInput = [[EQInputData alloc] initWithStemType:inputTypeSub];
        [self parseInputData:newInput withData:selectedData inRange:selectedTextRange
              withMarkedData:markedData inRange:markedTextRange usingRenderData:renderData];
        return;
    }
    else if ([text isEqualToString:@"\\"])
    {
        EQInputData *newInput = [[EQInputData alloc] initWithStemType:inputTypeFractionOver];
        [self parseInputData:newInput withData:selectedData inRange:selectedTextRange
              withMarkedData:markedData inRange:markedTextRange usingRenderData:renderData];
        return;
    }

    // Test to see if you are in the root data for a large stem.
    BOOL isIntegralData = NO;
    if (nil != selectedData && nil != selectedData.parentStem && selectedData.parentStem.isLargeOpStemType && [selectedData.parentStem.getFirstChild isEqual:selectedData])
    {
        isIntegralData = YES;
    }
    // Test to see if you are in a radical or not.
    BOOL isRadicalData = NO;
    if (nil != selectedData && nil != selectedData.parentStem && selectedData.parentStem.hasSupplementaryData
        && [selectedData.parentStem.supplementaryData isEqual:selectedData])
    {
        isRadicalData = YES;
    }

    if (isIntegralData || isRadicalData)
    {
        // Move the correct location to add the data.
        // Or move add an empty data if that doesn't work.
        if (selectedNSRange.location > 0)
        {
            EQRenderStem *selectedParent = selectedData.parentStem;
            if (isRadicalData)
            {
                EQRenderData *firstDesc = (EQRenderData *)[selectedParent getFirstDescendent];
                if (nil == firstDesc)
                    return;
                selectedData = firstDesc;
                selectedNSRange = NSMakeRange(0, 0);
                selectedLoc = [renderData indexOfObject:selectedData];
                selectedTextRange.range = selectedNSRange;
                selectedTextRange.dataLoc = selectedLoc;
            }
            else if (isIntegralData)
            {
                EQRenderStem *parentOfParent = selectedParent.parentStem;
                if (nil == parentOfParent || !parentOfParent.isRowStemType)
                    return;

                id nextSiblingObj = [selectedParent getNextSiblingForChild:selectedParent];
                if (nil == nextSiblingObj || [nextSiblingObj isKindOfClass:[EQRenderStem class]])
                {
                    EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
                    if (nil == nextSiblingObj)
                    {
                        [parentOfParent appendChild:newData];
                    }
                    else if ([nextSiblingObj isKindOfClass:[EQRenderStem class]])
                    {
                        NSUInteger useLoc = [parentOfParent getLocForChild:selectedParent];
                        [parentOfParent insertChild:newData atLoc:useLoc];
                    }

                    [renderData addObject:newData];
                    selectedData = newData;
                    selectedNSRange = NSMakeRange(0, 0);
                    selectedLoc = [renderData indexOfObject:newData];
                    selectedTextRange.range = selectedNSRange;
                    selectedTextRange.dataLoc = selectedLoc;
                }
                else if ([nextSiblingObj isKindOfClass:[EQRenderData class]])
                {
                    selectedData = (EQRenderData *)nextSiblingObj;
                    selectedNSRange = NSMakeRange(0, 0);
                    selectedLoc = [renderData indexOfObject:selectedData];
                    selectedTextRange.range = selectedNSRange;
                    selectedTextRange.dataLoc = selectedLoc;
                }
                else
                {
                    return;
                }
            }
        }
        else
        {
            if (nil == selectedData.parentStem.parentStem)
                return;

            EQRenderStem *parentOfParent = selectedData.parentStem.parentStem;
            id previousObj = [parentOfParent getPreviousSiblingForChild:selectedData.parentStem];
            if (nil == previousObj || [previousObj isKindOfClass:[EQRenderStem class]])
            {
                // Insert a new empty renderData.
                NSUInteger prevLoc = [parentOfParent getLocForChild:selectedData.parentStem];
                EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
                [parentOfParent insertChild:newData atLoc:prevLoc];
                [renderData addObject:newData];
                selectedData = newData;
                selectedNSRange = NSMakeRange(1, 0);
                selectedLoc = [renderData indexOfObject:newData];
                selectedTextRange.range = selectedNSRange;
                selectedTextRange.dataLoc = selectedLoc;
            }
            else if ([previousObj isKindOfClass:[EQRenderData class]])
            {
                selectedData = (EQRenderData *)previousObj;
                selectedNSRange = NSMakeRange(selectedData.renderString.length, 0);
                selectedLoc = [renderData indexOfObject:selectedData];
                selectedTextRange.range = selectedNSRange;
                selectedTextRange.dataLoc = selectedLoc;
            }
            else
            {
                return;
            }
        }
    }

    Boolean useSmaller = selectedData.shouldUseSmaller;
    Boolean parentSmaller = FALSE;
    if (nil != selectedData.parentStem)
    {
        if (useSmaller == YES && selectedData.parentStem.stemType == stemTypeRow)
        {
            parentSmaller = selectedData.parentStem.shouldUseSmallest;
        }
        else
        {
            parentSmaller = selectedData.parentStem.shouldUseSmaller;
        }
    }

    NSAttributedString *customTextStr = nil;
    BOOL hasPlainText = NO;
    if (nil == fontDictionary && nil == attributedText)
    {
        // Used to add spacing around operations. Not needed for custom text strings (currently only bigOps).
        text = [self parseTextForOperation:text atSelectionLoc:selectedNSRange inAttributedString:selectedData.renderString
                                useSmaller:useSmaller withData:selectedData];
    }
    else if (nil != attributedText)
    {
        // May need to check for spaces that have been added.
        text = [self parseTextForOperation:text atSelectionLoc:selectedNSRange inAttributedString:selectedData.renderString
                                useSmaller:useSmaller withData:selectedData];

        if (useSmaller)
        {
            NSMutableAttributedString *editStr = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
            [editStr enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, editStr.length) options:0 usingBlock:
             ^(UIFont *useFont, NSRange range, BOOL *stop)
            {
                useFont = [UIFont fontWithName:useFont.fontName size:kDEFAULT_FONT_SIZE_SMALL];
                [editStr addAttribute:NSFontAttributeName value:useFont range:range];
            }];
            attributedText = editStr.copy;
        }
        customTextStr = attributedText;
    }
    else if (nil != fontDictionary && nil != text)
    {
        if (useSmaller)
        {
            NSMutableDictionary *editDict = [[NSMutableDictionary alloc] initWithDictionary:fontDictionary];
            UIFont *useFont = editDict[NSFontAttributeName];
            useFont = [UIFont fontWithName:useFont.fontName size:kDEFAULT_FONT_SIZE_SMALL];
            editDict[NSFontAttributeName] = useFont;
            fontDictionary = editDict.copy;
        }
        customTextStr = [[NSAttributedString alloc] initWithString:text attributes:fontDictionary];

        // Plain text should send nil for attributed text.
        NSNumber *usesPlainTextValue = fontDictionary[kUSES_PLAIN_TEXT];
        if (nil != usesPlainTextValue)
        {
            hasPlainText = usesPlainTextValue.boolValue;
        }
    }

    if (nil != markedData)
    {
        // Not bothering with undo/redo support as I'm not even sure what marked text will be used for yet.
        if (nil == customTextStr)
        {
            [markedData replaceCharactersInRange:markedTextRange withText:text];
        }
        else
        {
            [markedData replaceCharactersAndAttributesInRange:markedTextRange withAttributedString:customTextStr];
        }
        selectedNSRange.location = markedTextNSRange.location + text.length;
        selectedNSRange.length = 0;
        markedTextNSRange = NSMakeRange(NSNotFound, 0);
        markedLoc = selectedLoc;
    }
    else if (nil != selectedData)
    {
        // If you've got an unselected range and a single space as the string, replace the string with your new text.
        // Should only do this auto replace the first time.
        // Should prevent duplicate spaces, however.
        BOOL shouldCheckDupes = YES;
        if (selectedNSRange.length == 0 && [selectedData.renderString.string isEqualToString:@" "])
        {
            if (![text isEqualToString:@" "] && (selectedData.hasAutoReplacedSpace == NO || (text.length > 1 && [text hasPrefix:@" "])) )
            {
                selectedNSRange = NSMakeRange(0, 1);
                selectedTextRange.range = selectedNSRange;
                selectedData.hasAutoReplacedSpace = YES;
                shouldCheckDupes = NO;
            }
        }
        // Test if you are inserting an extra white space at the start of the new string.
        // You should only do this for selections, or if it is an auto insert after an undo/redo.
        // In which case the range.length > 0, or the attributedText is not nil.
        if ((selectedNSRange.length > 0 || nil != attributedText) && text.length > 0 && [text hasPrefix:@" "] && selectedNSRange.location > 0)
        {
            NSRange testRange = NSMakeRange(selectedNSRange.location - 1, 1);
            NSString *testPrev = [selectedData.renderString.string substringWithRange:testRange];
            if ([testPrev isEqualToString:@" "])
            {
                text = [text substringFromIndex:1];
            }
        }

        // Test if you are inserting an extra white space at the end of the new string.
        // You should only do this for selections, or if it is an auto insert after an undo/redo.
        // In which case the range.length > 0, or the attributedText is not nil.
        unsigned long location = selectedNSRange.location + selectedNSRange.length;
        if ((selectedNSRange.length > 0 || nil != attributedText) && [text hasSuffix:@" "] && text.length > 1
            && (location < selectedData.renderString.string.length))
        {
            NSRange testRange = NSMakeRange((selectedNSRange.location + selectedNSRange.length), 1);
            NSString *testNext = [selectedData.renderString.string substringWithRange:testRange];
            if ([testNext isEqualToString:@" "])
            {
                text = [text substringToIndex:(text.length - 1)];
            }
        }

        // If you're inserting something with a leading space,
        // check for a trailing space to help avoid adding a duplicate space.
        if (shouldCheckDupes == YES && text.length > 1 && [text hasPrefix:@" "] && !hasPlainText)
        {
            BOOL hasTrailingSpace = [self checkForTrailingString:@" " inTextRange:selectedTextRange withData:selectedData];
            if (hasTrailingSpace == YES)
            {
                text = [text substringFromIndex:1];
            }
        }

        // You need to transfer any changes made to the text string back into the attributed string.
        // Should try to preserve styling though.
        if (nil != attributedText && ![attributedText.string isEqualToString:text])
        {
            NSMutableAttributedString *replaceStr = [attributedText mutableCopy];
            [replaceStr replaceCharactersInRange:NSMakeRange(0, attributedText.length) withString:text];
            attributedText = [[NSAttributedString alloc] initWithAttributedString:replaceStr];
            customTextStr = attributedText;
        }

        if (selectedNSRange.length > 0)
        {
            storedRange = [selectedTextRange copy];
            NSRange useRange = storedRange.range;
            useRange.length = text.length;
            storedRange.range = useRange;

            // In this case you are actually replacing one substring with another.
            // So undo/redo needs to store the string fragment (with style).
            if (nil == customTextStr)
            {
                [selectedData replaceCharactersInRange:selectedTextRange withText:text];
            }
            else
            {
                [selectedData replaceCharactersAndAttributesInRange:selectedTextRange withAttributedString:customTextStr];
            }
            selectedNSRange.length = 0;
            selectedNSRange.location += text.length;
        }
        else
        {
            // Test to see if you are appending a operator at the start of a small font stem.
            // Edge case that should collapse extra space in the stem.
            if ([self stringHasBinomialOperator:text] && [selectedData.renderString.string isEqualToString:@" "]
                && selectedData.shouldUseSmaller == YES && hasPlainText == NO)
            {
                // In this case, you are replacing the entire string.
                // So undo/redo needs to store the entire old string.

                if (nil == customTextStr)
                {
                    [selectedData replaceRenderStringWithNewString:text];
                }
                else
                {
                    selectedData.renderString = [customTextStr mutableCopy];
                }
                selectedNSRange.length = 0;
                selectedNSRange.location = text.length;
            }
            else
            {
                if (nil == customTextStr)
                {
                    [selectedData insertText:text atPosition:selectedTextRange.textPosition];
                }
                else
                {
                    [selectedData insertAttributedString:customTextStr atPosition:selectedTextRange.textPosition];
                }
                selectedNSRange.location += text.length;
            }
        }
    }

    markedTextRange = [EQTextRange textRangeWithRange:markedTextNSRange andLocation:markedLoc andEquationLoc:markedEqLoc];
    [self sendWillUpdateAll];
    [self.typesetterDelegate sendUpdateMarkedTextRange:markedTextRange];

    selectedTextRange = [EQTextRange textRangeWithRange:selectedNSRange andLocation:selectedLoc andEquationLoc:selectedEqLoc];
    [self.typesetterDelegate sendUpdateSelectedTextRange:selectedTextRange];

    // Apply styling to the data being worked on.
    // Ignore for custom text strings.
    if (nil == customTextStr)
    {
        if (selectedNSRange.location != NSNotFound)
        {
            [self applyMathStyleToAttributedString:selectedData.renderString inRange:NSMakeRange(0, selectedNSRange.location) useSmaller:useSmaller
             parentSmaller:parentSmaller];
        }
        [self kernMathInAttributedString:selectedData.renderString];
    }

    [self.typesetterDelegate sendFinishedUpdating];
    [self sendDidUpdateAll];
    return;
}

/*
    Internal methods used to manipulate renderStems and their associated renderData.
*/

// Updates the renderData splitting its attributedString into pieces: the old renderData, the new stem pieces, and the remaining renderData.
// Returns nil if it is unable to do the insertion.

- (NSArray *)updateRenderData: (EQRenderData *)renderData
                     useRange: (EQTextRange *)textRange
          insertNewStemOfType: (EQRenderStemType)stemType
                shouldAddData: (BOOL)addDataToStem
{
    // Sanity check the inputs.
    if (nil == renderData || renderData.renderString.length == 0 || textRange.range.location == NSNotFound
        || textRange.range.location > renderData.renderString.length
        || textRange.range.location + textRange.range.length > renderData.renderString.length
        || textRange.range.location + textRange.range.length == 0)
    {
        return nil;
    }

    if (stemType == stemTypeSup || stemType == stemTypeSub || stemType == stemTypeFraction || stemType == stemTypeOver || stemType == stemTypeUnder
        || stemType == stemTypeSqRoot || stemType == stemTypeNRoot || stemType == stemTypeMatrix)
    {
        NSRange useRange = textRange.range;
        NSAttributedString *stemString = [[NSAttributedString alloc] initWithString:@""];
        BOOL hasLargeOp = NO;

        // For sub/sup, build the base renderData object.
        // May need to expand this to handle /over fractions later.
        if (addDataToStem == YES)
        {
            if (useRange.length == 0)
            {
                // Test for function names or other groupings here.
                // This allows you to put the entire name in the root stem instead of just the last character.
                useRange = [self findRootRangeForRange:useRange RenderData:renderData withStemType:stemType];
            }
            stemString = [renderData.renderString attributedSubstringFromRange:useRange];
            BOOL currentIsNumeral = [stemString.string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound;
            while (currentIsNumeral && useRange.location > 0)
            {
                NSRange testRange = useRange;
                testRange.location --;
                testRange.length = 1;
                NSString *testString = [renderData.renderString.string substringWithRange:testRange];
                currentIsNumeral = [testString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound;
                if (currentIsNumeral)
                {
                    useRange.location --;
                    useRange.length ++;
                    stemString = [renderData.renderString attributedSubstringFromRange:useRange];
                }
            }
            // Test to see if the parent is a large op.
            // May need to adjust this later to be less dependent upon base font size.
            UIFont *testFont = [stemString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
            hasLargeOp = testFont.pointSize > kDEFAULT_FONT_SIZE;
        }

        // Build the renderData for the string to the left side of where you are inserting.
        NSAttributedString *leftString = [renderData.renderString attributedSubstringFromRange:NSMakeRange(0, useRange.location)];
        NSInteger rightPos = useRange.location + useRange.length;

        // Build the new data for the right side of the old data, if needed.
        EQRenderData *rightData;
        if (rightPos < renderData.renderString.length)
        {
            NSAttributedString *rightString = [renderData.renderString attributedSubstringFromRange:NSMakeRange(rightPos, renderData.renderString.length - rightPos)];
            rightData = [[EQRenderData alloc]init];
            rightData.renderString = [rightString mutableCopy];
            rightData.parentStem = renderData.parentStem;
        }
        else
        {
            rightData = nil;
        }

        // Update the renderData to the new substring and set needs redrawn.
        renderData.renderString = [leftString mutableCopy];
        renderData.needsRedrawn = YES;
        if (renderData.renderString.length > 0)
        {
            NSNumber *leftKernValue = [renderData.renderString attribute:NSKernAttributeName atIndex:(renderData.renderString.length - 1) effectiveRange:NULL];
            if (leftKernValue.floatValue > 1.5 && [rightBracketCharacters containsObject:stemString.string] && ![stemString.string isEqualToString:@"}"])
            {
                [self clearTrailingKernInAttributedString:renderData.renderString];
            }
        }

        // Create the new stem object.
        EQRenderStem *supStem = [[EQRenderStem alloc] init];
        supStem.hasLargeOp = hasLargeOp;

        if (stemType == stemTypeSub || stemType == stemTypeSup || stemType == stemTypeUnder || stemType == stemTypeOver)
        {
            // Build the new renderData for the base and the sup.
            EQRenderData *baseData = [[EQRenderData alloc] init];
            baseData.renderString = [stemString mutableCopy];
            EQRenderData *supData = [[EQRenderData alloc] initWithString:@""];

            // Add the new data to the stem.
            [supStem setChild:baseData atLoc:0];
            [supStem setChild:supData atLoc:1];
        }
        else if (stemType == stemTypeFraction)
        {
            supStem = [[EQRenderFracStem alloc] init];

            // Add the new data to the stem.
            // For MFRAC, order is: numerator, denominator.
            // Use existing stem if addDataToStem = YES.
            EQRenderData *numData;
            if (addDataToStem == YES)
            {
                numData = [[EQRenderData alloc] init];
                numData.renderString = [stemString mutableCopy];
            }
            else
            {
                numData = [[EQRenderData alloc] initWithString:@" "];
            }

            EQRenderData *denData = [[EQRenderData alloc] initWithString:@" "];
            [supStem setChild:numData atLoc:0];
            [supStem setChild:denData atLoc:1];
        }
        else if (stemType == stemTypeSqRoot)
        {
            EQRenderData *rootData = [[EQRenderData alloc] initWithString:@" "];
            supStem = [[EQRenderStem alloc] initWithObject:rootData andStemType:stemTypeSqRoot];
        }
        else if (stemType == stemTypeNRoot)
        {
            EQRenderData *rootData = [[EQRenderData alloc] initWithString:@" "];
            supStem = [[EQRenderStem alloc] initWithObject:rootData andStemType:stemTypeNRoot];
        }
        else if (stemType == stemTypeMatrix)
        {
            // Will need to re-initialize it in the calling method as it requires
            // the characterData from the inputData in order to know how large it should make it.
            supStem = [[EQRenderMatrixStem alloc] init];
        }
        supStem.stemType = stemType;
        supStem.parentStem = renderData.parentStem;

        // Return the values as needed.
        if (nil == rightData)
        {
            return @[renderData, supStem];
        }
        else
        {
            return @[renderData, supStem, rightData];
        }
    }
    return nil;
}

- (void)clearTrailingKernInAttributedString: (NSMutableAttributedString *)renderString
{
    NSRange updateRange = NSMakeRange((renderString.length -1), 1);
    NSDictionary *oldDict = [renderString attributesAtIndex:updateRange.location effectiveRange:NULL];
    NSMutableDictionary *newDict = oldDict.mutableCopy;
    newDict[NSKernAttributeName] = @0.0;
    [renderString setAttributes:newDict range:updateRange];
}

- (NSRange)findRootRangeForRange: (NSRange)useRange RenderData: (EQRenderData *)renderData withStemType: (EQRenderStemType)stemType
{
    // Don't correct errors, just pass back whatever input you were given without evaluation.
    if (nil == renderData || stemType == stemTypeUnassigned || useRange.location == NSNotFound)
    {
        return useRange;
    }

    if (useRange.location + useRange.length > renderData.renderString.length || useRange.location == 0 || useRange.length > 0)
    {
        return useRange;
    }

    // Default behavior is to just capture the previous character.
    NSRange returnRange = useRange;
    returnRange.location --;
    returnRange.length = 1;

    if (stemType == stemTypeFraction || stemType == stemTypeSqRoot || stemType == stemTypeNRoot || stemType == stemTypeMatrix)
    {
        return returnRange;
    }

    NSString *testString = renderData.renderString.string;
    NSString *renderString = [testString substringToIndex:useRange.location];
    NSRange renderStringRange = NSMakeRange(0, renderString.length);

    if ([self->functionNames containsObject:renderString])
    {
        return renderStringRange;
    }

    // Find the last word in the usable range.
    __block NSString *lastWord;
    __block NSRange lastWordRange;
    [renderString enumerateSubstringsInRange:renderStringRange options:(NSStringEnumerationByWords | NSStringEnumerationReverse)
                                        usingBlock: ^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop)
     {
         lastWord = subString;
         lastWordRange = subStringRange;
         *stop = YES;
     }];

    if (nil == lastWord || lastWordRange.location == NSNotFound)
        return returnRange;

    // If you have a matching function name, return the range for that.
    if ([self->functionNames containsObject:lastWord])
    {
        return lastWordRange;
    }

    // Return the last character if you don't have a good match.
    return returnRange;
}

- (void)removeChildrenFromRenderDataForStem: (EQRenderStem *)renderStem
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    if (nil == renderStem)
        return;

    NSMutableArray *renderData = [self.typesetterDelegate getRenderData];

    for (id renderObj in renderStem.renderArray)
    {
        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            [renderData removeObject:renderObj];
        }
        else if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            [self removeChildrenFromRenderDataForStem:(EQRenderStem *)renderObj];
        }
    }
    if (renderStem.hasSupplementaryData && nil != renderStem.supplementaryData)
    {
        [renderData removeObject:renderStem.supplementaryData];
    }
}

- (void)handleReturnCharacterWithData: (EQRenderData *)selectedData
                              inRange: (EQTextRange *)selectedTextRange
                      usingRenderData: (NSMutableArray *)renderData
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    if (selectedData.renderString == nil || selectedTextRange.range.location == NSNotFound)
        return;

    EQRenderStem *parentStem = selectedData.parentStem;
    if (nil == parentStem)
    {
        return;
    }
    if (nil == parentStem.parentStem)
    {
        if (parentStem.stemType == stemTypeRoot)
        {
            // Test to see if you are at the end of the equation or not.
            id lastChild = [parentStem getLastDescendent];
            NSUInteger childLength = [(EQRenderData *)lastChild renderString].length;
            if (lastChild == selectedData && selectedTextRange.range.location >= childLength)
            {
                // If at the end, then add a new equation line.
                [self.typesetterDelegate addNewEquationLine];
            }
            else if (nil != lastChild)
            {
                NSUInteger useLoc = [renderData indexOfObject:lastChild];
                selectedTextRange.dataLoc = useLoc;
                selectedTextRange.range = NSMakeRange(childLength, 0);
                [self sendUpdatesAndResetSelectedRange:selectedTextRange];
            }
        }
        return;
    }

    // Check to see if it is a radical character.
    if (nil != selectedData && nil != selectedData.parentStem && selectedData.parentStem.hasSupplementaryData
        && [selectedData.parentStem.supplementaryData isEqual:selectedData])
    {
        // Move it to the correct location for a radical stem.
        EQRenderData *firstDesc = [parentStem getFirstDescendent];
        if (nil == firstDesc)
            return;

        NSUInteger useLoc = [renderData indexOfObject:firstDesc];
        selectedTextRange.dataLoc = useLoc;
        selectedTextRange.range = NSMakeRange(firstDesc.renderString.length, 0);
        [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        return;
    }

    NSUInteger useChildLoc = [parentStem getLocForChild:selectedData];

    // You should handle row stems differently.
    if (parentStem.stemType == stemTypeRow)
    {
        EQRenderStem *testStem = parentStem.parentStem.parentStem;
        if (nil == testStem)
            return;

        // Test to see if your current stem is empty.
        // If it is, then you should remove it from the parent.
        if ([selectedData.renderString.string isEqualToString:@" "])
        {
            [parentStem removeChild:selectedData];
            [renderData removeObject:selectedData];
        }

        // Should now do a normal return with the parent of parent as the root.
        useChildLoc = [parentStem.parentStem getLocForChild:parentStem];
        parentStem = parentStem.parentStem;
    }

    if (nil == parentStem.renderArray || parentStem.renderArray.count == 0 || useChildLoc == NSNotFound)
        return;

    EQRenderStem *parentStem2 = parentStem.parentStem;
    if (nil == parentStem2)
        return;

    id nextSiblingObj;
    BOOL parentStemIsNumerator = NO;

    if (parentStem.stemType == stemTypeSup || parentStem.stemType == stemTypeSub || parentStem.stemType == stemTypeSubSup
        || parentStem.stemType == stemTypeUnder || parentStem.stemType == stemTypeOver || parentStem.stemType == stemTypeUnderOver)
    {
        // Treat fraction numerators different from normal next sibling checks.
        if (parentStem2.stemType == stemTypeFraction && [parentStem isEqual:[parentStem2 getFirstChild]])
        {
            nextSiblingObj = nil;
            parentStemIsNumerator = YES;
        }
        else
        {
            nextSiblingObj = [parentStem2 getNextSiblingForChild:parentStem];
        }
    }
    else if (parentStem.stemType == stemTypeFraction)
    {
        id testChildObj = [parentStem.renderArray objectAtIndex:useChildLoc];
        if (nil == testChildObj)
            return;

        if (useChildLoc == 0)
        {
            nextSiblingObj = [parentStem getNextSiblingForChild:testChildObj];
        }
        else
        {
            // Treat fraction numerators different from normal next sibling checks.
            if (parentStem2.stemType == stemTypeFraction && [parentStem isEqual:[parentStem2 getFirstChild]])
            {
                nextSiblingObj = nil;
                parentStemIsNumerator = YES;
            }
            else
            {
                nextSiblingObj = [parentStem2 getNextSiblingForChild:parentStem];
            }
        }
    }
    else if (parentStem.stemType == stemTypeSqRoot || parentStem.stemType == stemTypeNRoot)
    {
        nextSiblingObj = [parentStem2 getNextSiblingForChild:parentStem];
    }
    // Matrix cells take a different path due to the 2 dimensional navigation.
    else if (parentStem.stemType == stemTypeMatrixCell)
    {
        // Get the next child in the cell.
        nextSiblingObj = [parentStem getNextSiblingForChild:selectedData];
        EQRenderStem *rowParent = parentStem2;

        // If next object is nil, then test to see
        // if this is the last object in the cell or not.
        if (nil == nextSiblingObj && [selectedData isEqual:[parentStem getLastChild]])
        {
            // If it is, try to get the next cell.
            nextSiblingObj = [rowParent getNextSiblingForChild:parentStem];
            NSUInteger useLoc = 0;
            NSRange useRange = NSMakeRange(0, 0);
            BOOL foundMatch = NO;
            BOOL moveToEnd = YES;
            if (nil != nextSiblingObj && [nextSiblingObj isKindOfClass:[EQRenderStem class]] && [nextSiblingObj stemType] == stemTypeMatrixCell)
            {
                // If you've got the next cell, what you really want is the first child inside of it.
                EQRenderStem *nextStemSibling = (EQRenderStem *)nextSiblingObj;
                nextSiblingObj = [nextStemSibling getFirstChild];
                foundMatch = YES;
            }
            // Haven't found the next sibling yet.
            // Test to see if this is the last object in the row.
            else if (nil == nextSiblingObj)
            {
                if (nil != rowParent && [parentStem isEqual:[rowParent getLastChild]])
                {
                    EQRenderStem *matrixParent = rowParent.parentStem;
                    if (nil != matrixParent)
                    {
                        // Test to see if there's another row. If so, then get its first child.
                        id nextRowObj = [matrixParent getNextSiblingForChild:rowParent];
                        if (nil != nextRowObj && [nextRowObj isKindOfClass:[EQRenderStem class]]
                            && [(EQRenderStem *)nextRowObj stemType] == stemTypeMatrixRow)
                        {
                            EQRenderStem *nextRowParent = (EQRenderStem *)nextRowObj;
                            id nextCell = [nextRowParent getFirstChild];
                            if (nil != nextCell && [nextCell isKindOfClass:[EQRenderStem class]]
                                && [(EQRenderStem *)nextCell stemType] == stemTypeMatrixCell)
                            {
                                nextSiblingObj = [(EQRenderStem *)nextCell getFirstChild];
                                foundMatch = YES;
                            }
                        }
                        else if (nil == nextRowObj)
                        {
                            // If there is no next row, then you may be at the end of the matrix.
                            EQRenderStem *parentOfMatrix = matrixParent.parentStem;
                            if (nil != parentOfMatrix)
                            {
                                id testNextObj = [parentOfMatrix getNextSiblingForChild:matrixParent];
                                // Object may or may not exist depending upon whether this is the last child.
                                if (nil != testNextObj)
                                {
                                    if ([testNextObj isKindOfClass:[EQRenderData class]])
                                    {
                                        nextSiblingObj = testNextObj;
                                        foundMatch = YES;
                                        moveToEnd = NO;
                                    }
                                    else if ([testNextObj isKindOfClass:[EQRenderStem class]])
                                    {
                                        // Insert a new empty renderData in between the two.
                                        // This may not be the ideal solution but the other option
                                        // has problems as you start to add items to the base of the stem object.
                                        // May need to adjust this further to handle row stems or other objects.
                                        NSUInteger currentLoc = [parentOfMatrix getLocForChild:testNextObj];
                                        EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
                                        [parentOfMatrix insertChild:newData atLoc:currentLoc];
                                        [renderData addObject:newData];
                                        nextSiblingObj = newData;
                                        foundMatch = YES;
                                    }
                                }
                                else if ([matrixParent isEqual:[parentOfMatrix getLastChild]])
                                {
                                    // You are the last object, so add data to the end.
                                    EQRenderData *newLastData = [[EQRenderData alloc] initWithString:@" "];
                                    [parentOfMatrix appendChild:newLastData];
                                    [renderData addObject:newLastData];
                                    nextSiblingObj = newLastData;
                                    foundMatch = YES;
                                }
                            }
                        }
                    }
                }
            }

            if (foundMatch == NO)
            {
                // Return if you can't find the parent, something weird may be going on.
//                NSLog(@"Missing row parent, or something else weird going on with navigation.");
                return;
            }

            if ([nextSiblingObj isKindOfClass:[EQRenderData class]])
            {
                useLoc = [renderData indexOfObject:nextSiblingObj];
                if (moveToEnd == YES)
                {
                    NSUInteger length = [(EQRenderData *)nextSiblingObj renderString].string.length;
                    useRange = NSMakeRange(length, 0);
                }
            }
            else if ([nextSiblingObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderData *lastDesc = [(EQRenderStem *)nextSiblingObj getLastDescendent];
                if (nil != lastDesc && [lastDesc isKindOfClass:[EQRenderData class]])
                {
                    useLoc = [renderData indexOfObject:lastDesc];
                    if (moveToEnd == YES)
                    {
                        NSUInteger length = lastDesc.renderString.length;
                        useRange = NSMakeRange(length, 0);
                    }
                }
            }
            selectedTextRange.dataLoc = useLoc;
            selectedTextRange.range = useRange;
            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
            return;
        }
    }
    else
    {
//        NSLog(@"No matching return handle for this stem type.");
        return;
    }

    // If you have found the next sibling object, do a normal insert.
    if (nil != nextSiblingObj)
    {
        if ([nextSiblingObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *nextSiblingData = (EQRenderData *)nextSiblingObj;
            selectedTextRange.dataLoc = [renderData indexOfObject:nextSiblingData];
            if ([nextSiblingData.renderString.string isEqualToString:@" "])
            {
                selectedTextRange.range = NSMakeRange(1, 0);
            }
            else
            {
                selectedTextRange.range = NSMakeRange(0, 0);
            }
        }
        else if ([nextSiblingObj isKindOfClass:[EQRenderStem class]])
        {
            // Insert a new empty renderData in between the two.
            // This may not be the ideal solution but the other option
            // has problems as you start to add items to the base of the stem object.
            // May need to adjust this further to handle row stems or other objects.
            NSUInteger currentLoc = [parentStem2 getLocForChild:nextSiblingObj];
            EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
            [parentStem2 insertChild:newData atLoc:currentLoc];
            [renderData addObject:newData];
            selectedTextRange.dataLoc = [renderData indexOfObject:newData];
            selectedTextRange.range = NSMakeRange(0, 0);
        }
        else
        {
            return;
        }

        [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        return;
    }
    else
    {
        // Test to see if your parent is the last child or a numerator.
        // If it is, then create a new renderData and append it.
        if (parentStemIsNumerator || [parentStem isEqual:[parentStem2 getLastChild]])
        {
            // The " " seems to be necessary for any insertion (empty strings cause problems I guess).
            EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];

            // Test to see if you should append or add a new rowStem object to the location.
            if ([parentStem2 isRowStemType])
            {
                [parentStem2 appendChild:newData];
                [renderData addObject:newData];
            }
            else
            {
                EQRenderStem *newRowStem = [[EQRenderStem alloc] init];
                newRowStem.stemType = stemTypeRow;
                NSUInteger oldParentLoc = [parentStem2 getLocForChild:parentStem];
                [newRowStem appendChild:parentStem];
                [newRowStem appendChild:newData];
                [parentStem2 setChild:newRowStem atLoc:oldParentLoc];
                [renderData addObject:newData];
            }
            selectedTextRange.dataLoc = [renderData indexOfObject:newData];
            selectedTextRange.range = NSMakeRange(1, 0);

            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
            return;
        }
    }
}

// Do smart insert that converts the data to a row if need be.
- (void)addChildStem: (EQRenderStem *)childStem
        toParentStem: (EQRenderStem *)parentStem
               atLoc: (NSUInteger)selectedLoc
        withLeftData: (EQRenderData *)leftData
        withRightData: (EQRenderData *)rightData
{
    if (parentStem.stemType == stemTypeRow || parentStem.stemType == stemTypeRoot)
    {
        if (leftData.renderString.length == 0)
        {
            [parentStem setChild:childStem atLoc:selectedLoc];
        }
        else
        {
            [parentStem insertChild:childStem atLoc:(selectedLoc + 1)];
        }

        if (nil != rightData)
        {
            NSUInteger rightLoc = [parentStem getLocForChild:childStem] + 1;
            [parentStem insertChild:rightData atLoc:rightLoc];
        }

        return;
    }

    // Test to see if you need to add a new rowStem or not.
    if (leftData.renderString.length > 0 || rightData.renderString.length > 0)
    {
        EQRenderStem *rowStem = [[EQRenderStem alloc] init];
        rowStem.stemType = stemTypeRow;
        if (nil != leftData && leftData.renderString.length > 0)
        {
            [rowStem appendChild:leftData];
        }
        [rowStem appendChild:childStem];
        if (nil != rightData && rightData.renderString.length > 0)
        {
            [rowStem appendChild:rightData];
        }

        [parentStem setChild:rowStem atLoc:selectedLoc];
    }
    else
    {
        [parentStem setChild:childStem atLoc:selectedLoc];
    }
}

- (void)addStemOfType: (EQRenderStemType)stemType
               ToData: (EQRenderData *)selectedData
        withInputData: (EQInputData *)inputData
              inRange: (EQTextRange *)selectedTextRange
      usingRenderData: (NSMutableArray *)renderData
        shouldAddData: (BOOL)addDataToStem
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    EQRenderStem *parentStem = selectedData.parentStem;

    // Stores the location in the parent stem array of the selectedData.
    NSUInteger selectedLoc = [parentStem getLocForChild:selectedData];

    // For Binomials, just change the stem type to fraction and flag it as having no divider line.
    BOOL useBinomialFraction = NO;
    if (stemType == stemTypeBinomial)
    {
        useBinomialFraction = YES;
        stemType = stemTypeFraction;
    }

    if (addDataToStem == YES)
    {

        // Special case for stems that are trying to insert using string with trailing space.
        // Need to only check the selection, rather than the entire string.
        // Should also ignore operators and other left bracket characters.

        BOOL trailingCharOkay = YES;

        NSString *trailingString = [self getTrailingStringForTextRange:selectedTextRange withData:selectedData];

        if (nil != trailingString)
        {
            if ([trailingString isEqualToString:@" "])
            {
                trailingCharOkay = NO;
            }
            else
            {
                if ([self stringHasBinomialOperator:trailingString] || [leftBracketCharacters containsObject:trailingString])
                {
                    trailingCharOkay = NO;
                }
            }
        }

        if (trailingCharOkay == NO)
        {
            // These should never add the stem.
            if (stemType == stemTypeSup || stemType == stemTypeSub || stemType == stemTypeOver || stemType == stemTypeUnder)
                return;

            // Others should just add an empty stem.
            addDataToStem = NO;
        }
    }

    if (selectedData.renderString.length == 0 || selectedTextRange.range.location == NSNotFound
        || ([selectedData.renderString.string isEqualToString:@" "]))
    {
        if (nil == parentStem || selectedLoc == NSNotFound)
        {
            return;
        }

        // Replace empty data with a new stem.
        if (stemType == stemTypeFraction)
        {
            EQRenderFracStem *newFracStem = [[EQRenderFracStem alloc] init];
            if (useBinomialFraction == YES)
            {
                newFracStem.lineThickness = 0.0;
            }

            [parentStem setChild:newFracStem atLoc:selectedLoc];

            // Set the numerator and the denominator of the fraction.
            if (selectedData.renderString.length == 0)
            {
                [selectedData appendString:@" "];
            }
            [newFracStem appendChild:selectedData];
            EQRenderData *denData = [[EQRenderData alloc] initWithString:@" "];
            [newFracStem appendChild:denData];
            [renderData addObject:denData];

            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        }
        else if (stemType == stemTypeSqRoot)
        {
            EQRenderData *rootData = [[EQRenderData alloc] initWithString:@" "];
            EQRenderStem *newSqRootStem = [[EQRenderStem alloc] initWithObject:rootData andStemType:stemTypeSqRoot];
            [parentStem setChild:newSqRootStem atLoc:selectedLoc];

            [renderData replaceObjectAtIndex:selectedTextRange.dataLoc withObject:rootData];
            if (newSqRootStem.hasSupplementaryData && nil != newSqRootStem.supplementaryData
                && [newSqRootStem.supplementaryData isKindOfClass:[EQRenderData class]])
            {
                [renderData addObject:newSqRootStem.supplementaryData];
            }

            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        }
        else if (stemType == stemTypeNRoot)
        {
            EQRenderData *rootData = [[EQRenderData alloc] initWithString:@" "];
            EQRenderStem *newNRootStem = [[EQRenderStem alloc] initWithObject:rootData andStemType:stemTypeNRoot];
            newNRootStem.hasStoredCharacterData = YES;
            newNRootStem.storedCharacterData = inputData.storedCharacterData;
            [newNRootStem updateSupplementaryData];
            [parentStem setChild:newNRootStem atLoc:selectedLoc];

            [renderData replaceObjectAtIndex:selectedTextRange.dataLoc withObject:rootData];
            if (newNRootStem.hasSupplementaryData && nil != newNRootStem.supplementaryData
                && [newNRootStem.supplementaryData isKindOfClass:[EQRenderData class]])
            {
                [renderData addObject:newNRootStem.supplementaryData];
            }

            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        }
        else if (stemType == stemTypeMatrix)
        {
            EQRenderMatrixStem *newMatrixStem = [[EQRenderMatrixStem alloc] initWithStoredCharacterData:inputData.storedCharacterData];
            [parentStem setChild:newMatrixStem atLoc:selectedLoc];

            // Not sure if we need to remove this or not, but we'll see.
            [renderData removeObjectAtIndex:selectedTextRange.dataLoc];
            [newMatrixStem addChildDataToRenderArray:renderData];
            id firstCellObj = [newMatrixStem getFirstCellObj];
            if (nil != firstCellObj && [firstCellObj isKindOfClass:[EQRenderData class]])
            {
                NSUInteger newLoc = [renderData indexOfObject:firstCellObj];
                if (newLoc != NSNotFound)
                {
                    NSUInteger length = [(EQRenderData *)firstCellObj renderString].string.length;
                    selectedTextRange.dataLoc = newLoc;
                    selectedTextRange.range = NSMakeRange(length, 0);
                }
            }

            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        }
        return;
    }

    // Handle most stem types. subsup is handled by adding to an existing sub or sup stem.
    if (stemType == stemTypeSup || stemType == stemTypeSub || stemType == stemTypeFraction || stemType == stemTypeUnder || stemType == stemTypeOver
        || stemType == stemTypeSqRoot || stemType == stemTypeNRoot || stemType == stemTypeMatrix)
    {
        NSArray *supArray = [self updateRenderData:selectedData useRange:selectedTextRange insertNewStemOfType:stemType shouldAddData:addDataToStem];
        if (nil != supArray)
        {
            EQRenderData *newSelectedData = supArray[0];
            EQRenderStem *newSupStem = supArray[1];
            EQRenderData *rightData = nil;
            if (supArray.count == 3)
            {
                rightData = supArray[2];
                [renderData addObject:rightData];
            }
            if (useBinomialFraction == YES && [newSupStem isKindOfClass:[EQRenderFracStem class]])
            {
                [(EQRenderFracStem *)newSupStem setLineThickness:0.0];
            }
            // Re-initialize the stem type as you didn't pass it how large it should be in the previous method call.
            if (stemType == stemTypeMatrix)
            {
                newSupStem = [[EQRenderMatrixStem alloc] initWithStoredCharacterData:inputData.storedCharacterData];
            }

            [self addChildStem:newSupStem toParentStem:parentStem atLoc:selectedLoc withLeftData:newSelectedData withRightData:rightData];

            // If there is anything on the left side of the old selectedData, stick it in the old location.
            if (newSelectedData.renderString.length > 0)
            {
                [renderData replaceObjectAtIndex:selectedTextRange.dataLoc withObject:newSelectedData];
            }
            else
            {
                [parentStem removeChild:selectedData];
                [renderData removeObject:selectedData];
            }

            // Add all of the stem's children to the data array.
            int childCounter = 0;

            // Find the location to place the new cursor.
            // This may vary depending on type of type of insert you are doing.
            NSUInteger initLoc = newSupStem.getInitialCursorLoc;
            if (stemType == stemTypeFraction && addDataToStem == YES)
            {
                initLoc = newSupStem.getLastCursorLoc;

                // Need to adjust size of numerator if you are a new nested fraction.
                if (newSupStem.shouldUseSmaller)
                {
                    EQRenderData *firstChild = (EQRenderData *)[newSupStem getFirstChild];
                    if (firstChild.shouldUseSmaller && [firstChild isKindOfClass:[EQRenderData class]])
                    {
                        [self applyMathStyleToAttributedString:firstChild.renderString inRange:NSMakeRange(0, firstChild.renderString.length)
                                                    useSmaller:YES parentSmaller:YES];
                    }
                }
            }
            // Need to include any stored character data for n-root stem types.
            // Also update the supplementary data before adding it.
            else if (stemType == stemTypeNRoot)
            {
                newSupStem.hasStoredCharacterData = YES;
                newSupStem.storedCharacterData = inputData.storedCharacterData;
                [newSupStem updateSupplementaryData];
            }

            // Matrices should be handled differently as they are multiple nested stems.
            if (stemType == stemTypeMatrix)
            {
                [(EQRenderMatrixStem *)newSupStem addChildDataToRenderArray:renderData];
                id firstCellObj = [(EQRenderMatrixStem *)newSupStem getFirstCellObj];
                if (nil != firstCellObj && [firstCellObj isKindOfClass:[EQRenderData class]])
                {
                    NSUInteger newLoc = [renderData indexOfObject:firstCellObj];
                    if (newLoc != NSNotFound)
                    {
                        NSUInteger length = [(EQRenderData *)firstCellObj renderString].string.length;
                        selectedTextRange.dataLoc = newLoc;
                        selectedTextRange.range = NSMakeRange(length, 0);
                    }
                }
            }
            else
            {
                for (id childData in newSupStem.renderArray)
                {
                    [renderData addObject:childData];
                    if (childCounter == initLoc && [childData isKindOfClass:[EQRenderData class]])
                    {
                        EQRenderData *child = (EQRenderData *)childData;
                        selectedTextRange.dataLoc = [renderData indexOfObject:childData];
                        selectedTextRange.range = NSMakeRange(child.renderString.length, 0);
                    }
                    childCounter ++;
                }

                // Add any supplementary data to the renderData array.
                // Should do this after the other data so as not to disturb the counter.
                if (newSupStem.hasSupplementaryData && nil != newSupStem.supplementaryData
                    && [newSupStem.supplementaryData isKindOfClass:[EQRenderData class]])
                {
                    [renderData addObject:newSupStem.supplementaryData];
                }
            } // End loop over childData branch.

            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        }
        else
        {
            // This can happen when you're trying to insert a stem at the very start of an equation row.
            // Should only allow this kind of inserts for certain stem types.
            if (selectedLoc == 0)
            {
                if (stemType == stemTypeFraction)
                {
                    EQRenderData *numData = [[EQRenderData alloc] initWithString:@" "];
                    EQRenderData *denData = [[EQRenderData alloc] initWithString:@" "];
                    EQRenderFracStem *newFracStem = [[EQRenderFracStem alloc] initWithObject:numData andStemType:stemTypeFraction];
                    if (useBinomialFraction == YES)
                    {
                        newFracStem.lineThickness = 0.0;
                    }
                    [newFracStem appendChild:denData];
                    [renderData addObject:numData];
                    [renderData addObject:denData];
                    [parentStem insertChild:newFracStem atLoc:0];
                }
                else if (stemType == stemTypeSqRoot)
                {
                    EQRenderData *rootData = [[EQRenderData alloc] initWithString:@" "];
                    EQRenderStem *newSqRootStem = [[EQRenderStem alloc] initWithObject:rootData andStemType:stemTypeSqRoot];

                    [renderData addObject:rootData];
                    if (newSqRootStem.hasSupplementaryData && nil != newSqRootStem.supplementaryData
                        && [newSqRootStem.supplementaryData isKindOfClass:[EQRenderData class]])
                    {
                        [renderData addObject:newSqRootStem.supplementaryData];
                    }
                    [parentStem insertChild:newSqRootStem atLoc:0];
                    selectedTextRange.dataLoc = [renderData indexOfObject:rootData];
                    selectedTextRange.range = NSMakeRange(rootData.renderString.length, 0);
                }
                else if (stemType == stemTypeNRoot)
                {
                    EQRenderData *rootData = [[EQRenderData alloc] initWithString:@" "];
                    EQRenderStem *newNRootStem = [[EQRenderStem alloc] initWithObject:rootData andStemType:stemTypeNRoot];
                    newNRootStem.hasStoredCharacterData = YES;
                    newNRootStem.storedCharacterData = inputData.storedCharacterData;
                    [newNRootStem updateSupplementaryData];

                    [renderData addObject:rootData];
                    if (newNRootStem.hasSupplementaryData && nil != newNRootStem.supplementaryData
                        && [newNRootStem.supplementaryData isKindOfClass:[EQRenderData class]])
                    {
                        [renderData addObject:newNRootStem.supplementaryData];
                    }
                    [parentStem insertChild:newNRootStem atLoc:0];
                    selectedTextRange.dataLoc = [renderData indexOfObject:rootData];
                    selectedTextRange.range = NSMakeRange(rootData.renderString.length, 0);
                }
                else if (stemType == stemTypeMatrix)
                {
                    EQRenderMatrixStem *newMatrixStem = [[EQRenderMatrixStem alloc] initWithStoredCharacterData:inputData.storedCharacterData];
                    [newMatrixStem addChildDataToRenderArray:renderData];
                    [parentStem insertChild:newMatrixStem atLoc:0];
                }
                else
                {
//                    NSLog(@"Found new stem type with nil insert array.");
                    return;
                }

                [self sendUpdatesAndResetSelectedRange:selectedTextRange];
                return;
            }
            // Should still log if you are trying to do this weird insert in another location.
//            NSLog(@"Found nil for insert array.");
            return;
        }
    }
    else
    {
//        NSLog(@"No code to append stem of this type.");
    }
    return;
}

// Returns the last character in the selected string.
- (NSString *)getTrailingStringForTextRange: (EQTextRange *)selectedTextRange withData: (EQRenderData *)selectedData
{
    if (nil == selectedTextRange || selectedTextRange.range.location == NSNotFound || nil == selectedData)
        return nil;

    NSRange testRange = selectedTextRange.range;

    // Need to check the tail end of the selected string, which is more complicated than you'd think.
    NSString *testStr = nil;

    // Need to also make sure it has some length for the test string to work with.
    if (testRange.length == 0 && testRange.location > 0)
    {
        testRange.location --;
        testRange.length = 1;
    }

    // Get the test string, if you can.
    if (testRange.length > 0 && testRange.location <= selectedData.renderString.length &&
        (testRange.location + testRange.length) <= selectedData.renderString.length)
    {
        testStr = [selectedData.renderString.string substringWithRange:testRange];
        testStr = [testStr substringFromIndex:(testStr.length - 1)];
        return testStr;
    }

    return nil;
}

// Returns YES if selectedTextRange has a trailing space.
- (BOOL)checkForTrailingString: (NSString *)suffixStr inTextRange: (EQTextRange *)selectedTextRange withData: (EQRenderData *)selectedData
{
    // Sanity checks.
    if (nil == suffixStr || nil == selectedTextRange || selectedTextRange.range.location == NSNotFound || nil == selectedData)
        return NO;

    NSString *testStr = [self getTrailingStringForTextRange:selectedTextRange withData:selectedData];

    // return YES if it has a trailing space.
    if (nil != testStr && [testStr isEqualToString:suffixStr])
    {
        return YES;
    }

    return NO;
}

// Test to see if the previous is sub/sup stem that can be turned into a subsup stem.
- (BOOL)shouldConvertToSubSup: (EQRenderData *)selectedData
            withInputStemType: (EQRenderStemType)stemType
                withTextRange: (EQTextRange *)selectedTextRange
{
    if (nil == selectedData || nil == selectedData.renderString)
        return NO;

    // Decide what the stem type you're checking for should be.
    EQRenderStemType testType = stemTypeUnassigned;
    if (stemType == stemTypeSub)
        testType = stemTypeSup;
    else if (stemType == stemTypeSup)
        testType = stemTypeSub;
    else if (stemType == stemTypeOver)
        testType = stemTypeUnder;
    else if (stemType == stemTypeUnder)
        testType = stemTypeOver;

    // If you haven't found a match, then return NO.
    if (testType == stemTypeUnassigned)
        return NO;

    // Test to see if you are adding to an empty or whitespace string.
    if (selectedData.renderString.length == 0 || [selectedData.renderString.string isEqualToString:@" "] ||
        (selectedTextRange.range.location + selectedTextRange.range.length) == 0)
    {
        // Test to see if there is a previous stem.
        if (nil != selectedData.parentStem && nil != [selectedData.parentStem getPreviousSiblingForChild:selectedData])
        {
            id previousObj = [selectedData.parentStem getPreviousSiblingForChild:selectedData];
            if ([previousObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderStem *previousStem = (EQRenderStem *)previousObj;
                if (previousStem.stemType == testType)
                {
                    return YES;
                }
            }
        }
    }
    return NO;
}


// Convert the previous stem to a subsup stem.
// Should always check shouldConvert first to make sure this is okay.
- (void)convertPreviousStemToSubSupWithData: (EQRenderData *)selectedData
                                      range: (EQTextRange *)selectedTextRange
                              andRenderData: (NSMutableArray *)renderData
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    if (nil == selectedTextRange || nil == renderData || renderData.count == 0)
        return;

    if (nil == selectedData || nil == selectedData.parentStem || nil == [selectedData.parentStem getPreviousSiblingForChild:selectedData])
        return;

    id previousObj = [selectedData.parentStem getPreviousSiblingForChild:selectedData];
    if ([previousObj isKindOfClass:[EQRenderStem class]])
    {
        EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];

        // Convert previous stem to subsup.
        // subsup means sub in location 1, sup in location 2.
        EQRenderStem *previousStem = (EQRenderStem *)previousObj;
        EQRenderStemType previousStemType = previousStem.stemType;
        EQRenderStemType useType = stemTypeSubSup;
        if (previousStemType == stemTypeSub)
        {
            [previousStem appendChild:newData];
        }
        else if (previousStemType == stemTypeSup)
        {
            [previousStem insertChild:newData atLoc:1];
        }
        else if (previousStemType == stemTypeUnder)
        {
            useType = stemTypeUnderOver;
            [previousStem appendChild:newData];
        }
        else if (previousStemType == stemTypeOver)
        {
            useType = stemTypeUnderOver;
            [previousStem insertChild:newData atLoc:1];
        }
        else return;

        previousStem.stemType = useType;
        [renderData addObject:newData];
        selectedTextRange.dataLoc = [renderData indexOfObject:newData];
        selectedTextRange.range = NSMakeRange(0, 0);
        [self sendUpdatesAndResetSelectedRange:selectedTextRange];
    }
}

// Handles converting the parent to an under over. Mostly used when dealing with inserts at the start of an equation line.
- (BOOL)shouldConvertParentToUnderOverWithData: (EQRenderData *)selectedData
                                         range: (EQTextRange *)selectedTextRange
{
    if (nil == selectedData || nil == selectedData.renderString || nil == selectedData.parentStem)
        return NO;

    EQRenderStem *parentStem = selectedData.parentStem;
    if (parentStem.stemType != stemTypeUnder && parentStem.stemType != stemTypeOver)
        return NO;

    return [self shouldUseUnderOverInput:selectedData inRange:selectedTextRange];

    return NO;
}

- (void)convertParentToUnderOverWithData: (EQRenderData *)selectedData
                                   range: (EQTextRange *)selectedTextRange
                           andRenderData: (NSMutableArray *)renderData
{
    NSAssert(nil != self.typesetterDelegate, @"Uninitialized Delegate.");

    if (nil == selectedTextRange || nil == renderData || renderData.count == 0)
        return;

    if (nil == selectedData || nil == selectedData.parentStem)
        return;

    EQRenderStem *parentStem = selectedData.parentStem;
    if (parentStem.stemType != stemTypeUnder && parentStem.stemType != stemTypeOver)
        return;

    EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
    if (parentStem.stemType == stemTypeUnder)
    {
        [parentStem appendChild:newData];
    }
    else
    {
        [parentStem insertChild:newData atLoc:0];
    }
    parentStem.stemType = stemTypeUnderOver;
    [renderData addObject:newData];
    selectedTextRange.dataLoc = [renderData indexOfObject:newData];
    selectedTextRange.range = NSMakeRange(0, 0);
    [self sendUpdatesAndResetSelectedRange:selectedTextRange];
}


- (BOOL)shouldUseUnderOverInput: (EQRenderData *)selectedData
                    inRange: (EQTextRange *)selectedTextRange
{
    if (nil == selectedData || nil == selectedData.renderString || nil == selectedTextRange)
        return NO;

    NSAttributedString *renderStr = selectedData.renderString;
    if (renderStr.length == 0 || [renderStr.string isEqualToString:@" "])
    {
        return NO;
    }
    NSRange useRange = selectedTextRange.range;
    if (useRange.location > 0)
    {
        useRange.location -= 1;
    }
    if (useRange.length == 0)
    {
        useRange.length = 1;
    }

    if ((useRange.location + useRange.length) > renderStr.length)
    {
        return NO;
    }

    // Get a substring containing the last character.
    // Test that to see if it is a sum op character or not.
    NSAttributedString *testStr = [renderStr attributedSubstringFromRange:useRange];
    NSDictionary *testAttributes = [testStr attributesAtIndex:0 effectiveRange:NULL];

    NSNumber *sumOpCheck = [testAttributes objectForKey:kSUM_OP_CHARACTER];

    if (sumOpCheck != nil && [sumOpCheck boolValue] == YES)
    {
        return YES;
    }

    // Currently only do this check for sum op characters.
    // Could later expand to include checks against under/over stem type
    // as well as using _ _ or ^ ^ to indicate normal under/over stem types.
    return NO;
}

- (BOOL)shouldNavigateToPrevParentWithInputType: (EQInputStemType)inputType andData: (EQRenderData *)selectedData
                                        inRange: (EQTextRange *)selectedTextRange
{
    if (nil == selectedData || nil == selectedData.parentStem || inputType == stemTypeUnassigned)
        return NO;

    if (selectedTextRange.range.location > 0 && ![selectedData.renderString.string isEqualToString:@" "])
    {
        return NO;
    }

    id prevObj = [selectedData.parentStem getPreviousSiblingForChild:selectedData];
    if (nil == prevObj || ![prevObj isKindOfClass:[EQRenderStem class]])
    {
        return NO;
    }
    EQRenderStemType prevType = [(EQRenderStem *)prevObj stemType];

    if (inputType == inputTypeSup || inputType == inputTypeOver)
    {
        if (prevType == stemTypeFraction || prevType == stemTypeSup || prevType == stemTypeSubSup
            || prevType == stemTypeOver || prevType == stemTypeUnderOver)
        {
            return YES;
        }
    }
    else if (inputType == inputTypeSub || inputType == inputTypeUnder)
    {
        if (prevType == stemTypeFraction || prevType == stemTypeSub || prevType == stemTypeSubSup
            || prevType == stemTypeUnder || prevType == stemTypeUnderOver)
        {
            return YES;
        }
    }
    return NO;
}

- (void)navigateToPreviousStemWithInputType: (EQInputStemType)inputType
                                    andData: (EQRenderData *)selectedData
                                    inRange: (EQTextRange *)selectedTextRange
                              andRenderData: (NSMutableArray *)renderData
{
    if (nil == selectedTextRange || nil == renderData || renderData.count == 0)
        return;

    if (nil == selectedData || nil == selectedData.parentStem)
        return;

    EQRenderStem *parentStem = selectedData.parentStem;
    id prevObj = [parentStem getPreviousSiblingForChild:selectedData];
    if (nil == prevObj || ![prevObj isKindOfClass:[EQRenderStem class]])
    {
        return;
    }

    EQRenderStem *prevStem = (EQRenderStem *)prevObj;
    EQRenderData *navData = nil;

    // Handle stems with only one possible child first.
    if (prevStem.stemType == stemTypeSup || prevStem.stemType == stemTypeSub
        || prevStem.stemType == stemTypeUnder || prevStem.stemType == stemTypeOver)
    {
        id lastChild = [prevStem getLastDescendent];
        if ([lastChild isKindOfClass:[EQRenderData class]])
        {
            navData = (EQRenderData *)lastChild;
        }
    }
    else if (prevStem.stemType == stemTypeFraction)
    {
        id testChild = nil;

        if (inputType == inputTypeSup || inputType == inputTypeOver)
        {
            testChild = [prevStem getFirstChild];
        }
        else if (inputType == inputTypeSub || inputType == inputTypeUnder)
        {
            testChild = [prevStem getLastChild];
        }
        navData = [self getNavDataForTestChild:testChild];
    }
    else if (prevStem.stemType == stemTypeUnderOver || prevStem.stemType == stemTypeSubSup)
    {
        id testChild = nil;

        if (inputType == inputTypeSup || inputType == inputTypeOver)
        {
            testChild = [prevStem getLastChild];
        }
        else if (inputType == inputTypeSub || inputType == inputTypeUnder)
        {
            testChild = [prevStem.renderArray objectAtIndex:1];
        }
        navData = [self getNavDataForTestChild:testChild];
    }

    if (nil != navData && [navData isKindOfClass:[EQRenderData class]])
    {
        NSUInteger selectedLoc = [renderData indexOfObject:navData];
        if (selectedLoc != NSNotFound)
        {
            NSRange useRange = NSMakeRange(navData.renderString.length, 0);
            selectedTextRange = [EQTextRange textRangeWithRange:useRange andLocation:selectedLoc andEquationLoc:selectedTextRange.equationLoc];
            [self sendUpdatesAndResetSelectedRange:selectedTextRange];
        }

    }
}

- (id)getNavDataForTestChild: (id)testChild
{
    if (nil != testChild)
    {
        if ([testChild isKindOfClass:[EQRenderData class]])
        {
            return testChild;
        }
        else if ([testChild isKindOfClass:[EQRenderStem class]])
        {
            id testObj = [(EQRenderStem *)testChild getLastDescendent];
            if ([testObj isKindOfClass:[EQRenderData class]])
            {
                return testObj;
            }
        }
    }
    return nil;
}

/*
    Used to parse inputData (as opposed to character data).
    Partial refactor of existing methods that also handle character data.
 */

- (void)parseInputData: (EQInputData *)inputData
              withData: (EQRenderData *)selectedData
               inRange: (EQTextRange *)selectedTextRange
        withMarkedData: (EQRenderData *)markedData
               inRange: (EQTextRange *)markedTextRange
       usingRenderData: (NSMutableArray *)renderData
{


    // Test to see if you are in the root data for a large stem.
    BOOL isIntegralData = NO;
    if (nil != selectedData && nil != selectedData.parentStem && selectedData.parentStem.isLargeOpStemType && [selectedData.parentStem.getFirstChild isEqual:selectedData])
    {
        isIntegralData = YES;
    }

    BOOL isRadicalData = NO;
    // Check to see if it is a radical character.
    if (nil != selectedData && nil != selectedData.parentStem && selectedData.parentStem.hasSupplementaryData
        && [selectedData.parentStem.supplementaryData isEqual:selectedData])
    {
        isRadicalData = YES;
    }

    // Check to see if it is a radical character.
    if (isRadicalData || isIntegralData)
    {
        EQRenderStem *parentOfParent = selectedData.parentStem.parentStem;
        if (selectedTextRange.range.location > 0 || nil == parentOfParent)
        {
            if (isRadicalData)
            {
                // Move it to the correct location for a radical stem.
                EQRenderData *firstDesc = [selectedData.parentStem getFirstDescendent];
                if (nil == firstDesc)
                    return;

                selectedData = firstDesc;
                NSUInteger useLoc = [renderData indexOfObject:firstDesc];
                selectedTextRange.dataLoc = useLoc;
                selectedTextRange.range = NSMakeRange(0, 0);
            }
            else if (isIntegralData)
            {
                if (nil == parentOfParent || !parentOfParent.isRowStemType)
                    return;

                EQRenderStem *selectedParent = selectedData.parentStem;
                id nextSiblingObj = [selectedParent getNextSiblingForChild:selectedParent];
                if (nil == nextSiblingObj || [nextSiblingObj isKindOfClass:[EQRenderStem class]])
                {
                    EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
                    if (nil == nextSiblingObj)
                    {
                        [parentOfParent appendChild:newData];
                    }
                    else if ([nextSiblingObj isKindOfClass:[EQRenderStem class]])
                    {
                        NSUInteger useLoc = [parentOfParent getLocForChild:selectedParent];
                        [parentOfParent insertChild:newData atLoc:useLoc];
                    }

                    [renderData addObject:newData];
                    selectedData = newData;
                    selectedTextRange.range = NSMakeRange(0, 0);
                    selectedTextRange.dataLoc = [renderData indexOfObject:newData];
                }
                else if ([nextSiblingObj isKindOfClass:[EQRenderData class]])
                {
                    selectedData = (EQRenderData *)nextSiblingObj;
                    selectedTextRange.range = NSMakeRange(0, 0);
                    selectedTextRange.dataLoc = [renderData indexOfObject:selectedData];
                }
                else
                {
                    return;
                }
            }
        }
        else
        {
            id prevObj = [parentOfParent getPreviousSiblingForChild:selectedData.parentStem];
            if (nil == prevObj || [prevObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderData *newData = [[EQRenderData alloc] initWithString:@" "];
                NSUInteger useLoc = [parentOfParent getLocForChild:selectedData.parentStem];
                [parentOfParent insertChild:newData atLoc:useLoc];
                [renderData addObject:newData];
                selectedData = newData;

                useLoc = [renderData indexOfObject:selectedData];
                selectedTextRange.range = NSMakeRange(1, 0);
                selectedTextRange.dataLoc = useLoc;
            }
            else if ([prevObj isKindOfClass:[EQRenderData class]])
            {
                EQRenderData *prevData = (EQRenderData *)prevObj;
                selectedData = prevData;
                NSUInteger useLoc = [renderData indexOfObject:selectedData];
                selectedTextRange.dataLoc = useLoc;
                selectedTextRange.range = NSMakeRange(prevData.renderString.length, 0);
            }
            else
            {
                return;
            }
        }
    }

    if (inputData.stemType == inputTypeSup)
    {
        // Test to see if you should convert the previous to a subsup stem.
        if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeSup withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeOver withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldConvertParentToUnderOverWithData:selectedData range:selectedTextRange])
        {
            [self convertParentToUnderOverWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldUseUnderOverInput:selectedData inRange:selectedTextRange])
        {
            [self addStemOfType:stemTypeOver ToData:selectedData withInputData:inputData
                        inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
            return;
        }

        if ([self shouldNavigateToPrevParentWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange])
        {
            [self navigateToPreviousStemWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange andRenderData:renderData];
            return;
        }
        // If you don't need to convert, then add superior to the data.
        [self addStemOfType:stemTypeSup ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
        return;
    }
    else if (inputData.stemType == inputTypeSub)
    {
        // Test to see if you should convert the previous to a subsup stem.
        if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeSub withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeUnder withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldUseUnderOverInput:selectedData inRange:selectedTextRange])
        {
            [self addStemOfType:stemTypeUnder ToData:selectedData withInputData:inputData
                        inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
            return;
        }

        // Test for navigation first.
        if ([self shouldNavigateToPrevParentWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange])
        {
            [self navigateToPreviousStemWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange andRenderData:renderData];
            return;
        }

        // If you don't need to convert, then add inferior to the data.
        [self addStemOfType:stemTypeSub ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
        return;
    }
    else if (inputData.stemType == inputTypeSubSup)
    {
//        NSLog(@"Subsup found.");
        return;
    }
    else if (inputData.stemType == inputTypeUnder)
    {
        // Test to see if you should convert the previous to a subsup stem.
        if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeSub withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeUnder withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldUseUnderOverInput:selectedData inRange:selectedTextRange])
        {
            [self addStemOfType:stemTypeUnder ToData:selectedData withInputData:inputData
                        inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
            return;
        }

        // Test for navigation first.
        if ([self shouldNavigateToPrevParentWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange])
        {
            [self navigateToPreviousStemWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange andRenderData:renderData];
            return;
        }

        // If you don't need to convert, then add under stem to the data.
        [self addStemOfType:stemTypeUnder ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
        return;
    }
    else if (inputData.stemType == inputTypeOver)
    {
        // Test to see if you should convert the previous to a subsup stem.
        if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeSup withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldConvertToSubSup:selectedData withInputStemType:stemTypeOver withTextRange:selectedTextRange])
        {
            [self convertPreviousStemToSubSupWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldConvertParentToUnderOverWithData:selectedData range:selectedTextRange])
        {
            [self convertParentToUnderOverWithData:selectedData range:selectedTextRange andRenderData:renderData];
            return;
        }
        else if ([self shouldUseUnderOverInput:selectedData inRange:selectedTextRange])
        {
            [self addStemOfType:stemTypeOver ToData:selectedData withInputData:inputData
                        inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
            return;
        }

        if ([self shouldNavigateToPrevParentWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange])
        {
            [self navigateToPreviousStemWithInputType:inputData.stemType andData:selectedData inRange:selectedTextRange andRenderData:renderData];
            return;
        }

        // If you don't need to convert, then add over stem to the data.
        [self addStemOfType:stemTypeOver ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
        return;
    }
    else if (inputData.stemType == inputTypeUnderOver)
    {
//        NSLog(@"UnderOver found.");
        return;
    }
    else if (inputData.stemType == inputTypeFraction)
    {
        [self addStemOfType:stemTypeFraction ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:NO];
        return;
    }
    else if (inputData.stemType == inputTypeFractionOver)
    {
        [self addStemOfType:stemTypeFraction ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
        return;
    }
    else if (inputData.stemType == inputTypeBinomial)
    {
        [self addStemOfType:stemTypeBinomial ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:NO];
        return;
    }
    else if (inputData.stemType == inputTypeBinomialOver)
    {
        [self addStemOfType:stemTypeBinomial ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:YES];
        return;
    }
    else if (inputData.stemType == inputTypeReturn && selectedData.renderString.length > 0)
    {
        [self handleReturnCharacterWithData:selectedData inRange:selectedTextRange usingRenderData:renderData];
        return;
    }
    else if (inputData.stemType == inputTypeBigOp || inputData.stemType == inputTypeSumOp)
    {
        // Adds a specific type of character data that is larger and non-italic.
        // Should use a smaller size if it is in a fraction.
        // Likely should not be allowed if it is in a stem,
        // though maybe you needn't enforce that, just don't support drawing properly.
        NSDictionary *characterDictionary = inputData.characterData;
        if (nil == characterDictionary || characterDictionary.count == 0)
            return;

        id characterObj = characterDictionary[kEQInputCharacterKey];
        id characterStyle = characterDictionary[kEQInputStyleKey];
        if (nil == characterObj || nil == characterStyle)
            return;

        if ([characterObj isKindOfClass:[NSString class]] && [characterStyle isKindOfClass:[NSDictionary class]])
        {
            [self addText:(NSString *)characterObj withFontDictionary:(NSDictionary *)characterStyle withAttributedText: nil
                 withData:selectedData inRange:selectedTextRange withMarkedData:markedData
                  inRange:markedTextRange usingRenderData:renderData];
        }
        return;
    }
    else if (inputData.stemType == inputTypeSqRootOp)
    {
        [self addStemOfType:stemTypeSqRoot ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:NO];
        return;
    }
    else if (inputData.stemType == inputTypeNRootOp)
    {
        [self addStemOfType:stemTypeNRoot ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:NO];
        return;
    }
    else if (inputData.stemType == inputTypeMatrixOp)
    {
        [self addStemOfType:stemTypeMatrix ToData:selectedData withInputData:inputData
                    inRange:selectedTextRange usingRenderData:renderData shouldAddData:NO];
        return;
    }
    else if (inputData.stemType == inputTypeText)
    {
        NSDictionary *plainTextDict = [EQRenderFontDictionary plainTextFontDictWithName:kDEFAULT_FONT size:kDEFAULT_FONT_SIZE kernValue:0.0];
        if (nil != self.typesetterDelegate)
        {
            NSDictionary *activeStyle = [self.typesetterDelegate storedStyle];
            if (nil != activeStyle)
            {
                plainTextDict = [self applyStyle:activeStyle toAttributes:plainTextDict plainText:YES];
            }
        }
        [self addText:inputData.storedCharacterData withFontDictionary:plainTextDict withAttributedText:nil
             withData:selectedData inRange:selectedTextRange withMarkedData:markedData inRange:markedTextRange usingRenderData:renderData];
        return;
    }
    else if (inputData.stemType == inputTypeSpace)
    {
        BOOL trailingSpace = [self checkForTrailingString:@" " inTextRange:selectedTextRange withData:selectedData];
        if (!trailingSpace)
        {
            [self addData:@" "];
        }
    }
}


- (BOOL)stringHasBinomialOperator: (NSString *)testString
{
    if (nil == testString || testString.length == 0)
        return FALSE;

    NSRange testRange = [testString rangeOfCharacterFromSet:self->binomialCharacterSet];
    if (testRange.location != NSNotFound)
    {
        return TRUE;
    }

    return FALSE;
}

/*
    Internal methods used to build the dictionaries to parse some of the strings.
    This could be used in an initialize method, but for now, we're going ahead and
    putting it in the class init method instead.
*/

// Only used to parse characters that need converted from qwerty keyboard values.
+ (NSDictionary *)getBinomialOperators
{
    NSDictionary *returnDict = @{
                                  @"-" : @" − ",
                                  @"*" : @" ⋅ ",
                                  @"/" : @"∕",
                                  @"∕" : @"∕",
                                  @"|" : @" ∣ ",
                                };
    return returnDict;
}

+ (NSDictionary *)getUnaryOperators
{
    NSDictionary *returnDict = @{
                                 @"+" : @"+",
                                 @"-" : @"−",
                                 @"−" : @"−", // in case the hyphen was already turned to minus sign.
                                };
    return returnDict;
}

+ (NSSet *)getLeftBracketCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:
                        @"(",
                        @"[",
                        @"⌈",
                        @"⌊",
                        @"{",
                        @"⟨", //left angle bracers
                        @"⟪", //double left angle bracers
                        nil];
    return returnSet;
}

+ (NSSet *)getRightBracketCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:
                        @")",
                        @"]",
                        @"⌉",
                        @"⌋",
                        @"}",
                        @"⟩", //angle bracers
                        @"⟫", //right angle bracers
                        nil];
    return returnSet;
}

+ (NSSet *)getDescenderCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:@"f", @"g", @"j", @"p", @"q", @"y", nil];
    return returnSet;
}

// Used to indicate characters that extend too far left when italic.
// May also need to check if it *is* italic later.
+ (NSSet *)getTrailingCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects: @"f", @"j", @"y", nil];
    return returnSet;
}

+ (NSSet *)getItalicAdjustCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects: @"C", @"E", @"F", @"G", @"I", @"J", @"M", @"S", @"T", @"U", @"V", @"W", @"Y", nil];
    return returnSet;
}

+ (NSSet *)getLeftTrailingCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects: @"a", @"b", @"d", @"f", @"g", @"i", @"j", @"p", @"r", @"x", @"y", nil];
    return returnSet;
}

// For string searching, you may need a character set instead of just a set of individual characters.
+ (NSCharacterSet *)getDescenderCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"fgjpqy"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getCapAndNumberCharacterSet
{
    NSMutableCharacterSet *capAndNumCharacterSet = [[NSMutableCharacterSet alloc] init];
    [capAndNumCharacterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [capAndNumCharacterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    return [capAndNumCharacterSet copy];
}

// For stretchy bracers, it will have separate character sets in case you want to identify bracers that are left/right but not stretchy.
// The left/right is used to handle kerning, so you should likely add the stretchy characters to the set of left/right brachers.

+ (NSSet *)getStretchyBracerCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:
                        @"(",
                        @")",
                        @"[",
                        @"]",
                        @"⌈",
                        @"⌉",
                        @"⌊",
                        @"⌋",
                        @"{",
                        @"}",
                        @"⟨", //left and right angle bracers
                        @"⟩",
                        @"⟪", //double left and right angle bracers
                        @"⟫",
                        @"|", // ascii vertical bar
                        @"‖", // double vertical bar
                        nil];
    return returnSet;
}

+ (NSSet *)getLeftStretchyBracerCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:
                        @"(",
                        @"[",
                        @"⌈",
                        @"⌊",
                        @"{",
                        @"⟨", //left angle bracers
                        @"⟪", //double left angle bracers
                        nil];
    return returnSet;
}

+ (NSSet *)getRightStretchyBracerCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:
                        @")",
                        @"]",
                        @"⌉",
                        @"⌋",
                        @"}",
                        @"⟩", //angle bracers
                        @"⟫", //right angle bracers
                        nil];
    return returnSet;
}

+ (NSSet *)getVerticalStretchyBracerCharacters
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:
                        @"|", // ascii vertical bar
                        @"‖", // double vertical bar
                        nil];
    return returnSet;
}

+ (NSSet *)getFunctionNames
{
    NSSet *returnSet = [[NSSet alloc] initWithObjects:
                        @"sin", @"cos", @"tan",
                        @"sec", @"csc", @"cot",
                        @"arcsin", @"arccos", @"arctan",
                        @"arcsec", @"arccsc", @"arccot",
                        @"sinh", @"cosh", @"tanh",
                        @"sech", @"csch", @"coth",
                        @"arcsinh", @"arccosh", @"arctanh",
                        @"arcsech", @"arccsch", @"arccoth",
                        @"ln", @"lg", @"lb", @"log",
                        @"ker", @"lim", @"dim", @"det",
                        nil];
    return returnSet;
}

+ (NSCharacterSet *)getOperatorCharacterSet
{
    NSMutableCharacterSet *returnCharacterSet = [[NSMutableCharacterSet alloc] init];
    NSCharacterSet *standardOps = [NSCharacterSet characterSetWithCharactersInString:@"+−−⋅⋅∕∕=><∣"];
    [returnCharacterSet formUnionWithCharacterSet:standardOps];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getLargeOpCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getBracerCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getMiscOperatorCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getEqualityCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getUncommonOperatorCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getSetTheoryCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getArrowCharacters]];

    return returnCharacterSet.copy;
}

+ (NSCharacterSet *)getLargeOpCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"∫∬∭⨌∮∯∰∱⨑∲∳∑∏∐⅀⨊⨒⨓⨔⨕⨍⨎⨏⨐⨖⨗⨋⨘⨙⨚⨛⨜⨉⋀⨇⋁⨈⋂⋃⨀⨁⨂⨃⨄⨅⨆"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getSumOpCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"∑∏∐⅀⨊⨉⋀⨇⋁⨈⋂⋃⨀⨁⨂⨃⨄⨅⨆"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getBinomialOperatorSet
{
    NSMutableCharacterSet *returnCharacterSet = [[NSMutableCharacterSet alloc] init];

    // Add existing sets that are all infix operators.
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getEqualityCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getUncommonOperatorCharacterSet]];
    [returnCharacterSet formUnionWithCharacterSet:[EQRenderTypesetter getArrowCharacters]];

    // Set theory infix set.
    NSCharacterSet *addSet = [NSCharacterSet characterSetWithCharactersInString:@"∁∧∨⊻⊼∩∪∖∴∵∝∎∶∷∈∉∋∌⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋≺≻⊀⊁≼≽≾≿⋞⋟⋠⋡⋨⋩⊏⊐⊑⊒⋢⋣⋤⋥⋐⋑⋒⋓⋔⋎⋏⊓⊔"];
    [returnCharacterSet formUnionWithCharacterSet:addSet];

    // Misc operator infix set.
    addSet = [NSCharacterSet characterSetWithCharactersInString:@"+-−⋅×/∕÷±∓∆⋄∙∘∗∣∖∤∶∷⦂∝∹∺⨥∔⨢∸∻∼∽∾∿≀⨤⨦≂≁⨧⧺⧻⋇⋈⋉⋊⋋⋌"];
    [returnCharacterSet formUnionWithCharacterSet:addSet];

    // Geometry operator infix set.
    addSet = [NSCharacterSet characterSetWithCharactersInString:@"∟⦦∣∤∥∦⊿⦢⦣⦧⦡⦛⦠⊾⦜⦝⊥⊢⊣⊤"];
    [returnCharacterSet formUnionWithCharacterSet:addSet];

    return returnCharacterSet.copy;
}

+ (NSCharacterSet *)getNumberCharacterSet
{
    NSMutableCharacterSet *returnCharacterSet = [[NSMutableCharacterSet alloc] init];
    [returnCharacterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    [returnCharacterSet addCharactersInString:@".,%"];
    return returnCharacterSet.copy;
}

+ (NSCharacterSet *)getStretchyBracerSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"()[]⌈⌉⌊⌋{}⟨⟩⟪⟫|‖"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getBracerCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"(){}[]⌈⌉⌊⌋⟨⟩⟪⟫⧼⧽⦉⦊⦑⦒⦗⦘⟬⟭⟮⟯⟦⟧⦃⦄⦋⦌⦍⦎⦏⦐⦅⦆⦇⦈|‖"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getGreekCapCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩϚϴ"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getGreekLowerCaseCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"αβγδεζηθικλμνξοπρστυϕχψωφϑϵ"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getGreekCharacterSet
{
    NSMutableCharacterSet *returnSet = [[NSMutableCharacterSet alloc] init];
    [returnSet formUnionWithCharacterSet:[EQRenderTypesetter getGreekCapCharacterSet]];
    [returnSet formUnionWithCharacterSet:[EQRenderTypesetter getGreekLowerCaseCharacterSet]];
    return returnSet.copy;
}

+ (NSCharacterSet *)getMiscIdentifierCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"∞Ɛℇℎℏ℘ℵℶℷℸ"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getMiscNumericCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"Ω℧µ°%‰‱"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getMiscOperatorCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+−⋅×∕÷±∓⟌∂∆∇⋄∙∘∗∣∖∤…∶∷∝∹∺⨥∔⨢∸∻∼∽∾∿≀⨤⨦≂≁⨧⧺⧻⋇⋈⋉⋊⋋⋌ƒ′″‴⁗!‼–—"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getEqualityCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"=≠≟<>≤≥≈≉≮≯≰≱≪≫≦≧≨≩≡≢≃≄≅≌≆≇≊≋≲≳≴≵≶≷≸≹≣≬≍≭≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞⋘⋙⋚⋛⋜⋝⋖⋗"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getSetTheoryCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"∀∁∃∄∅∧∨⊻⊼∩∪¬∖∴∵∝∎∶∷∈∉∋∌⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋≺≻⊀⊁≼≽≾≿⋞⋟⋠⋡⋨⋩⊏⊐⊑⊒⋢⋣⋤⋥⋐⋑⋒⋓⋔⋎⋏⊓⊔"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getUncommonOperatorCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"⊦⊧⊨⊩⊪⊫⊬⊭⊮⊯⊰⊱⊲⊳⊴⊵⋪⋫⋬⋭⊶⊷⊸⋮⋯⋰⋱⋲⋳⋵⋶⋸⋹⋺⋻⋽⋿⊕⊗⊖⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getGeometryCharacterSet
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"∟∠⦟⦦∣∤∥∦⌓⊿⏥○⦢⦣⦧⦡⦛∡∢⦠⊾⦜⦝⊥⊢⊣⊤"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getArrowCharacters
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"←→⇐⇒↔⇔⇄⇆↤↦⤆⤇↩↪↜↝⇜⇝⬳⟿↭↑↓⇑⇓↕⇕↖↗↘↙↼↽⇀⇁⇋⇌↿↾⇃⇂—"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getScriptCharacters
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"𝒜ℬ𝒞𝒟ℰℱ𝒢ℋℐ𝒥𝒦ℒℳ𝒩𝒪𝒫𝒬ℛ𝒮𝒯𝒰𝒱𝒲𝒳𝒴𝒵𝒶𝒷𝒸𝒹ℯ𝒻ℊ𝒽𝒾𝒿𝓀𝓁𝓂𝓃ℴ𝓅𝓆𝓇𝓈𝓉𝓊𝓋𝓌𝓍𝓎𝓏"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getFrakturCharacters
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"𝔄𝔅ℭ𝔇𝔈𝔉𝔊ℌℑ𝔍𝔎𝔏𝔐𝔑𝔒𝔓𝔔ℜ𝔖𝔗𝔘𝔙𝔚𝔛𝔜ℨ𝔞𝔟𝔠𝔡𝔢𝔣𝔤𝔥𝔦𝔧𝔨𝔩𝔪𝔫𝔬𝔭𝔮𝔯𝔰𝔱𝔲𝔳𝔴𝔵𝔶𝔷"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getBlackboardCharacters
{
    NSCharacterSet *returnCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"𝔸𝔹ℂ𝔻𝔼𝔽𝔾ℍ𝕀𝕁𝕂𝕃𝕄ℕ𝕆ℙℚℝ𝕊𝕋𝕌𝕍𝕎𝕏𝕐ℤℼℽℾℿ𝕒𝕓𝕔𝕕𝕖𝕗𝕘𝕙𝕚𝕛𝕜𝕝𝕞𝕟𝕠𝕡𝕢𝕣𝕤𝕥𝕦𝕧𝕨𝕩𝕪𝕫𝟘𝟙𝟚𝟛𝟜𝟝𝟞𝟟𝟠𝟡⦂⦃⦄⦅⦆"];
    return returnCharacterSet;
}

+ (NSCharacterSet *)getAccentOpCharacters
{
    NSMutableString *overBracerStr = [[NSMutableString alloc] init];
    [overBracerStr appendString:[NSString stringWithFormat:@"%C",0x23DE]]; //top curly bracer
    [overBracerStr appendString:[NSString stringWithFormat:@"%C",0x23DF]]; //bottom curly bracer
    [overBracerStr appendString:[NSString stringWithFormat:@"%C",0x23DC]]; //top paren
    [overBracerStr appendString:[NSString stringWithFormat:@"%C",0x23DD]]; //bottom paren
    [overBracerStr appendString:[NSString stringWithFormat:@"%C",0x23B4]]; //top square bracer
    [overBracerStr appendString:[NSString stringWithFormat:@"%C",0x23B5]]; //bottom square bracer
    [overBracerStr appendString:@"–"]; // en dash, used for short overline
    [overBracerStr appendString:@"—"]; // em dash, used for long overline

    NSCharacterSet *overBracers = [NSCharacterSet characterSetWithCharactersInString:overBracerStr];

    NSMutableCharacterSet *returnCharacterSet = [[NSMutableCharacterSet alloc] init];
    [returnCharacterSet formUnionWithCharacterSet:overBracers];
    [returnCharacterSet formUnionWithCharacterSet:[self getArrowCharacters]];

    return returnCharacterSet.copy;
}

/*
    Internal methods used to broadcast when the typesetter is telling the delegate to change the marked, selected, or text values.
    No point in testing them as you don't care what happens most of the time.
*/

- (void)sendWillUpdateMarked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRENDER_TYPESETTER_WILL_CHANGE_MARKED_NOTIFICATION object:nil];
}

- (void)sendDidUpdateMarked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRENDER_TYPESETTER_DID_CHANGE_MARKED_NOTIFICATION object:nil];
}

- (void)sendWillUpdateSelected
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRENDER_TYPESETTER_WILL_CHANGE_SELECTED_NOTIFICATION object:nil];
}

- (void)sendDidUpdateSelected
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRENDER_TYPESETTER_DID_CHANGE_SELECTED_NOTIFICATION object:nil];
}

- (void)sendWillUpdateText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRENDER_TYPESETTER_WILL_CHANGE_TEXT_NOTIFICATION object:nil];
}

- (void)sendDidUpdateText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRENDER_TYPESETTER_DID_CHANGE_TEXT_NOTIFICATION object:nil];
}

- (void)sendWillUpdateAll
{
    [self sendWillUpdateMarked];
    [self sendWillUpdateSelected];
    [self sendWillUpdateText];
}

- (void)sendDidUpdateAll
{
    [self sendDidUpdateMarked];
    [self sendDidUpdateSelected];
    [self sendDidUpdateText];
}

- (void)sendUpdatesAndResetSelectedRange: (EQTextRange *)selectedTextRange
{
    [self sendWillUpdateAll];
    [self.typesetterDelegate unmarkText];
    [self.typesetterDelegate sendUpdateSelectedTextRange:selectedTextRange];
    [self.typesetterDelegate sendFinishedUpdating];
    [self sendDidUpdateAll];
}

@end

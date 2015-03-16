//
//  EQRenderStem.m
//  EQ Editor
//
//  Created by Raymond Hodgson on 09/27/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "EQRenderStem.h"
#import "EQRenderData.h"
#import "EQRenderLayout.h"
#import "EQRenderTypesetter.h"
#import "EQRenderFontDictionary.h"
#import "EQRenderBracers.h"
#import "EQRenderFracStem.h"
#import "EQRenderMatrixStem.h"
#import "EQRenderStretchyBracers.h"

@interface EQRenderStem ()
{
    // Internal variables used to record state during layoutChildren method.
    BOOL adjustForTrailingCharacter;
    BOOL baseIsSmaller;
    BOOL baseIsRightBracket;
    CGFloat xCoord;
    CGSize prevSize;
    CGSize prevTypoSize;
    CGSize storedRadicalSize;
}

- (CGFloat)computeWidthAdjustmentFor: (EQRenderData *)drawData
                     withAdjustDelta: (CGFloat)adjustDelta
                    rightBracketTest: (BOOL)baseIsRightBracket;

// Functions to handle layout of various stem types.
- (void)layoutSupStem;
- (void)layoutSubStem;
- (void)layoutSubSupStem;
- (void)layoutRowStem;
- (void)layoutSQRootStem;
- (void)layoutNRootStem;
- (void)layoutUnderStem;
- (void)layoutOverStem;
- (void)layoutUnderOverStem;

// Used internally by updateBounds
- (CGRect)computeReturnRectWithMyOrigin: (CGPoint)myOrigin
                            andBaseRect: (CGRect)returnRect
                              andOrigin: (CGPoint)useOrigin
                              andBounds: (CGRect)useBounds;

// Sub functions used by stem layout functions.
- (CGPoint)layoutAnchorNodeWithOrigin: (CGPoint)drawOrigin;
- (CGPoint)computeNextOriginForStem: (EQRenderStem *)drawStem
                        withPrevObj: (id)prevObj
                            atPoint: (CGPoint)drawOrigin
                        forLocation: (NSUInteger)childCounter;

- (CGPoint)computeNextUpperOriginForStem: (EQRenderStem *)drawStem
                             withPrevObj: (id)prevObj
                                 atPoint: (CGPoint)drawOrigin
                             forLocation: (NSUInteger)childCounter;

- (CGPoint)layoutChildNodeAtLoc: (NSUInteger)childLoc withOrigin: (CGPoint)drawOrigin;
- (CGPoint)layoutUpperChildNodeAtLoc: (NSUInteger)childLoc withOrigin: (CGPoint)drawOrigin;

- (CGPoint)layoutDrawData: (EQRenderData *)drawData
                  atPoint: (CGPoint)drawOrigin
              forLocation: (NSUInteger)childCounter;

- (CGPoint)layoutStemData: (EQRenderStem *)drawStem
                  atPoint: (CGPoint)drawOrigin
             withPrevious: (EQRenderData *)prevData;

- (CGPoint)layoutSubSupStemData: (EQRenderStem *)drawStem
                        atPoint: (CGPoint)drawOrigin
                   withPrevious: (EQRenderData *)prevData
                    forLocation: (NSUInteger)childCounter;

- (CGPoint)layoutUnderOverStemData: (EQRenderStem *)drawStem
                           atPoint: (CGPoint)drawOrigin
                      withPrevious: (EQRenderData *)prevData
                       forLocation: (NSUInteger)childCounter;

- (CGPoint)layoutLargeStemData: (EQRenderStem *)drawStem
                       atPoint: (CGPoint)drawOrigin
                  withStemType: (EQRenderStemType)useType
              withOriginOffset: (CGFloat)originOffset;

- (BOOL)shouldAdjustYCoordInStem: (EQRenderStem *)drawStem
                    withPrevious: (EQRenderData *)prevData;

- (BOOL)hasOnlyChildrenOfType: (EQRenderStemType)stemType;

- (CGFloat)adjustRowLayoutForStem: (EQRenderStem *)drawStem;
- (CGPoint)adjustPointForDescenderInData: (EQRenderData *)drawData atPoint: (CGPoint)adjustPoint;
- (CGPoint)adjustForDescendersInStem: (EQRenderStem *)drawStem atPoint: (CGPoint)drawOrigin;
- (CGFloat)adjustWidthForSuffixStr: (NSString *)suffixStr withGivenWidth: (CGFloat) adjustWidth;
- (CGFloat)adjustWidthForPrefixStr: (NSString *)prefixStr withGivenWidth: (CGFloat) adjustWidth;
- (CGFloat)adjustKerningForSuffixStr: (NSString *)suffixStr withGivenWidth: (CGFloat) adjustWidth;

- (void)centerChildrenHorizontally;
- (CGSize)getStoredRadicalSize;

- (NSArray *)sizedPairsForStretchyCharacters: (NSArray *)stretchyCharacters;
- (void)layoutStretchyBracersWithSizedPairs: (NSArray *)sizedPairs;
- (NSArray *)collectStringAndOriginForCharacterRange: (EQTextRange *)characterRange;
- (void)attachBracerData: (id)bracerData forCharacterRange: (EQTextRange *)characterRange;
- (id)checkStretchyBracerUseAttributed: (BOOL)useAttributed;
- (EQRenderData *)checkStretchyRenderData;

@end

@implementation EQRenderStem

- (id)init
{
    self = [super init];
    if (self)
    {
        self->_renderArray = [[NSMutableArray alloc]init];
        self->_parentStem = nil;
        self->_stemType = stemTypeUnassigned;
        self->_drawOrigin = CGPointZero;
        self->_drawSize = CGSizeZero;
        self->_drawBounds = CGRectZero;
        self->_hasLargeOp = NO;
        self->adjustForTrailingCharacter = NO;
        self->xCoord = 0;
        self->prevSize = CGSizeZero;
        self->prevTypoSize = CGSizeZero;
        self->storedRadicalSize = CGSizeZero;
        self->_hasSupplementaryData = NO;
        self->_supplementaryData = nil;
        self->_hasOverline = NO;
        self->_overlineStartPoint = CGPointZero;
        self->_overlineEndPoint = CGPointZero;
        self->_hasSupplementalLine = NO;
        self->_supplementalLineStartPoint = CGPointZero;
        self->_supplementalLineEndPoint = CGPointZero;
        self->_hasStoredCharacterData = NO;
        self->_storedCharacterData = nil;
        self->_useAlign = viewAlignAuto;
        self->_hasAccentCharacter = NO;
    }
    return self;
}

// Custom init methods.
- (id)initWithObject: (id)object
{
    self = [self init];
    if (self)
    {
        NSAssert(nil != object, @"Can not init with nil object.");
        [self appendChild:object];
    }
    return self;
}

- (id)initWithObject: (id)object andStemType: (EQRenderStemType)stemType
{
    self = [self init];
    if (self)
    {
        NSAssert(nil != object, @"Can not init with nil object.");
        [self appendChild:object];

        self.stemType = stemType;

        if (stemType == stemTypeSqRoot || stemType == stemTypeNRoot)
        {
            self->_hasSupplementaryData = YES;
            if (stemType == stemTypeSqRoot)
            {
                EQRenderData *newSuppleData = [[EQRenderData alloc] initWithString:[NSString stringWithFormat:@"%C",(unichar)0x221A]]; //sqrt
                newSuppleData.parentStem = self;
                self.supplementaryData = newSuppleData;
            }
            else if (stemType == stemTypeNRoot)
            {
                // Will match the correct glyph when updating before render.
                EQRenderData *newSuppleData = [[EQRenderData alloc] initWithString:[NSString stringWithFormat:@"%C",(unichar)0x221A]]; //sqrt
                newSuppleData.parentStem = self;
                self.supplementaryData = newSuppleData;
            }
            self->_hasOverline = YES;
        }
    }
    return self;
}

// Called to allow the object to update itself if needed.
// Mostly needed for n-roots that may have custom supplementary data values.
- (void)updateSupplementaryData
{
    if (self.stemType == stemTypeNRoot && self.hasStoredCharacterData == YES && nil != self.storedCharacterData)
    {
        NSString *testStr = self.storedCharacterData;
        if ([testStr isEqualToString:@"3"])
        {
            NSString *radicalStr = [NSString stringWithFormat:@"%C",(unichar)0x221B]; //3-root
            EQRenderData *newSuppleData = [[EQRenderData alloc] initWithString:radicalStr];
            newSuppleData.parentStem = self;
            self.supplementaryData = newSuppleData;
        }
        else if ([testStr isEqualToString:@"4"])
        {
            NSString *radicalStr = [NSString stringWithFormat:@"%C",(unichar)0x221C]; //4-root
            EQRenderData *newSuppleData = [[EQRenderData alloc] initWithString:radicalStr];
            newSuppleData.parentStem = self;
            self.supplementaryData = newSuppleData;
        }
        else
        {
            NSString *radicalStr = [NSString stringWithFormat:@"%C",(unichar)0x221A]; //sqrt
            EQRenderData *newSuppleData = [[EQRenderData alloc] initWithString:radicalStr];
            newSuppleData.parentStem = self;
            self.supplementaryData = newSuppleData;
        }
    }
}


// Custom add methods.
- (void)appendChild: (id)newChildStem
{
    NSAssert(self != newChildStem, @"Can not insert self as child object.");

    if (nil == newChildStem)
        return;

    if ([newChildStem respondsToSelector:@selector(setParentStem:)])
    {
        [newChildStem setParentStem:self];
    }
    [self.renderArray addObject:newChildStem];
}

- (void)insertChild: (id)newChildStem atLoc: (NSUInteger)loc
{
    NSAssert(self != newChildStem, @"Can not insert self as child object.");

    if (nil == newChildStem)
        return;

    if ([newChildStem respondsToSelector:@selector(setParentStem:)])
    {
        [newChildStem setParentStem:self];
    }

    if (loc < self.renderArray.count)
        [self.renderArray insertObject:newChildStem atIndex:loc];
    else
        [self.renderArray addObject:newChildStem];
}


- (void)setChild: (id)newChildStem atLoc: (NSUInteger)loc
{
    NSAssert(self != newChildStem, @"Can not insert self as child object.");

    if (nil == newChildStem || loc > self.renderArray.count)
        return;

    if ([newChildStem respondsToSelector:@selector(setParentStem:)])
    {
        [newChildStem setParentStem:self];
    }

    [self.renderArray setObject:newChildStem atIndexedSubscript:loc];
}

- (void)removeChild: (id)childToRemove
{
    if (nil == childToRemove)
        return;

    [self.renderArray removeObject:childToRemove];
}

- (NSUInteger)getLocForChild: (id)child
{
    if (nil == child)
        return NSNotFound;

    return [self.renderArray indexOfObject:child];
}

- (NSUInteger)getInitialCursorLoc
{
    if (self.stemType == stemTypeSup || self.stemType == stemTypeSub || self.stemType == stemTypeOver || self.stemType == stemTypeUnder)
    {
        return 1;
    }
    return 0;
}

- (NSUInteger)getLastCursorLoc
{
    return [self getLocForChild:[self getLastChild]];
}


- (id)getFirstChild
{
    if (nil == self.renderArray || self.renderArray.count == 0)
        return nil;

    return [self.renderArray firstObject];
}

- (id)getLastChild
{
    if (nil == self.renderArray || self.renderArray.count == 0)
        return nil;

    return [self.renderArray lastObject];
}

- (id)getPreviousSiblingForChild:(id)child
{
    NSUInteger childLoc = [self getLocForChild:child];
    if (childLoc == NSNotFound || childLoc == 0 || childLoc > self.renderArray.count)
        return nil;

    return [self.renderArray objectAtIndex:(childLoc - 1)];
}

- (id)getNextSiblingForChild: (id)child
{
    NSUInteger childLoc = [self getLocForChild:child];
    if (childLoc == NSNotFound || childLoc >= self.renderArray.count - 1)
        return nil;

    return [self.renderArray objectAtIndex:(childLoc + 1)];
}

// Navigates recursively to find the last renderData that is a descendent of this node.
- (id)getLastDescendent
{
    id lastChild = [self getLastChild];

    if (nil == lastChild)
        return nil;

    if ([lastChild isKindOfClass:[EQRenderData class]])
    {
        return lastChild;
    }
    else if ([lastChild isKindOfClass:[EQRenderStem class]])
    {
        return [(EQRenderStem *)lastChild getLastDescendent];
    }
    return nil;
}

- (id)getFirstDescendent
{
    id firstChild = [self getFirstChild];
    if (nil == firstChild)
        return nil;

    if ([firstChild isKindOfClass:[EQRenderData class]])
    {
        return firstChild;
    }
    else if ([firstChild isKindOfClass:[EQRenderStem class]])
    {
        return [(EQRenderStem *)firstChild getFirstDescendent];
    }

    return nil;
}


- (CGSize)getStoredRadicalSize
{
    if (nil == self.supplementaryData || ![self.supplementaryData isKindOfClass:[EQRenderData class]])
    {
        return CGSizeZero;
    }

    EQRenderData *radicalRenderData = self.supplementaryData;
    if (CGSizeEqualToSize(self->storedRadicalSize, CGSizeZero))
    {
        self->storedRadicalSize = [radicalRenderData imageBounds].size;
    }
    return self->storedRadicalSize;
}


- (void)layoutChildren
{
    if (self.renderArray.count == 0)
    {
        // Should always update bounds after calling this method.
        [self updateBounds];
        return;
    }

    self->xCoord = 0;
    self->prevSize = CGSizeZero;
    self->prevTypoSize = CGSizeZero;
    self->adjustForTrailingCharacter = NO;

    if (self.stemType == stemTypeSup)
    {
        [self layoutSupStem];
    }
    else if (self.stemType == stemTypeSub)
    {
        [self layoutSubStem];
    }
    else if (self.stemType == stemTypeSubSup)
    {
        [self layoutSubSupStem];
    }
    else if (self.isRowStemType)
    {
        [self layoutRowStem];
    }
    else if (self.stemType == stemTypeUnder)
    {
        [self applyAccentCharacter];
        [self layoutUnderStem];
    }
    else if (self.stemType == stemTypeOver)
    {
        [self applyAccentCharacter];
        [self layoutOverStem];
    }
    else if (self.stemType == stemTypeUnderOver)
    {
        [self applyAccentCharacter];
        [self layoutUnderOverStem];
    }
    else if (self.stemType == stemTypeSqRoot)
    {
        [self layoutSQRootStem];
    }
    else if (self.stemType == stemTypeNRoot)
    {
        [self layoutNRootStem];
    }
    else
    {
//        NSLog(@"No matching layout for stem type.");
    }

    // Should always update bounds after calling this method.
    [self updateBounds];
}

- (void)applyAccentCharacter
{
    // Accent characters only apply for under/over types.
    if (self.stemType != stemTypeUnder && self.stemType != stemTypeOver && self.stemType != stemTypeUnderOver)
    {
        return;
    }

    if (self.renderArray.count == 2 || self.renderArray.count == 3)
    {
        NSCharacterSet *accentOpCharacters = [EQRenderTypesetter getAccentOpCharacters];
        for (int i = 1; i < self.renderArray.count; i++)
        {
            id renderObj = self.renderArray[i];
            if ([renderObj isKindOfClass:[EQRenderData class]])
            {
                EQRenderData *renderData = (EQRenderData *)renderObj;
                if (renderData.renderString.length == 1)
                {
                    NSRange testRange = [renderData.renderString.string rangeOfCharacterFromSet:accentOpCharacters];
                    if (testRange.location != NSNotFound)
                    {
                        self.hasAccentCharacter = YES;
                        return;
                    }
                }
            }
        }
    }
}

- (void)layoutSupStem
{
    CGPoint drawOrigin = self.drawOrigin;
    drawOrigin = [self layoutAnchorNodeWithOrigin:drawOrigin];
    if (self.hasLargeOp == YES)
    {
        drawOrigin.x -= 1.0f;
    }
    [self layoutChildNodeAtLoc:1 withOrigin:drawOrigin];
}

- (void)layoutSubStem
{
    CGPoint drawOrigin = self.drawOrigin;
    drawOrigin = [self layoutAnchorNodeWithOrigin:drawOrigin];
    if (self.hasLargeOp == YES)
    {
        drawOrigin.x -= 0.5f;
    }
    [self layoutChildNodeAtLoc:1 withOrigin:drawOrigin];
}

- (void)layoutSubSupStem
{
    CGPoint drawOrigin = self.drawOrigin;
    drawOrigin = [self layoutAnchorNodeWithOrigin:drawOrigin];
    CGPoint anchorOrigin = drawOrigin;
    CGFloat anchorXCoord = xCoord;

    if (self.hasLargeOp == NO)
    {
        drawOrigin.x += 1.0f;
    }
    else
    {
        drawOrigin.x -= 1.5f;
    }
    [self layoutChildNodeAtLoc:1 withOrigin:drawOrigin];

    drawOrigin = anchorOrigin;
    xCoord = anchorXCoord;

    if (self.hasLargeOp == YES)
    {
        drawOrigin.x += 5.0f;
    }
    [self layoutUpperChildNodeAtLoc:2 withOrigin:drawOrigin];
}

- (void)layoutRowStem
{
    int childCounter = 0;
    // For some reason, the spacing is not correct between renderData and renderStem children.
    // May never have been correct, so it's hard to say whether this is a proper fix or a workaround.
    BOOL previousWasData = NO;
    BOOL previousHasTrailingSpace = NO;
    BOOL previousWasLeftBracket = NO;
    BOOL previousWasRightBracket = NO;
    BOOL previousWasFraction = NO;
    BOOL previousWasLeftSquare = NO;
    BOOL previousWasLeftParen = NO;

    CGPoint drawOrigin = self.drawOrigin;
    NSMutableArray *foundStretchyCharacters = [[NSMutableArray alloc] init];
    NSSet *leftBracketSet = [EQRenderTypesetter getLeftStretchyBracerCharacters];
    NSSet *rightBracketSet = [EQRenderTypesetter getRightStretchyBracerCharacters];

    for (id drawObj in self.renderArray)
    {
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *drawData = (EQRenderData *)drawObj;
            BOOL curIsLeftBracket;
            BOOL curIsRightBracket;
            BOOL curIsLeftSquare;
            BOOL curIsLeftParen;

            if (drawData.renderString.string.length > 0)
            {
                NSString *testChar = [drawData.renderString.string substringFromIndex:(drawData.renderString.string.length - 1)];
                curIsLeftBracket = [leftBracketSet containsObject:testChar];
                NSString *testChar2 = [drawData.renderString.string substringToIndex:1];
                curIsRightBracket = [rightBracketSet containsObject:testChar2];
                curIsLeftSquare = [testChar isEqualToString:@"["];
                curIsLeftParen = [testChar isEqualToString:@"("];
            }
            else
            {
                curIsLeftBracket = NO;
                curIsRightBracket = NO;
                curIsLeftSquare = NO;
                curIsLeftParen = NO;
            }

            if (previousWasFraction == YES && !curIsRightBracket)
            {
                drawOrigin.x += 6.0;
            }
            else if (!previousWasData && [drawData.renderString.string hasPrefix:@"."])
            {
                drawOrigin.x += 2.0;
            }

            // Zero out any stored stretchy data here.
            [drawData resetStretchyCharacterData];
            drawOrigin = [self layoutDrawData: drawData atPoint: (CGPoint)drawOrigin forLocation: (NSUInteger)childCounter];
            __block NSMutableArray *rangeArray = [[NSMutableArray alloc] init];
            __block NSSet *stretchyBracers = [EQRenderTypesetter getStretchyBracerCharacters];
            __block int blockCounter = childCounter;

            [drawData.renderString.string enumerateSubstringsInRange:NSMakeRange(0, drawData.renderString.string.length)
                                                             options:NSStringEnumerationByComposedCharacterSequences
                                                          usingBlock:
             ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
             {
                 if ([stretchyBracers containsObject:substring])
                 {
                     // EQTextRange is used internally by EQRenderStem to store similar data,
                     // so we don't care about equation location.
                     EQTextRange *stretchyRange = [EQTextRange textRangeWithRange:substringRange andLocation:blockCounter andEquationLoc:0];
                     [rangeArray addObject:stretchyRange];
                 }
             }];

            if (rangeArray.count > 0)
            {
                [foundStretchyCharacters addObjectsFromArray:rangeArray];
            }

            previousWasData = YES;
            previousHasTrailingSpace = [drawData.renderString.string hasSuffix:@" "];
            previousWasFraction = NO;
            previousWasLeftBracket = curIsLeftBracket;
            previousWasRightBracket = curIsRightBracket;
            previousWasLeftSquare = curIsLeftSquare;
            previousWasLeftParen = curIsLeftParen;
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *drawStem = (EQRenderStem *)drawObj;
            float adjustXCoord = 0.0;

            if (drawStem.stemType == stemTypeFraction && [drawObj isKindOfClass:[EQRenderFracStem class]])
            {
                EQRenderFracStem *fracStem = (EQRenderFracStem *)drawStem;
                BOOL smallerCheck = fracStem.shouldUseSmaller || fracStem.shouldUseSmallest;
                CGSize imageSize = fracStem.computeImageBounds.size;
                CGFloat xOffset = fracStem.drawSize.width - imageSize.width;

                if (fracStem.lineThickness == 0.0 && previousWasLeftBracket && !smallerCheck)
                {
                    // Need to compute a more exact bounds for these as they don't position correctly otherwise.
                    CGSize imageSize = fracStem.computeImageBounds.size;
                    CGFloat xOffset = fracStem.drawSize.width - imageSize.width;
                    adjustXCoord = -1.0 * xOffset + 1.5;
                    if (!previousWasLeftSquare)
                    {
                        adjustXCoord -= 2.0;
                        drawOrigin.x += 1.0;
                    }
                    adjustXCoord = ceil(adjustXCoord);
                    if (fracStem.drawSize.width < 2.0 * kDEFAULT_FONT_SIZE)
                    {
                        if (previousWasLeftSquare)
                        {
                            drawOrigin.x += 5.0;
                            adjustXCoord += 1.0;
                        }
                        else if (previousWasLeftParen)
                        {
                            drawOrigin.x += 3.0;
                            adjustXCoord -= 1.0;
                        }
                    }
                    else
                    {
                        if (xOffset > 12.0)
                        {
                            drawOrigin.x += 4.0;
                            adjustXCoord = -4.0;
                        }
                    }
                }
                else if (fracStem.lineThickness != 0.0 && previousWasLeftBracket && !smallerCheck)
                {
                    if (fracStem.drawSize.width < 2.0 * kDEFAULT_FONT_SIZE)
                    {
                        if (previousWasLeftSquare)
                        {
                            adjustXCoord = 3.0;
                        }
                    }
                    else
                    {
                        if (xOffset > 12.0)
                        {
                            adjustXCoord = 3.0;
                        }
                    }
                }
                else if (previousWasLeftBracket && smallerCheck)
                {
                    // Not sure why there was so much space when there was less than a point difference in the offset.
                    if (xOffset >= 2.0)
                    {
                        drawOrigin.x -= 3.75 * xOffset;
                    }
                    else
                    {
                        drawOrigin.x -= 2.0 * xOffset;
                    }
                }

                // Need to make a size adjustment if you have two fractions stacked together.
                if (previousWasFraction)
                {
                    drawOrigin.x += 8.0;
                }
                else if (previousHasTrailingSpace && (fracStem.shouldUseSmaller || fracStem.shouldUseSmallest))
                {
                    drawOrigin.x -= 2.0;
                }
            }
            // Make other adjustments for special cases if you have a stem.
            else if (previousWasRightBracket && previousHasTrailingSpace)
            {
                drawOrigin.x += 3.0;
            }
            else if (previousWasData)
            {
                drawOrigin.x += [drawStem computeLeftAdjustment];
            }
            // Make an additional adjustment for stems next to fractions.
            else if (previousWasFraction)
            {
                drawOrigin.x += 6.0;
            }

            // Small fractions needs another adjustment.
            if (drawStem.stemType == stemTypeFraction && nil != drawStem.parentStem && [drawStem.parentStem useSmallFontForChild:drawStem])
            {
                drawOrigin.x += 3.0;
            }

            // Test to see if the stem contains a stretchy bracer.
            NSString *testBracerStr = [drawStem nestedStretchyBracerCheck];
            if (testBracerStr != nil)
            {
                [drawStem resetNestedStretchyData];
                NSRange subStringRange = NSMakeRange(0, testBracerStr.length);
                // EQTextRange is used internally by EQRenderStem to store similar data,
                // so we don't care about equation location.
                EQTextRange *stretchyRange = [EQTextRange textRangeWithRange:subStringRange andLocation:childCounter andEquationLoc:0];
                [foundStretchyCharacters addObject:stretchyRange];
            }

            drawStem.drawOrigin = drawOrigin;
            [drawStem layoutChildren];
            xCoord = drawStem.drawSize.width;
            prevSize = drawStem.drawSize;
            xCoord += [self adjustRowLayoutForStem:drawStem];
            xCoord += adjustXCoord;
            previousWasData = NO;
            previousHasTrailingSpace = NO;
            previousWasLeftBracket = NO;
            previousWasRightBracket = NO;
            previousWasFraction = [drawObj isKindOfClass:[EQRenderFracStem class]];
            previousWasLeftSquare = NO;
            previousWasLeftParen = NO;
        }
        drawOrigin.x = ceilf( drawOrigin.x + xCoord );
        childCounter ++;
    }
    if (foundStretchyCharacters.count > 0)
    {
        NSArray *sizedPairs = [self sizedPairsForStretchyCharacters:foundStretchyCharacters];
        if (nil != sizedPairs && sizedPairs.count > 0)
        {
            [self layoutStretchyBracersWithSizedPairs:sizedPairs];
        }
    }
}

- (NSArray *)sizedPairsForStretchyCharacters: (NSArray *)foundStretchyCharacters
{
    NSSet *leftStretchyChars = [EQRenderTypesetter getLeftStretchyBracerCharacters];
    NSSet *rightStretchyChars = [EQRenderTypesetter getRightStretchyBracerCharacters];
    NSSet *verticalStretchyChars = [EQRenderTypesetter getVerticalStretchyBracerCharacters];
    NSMutableArray *leftStretchyStack = [[NSMutableArray alloc] initWithCapacity:foundStretchyCharacters.count];
    NSMutableArray *matchedStretchyArray = [[NSMutableArray alloc] initWithCapacity:self.renderArray.count];
    // Initialize matched array.
    for (int i = 0; i < self.renderArray.count; i++)
    {
        NSMutableArray *matchedPairs = [[NSMutableArray alloc] init];
        [matchedStretchyArray addObject:matchedPairs];
    }

    // Loop through the found stretchy array and match up pairs of locations.
    EQTextRange *currentLeftStretchy = nil;
    EQTextRange *currentVerticalStretchy = nil;
    for (EQTextRange *charRange in foundStretchyCharacters)
    {
        id renderObj = [self.renderArray objectAtIndex:charRange.dataLoc];
        NSString *stretchyChar = nil;
        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderData = (EQRenderData *)renderObj;
            stretchyChar = [renderData.renderString.string substringWithRange:charRange.range];
        }
        else if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            stretchyChar = [(EQRenderStem *)renderObj nestedStretchyBracerCheck];
        }

        // If you found a matching character, add the data you need.
        if (nil != stretchyChar)
        {
            if ([leftStretchyChars containsObject:stretchyChar])
            {
                if (nil == currentLeftStretchy)
                {
                    currentLeftStretchy = charRange;
                }
                else
                {
                    [leftStretchyStack addObject:currentLeftStretchy];
                    currentLeftStretchy = charRange;
                }
            }
            else if ([rightStretchyChars containsObject:stretchyChar])
            {
                if (nil != currentLeftStretchy)
                {
                    NSUInteger storeLoc = currentLeftStretchy.dataLoc;
                    NSArray *matchedPair = @[currentLeftStretchy, charRange];
                    NSMutableArray *matchedPairs = matchedStretchyArray[storeLoc];
                    [matchedPairs addObject:matchedPair];
                    // Pop the stack to get the new last object.
                    if (leftStretchyStack.count > 0)
                    {
                        currentLeftStretchy = [leftStretchyStack lastObject];
                        [leftStretchyStack removeLastObject];
                    }
                    else
                    {
                        //stack is empty, so set to nil.
                        currentLeftStretchy = nil;
                    }
                }
            }
            else if ([verticalStretchyChars containsObject:stretchyChar])
            {
                // These act can act as either a left or right bracer.
                // Should only be paired with other vertical stretchy characters.
                // Shouldn't be nested so it will not need a stack.
                if (nil == currentVerticalStretchy)
                {
                    currentVerticalStretchy = charRange;
                }
                else
                {
                    NSUInteger storeLoc = currentVerticalStretchy.dataLoc;
                    NSArray *matchedPair = @[currentVerticalStretchy, charRange];
                    NSMutableArray *matchedPairs = matchedStretchyArray[storeLoc];
                    [matchedPairs addObject:matchedPair];
                    currentVerticalStretchy = nil;
                }
            }
        }
    }

    NSMutableArray *sizedPairs = [[NSMutableArray alloc] init];
    for (NSMutableArray *matchedPairs in matchedStretchyArray)
    {
        if (matchedPairs.count > 0)
        {
            for (NSArray *matchedPair in matchedPairs)
            {
                // Should always be the case.
                NSAssert(nil != matchedPair, @"Should never be nil in this array.");
                NSAssert(matchedPair.count == 2, @"Should only store pairs in this array.");
                EQTextRange *leftLoc = matchedPair[0];
                EQTextRange *rightLoc = matchedPair[1];

                // Compute the size you should use by searching the data between the two bracers.
                // Ignore pairs that are in the same renderData or immediately next to each other.
                CGFloat useHeight = 0;
                BOOL containsDescenderData = NO;
                CGPoint useDescenderOrigin = CGPointZero;
                int locCounter = 0;

                for (NSUInteger testLoc = leftLoc.dataLoc; testLoc < rightLoc.dataLoc; testLoc ++)
                {
                    id renderObj = [self.renderArray objectAtIndex:testLoc];
                    if ([renderObj isKindOfClass:[EQRenderStem class]])
                    {
                        EQRenderStem *renderStem = (EQRenderStem *)renderObj;
                        CGFloat testHeight = renderStem.drawSize.height;

                        // Need to not add as much height when you have sups that are not nested.
                        BOOL testSupHeight = (renderStem.stemType == stemTypeSup || renderStem.stemType == stemTypeSub || renderStem.stemType == stemTypeSubSup) && [renderStem hasOnlyRenderDataChildren];

                        // Add code to compute the offset for stems with descenders.
                        // This allows you to center the bracer vertically around the stem.
                        BOOL testDescender = [renderStem isStemWithDescender];
                        if (testDescender == YES)
                        {
                            CGPoint testDescenderOrigin = [EQRenderLayout findLowestChildOrigin:renderStem];

                            if (![renderStem isKindOfClass:[EQRenderMatrixStem class]])
                            {
                                CGPoint testOrigin = renderStem.drawOrigin;
                                CGFloat heightAdjust = testDescenderOrigin.y - testOrigin.y;
                                testHeight += heightAdjust * 0.3333;
                                testDescenderOrigin.y -= heightAdjust * 0.3333;
                                if (locCounter == 0 && (renderStem.stemType == stemTypeFraction || renderStem.isBinomialStemType))
                                {
                                    testDescenderOrigin.y += 3.0;
                                    testHeight += 6.0;
                                }
                            }

                            if (containsDescenderData == NO)
                            {
                                containsDescenderData = YES;
                                useDescenderOrigin = testDescenderOrigin;
                            }
                            else
                            {
                                if (useDescenderOrigin.y < testDescenderOrigin.y)
                                {
                                    useDescenderOrigin = testDescenderOrigin;
                                }
                            }
                        }
                        else if (testSupHeight == YES)
                        {
                            EQRenderData *testChildData = renderStem.getFirstChild;
                            useHeight = MAX(useHeight, testChildData.imageBounds.size.height);
                            continue;
                        }
                        useHeight = MAX(useHeight, testHeight);
                    }
                    else if ([renderObj isKindOfClass:[EQRenderData class]])
                    {
                        EQRenderData *renderData = (EQRenderData *)renderObj;

                        // If you are in the first location, you should only check after the bracer.
                        if (testLoc == leftLoc.dataLoc)
                        {
                            NSInteger subStrLoc = leftLoc.range.location + leftLoc.range.length;
                            NSInteger subStrLength = renderData.renderString.length - subStrLoc;
                            if ((subStrLoc + subStrLength) <= renderData.renderString.length && subStrLength > 0)
                            {
                                NSAttributedString *subStr = [renderData.renderString attributedSubstringFromRange:NSMakeRange(subStrLoc, subStrLength)];
                                renderData = [[EQRenderData alloc] initWithAttributedString:subStr];
                            }
                        }
                        useHeight = MAX(useHeight, renderData.imageBounds.size.height);
                    }
                }
                if (useHeight > 0)
                {
                    NSNumber *useHeightNumber = [NSNumber numberWithFloat:useHeight];
                    NSNumber *hasDescenderDataNumber = [NSNumber numberWithBool:containsDescenderData];
                    NSValue *useDescenderPointValue = [NSValue valueWithCGPoint:useDescenderOrigin];
                    NSArray *storedPairData = @[useHeightNumber, hasDescenderDataNumber, useDescenderPointValue];
                    [sizedPairs addObject:@[matchedPair, storedPairData]];
                }
                else
                {
                    // Vertical bracers that are not stretchy need a separate kerning applied to them.
                    // This is the best place as it is the only location where you have matched the left and right bracer locations.
                    id testLeftObj = [self.renderArray objectAtIndex:leftLoc.dataLoc];
                    id testRightObj = [self.renderArray objectAtIndex:rightLoc.dataLoc];
                    if ([testLeftObj isKindOfClass:[EQRenderData class]] && [testRightObj isKindOfClass:[EQRenderData class]])
                    {
                        EQRenderData *leftData = (EQRenderData *)testLeftObj;
                        EQRenderData *rightData = (EQRenderData *)testRightObj;
                        NSString *leftBracerStr = [leftData.renderString.string substringWithRange:leftLoc.range];
                        NSString *rightBracerStr = [rightData.renderString.string substringWithRange:rightLoc.range];
                        if ([verticalStretchyChars containsObject:leftBracerStr])
                        {
                            NSDictionary *currentDict = [leftData.renderString attributesAtIndex:leftLoc.range.location effectiveRange:NULL];
                            NSMutableDictionary *newDict = currentDict.mutableCopy;
                            newDict[NSKernAttributeName] = @4.0;
                            [leftData.renderString setAttributes:newDict.copy range:leftLoc.range];
                        }
                        if ([verticalStretchyChars containsObject:rightBracerStr] && rightLoc.range.location > 0)
                        {
                            NSRange useRange = rightLoc.range;
                            useRange.location -= 1;
                            useRange.length = 1;
                            NSDictionary *currentDict = [rightData.renderString attributesAtIndex:useRange.location effectiveRange:NULL];
                            NSMutableDictionary *newDict = currentDict.mutableCopy;
                            newDict[NSKernAttributeName] = @4.0;
                            [rightData.renderString setAttributes:newDict.copy range:useRange];
                        }
                    }
                }
                locCounter ++;
            }
        }
    }
    return [NSArray arrayWithArray:sizedPairs];
}

- (void)layoutStretchyBracersWithSizedPairs: (NSArray *)sizedPairs
{
    // Loops through the array and calls the functions to let it compute and attach
    // the data to draw the correctly sized bracers.
    // Skips a pair if new sizing data is not needed.
    for (NSArray *matchedPair in sizedPairs)
    {
        NSAssert(nil != matchedPair, @"Should never be nil in this array.");
        NSAssert(matchedPair.count == 2, @"Should only store pairs in this array.");
        NSArray *pairLocs = matchedPair[0];

        NSAssert(nil != pairLocs, @"Should never be nil in this array.");
        NSAssert(pairLocs.count == 2, @"Should only store pairs in this array.");

        NSArray *storedPairData = matchedPair[1];

        NSAssert(nil != storedPairData, @"Should never be nil for the data array.");
        NSAssert(storedPairData.count == 3, @"Should store three values for the pair data.");

        NSNumber *heightNumber = storedPairData[0];
        NSNumber *hasDescenderNumber = storedPairData[1];
        NSValue *useDescenderPointValue = storedPairData[2];

        NSAssert(nil != heightNumber, @"Should never be nil for a height number.");
        NSAssert(nil != hasDescenderNumber, @"Should never be nil for this number.");
        NSAssert(nil != useDescenderPointValue, @"Should never be nil for this point value.");

        EQTextRange *leftCharRange = pairLocs[0];
        EQTextRange *rightCharRange = pairLocs[1];

        NSArray *leftCharArray = [self collectStringAndOriginForCharacterRange:leftCharRange];
        NSArray *rightCharArray = [self collectStringAndOriginForCharacterRange:rightCharRange];

        // If one of them does not need resized, assume the other does not either.
        // Continue to the next pair.
        if (nil == leftCharArray || nil == leftCharArray)
            continue;

        NSAttributedString *leftCharStr = leftCharArray[0];
        NSValue *leftCharStoredOrigin = leftCharArray[1];

        NSAttributedString *rightCharStr = rightCharArray[0];
        NSValue *rightCharStoredOrigin = rightCharArray[1];

        id leftCharData = [EQRenderBracers buildDataForBracerCharacter:leftCharStr withHeight:heightNumber originValue:leftCharStoredOrigin];
        id rightCharData = [EQRenderBracers buildDataForBracerCharacter:rightCharStr withHeight:heightNumber originValue:rightCharStoredOrigin];

        // If one of them does not need resized, assume the other does not either.
        // Continue to the next pair.
        if (nil == leftCharData || nil == rightCharData)
            continue;

        // Need to attach descender data if it exists.
        // Should be done by the bracer class in case we need to make internal adjustments
        // (like using a stem or array for the bracerData).

        if (hasDescenderNumber.boolValue == YES)
        {
            [EQRenderBracers addDescenderDataToBracerData:leftCharData withDescenderPoint:useDescenderPointValue.CGPointValue];
            [EQRenderBracers addDescenderDataToBracerData:rightCharData withDescenderPoint:useDescenderPointValue.CGPointValue];
        }
        [self attachBracerData:leftCharData forCharacterRange:leftCharRange];
        [self attachBracerData:rightCharData forCharacterRange:rightCharRange];

        CGFloat leftTest = [EQRenderBracers computeNewOffsetForBracerData:leftCharData withPreviousOrigin:leftCharStoredOrigin.CGPointValue];
        if (leftTest != 0.0)
        {
            CGFloat useOffset = leftTest;
            id renderObj = self.renderArray[leftCharRange.dataLoc];
            [self shiftChildrenAfter:renderObj horizontally:useOffset];
        }
        CGFloat rightTest = [EQRenderBracers computeKernAdjustmentForBracerData:rightCharData];
        if (rightTest != 0.0)
        {
            CGFloat useOffset = rightTest;
            id renderObj = self.renderArray[rightCharRange.dataLoc];
            if ([rightCharData isKindOfClass:[EQRenderStretchyBracers class]])
            {
                [self shiftChildrenAfter:renderObj horizontally:useOffset inclusive:YES];
            }
            else
            {
                [self shiftChildrenAfter:renderObj horizontally:useOffset];
            }
        }
    }
}


- (NSArray *)collectStringAndOriginForCharacterRange: (EQTextRange *)characterRange
{
    NSAssert(nil != characterRange, @"Nil value received for characterRange");
    NSAssert([characterRange isKindOfClass:[EQTextRange class]], @"Invalid class received for characterRange.");
    NSAssert(characterRange.dataLoc < self.renderArray.count, @"characterRange data location is out of bounds.");

    id renderObj = self.renderArray[characterRange.dataLoc];

    if ([renderObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *renderData = (EQRenderData *)renderObj;
        NSAssert(characterRange.range.location + characterRange.range.length <= renderData.renderString.length, @"characterRange is out of string bounds.");
        NSAttributedString *returnStr = [renderData.renderString attributedSubstringFromRange:characterRange.range];

        NSUInteger useIndex = characterRange.range.location;
        // This value is close to the correct one, but the origin will need to be computed again
        // once the bracers have been sized and placed in the attributedString.
        // This is done automatically by the call to [EQRenderData getStretchyDescenders]
        CGRect prevRect = [renderData cursorRectForStringIndex:useIndex];
        CGPoint originPoint = prevRect.origin;

        originPoint.x += renderData.drawOrigin.x;
        originPoint.y += renderData.drawOrigin.y;
        NSValue *storedOrigin = [NSValue valueWithCGPoint:originPoint];

        return @[returnStr, storedOrigin];
    }
    else if ([renderObj isKindOfClass:[EQRenderStem class]])
    {
        EQRenderStem *renderStem = (EQRenderStem *)renderObj;
        NSAttributedString *returnStr = [renderStem nestedAttributedStretchyBracerCheck];
        if (nil != returnStr)
        {
            EQRenderData *baseData = [renderStem checkStretchyRenderData];
            if (nil != baseData)
            {
                NSUInteger useIndex = characterRange.range.location;

                // This value is close to the correct one, but the origin will need to be computed again
                // once the bracers have been sized and placed in the attributedString.
                // This is done automatically by the call to [EQRenderData getStretchyDescenders]
                CGRect prevRect = [baseData cursorRectForStringIndex:useIndex];
                CGPoint originPoint = prevRect.origin;

                originPoint.x += baseData.drawOrigin.x;
                originPoint.y += baseData.drawOrigin.y;
                NSValue *storedOrigin = [NSValue valueWithCGPoint:originPoint];

                return @[returnStr, storedOrigin];
            }
        }
    }

    return nil;
}

- (void)attachBracerData: (id)bracerData forCharacterRange: (EQTextRange *)characterRange
{
    NSAssert(nil != characterRange, @"Nil value received for characterRange");
    NSAssert([characterRange isKindOfClass:[EQTextRange class]], @"Invalid class received for characterRange.");
    NSAssert(characterRange.dataLoc < self.renderArray.count, @"characterRange data location is out of bounds.");

    id renderObj = self.renderArray[characterRange.dataLoc];
    if ([renderObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *renderData = (EQRenderData *)renderObj;
        NSAssert(characterRange.range.location + characterRange.range.length <= renderData.renderString.length, @"characterRange is out of string bounds.");
        renderData.hasStretchyCharacterData = YES;
        [renderData addStretchyCharacterData:bracerData forTextRange:characterRange];
    }
    else if ([renderObj isKindOfClass:[EQRenderStem class]])
    {
        EQRenderData *baseData = [(EQRenderStem *)renderObj checkStretchyRenderData];
        if (nil != baseData)
        {
            baseData.hasStretchyCharacterData = YES;
            [baseData addStretchyCharacterData:bracerData forTextRange:characterRange];
            [(EQRenderStem *)renderObj adjustLayoutForNestedStretchyDataWithBracerData:bracerData];
        }
    }
}

// Will adjust the position of the sup/sub depending upon the size of the bracer.
- (void)adjustLayoutForNestedStretchyDataWithBracerData: (id)bracerData
{
    CGRect bracerImageBounds;
    if ([bracerData isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *useBracerData = (EQRenderData *)bracerData;
        bracerImageBounds = useBracerData.imageBounds;
    }
    else if ([bracerData isKindOfClass:[EQRenderStretchyBracers class]])
    {
        EQRenderStretchyBracers *stretchyBracerData = (EQRenderStretchyBracers *)bracerData;
        bracerImageBounds = stretchyBracerData.computeBounds;
    }
    else
    {
//        NSLog(@"Unknown bracer data type.");
        return;
    }

    if (self.stemType == stemTypeSup && self.renderArray.count >= 2)
    {
        id supObj = self.renderArray[1];
        [self adjustSupObj:supObj withBracerBounds:bracerImageBounds];

        if ([supObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)supObj layoutChildren];
        }
    }
    else if (self.stemType == stemTypeSub && self.renderArray.count >= 2)
    {
        id subObj = self.renderArray[1];
        [self adjustSubObj:subObj withBracerBounds:bracerImageBounds];

        if ([subObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)subObj layoutChildren];
        }
    }
    else if (self.stemType == stemTypeSubSup && self.renderArray.count >= 3)
    {
        id subObj = self.renderArray[1];
        [self adjustSubObj:subObj withBracerBounds:bracerImageBounds];

        id supObj = self.renderArray[2];
        [self adjustSupObj:supObj withBracerBounds:bracerImageBounds];

        CGPoint subOrigin = [subObj drawOrigin];
        CGPoint supOrigin = [supObj drawOrigin];
        supOrigin.x = subOrigin.x;
        [supObj setDrawOrigin:supOrigin];

        if ([supObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)supObj layoutChildren];
        }

        if ([subObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)subObj layoutChildren];
        }
    }
}

- (CGPoint)computeSupStemAdjustHeightWithBracerHeight: (CGFloat)bracerHeight bracerWidth: (CGFloat)bracerWidth
{
    // Remember the origin is the upper left in this case.
    CGFloat useAscentValue = [EQRenderFontDictionary defaultFontAscentValueWithSize:kDEFAULT_FONT_SIZE];

    CGFloat widthAdjust = 0.0;
    if (bracerWidth > 10.0)
    {
        widthAdjust = 0.5 * bracerWidth;
    }

    CGFloat heightAdjust = 0.0;
    if (bracerHeight < 30.0)
    {
        heightAdjust = - 0.05 * useAscentValue;
    }
    else if (bracerHeight > 60.0)
    {
        heightAdjust = -0.75 * useAscentValue;
        widthAdjust -= 2.0;
    }
    else
    {
        heightAdjust = -0.5 * useAscentValue;
    }

    return CGPointMake(widthAdjust, heightAdjust);
}

- (CGPoint)computeSubStemAdjustHeightWithBracerHeight: (CGFloat)bracerHeight bracerWidth: (CGFloat)bracerWidth
{
    // Remember the origin is the upper left in this case.
    CGFloat useAscentValue = [EQRenderFontDictionary defaultFontAscentValueWithSize:kDEFAULT_FONT_SIZE];

    CGFloat widthAdjust = 0.0;
    if (bracerWidth > 10.0)
    {
        widthAdjust = 0.5 * bracerWidth;
    }

    CGFloat heightAdjust = 0.0;
    if (bracerHeight < 30.0)
    {
        heightAdjust = 0.25 * useAscentValue;
    }
    else if (bracerHeight > 65.0)
    {
        if (bracerHeight > 100.0)
        {
            heightAdjust = 1.0 * useAscentValue;
            widthAdjust += 2.0;
        }
        else
        {
            heightAdjust = 0.75 * useAscentValue;
            widthAdjust += 2.0;
        }
    }
    else
    {
        heightAdjust = 0.5 * useAscentValue;
    }

    return CGPointMake(widthAdjust, heightAdjust);
}

- (void)adjustObj: (id)renderObj withBracerBounds: (CGRect)bracerBounds useSup: (BOOL)useSup
{
    CGFloat bracerHeight = bracerBounds.size.height;
    CGFloat bracerWidth = bracerBounds.size.width;
    CGPoint adjustPoint;

    // Compute the yAdjust value depending upon whether it is a sup or sub.
    if (useSup)
    {
        adjustPoint = [self computeSupStemAdjustHeightWithBracerHeight:bracerHeight bracerWidth:bracerWidth];
    }
    else
    {
        adjustPoint = [self computeSubStemAdjustHeightWithBracerHeight:bracerHeight bracerWidth:bracerWidth];
    }

    CGPoint newOrigin = [renderObj drawOrigin];
    newOrigin.x += adjustPoint.x;
    newOrigin.y += adjustPoint.y;
    [renderObj setDrawOrigin:newOrigin];
}

- (void)adjustSupObj: (id)supObj withBracerBounds: (CGRect)bracerBounds
{
    [self adjustObj:supObj withBracerBounds:bracerBounds useSup:YES];
}

- (void)adjustSubObj: (id)subObj withBracerBounds: (CGRect)bracerBounds
{
    [self adjustObj:subObj withBracerBounds:bracerBounds useSup:NO];
}

- (void)layoutSQRootStem
{
    int childCounter = 0;

    CGPoint drawOrigin = self.drawOrigin;

    // Move startpoint to account for radical.
    // Note: stored radical size is a cached value that is populated on first call to getStoredRadical.
    // Will need to reset that to CGSizeZero if you change the size of the radical so that it knows to repopulate the cache.
    if (nil != self.supplementaryData && [self.supplementaryData isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *radicalRenderData = (EQRenderData *)self.supplementaryData;
        radicalRenderData.drawOrigin = drawOrigin;
        drawOrigin.x += [self getStoredRadicalSize].width + 3.0;
    }

    CGPoint overlineStartPoint = drawOrigin;
    CGFloat maxHeight = 0.0f;

    for (id drawObj in self.renderArray)
    {
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            drawOrigin = [self layoutDrawData: (EQRenderData *)drawObj atPoint: (CGPoint)drawOrigin forLocation: (NSUInteger)childCounter];
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *drawStem = (EQRenderStem *)drawObj;
            drawStem.drawOrigin = drawOrigin;
            [drawStem layoutChildren];
            xCoord = drawStem.drawSize.width;
            prevSize = drawStem.drawSize;
            xCoord += [self adjustRowLayoutForStem:drawStem];
        }
        // Draw size is going to be zero if only dealing with renderData children.
        // This should be okay, though since those should remain under the radical in normal cases.
        // May need to change algorithm if this turns out to not be the case.
        maxHeight = MAX(maxHeight, [drawObj drawSize].height);
        drawOrigin.x = ceilf( drawOrigin.x + xCoord );
        childCounter ++;
    }
    CGPoint overlineEndPoint = drawOrigin;

    // Adjust the horizontal positioning so that the overline overlaps the expression.
    overlineStartPoint.x -= 1.0;
    overlineEndPoint.x += 2.0;
    CGFloat testWidth = ABS(overlineEndPoint.x - overlineStartPoint.y);
    if (testWidth < 8.0)
    {
        CGFloat testDelta = 8.0 - testWidth;
        overlineEndPoint.x += testDelta;
    }

    // Adjust the vertical position to line up with the top of the radical.
    // This will likely need to be altered for more complicated expressions later on.
    CGSize radicalTestSize = [self getStoredRadicalSize];
    CGFloat useHeight = 0.0;

    if ((radicalTestSize.height + 7.0) >= maxHeight)
    {
        useHeight = radicalTestSize.height;
    }
    else
    {
        useHeight = maxHeight;
    }

    CGFloat useAscentValue = [EQRenderFontDictionary defaultFontAscentValueWithSize:kDEFAULT_FONT_SIZE];
    CGFloat deltaY = useHeight - radicalTestSize.height;
    CGFloat xAdjust = 0;
    double useAngle = 70.0 * (M_PI / 180.0); // 60 deg -> radians
    self.hasSupplementalLine = NO;
    CGPoint suppleStart = CGPointZero;
    CGPoint suppleEnd = CGPointZero;

    // Currently just uses the same radical size no matter what.
    // May need to adjust this when/if we use very large expressions under the overline.
    // The glyph you use and the slope of the angle will be different.
    if (deltaY > 0)
    {
        xAdjust = deltaY / tanf(useAngle); // Need to adjust the position of the overline to match the radical slope.
        self.hasSupplementalLine = YES;
        suppleStart = overlineStartPoint;
        suppleStart.y -= radicalTestSize.height - 0.25 * useAscentValue;
        suppleStart.y += 1.0;
        suppleStart.x -= 1.0 / tan(useAngle);
    }

    overlineStartPoint.y -= useHeight - 0.25 * useAscentValue;
    overlineEndPoint.y -= useHeight - 0.25 * useAscentValue;

    if (xAdjust > 0)
    {
        overlineStartPoint.x += xAdjust;
        overlineEndPoint.x += xAdjust;
        CGFloat xShift = xAdjust + 1.25f;
        [self shiftChildrenHorizontally:xShift];
    }

    if (self.hasSupplementalLine == YES)
    {
        suppleEnd = overlineStartPoint;
    }

    self.overlineStartPoint = overlineStartPoint;
    self.overlineEndPoint = overlineEndPoint;

    self.supplementalLineStartPoint = suppleStart;
    self.supplementalLineEndPoint = suppleEnd;
}

- (void)layoutNRootStem
{
    // Currently just call layout square root as we are not implementing custom n-root drawing until later.
    [self layoutSQRootStem];
}

- (void)layoutUnderStem
{
    CGPoint drawOrigin = self.drawOrigin;
    drawOrigin = [self layoutAnchorNodeWithOrigin:drawOrigin];
    [self layoutChildNodeAtLoc:1 withOrigin:drawOrigin];
    [self centerChildrenHorizontally];
    [self adjustLayoutForAccentCharacters];
}

- (void)layoutOverStem
{
    CGPoint drawOrigin = self.drawOrigin;
    drawOrigin = [self layoutAnchorNodeWithOrigin:drawOrigin];
    [self layoutChildNodeAtLoc:1 withOrigin:drawOrigin];
    [self centerChildrenHorizontally];
    [self adjustLayoutForAccentCharacters];
}

- (void)layoutUnderOverStem
{
    CGPoint drawOrigin = self.drawOrigin;
    drawOrigin = [self layoutAnchorNodeWithOrigin:drawOrigin];
    CGPoint anchorOrigin = drawOrigin;
    CGFloat anchorXCoord = xCoord;

    drawOrigin = anchorOrigin;
    xCoord = anchorXCoord;

    [self layoutUpperChildNodeAtLoc:2 withOrigin:drawOrigin];
    [self centerChildrenHorizontally];
    [self adjustLayoutForAccentCharacters];
}

- (void)adjustLayoutForAccentCharacters
{
    if (self.hasAccentCharacter == NO)
        return;

    CGFloat useSize = kDEFAULT_FONT_SIZE;
    if (self.shouldUseSmaller || self.shouldUseSmallest)
    {
        useSize = kDEFAULT_FONT_SIZE_SMALL;
    }

    CGFloat useDescent = [EQRenderFontDictionary defaultFontDescentValueWithSize:useSize];

    BOOL adjustForCaps = [self adjustAccentForCap];
    BOOL adjustForStemCharacters = [self adjustAccentForStemCharacters];
    BOOL adjustForDescenderCharacters = [self adjustAccentForDescenderCharacters];

    // Not sure if this is the optimal way to handle underover, but can work with this for now.
    if (self.stemType == stemTypeOver || self.stemType == stemTypeUnder || self.stemType == stemTypeUnderOver)
    {
        id renderObj = self.renderArray[1];
        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderData = (EQRenderData *)renderObj;
            CGPoint renderOrigin = renderData.drawOrigin;
            if (self.stemType == stemTypeOver)
            {
                CGFloat adjustValue = 0.33333 * useDescent;
                if (adjustForCaps == YES || adjustForStemCharacters == YES)
                {
                    adjustValue = 0.0;
                }

                renderOrigin.y -= adjustValue;
            }
            else
            {
                if (adjustForDescenderCharacters == YES)
                {
                    renderOrigin.y += 0.45 * useDescent;
                }
                else
                {
                    renderOrigin.y += 0.75 * useDescent;
                }
            }
            renderData.drawOrigin = renderOrigin;
        }
    }
}

- (BOOL)adjustAccentForCharacters: (NSCharacterSet *)useCharSet
{
    if (nil == self.renderArray || self.renderArray.count == 0 || nil == useCharSet)
    {
        return NO;
    }

    id baseObj = self.renderArray[0];
    if ([baseObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *baseData = (EQRenderData *)baseObj;
        if (nil == baseData.renderString || baseData.renderString.length == 0)
        {
            return NO;
        }

        NSRange capRange = [baseData.renderString.string rangeOfCharacterFromSet:useCharSet];
        if (capRange.location != NSNotFound)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)adjustAccentForCap
{
    return [self adjustAccentForCharacters:[NSCharacterSet uppercaseLetterCharacterSet]];
}

- (BOOL)adjustAccentForStemCharacters
{
    return [self adjustAccentForCharacters:[NSCharacterSet characterSetWithCharactersInString:@"bdfhijkl"]];
}

- (BOOL)adjustAccentForDescenderCharacters
{
    return [self adjustAccentForCharacters:[NSCharacterSet characterSetWithCharactersInString:@"fgjpqy"]];
}

- (CGFloat) adjustRowLayoutForStem: (EQRenderStem *)drawStem
{
    CGFloat xAdjust = 0.0f;

    if (drawStem.hasLargeOp == YES && xCoord > 35.0f)
    {
        NSUInteger maxLoc = [drawStem getLocOfMaxWidth];
        if (maxLoc == 1)
        {
            xAdjust = 5.0f;
        }
        else if (maxLoc > 1)
        {
            xAdjust = 1.0f;
        }
    }
    else if (drawStem.stemType == stemTypeFraction && drawStem.shouldUseSmaller == NO)
    {
        if (xCoord < 35.0f)
        {
            xAdjust = 3.0f;
        }
        else
        {
            xAdjust = 6.0f;
        }
    }
    else if (drawStem.stemType == stemTypeSqRoot || drawStem.stemType == stemTypeNRoot)
    {
        xAdjust = 4.0f;
    }
    else if (drawStem.stemType == stemTypeSubSup)
    {
        xAdjust = 1.5;
    }

    return xAdjust;
}

- (NSUInteger) getLocOfMaxWidth
{
    NSUInteger maxLoc = 0;

    for (NSUInteger i = 1; i < self.renderArray.count; i++)
    {
        id curMaxObj = [self.renderArray objectAtIndex:maxLoc];
        id testObj = [self.renderArray objectAtIndex:i];
        CGSize curMaxSize = CGSizeZero;
        if ([curMaxObj respondsToSelector:@selector(boundingRectTypographic)])
        {
            curMaxSize = [curMaxObj boundingRectTypographic].size;
        }
        else if ([curMaxObj respondsToSelector:@selector(drawSize)])
        {
            curMaxSize = [curMaxObj drawSize];
        }

        CGSize testSize = CGSizeZero;
        if ([testObj respondsToSelector:@selector(boundingRectTypographic)])
        {
            testSize = [testObj boundingRectTypographic].size;
        }
        else if ([testObj respondsToSelector:@selector(drawSize)])
        {
            testSize = [testObj drawSize];
        }

        if (testSize.width + 6.0f > curMaxSize.width)
        {
            maxLoc = i;
        }
    }

    return maxLoc;
}

- (CGPoint)layoutAnchorNodeWithOrigin: (CGPoint)drawOrigin
{
    id drawObj = self.renderArray.firstObject;
    if ([drawObj isKindOfClass:[EQRenderData class]])
    {
        drawOrigin = [self layoutDrawData: (EQRenderData *)drawObj atPoint: (CGPoint)drawOrigin forLocation: 0];
    }
    else if ([drawObj isKindOfClass:[EQRenderStem class]])
    {
        EQRenderStem *drawStem = (EQRenderStem *)drawObj;
        // You need to lay it out at the current location,
        // then use those metrics to lay it out at the correct location.
        drawStem.drawOrigin = drawOrigin;
        [drawStem layoutChildren];
        xCoord = drawStem.drawSize.width;
        prevSize = drawStem.drawSize;
    }

    drawOrigin.x = ceilf( drawOrigin.x + xCoord );
    return drawOrigin;
}

- (CGPoint)computeNextOriginForStem: (EQRenderStem *)drawStem
                        withPrevObj: (id)prevObj
                            atPoint: (CGPoint)drawOrigin
                        forLocation: (NSUInteger)childCounter
{
    if (nil != prevObj)
    {
        if ([prevObj isKindOfClass:[EQRenderStem class]])
        {
            drawOrigin.y -= prevSize.height;
        }
        else if ([prevObj isKindOfClass:[EQRenderData class]])
        {
            if (self.stemType == stemTypeSubSup)
            {
                drawOrigin = [self layoutSubSupStemData:drawStem atPoint:drawOrigin withPrevious:(EQRenderData *)prevObj forLocation:childCounter];
            }
            else if (self.stemType == stemTypeUnderOver)
            {
                drawOrigin = [self layoutUnderOverStemData:drawStem atPoint:drawOrigin withPrevious:(EQRenderData *)prevObj forLocation:childCounter];
            }
            else
            {
                drawOrigin = [self layoutStemData:drawStem atPoint:drawOrigin withPrevious:(EQRenderData *)prevObj];
            }
        }
    }
    return drawOrigin;
}

// This may need further refactoring as well. See comment inside function.
- (CGPoint)computeNextUpperOriginForStem: (EQRenderStem *)drawStem
                             withPrevObj: (id)prevObj
                                 atPoint: (CGPoint)drawOrigin
                             forLocation: (NSUInteger)childCounter
{
    if (nil != prevObj)
    {
        if ([prevObj isKindOfClass:[EQRenderStem class]])
        {
            if (self.hasLargeOp == YES && childCounter >= 2
                && (self.stemType == stemTypeSub || self.stemType == stemTypeSup || self.stemType == stemTypeSubSup)
                && (drawStem.stemType == stemTypeFraction || drawStem.isRowStemType))
            {
                // You need to adjust the superior by some set margin but you can't compute it directly as it is a stem type.
                // So build a mock tempData and use that to compute the adjust height.
                // Will likely need refactoring, but at least it works.
                CGPoint tempOrigin = drawOrigin;
                EQRenderData *tempData = [[EQRenderData alloc] initWithString:@"X"];
                drawOrigin = self.drawOrigin;
                [self layoutDrawData: tempData atPoint: (CGPoint)drawOrigin forLocation: (NSUInteger)childCounter];
                drawOrigin = tempData.drawOrigin;
                drawOrigin.x = tempOrigin.x;
                CGFloat fracHeight = drawStem.drawSize.height;
                fracHeight == 0 ? fracHeight = 36.0 : fracHeight;
                drawOrigin.y -= 0.5 * fracHeight;
            }
            else
            {
                drawOrigin.y -= prevSize.height;
            }
        }
        else if ([prevObj isKindOfClass:[EQRenderData class]])
        {
            drawOrigin = [self layoutSubSupStemData:drawStem atPoint:drawOrigin withPrevious:(EQRenderData *)prevObj forLocation:childCounter];
        }
    }
    return drawOrigin;
}

- (CGPoint)layoutChildNodeAtLoc: (NSUInteger)childLoc
                     withOrigin: (CGPoint)drawOrigin
{
    NSAssert(childLoc < self.renderArray.count, @"Stem Child location out of bounds.");
    NSAssert(childLoc > 0, @"Stem Child location must be > 0.");

    id drawObj = self.renderArray[childLoc];
    id prevObj = self.renderArray[childLoc - 1];

    if ([drawObj isKindOfClass:[EQRenderData class]])
    {
        drawOrigin = [self layoutDrawData: (EQRenderData *)drawObj atPoint: (CGPoint)drawOrigin forLocation: childLoc];
    }
    else if ([drawObj isKindOfClass:[EQRenderStem class]])
    {
        EQRenderStem *drawStem = (EQRenderStem *)drawObj;
        drawOrigin = [self computeNextOriginForStem:drawStem withPrevObj:prevObj atPoint:drawOrigin forLocation:childLoc];
        drawStem.drawOrigin = drawOrigin;
        [drawStem layoutChildren];
        xCoord = drawStem.drawSize.width;
        prevSize = drawStem.drawSize;
    }

    drawOrigin.x = ceilf( drawOrigin.x + xCoord );
    return drawOrigin;
}

- (CGPoint)layoutUpperChildNodeAtLoc: (NSUInteger)childLoc withOrigin: (CGPoint)drawOrigin
{
    NSAssert(childLoc < self.renderArray.count, @"Stem Child location out of bounds.");
    NSAssert(childLoc > 1, @"Stem Child location must be > 1.");

    id drawObj = self.renderArray[childLoc];
    id prevObj = self.renderArray[childLoc - 1];

    if ([drawObj isKindOfClass:[EQRenderData class]])
    {
        drawOrigin = [self layoutDrawData: (EQRenderData *)drawObj atPoint: (CGPoint)drawOrigin forLocation: childLoc];
    }
    else if ([drawObj isKindOfClass:[EQRenderStem class]])
    {
        EQRenderStem *drawStem = (EQRenderStem *)drawObj;
        // The previous object needs to be the root object when computing sups.
        // This doesn't matter for drawData objects as they don't use that variable.
        if (self.stemType == stemTypeSubSup)
        {
            prevObj = self.renderArray[0];
            if (self.hasLargeOp == YES)
            {
                drawOrigin.x -= 6.0f;
            }
        }
        drawOrigin = [self computeNextUpperOriginForStem:drawStem withPrevObj:prevObj atPoint:drawOrigin forLocation:childLoc];
        drawStem.drawOrigin = drawOrigin;
        [drawStem layoutChildren];

        // May need to adjust to avoid collisions with lower stem.
        CGPoint testPoint = [EQRenderLayout findLowestChildOrigin:drawStem];
        if (testPoint.y > drawOrigin.y)
        {
            CGFloat adjustY = drawOrigin.y - testPoint.y;
            drawOrigin.y += adjustY;
            drawStem.drawOrigin = drawOrigin;
            [drawStem layoutChildren];
        }

        xCoord = drawStem.drawSize.width;
        prevSize = drawStem.drawSize;
    }
    // Dangling descenders can intersect the root object.
    // It should already offset the x position for sup stems,
    // but you need to set the sub x position to equal the sup x position.
    if (self.hasLargeOp == NO && self->adjustForTrailingCharacter == YES)
    {
        id subObj = [self.renderArray objectAtIndex:1];
        if (nil != subObj && [subObj respondsToSelector:@selector(drawOrigin)] && [subObj respondsToSelector:@selector(setDrawOrigin:)]
            && [drawObj respondsToSelector:@selector(drawOrigin)])
        {
            CGPoint supOrigin = [drawObj drawOrigin];
            CGPoint subOrigin = [subObj drawOrigin];
            subOrigin.x = supOrigin.x;
            [subObj setDrawOrigin:subOrigin];
        }
    }

    drawOrigin.x = ceilf( drawOrigin.x + xCoord );
    return drawOrigin;
}

- (CGPoint)adjustPointForDescenderInData: (EQRenderData *)drawData atPoint: (CGPoint)adjustPoint
{
    NSSet *trailingChars = [EQRenderTypesetter getTrailingCharacters];
    if ([trailingChars containsObject:drawData.renderString.string])
    {
        if (self.hasLargeOp == NO)
        {
            CGFloat adjustDelta = prevSize.width - prevTypoSize.width;

            // Call internal method to compute adjustment width.
            CGFloat adjustWidth = [self computeWidthAdjustmentFor:drawData withAdjustDelta:adjustDelta rightBracketTest:baseIsRightBracket];
            adjustPoint.x += adjustWidth;
            self->adjustForTrailingCharacter = YES;
        }
        else
        {
            adjustPoint.y -= 2.0f;
        }
    }
    return adjustPoint;
}

- (CGPoint)adjustForDescendersInStem: (EQRenderStem *)drawStem atPoint: (CGPoint)drawOrigin
{
    if (drawStem.renderArray.count == 0)
        return drawOrigin;

    if (drawStem.stemType == stemTypeSup || drawStem.stemType == stemTypeSub || drawStem.stemType == stemTypeSubSup)
    {
        id rootObj = drawStem.renderArray.firstObject;
        if ([rootObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *rootData = (EQRenderData *)rootObj;
            drawOrigin = [self adjustPointForDescenderInData:rootData atPoint:drawOrigin];
        }
    }
    else if (drawStem.stemType == stemTypeRow)
    {
        id rootObj = drawStem.renderArray.firstObject;
        if ([rootObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *rootStem = (EQRenderStem *)rootObj;
            drawOrigin = [self adjustForDescendersInStem:rootStem atPoint:drawOrigin];
        } else if ([rootObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *rootData = (EQRenderData *)rootObj;
            drawOrigin = [self adjustPointForDescenderInData:rootData atPoint:drawOrigin];
        }
    }
    return drawOrigin;
}

// Much of the work done here would be better handled by kerning in the attributed strings that make up the various pieces.
// Will likely need to refactor this even more when/if we allow other font faces besides STIX.
- (CGPoint)layoutDrawData: (EQRenderData *)drawData
                  atPoint: (CGPoint)drawOrigin
              forLocation: (NSUInteger)childCounter
{
    NSAssert(nil != drawData, @"Input draw data can not be nil.");
    drawData = [EQRenderLayout layoutData:drawData forStemType:self.stemType atPoint:drawOrigin forLocation:childCounter];
    CGFloat adjustWidth = 0.0;

    if (childCounter == 0 && self.isRowStemType == NO)
    {
        // Reset the trailing kern value to keep it from adding/removing extra string length.
        if (drawData.renderString.length > 0)
        {
            NSMutableAttributedString *stringPeek = drawData.renderString;
            NSDictionary *stringDict = [stringPeek attributesAtIndex:(stringPeek.length - 1) effectiveRange:NULL];
            if ([stringDict valueForKey:NSKernAttributeName] != nil && [stringDict valueForKey:NSFontAttributeName] != nil)
            {
                // Should retain kerning for large ops.
                UIFont *testFont = [stringDict valueForKey:NSFontAttributeName];
                if (testFont.pointSize <= kDEFAULT_FONT_SIZE)
                {
                    NSNumber *kernValue = @0.0;
                    NSMutableDictionary *newDict = stringDict.mutableCopy;
                    newDict[NSKernAttributeName] = kernValue;
                    NSRange updatedRange = NSMakeRange((stringPeek.length - 1), 1);
                    [stringPeek setAttributes:newDict range:updatedRange];
                    drawData.renderString = stringPeek;
                }
            }
        }

        // Need to do additional adjustments to layout based on character type.
        // Can't use built in kerning as it only (indirectly) affects the layout by adjusting the typographic boundaries.
        // Doesn't seem to affect the image boundaries, which you need to use for precision layout.
        self->baseIsSmaller = [drawData shouldUseSmaller];
        self->baseIsRightBracket = [[EQRenderTypesetter getRightBracketCharacters] containsObject:drawData.renderString.string];

        // Adjust the position of the sup if the base is a right bracket.
        // The amount depends on the type of bracket.
        // Could be refactored to use a dictionary if this gets overly complicated.
        if (self.stemType == stemTypeSup || self.stemType == stemTypeSubSup)
        {
            if (baseIsRightBracket)
            {
                NSString *testString = [drawData.renderString.string substringToIndex:1];
                if ([testString isEqualToString:@")"])
                {
                    adjustWidth = 0.0;
                }
                else if ([testString isEqualToString:@"]"])
                {
                    adjustWidth = -1.0;
                }
                else if ([testString isEqualToString:@"}"])
                {
                    adjustWidth = -3.0;
                }
                else
                {
                    adjustWidth = -4.0;
                }
            }
            else if (drawData.renderString.string.length > 0)
            {
                NSString *testString = [drawData.renderString.string substringToIndex:1];
                if ([testString isEqualToString:@"1"])
                {
                    if (!baseIsSmaller)
                    {
                        adjustWidth = 3.5f;
                    }
                    else
                    {
                        adjustWidth = 1.5f;
                    }
                }
                else if ([testString isEqualToString:@"0"])
                {
                    if (!baseIsSmaller)
                    {
                        adjustWidth = 3.0f;
                    }
                    else
                    {
                        adjustWidth = 1.0f;
                    }
                }
                NSSet *testNumericRight = [[NSSet alloc] initWithObjects:@"2", @"4", @"5", @"6", @"7", nil];
                BOOL baseNeedsSmallAdjustment = [testNumericRight containsObject:testString];
                if (baseNeedsSmallAdjustment)
                {
                    adjustWidth = 1.0f;
                }
            }
        }
    }

    CGRect cursorRect = [EQRenderLayout cursorRectWithData:drawData forStemType:self.stemType forLocation:childCounter smallerBase: baseIsSmaller];
    xCoord = cursorRect.origin.x;

    // Need to adjust position to account for dangling descenders in the sup location.
    if (childCounter > 0 && (self.stemType == stemTypeSup || (self.stemType == stemTypeSubSup && childCounter > 1)) )
    {
        drawData.drawOrigin = [self adjustPointForDescenderInData:drawData atPoint:drawData.drawOrigin];

    }
    else if (self.hasLargeOp == YES && childCounter > 0 &&
               (self.stemType == stemTypeSub || (self.stemType == stemTypeSubSup && childCounter == 1)) )
    {
        CGPoint adjustPoint = drawData.drawOrigin;
        adjustPoint.y += 4.0f;
        drawData.drawOrigin = adjustPoint;
    }
    // Need to adjust for large cap letters in base
    else if (childCounter == 0 && drawData.renderString.string.length > 0 && (self.isSupStemType || self.stemType == stemTypeSub))
    {
        NSString *suffixStr = [drawData.renderString.string substringFromIndex:(drawData.renderString.length - 1)];
        if (self.isSupStemType)
        {
            adjustWidth = [self adjustWidthForSuffixStr:suffixStr withGivenWidth:adjustWidth];
        }
        else if (self.stemType == stemTypeSub)
        {
            adjustWidth = [self adjustKerningForSuffixStr:suffixStr withGivenWidth:adjustWidth];
        }
    }

    prevTypoSize = drawData.typographicBounds.size;
    prevSize = drawData.imageBounds.size;
    xCoord += adjustWidth;
    return drawOrigin;
}

// Computes the offset for characters that may trail to far to the right if you use only their imageBounds as a guide.
- (CGFloat)adjustWidthForSuffixStr: (NSString *)suffixStr withGivenWidth: (CGFloat) adjustWidth
{
    NSSet *adjustSet = [EQRenderTypesetter getItalicAdjustCharacters];
    BOOL containsItalicAdjust = [adjustSet containsObject:suffixStr];
    if (containsItalicAdjust)
    {
        if (!baseIsSmaller)
        {
            adjustWidth = 2.5f;
        }
        else
        {
            adjustWidth = 1.0f;
        }
    }
    // Some values need additional adjustment.
    NSSet *smallAdjustSet = [[NSSet alloc] initWithObjects: @"B", @"C", @"D", @"H", @"K", @"N", @"P", @"R", @"U", @"V", @"W", @"Y", @"Z", nil];
    BOOL containsSmallAdjust = [smallAdjustSet containsObject:suffixStr];
    if (containsSmallAdjust)
    {
        if (!baseIsSmaller)
        {
            if ([suffixStr isEqualToString:@"W"])
            {
                adjustWidth += 1.0;
            }
            else
            {
                adjustWidth += 1.5;
            }
        }
        else
        {
            // Some overlap, so just set the adjust to a static value.
            adjustWidth = 1.5;
        }
    }
    // Everything else still should use some minimum.
    if (!containsItalicAdjust && !containsSmallAdjust)
    {
        // Also check for these characters which are not kerned correctly.
        if ([suffixStr isEqualToString:@"i"] || [suffixStr isEqualToString:@"r"])
        {
            adjustWidth = 1.5;
        }
        else if ([suffixStr isEqualToString:@"f"] || [suffixStr isEqualToString:@"j"]
                 || [suffixStr isEqualToString:@"p"] || [suffixStr isEqualToString:@"u"])
        {
            adjustWidth = -1.5;
        }
        else if ([suffixStr isEqualToString:@"d"] || [suffixStr isEqualToString:@"l"] || [suffixStr isEqualToString:@"t"])
        {
            adjustWidth = 2.5;
        }
        else
        {
            adjustWidth += 1.0;
        }
    }
    return adjustWidth;
}

// Computes the offset for characters that trail too far to the left if you use only their image bounds as a guide.
- (CGFloat)adjustWidthForPrefixStr: (NSString *)prefixStr withGivenWidth: (CGFloat)adjustWidth
{
    NSSet *leftAdjustChars = [EQRenderTypesetter getLeftTrailingCharacters];
    if ([leftAdjustChars containsObject:prefixStr])
    {
        adjustWidth += 2.0;

        NSSet *smallAdjust = [[NSSet alloc] initWithObjects:@"b", @"d", nil];
        if ([smallAdjust containsObject:prefixStr])
        {
            adjustWidth -= 1.5;
            return adjustWidth;
        }

        NSSet *largeAdjust = [[NSSet alloc] initWithObjects: @"g", @"p", nil];
        if ([largeAdjust containsObject:prefixStr])
        {
            adjustWidth += 1.5;
            return adjustWidth;
        }

        NSSet *extraLargeAdjust = [[NSSet alloc] initWithObjects:@"f", @"j", nil];
        if ([extraLargeAdjust containsObject:prefixStr])
        {
            adjustWidth += 2.0;
            return adjustWidth;
        }
    }
    else if ([[EQRenderTypesetter getRightBracketCharacters] containsObject:prefixStr])
    {
        adjustWidth += 2.0;
    }

    return adjustWidth;
}

// Computes the offset for characters with a lower right hand width that trails too far to the right if you use image bounds as a guide.
- (CGFloat)adjustKerningForSuffixStr:(NSString *)suffixStr withGivenWidth:(CGFloat)adjustWidth
{
    NSCharacterSet *adjustKernSet = [NSCharacterSet letterCharacterSet];
    NSCharacterSet *numericKernSet = [NSCharacterSet decimalDigitCharacterSet];
    if ([suffixStr rangeOfCharacterFromSet:adjustKernSet].location != NSNotFound)
    {
        NSSet *ignoreAdjust = [[NSSet alloc] initWithObjects:@"F", @"P", nil];
        if ([ignoreAdjust containsObject:suffixStr])
        {
            return adjustWidth;
        }

        adjustWidth += 2.0;
        NSSet *smallAdjust = [[NSSet alloc] initWithObjects:@"C", @"D", @"O", @"T", @"U", @"w", nil];
        if ([smallAdjust containsObject:suffixStr])
        {
            adjustWidth -= 1.0;
            return adjustWidth;
        }

        NSSet *largeAdjust = [[NSSet alloc] initWithObjects:@"A", @"E", @"I", @"L", @"Q", @"R", @"X", @"Z"
                              @"f", @"h", @"i", @"k", @"l", @"m", @"n", @"z", nil];
        if ([largeAdjust containsObject:suffixStr])
        {
            adjustWidth += 1.0;
            return adjustWidth;
        }
    }
    else if ([suffixStr rangeOfCharacterFromSet:numericKernSet].location != NSNotFound)
    {
        adjustWidth += 2.0;
    }
    return adjustWidth;
}

- (CGFloat)additionalAdjustWidthForPrefixStr: (NSString *)prefixStr withGivenWidth: (CGFloat)adjustWidth
{
    NSSet *additionalAdjustCharacters = [EQRenderTypesetter getDescenderCharacters];
    if ([additionalAdjustCharacters containsObject:prefixStr])
    {
        adjustWidth += 2.0;
        NSSet *largeAdjust = [[NSSet alloc] initWithObjects:@"f", @"q", nil];
        if ([largeAdjust containsObject:prefixStr])
        {
            adjustWidth += 1.0;
            return adjustWidth;
        }
    }
    return adjustWidth;
}


- (CGPoint)layoutStemData: (EQRenderStem *)drawStem
                  atPoint: (CGPoint)drawOrigin
             withPrevious: (EQRenderData *)prevData
{
    drawOrigin.y = [EQRenderLayout adjustDropHeight:drawOrigin.y forStemType:self.stemType usingData:prevData];
    drawOrigin = [self adjustForDescendersInStem:drawStem atPoint:drawOrigin];

    // Make adjustments for subs and rows containing nested stems.
    if ([self shouldAdjustYCoordInStem:drawStem withPrevious:prevData])
    {
        drawOrigin.y -= 5.0;
    }

    // Layout large op subs and sups differently.
    if (self.hasLargeOp == YES)
    {
        drawOrigin = [self layoutLargeStemData:drawStem atPoint:drawOrigin withStemType:self.stemType withOriginOffset:20.0f];
    }
    // Fractions need additional adjustment.
    // Currently only needed for sups and (maybe) subsups.
    else if (self.stemType == stemTypeSup &&
             (drawStem.stemType == stemTypeFraction ||
              (drawStem.stemType == stemTypeRow && [drawStem hasChildType:stemTypeFraction] == YES)))
    {
        // Set the coords and then make adjustments.
        drawStem.drawOrigin = drawOrigin;
        [drawStem layoutChildren];

        CGPoint lowestPoint = [EQRenderLayout findLowestChildOrigin:drawStem];
        CGFloat testHeight = lowestPoint.y - drawOrigin.y;
        drawOrigin.y -= testHeight * 0.5;
    }

    return drawOrigin;
}

- (CGPoint)layoutSubSupStemData: (EQRenderStem *)drawStem
                        atPoint: (CGPoint)drawOrigin
                   withPrevious: (EQRenderData *)prevData
                    forLocation: (NSUInteger)childCounter
{
    EQRenderStemType useType = stemTypeSub;
    if (childCounter >= 2)
        useType = stemTypeSup;

    drawOrigin.y = [EQRenderLayout adjustDropHeight:drawOrigin.y forStemType:useType usingData:(EQRenderData *)prevData];

    // Adjust layout for large op sizes.
    if (self.hasLargeOp == YES)
    {
        drawOrigin = [self layoutLargeStemData:drawStem atPoint:drawOrigin withStemType:useType withOriginOffset:14.0f];
    }
    return drawOrigin;
}

- (CGPoint)layoutUnderOverStemData: (EQRenderStem *)drawStem
                           atPoint: (CGPoint)drawOrigin
                      withPrevious: (EQRenderData *)prevData
                       forLocation: (NSUInteger)childCounter
{
    EQRenderStemType useType = stemTypeUnder;
    if (childCounter >= 2)
        useType = stemTypeOver;

    drawOrigin.y = [EQRenderLayout adjustDropHeight:drawOrigin.y forStemType:useType usingData:(EQRenderData *)prevData];
    return drawOrigin;
}


- (BOOL)shouldAdjustYCoordInStem: (EQRenderStem *)drawStem
                    withPrevious: (EQRenderData *)prevData
{
    if (self.stemType == stemTypeSub && self.hasLargeOp == NO)
    {
        // Need to adjust the y location for nested subs and rows containing nested subs.
        if (prevData.renderString.length <= 1)
        {
            if (self.parentStem != nil &&
                (self.parentStem.stemType == stemTypeRoot ||
                 self.parentStem.stemType == stemTypeFraction ||
                 self.parentStem.stemType == stemTypeRow)
                )
            {
                if (drawStem.stemType == stemTypeSub || (drawStem.stemType == stemTypeRow && [drawStem hasChildType:stemTypeSub]))
                {
                    return YES;
                }
            }
        }
    }

    return NO;
}


- (CGPoint)layoutLargeStemData: (EQRenderStem *)drawStem
                       atPoint: (CGPoint)drawOrigin
                  withStemType: (EQRenderStemType)useType
              withOriginOffset: (CGFloat)originOffset
{
    // Set the coords and then make adjustments.
    drawStem.drawOrigin = drawOrigin;
    [drawStem layoutChildren];

    CGPoint lowestPoint = [EQRenderLayout findLowestChildOrigin:drawStem];
    CGPoint highestPoint = [EQRenderLayout findHighestChildOrigin:drawStem];

    // Adjust sup coords.
    if (useType == stemTypeSup || useType == stemTypeOver)
    {
        CGFloat testHeight = lowestPoint.y - self.drawOrigin.y;

        if (CGPointEqualToPoint(lowestPoint, drawOrigin))
        {
            drawOrigin.y -= 6.0;
        }
        else if (testHeight < 6.0)
        {
            drawOrigin.y += testHeight + 5.0;
        }

        drawOrigin.x += 6.0;
    }
    // Adjust sub coords.
    else if (useType == stemTypeSub || useType == stemTypeSubSup)
    {
        CGFloat testHeight = lowestPoint.y - drawStem.drawSize.height;
        CGFloat highestDelta = highestPoint.x - drawOrigin.x;
        CGFloat highestToLowestDelta = lowestPoint.y - highestPoint.y;

        // Test to see if you need to adjust the height.
        // Remember origin is upper left corner for y.
        CGFloat yDelta = 0;
        CGFloat xDelta = 0;
        // Test to see if you are too tall.
        if ((testHeight + 6.0) < self.drawOrigin.y)
        {
            yDelta = testHeight - self.drawOrigin.y;
        }
        // Test to see if you are too short.
        else if ((testHeight - 8.0) > self.drawOrigin.y)
        {
            yDelta = self.drawOrigin.y - (testHeight - 8.0);

            // Fractions have a greater difference in highest to lowest.
            // This can cause it to adjust too far vertically.
            if (highestToLowestDelta > 10.0)
            {
                yDelta -= 3.0;
            }
        }
        // Make an additional adjustment for sup stems, which are further to the right at their highest point.
        else if (highestDelta > 6.0 && (testHeight < self.drawOrigin.y + 6.0))
        {
            yDelta = -6.0;
        }
        // Make an xAdjustment for fractions, which are laid out with extra space due to the fraction bar.
        if (drawStem.stemType == stemTypeFraction || drawStem.isRowStemType == YES)
        {
            xDelta = -3.0;
        }
        if (drawStem.stemType == stemTypeSub || (drawStem.stemType == stemTypeRow && [drawStem hasOnlyChildrenOfType:stemTypeSub]) )
        {
            yDelta -= 9.0;
        }
        drawOrigin.y += yDelta;
        drawOrigin.x -= originOffset + xDelta;
    }

    return drawOrigin;
}

- (CGRect)computeReturnRectWithMyOrigin: (CGPoint)myOrigin
                          andBaseRect: (CGRect)returnRect
                            andOrigin: (CGPoint)useOrigin
                            andBounds: (CGRect)useBounds
{
    useBounds.origin.x -= myOrigin.x;
    // Size is computed by distance from the lower left,
    // but coordinates use upper left as origin.
    // This requires some adjustment using the draw origin.
    useBounds.origin.y = myOrigin.y - useBounds.origin.y;

    useOrigin.x = MIN(returnRect.origin.x, useOrigin.x);
    useOrigin.y = MIN(returnRect.origin.y, useOrigin.y);

    // Compute the X and Y enclosing locations.
    CGFloat maxX = CGRectGetMaxX(useBounds);
    CGFloat maxY = CGRectGetMaxY(useBounds);

    CGFloat testX = useOrigin.x + returnRect.size.width;
    CGFloat testY = useOrigin.y + returnRect.size.height;

    // Increase the return rect width, if needed.
    if (testX < maxX)
    {
        returnRect.size.width += maxX - (useOrigin.x + returnRect.size.width);
    }
    // Increase the return rect height, if needed.
    if (testY < maxY)
    {
        returnRect.size.height += maxY - (useOrigin.y + returnRect.size.height);
    }

    return returnRect;
}

- (void)updateBounds
{
    CGRect returnRect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    if (self.renderArray.count == 0)
    {
        self.drawBounds = returnRect;
        self.drawSize = returnRect.size;
        return;
    }

    for (id drawObj in self.renderArray)
    {
        CGPoint useOrigin = CGPointZero;
        CGRect useBounds = CGRectZero;
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderData = (EQRenderData *)drawObj;
            useOrigin = renderData.drawOrigin;
            useBounds = renderData.boundingRectTypographic;
            useBounds.origin = useOrigin;
            // Reduce the typographic height for empty strings.
            if (renderData.renderString.length == 0 || [renderData.renderString.string isEqualToString:@" "])
            {
                useBounds.size.height *= 0.5;
            }
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *renderStem = (EQRenderStem *)drawObj;
            useOrigin = renderStem.drawOrigin;
            useBounds = renderStem.drawBounds;
            useBounds.origin = useOrigin;
        }
        returnRect = [self computeReturnRectWithMyOrigin:self.drawOrigin
                                             andBaseRect:returnRect
                                               andOrigin:useOrigin
                                               andBounds:useBounds];
    }
    if (self.hasOverline)
    {
        CGPoint useOrigin = self.overlineStartPoint;
        CGFloat useWidth = self.overlineEndPoint.x - self.overlineStartPoint.x;
        CGFloat useHeight = 2.0f;
        CGRect useBounds = CGRectMake(self.overlineStartPoint.x, self.overlineStartPoint.y, useWidth, useHeight);
        returnRect = [self computeReturnRectWithMyOrigin:self.drawOrigin
                                             andBaseRect:returnRect
                                               andOrigin:useOrigin
                                               andBounds:useBounds];
    }

    self.drawBounds = returnRect;
    self.drawSize = returnRect.size;
    return;
}

- (CGRect)computeUpdatedRectWithMyOrigin: (CGPoint)myOrigin
                            andBaseRect: (CGRect)returnRect
                              andOrigin: (CGPoint)useOrigin
                              andBounds: (CGRect)useBounds
{
    useOrigin.x -= myOrigin.x;
    useOrigin.y -= myOrigin.y;
    useOrigin.y *= -1.0;
    useBounds.origin = useOrigin;

    // Find the edges of the bounds you want to incorporate.
    CGFloat minX = CGRectGetMinX(useBounds);
    CGFloat maxX = CGRectGetMaxX(useBounds);

    CGFloat minY = CGRectGetMinY(useBounds);
    CGFloat maxY = CGRectGetMaxY(useBounds);

    CGFloat returnMinX = CGRectGetMinX(returnRect);
    CGFloat returnMaxX = CGRectGetMaxX(returnRect);

    CGFloat returnMinY = CGRectGetMinY(returnRect);
    CGFloat returnMaxY = CGRectGetMaxY(returnRect);

    CGFloat deltaLeftX = 0.0;
    CGFloat deltaRightX = 0.0;

    CGFloat deltaBottomY = 0.0;
    CGFloat deltaTopY = 0.0;

    // Check the bounds to see if rectangle needs to enclose new bounds.
    if (returnMaxX < maxX)
    {
        deltaRightX = maxX - returnMaxX;
    }
    if (minX < returnMinX)
    {
        deltaLeftX = minX - returnMinX;
    }
    if (returnMaxY < maxY)
    {
        deltaTopY = maxY - returnMaxY;
    }
    if (minY < returnMinY)
    {
        deltaBottomY = minY - returnMinY;
    }

    CGPoint returnOrigin = returnRect.origin;
    returnOrigin.x += deltaLeftX;
    returnOrigin.y += deltaBottomY;

    CGSize returnSize = returnRect.size;
    returnSize.width += deltaRightX;
    returnSize.height += deltaTopY;

    returnRect.origin = returnOrigin;
    returnRect.size = returnSize;

    return returnRect;
}

- (CGRect)computeImageBounds
{
    NSAssert(nil != self.renderArray, @"Render array must not be nil here.");

    CGRect returnBounds = CGRectZero;

    if (self.renderArray.count == 0)
    {
        return returnBounds;
    }
    for (id drawObj in self.renderArray)
    {
        CGRect useBounds = CGRectZero;
        CGPoint useOrigin = CGPointZero;

        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *drawData = (EQRenderData *)drawObj;
            useBounds = drawData.imageBounds;
            useOrigin = drawData.drawOrigin;
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *drawStem = (EQRenderStem *)drawObj;
            useBounds = [drawStem computeImageBounds];
            useOrigin = drawStem.drawOrigin;
        }
        returnBounds = [self computeUpdatedRectWithMyOrigin:self.drawOrigin
                                               andBaseRect:returnBounds
                                                 andOrigin:useOrigin
                                                 andBounds:useBounds];
    }

    return returnBounds;
}

// Needed to give the correct width for matrix cell stem types.
// May not be meaningful for other stem types.
- (CGRect)computeTypographicalLayout
{
    CGRect returnRect = CGRectZero;

    if (nil != self.renderArray && self.renderArray.count > 0)
    {
        CGFloat useWidth = 0.0;
        CGFloat useHeight = 0.0;

        for (id renderObj in self.renderArray)
        {
            CGRect typoBounds = CGRectZero;
            if ([renderObj isKindOfClass:[EQRenderData class]])
            {
                EQRenderData *renderData = (EQRenderData *)renderObj;
                typoBounds = renderData.typographicBounds;
            }
            // Will likely need to adjust this for some stem types, maybe all types.
            else if ([renderObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderStem *renderStem = (EQRenderStem *)renderObj;
                if (renderStem.stemType == stemTypeMatrixCell)
                {
                    typoBounds = [renderStem computeTypographicalLayout];
                }
                else if (renderStem.stemType == stemTypeMatrixRow)
                {
                    typoBounds = [renderStem computeTypographicalLayout];
                }
                else
                {
                    typoBounds = renderStem.drawBounds;
                }
            }

            useWidth += typoBounds.size.width;
            useHeight = MAX(useHeight, typoBounds.size.height);
        }
        returnRect.size.width = useWidth;
        returnRect.size.height = useHeight;
    }
    return returnRect;
}

// Needed to help sqrt radical draw filter out the radical and other
// supplemental characters from the part that needs an overline.
- (CGPoint)initialChildOrigin
{
    if (nil == self.renderArray || self.renderArray.count == 0)
        return CGPointZero;

    id drawObj = self.renderArray.firstObject;
    return [drawObj drawOrigin];
}

// Next two are used to help draw the radical in the correct location for sqrts inside fraction numerators.

- (CGFloat)supplementalLowerBounds
{
    if (self.hasSupplementaryData && nil != self.supplementaryData && [self.supplementaryData isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *suppleRenderData = (EQRenderData *)self.supplementaryData;
        CGFloat lowerBounds = suppleRenderData.drawOrigin.y;
        return lowerBounds;
    }

    return -1.0;
}

- (CGFloat)radicalLowerBounds
{
    if (self.stemType != stemTypeSqRoot && self.stemType != stemTypeNRoot)
    {
        return -1.0;
    }
    CGFloat suppleBounds = [self supplementalLowerBounds];
    if (suppleBounds != -1.0)
    {
        // May need to customize this for other radical sizes.
        suppleBounds -= 0.5 * [EQRenderFontDictionary defaultFontAscentValueWithSize:kDEFAULT_FONT_SIZE];
    }

    return suppleBounds;
}

// Used to find out how much adjustment you need between the previous character and the new sup.
// This adjustment is more important for stretchy bracers than other characters, but still relevant.
- (CGFloat)computeAdjustWidthUseAdditional: (BOOL)useAdditional
{
    CGFloat adjustWidth = 0.0;
    if (self.renderArray == nil || self.renderArray.count == 0)
    {
        return adjustWidth;
    }

    if ([self isSupStemType] || self.stemType == stemTypeSub)
    {
        id renderObj = [self getFirstChild];
        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderData = (EQRenderData *)renderObj;
            if (renderData.renderString.string.length > 0)
            {
                NSString *testStr = [renderData.renderString.string substringWithRange:NSMakeRange(0, 1)];
                if (useAdditional)
                {
                    adjustWidth = [self additionalAdjustWidthForPrefixStr:testStr withGivenWidth:3.5];
                }
                else
                {
                    adjustWidth = [self adjustWidthForPrefixStr:testStr withGivenWidth:0.0];
                }
            }
        }
    }

    return adjustWidth;
}

// Both these computations use the same methods for retrieving the string.
// They just hand the result off to different comparison functions.
- (CGFloat)computeLeftAdjustment
{
    return [self computeAdjustWidthUseAdditional:NO];
}

- (CGFloat)computeAdditionalLeftAdjustment
{
    return [self computeAdjustWidthUseAdditional:YES];
}


- (Boolean)useSmallFontForChild: (id)child
{
    if (nil == self.renderArray || self.renderArray.count == 0 || nil == child)
        return NO;

    NSUInteger i = [self.renderArray indexOfObject:child];
    if (i == NSNotFound)
        return NO;

    if (i == 1 && (self.stemType == stemTypeSup || self.stemType == stemTypeSub || self.stemType == stemTypeUnder || self.stemType == stemTypeOver))
    {
        return YES;
    }
    else if ((self.stemType == stemTypeSubSup || self.stemType == stemTypeUnderOver) && (i == 1 || i == 2))
    {
        return YES;
    }
    else if (self.stemType == stemTypeFraction)
    {
        if (nil != [self getFractionBarParent])
        {
            return YES;
        }
    }

    if (nil != self.parentStem)
    {
        if (self.stemType == stemTypeRow && self.parentStem.stemType == stemTypeFraction && [child isKindOfClass:[EQRenderFracStem class]])
        {
            return YES;
        }
        else if (self.stemType == stemTypeFraction && [child isKindOfClass:[EQRenderFracStem class]])
        {
            return YES;
        }
        return [self.parentStem useSmallFontForChild:self];
    }

    return NO;
}

- (Boolean)shouldUseSmaller
{
    if (nil == self.parentStem)
    {
        return NO;
    }

    return [self.parentStem useSmallFontForChild:self];
}

- (Boolean)shouldUseSmallest
{
    if (nil == self.parentStem || nil == self.parentStem.parentStem)
    {
        return NO;
    }

    return [self.parentStem.parentStem useSmallFontForChild:self.parentStem];
}

- (BOOL)isRowStemType
{
    if (self.stemType == stemTypeRoot || self.stemType == stemTypeRow || self.stemType == stemTypeMatrixCell)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isRootStemType
{
    if (self.stemType == stemTypeSqRoot || self.stemType == stemTypeNRoot)
    {
        return YES;
    }
    return NO;
}


// Returns true if it is a stem type that is likely to have a
// lowestChildOrigin different from the draw origin for the stem.
- (BOOL)isStemWithDescender
{
    if (self.stemType == stemTypeFraction || self.stemType == stemTypeUnder || self.stemType == stemTypeUnderOver
        || self.stemType == stemTypeMatrix)
    {
        return YES;
    }

    return NO;
}

// Works for standard stem types, which are sort of useless.
// However, it is also overriden by the fraction subclass
// which also checks its linethickness to see if it is 0.0 and if so, returns YES.
- (BOOL)isBinomialStemType
{
    if (self.stemType == stemTypeBinomial)
        return YES;

    return NO;
}

- (BOOL)isLargeOpStemType
{
    if (self.hasLargeOp == NO)
        return NO;

    if (self.stemType == stemTypeSup || self.stemType == stemTypeSub || self.stemType == stemTypeSubSup
        || self.stemType == stemTypeUnder || self.stemType == stemTypeOver || self.stemType == stemTypeUnderOver)
    {
        return YES;
    }

    return NO;
}


- (BOOL)hasOnlyChildrenOfType: (EQRenderStemType)stemType
{
    if (self.renderArray.count > 0)
    {
        for (id childObj in self.renderArray)
        {
            if ([childObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderStem *childStem = (EQRenderStem *)childObj;
                if (childStem.stemType != stemType)
                {
                    return NO;
                }
            }
        }
        return YES;
    }

    return NO;
}

- (BOOL)hasOnlyRenderDataChildren
{
    if (nil == self.renderArray || self.renderArray.count == 0)
        return NO;

    for (id childObj in self.renderArray)
    {
        if (![childObj isKindOfClass:[EQRenderData class]])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)testRowRenderChildren
{
    if (self.stemType != stemTypeRow)
    {
        return [self hasOnlyRenderDataChildren];
    }

    for (id childObj in self.renderArray)
    {
        if ([childObj isKindOfClass:[EQRenderStem class]])
        {
            BOOL test = [(EQRenderStem *)childObj hasOnlyRenderDataChildren];
            if (test == NO)
            {
                return test;
            }
        }
    }
    return YES;
}

// Used to return the parent fraction if your stem is a numerator or denominator.
// Or parent of parent in case of a nested row numerator.
// Returns nil otherwise.
- (id)getFractionBarParent
{
    if (nil != self.parentStem)
    {
        if (self.parentStem.stemType == stemTypeFraction)
            return self.parentStem;
        else if (self.parentStem.stemType == stemTypeRow)
            return [self.parentStem getFractionBarParent];
    }
    return nil;
}

- (id)getNRootParent
{
    if (nil != self.parentStem)
    {
        if (self.parentStem.stemType == stemTypeSqRoot || self.parentStem.stemType == stemTypeNRoot)
            return self.parentStem;
        else if (self.parentStem.stemType == stemTypeRow)
            return [self.parentStem getNRootParent];
    }
    return nil;
}

- (BOOL)isSupStemType
{
    if (self.stemType == stemTypeSup || self.stemType == stemTypeSubSup)
    {
        return TRUE;
    }

    return FALSE;
}


- (BOOL)hasChildType: (EQRenderStemType)stemType
{
    if (self.renderArray.count > 0)
    {
        for (id childObj in self.renderArray)
        {
            if ([childObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderStem *childStem = (EQRenderStem *)childObj;
                if (childStem.stemType == stemType)
                {
                    return YES;
                }
                else if (childStem.stemType == stemTypeRow)
                {
                    BOOL childTest = [childStem hasChildType:stemType];
                    if (childTest == YES)
                        return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)checkSupNestingInStemWithLevel: (NSUInteger)nestLevel
{
    NSUInteger useLevel = 2;
    if (self.stemType == stemTypeRow || (nil != self.parentStem && self.parentStem.stemType == stemTypeRow))
        useLevel = 3;

    if (nestLevel > useLevel)
        return YES;

    if ([self hasChildType:stemTypeSup] || [self hasChildType:stemTypeSubSup])
    {
        for (id childObj in self.renderArray)
        {
            if ([childObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderStem *childStem = (EQRenderStem *)childObj;
                if ([childStem isSupStemType] || childStem.stemType == stemTypeRow)
                {
                    if ([childStem checkSupNestingInStemWithLevel:(nestLevel + 1)])
                        return YES;
                }
            }
        }
    }
    return NO;
}


// Used to help fractions adjust their numerator or denominator.
// Some layout accounts for descenders in the stem and should not be also
// accounted for when laying the fractions out.
// This is important for nested sups 3 levels or more, but should return no for non-nested sups or nested 2 deep.
- (BOOL)shouldIgnoreDescent
{
    BOOL shouldCheck = self.stemType == stemTypeSup || self.stemType == stemTypeRow || self.stemType == stemTypeSubSup;
    if (shouldCheck == NO)
        return NO;

    return [self checkSupNestingInStemWithLevel:0];
}


// Used to check for bracers that may need to be scaled up.
// For now, it only cares about the base of subs and sups.
// Returns the string if it has a match or nil if not.
- (id)checkStretchyBracerUseAttributed: (BOOL)useAttributed
{
    EQRenderData *baseData = [self checkStretchyRenderData];
    if (nil != baseData)
    {
        NSAttributedString *baseAttrStr = baseData.renderString;
        NSString *baseStr = baseAttrStr.string;
        NSSet *stretchyChars = [EQRenderTypesetter getStretchyBracerCharacters];
        if ([stretchyChars containsObject:baseStr])
        {
            if (useAttributed == YES)
            {
                return baseAttrStr;
            }
            else
            {
                return baseStr;
            }
        }
    }

    return nil;
}

// Returns the renderData from the correct location you need to check if it has a stretchy bracer.
- (EQRenderData *)checkStretchyRenderData
{
    if (self.renderArray == nil || self.renderArray.count < 2)
        return nil;

    if (self.isSupStemType || self.stemType == stemTypeSub)
    {
        id baseObj = self.renderArray[0];
        if ([baseObj isKindOfClass:[EQRenderData class]] && [(EQRenderData *)baseObj renderString].length > 0)
        {
            return baseObj;
        }
    }

    return nil;
}

// Syntactic sugar functions for checking the stretchy bracer of a stem.
- (NSString *)nestedStretchyBracerCheck
{
    return [self checkStretchyBracerUseAttributed:NO];
}

- (NSAttributedString *)nestedAttributedStretchyBracerCheck
{
    return [self checkStretchyBracerUseAttributed:YES];
}

// Sends reset message to the data at the expected stretchy location.
// Doesn't care if that is nil as nothing happens.
- (void)resetNestedStretchyData
{
    EQRenderData *baseData = [self checkStretchyRenderData];
    [baseData resetStretchyCharacterData];
}



// Used mostly to handle descenders and such.
- (CGFloat)computeWidthAdjustmentFor: (EQRenderData *)drawData
                     withAdjustDelta: (CGFloat)adjustDelta
                    rightBracketTest: (BOOL)useBaseIsRightBracket
{
    CGFloat adjustWidth = ABS(adjustDelta);

    if (useBaseIsRightBracket)
    {
        adjustWidth = 4.0;
    }
    else if (adjustWidth <= 1.5)
    {
        adjustWidth = 3.0;
    }
    else if (adjustWidth < 2.5)
    {
        adjustWidth = 2.0;
    }
    else
    {
        adjustWidth = 0.5;
    }

    // f and j are still too large. Adjust the size a bit more.
    if (drawData.imageBounds.size.height > 12.0)
    {
        adjustWidth += 1.0;
    }

    return adjustWidth;
}

// Used for unders and overs to do final horizontal layout.
- (void)centerChildrenHorizontally
{
    NSAssert(nil != self.renderArray, @"Must have a render array.");
    NSAssert(self.renderArray.count > 0, @"Must have children in the array.");

    CGFloat maxWidth = 0.0;
    CGFloat baseWidth = 0.0;
    NSUInteger counter = 0;
    BOOL maxIsStem = FALSE;

    // Find the max width of the subs and sups.
    // Find the width of the base.
    for (id drawObj in self.renderArray)
    {
        CGSize testSize = CGSizeZero;
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *drawData = (EQRenderData *)drawObj;
            testSize = drawData.boundingRectImage.size;
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *drawStem = (EQRenderStem *)drawObj;
            testSize = drawStem.drawSize;
        }

        if (counter == 0)
        {
            baseWidth = testSize.width;
        }
        else
        {
            CGFloat testWidth = MAX(testSize.width, 3.0);
            maxWidth = MAX(maxWidth, testWidth);
            if (maxWidth == testWidth)
            {
                maxIsStem = [drawObj isKindOfClass:[EQRenderStem class]];
            }
        }
        counter ++;
    }

    // Find the overall max width.
    maxWidth = MAX(baseWidth, maxWidth);

    // Reset the counter and do adjustments of the xLocs.
    counter = 0;
    for (id drawObj in self.renderArray)
    {
        if ([drawObj respondsToSelector:@selector(drawOrigin)]
            && [drawObj respondsToSelector:@selector(setDrawOrigin:)])
        {
            CGSize testSize = CGSizeZero;
            if ([drawObj isKindOfClass:[EQRenderData class]])
            {
                EQRenderData *drawData = (EQRenderData *)drawObj;
                testSize = drawData.boundingRectImage.size;
            }
            else if ([drawObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderStem *drawStem = (EQRenderStem *)drawObj;
                testSize = drawStem.drawSize;
            }

            CGFloat xAdjust = 0.0;
            CGFloat newXLoc = self.drawOrigin.x;

            if (counter == 0)
            {
                xAdjust = (maxWidth - baseWidth) * 0.5;
                if (maxIsStem)
                {
                    xAdjust -= 6.0;
                }
                else if (self.hasLargeOp == YES)
                {
                    xAdjust -= 1.0;
                }
                newXLoc = [drawObj drawOrigin].x;
            }
            else
            {
                xAdjust = (maxWidth - testSize.width) * 0.5;

                if (self.hasLargeOp == NO)
                {
                    if (xAdjust <= 1.5 && self.stemType == stemTypeOver)
                    {
                        xAdjust = 3.5;
                    }
                    if (xAdjust < 2.0)
                    {
                        xAdjust = 0.0;
                    }
                    else if (xAdjust < 4.0)
                    {
                        xAdjust = 1.0;
                    }
                }
            }

            newXLoc += xAdjust;

            CGPoint testOrigin = [drawObj drawOrigin];
            testOrigin.x = newXLoc;
            [drawObj setDrawOrigin:testOrigin];
            if ([drawObj respondsToSelector:@selector(layoutChildren)])
            {
                [drawObj layoutChildren];
            }
        }
        counter ++;
    }
}

// Shift entire layout by xAdjust.
- (void)shiftLayoutHorizontally:(CGFloat)xAdjust
{
    for (id drawObj in self.renderArray)
    {
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            [(EQRenderData *)drawObj shiftLayoutHorizontally:xAdjust];
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *drawStem = (EQRenderStem *)drawObj;
            [drawStem shiftLayoutHorizontally:xAdjust];
        }
    }
    CGPoint stemOrigin = self.drawOrigin;
    stemOrigin.x += xAdjust;
    self.drawOrigin = stemOrigin;

    if (self.hasSupplementaryData && [self.supplementaryData isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *suppleData = (EQRenderData *)self.supplementaryData;
        CGPoint drawOrigin = suppleData.drawOrigin;
        drawOrigin.x += xAdjust;
        suppleData.drawOrigin = drawOrigin;
    }

    if (self.hasSupplementalLine)
    {
        CGPoint lineStart = self.supplementalLineStartPoint;
        CGPoint lineEnd = self.supplementalLineEndPoint;
        lineStart.x += xAdjust;
        lineEnd.x += xAdjust;
        self.supplementalLineStartPoint = lineStart;
        self.supplementalLineEndPoint = lineEnd;
    }

    if (self.hasOverline)
    {
        CGPoint lineStart = self.overlineStartPoint;
        CGPoint lineEnd = self.overlineEndPoint;
        lineStart.x += xAdjust;
        lineEnd.x += xAdjust;
        self.overlineStartPoint = lineStart;
        self.overlineEndPoint = lineEnd;
    }
}

// Shift internal layout only. Usually called from root parent being adjusted.
- (void)shiftChildrenHorizontally:(CGFloat)xAdjust
{
    for (id drawObj in self.renderArray)
    {
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            [(EQRenderData *)drawObj shiftLayoutHorizontally:xAdjust];
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *drawStem = (EQRenderStem *)drawObj;
            [drawStem shiftLayoutHorizontally:xAdjust];
        }
    }
}

- (void)shiftChildrenAfter: (id)startChild horizontally: (CGFloat)xAdjust inclusive: (BOOL)inclusive
{
    NSUInteger childLoc = [self getLocForChild:startChild];
    if (childLoc == NSNotFound || childLoc + 1 >= self.renderArray.count)
        return;

    int startLoc = 1;
    if (inclusive == YES)
        startLoc = 0;

    for (NSUInteger i = childLoc + startLoc; i < self.renderArray.count; i++)
    {
        id drawObj = [self.renderArray objectAtIndex:i];
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            [(EQRenderData *)drawObj shiftLayoutHorizontally:xAdjust];
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)drawObj shiftLayoutHorizontally:xAdjust];
        }
    }
}

- (void)shiftChildrenAfter: (id)startChild horizontally: (CGFloat)xAdjust
{
    [self shiftChildrenAfter:startChild horizontally:xAdjust inclusive:NO];
}

// Should just add the data correctly, but it may need more testing.
- (void) addChildDataToRenderArray: (NSMutableArray *)renderData
{
    if (nil != self.renderArray && self.renderArray.count > 0)
    {
        for (id renderObj in self.renderArray)
        {
            if ([renderObj isKindOfClass:[EQRenderData class]])
            {
                [renderData addObject:renderObj];
            }
            else if ([renderObj isKindOfClass:[EQRenderStem class]])
            {
                [(EQRenderStem *)renderObj addChildDataToRenderArray:renderData];
            }
        }
        if (self.hasSupplementaryData && [self.supplementaryData isKindOfClass:[EQRenderData class]])
        {
            [renderData addObject:self.supplementaryData];
        }
    }
}


- (CGPoint)findChildOverlinePoint
{
    CGPoint returnOverline = CGPointZero;
    if (self.hasOverline)
    {
        //Assume the start and end points have the same yCoord.
        returnOverline = self.overlineStartPoint;
    }

    // Recursively search through child stems.
    // Return the point with the lowest y coord (which draws highest).
    for (id renderObj in self.renderArray)
    {
        if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *renderStem = (EQRenderStem *)renderObj;
            if (renderStem.hasOverline)
            {
                CGPoint testOverline = [renderStem findChildOverlinePoint];
                if (CGPointEqualToPoint(returnOverline, CGPointZero))
                {
                    returnOverline = testOverline;
                }
                else if (testOverline.y < returnOverline.y)
                {
                    returnOverline = testOverline;
                }
            }
        }
    }

    return returnOverline;
}

- (CGPoint)findChildDescenderPoint
{
    CGPoint returnDescender = CGPointZero;
    for (id renderObj in self.renderArray)
    {
        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderData = (EQRenderData *)renderObj;
            if ([renderData containsStretchyDescenders])
            {
                NSArray *stretchyDescenders = [renderData getStretchyDescenders];
                for (id stretchyObj in stretchyDescenders)
                {
                    if ([stretchyObj respondsToSelector:@selector(hasStretchyDescenderPoint)] && [stretchyObj hasStretchyDescenderPoint] == YES
                        && [stretchyObj respondsToSelector:@selector(stretchyDescenderPoint)])
                    {
                        CGPoint testPoint = [stretchyObj stretchyDescenderPoint];
                        if (CGPointEqualToPoint(returnDescender, CGPointZero) || testPoint.y > returnDescender.y)
                        {
                            returnDescender = testPoint;
                        }
                    }
                }
            }
        }
        else if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            CGPoint testPoint = [(EQRenderStem *)renderObj findChildDescenderPoint];
            if (CGPointEqualToPoint(returnDescender, CGPointZero) || testPoint.y > returnDescender.y)
            {
                returnDescender = testPoint;
            }
        }
    }

    return returnDescender;
}


// Should just remove the data correctly, but may need more testing.
- (void)removeChildDataFromRenderArray: (NSMutableArray *)renderData
{
    if (nil != self.renderArray && self.renderArray.count > 0)
    {
        for (id renderObj in self.renderArray)
        {
            if ([renderObj isKindOfClass:[EQRenderData class]])
            {
                [renderData removeObject:renderObj];
            }
            else if ([renderObj isKindOfClass:[EQRenderStem class]])
            {
                [(EQRenderStem *)renderObj removeChildDataFromRenderArray:renderData];
            }
        }
        if (self.hasSupplementaryData && [self.supplementaryData isKindOfClass:[EQRenderData class]])
        {
            [renderData removeObject:self.supplementaryData];
        }
    }
}


/************************
 NSCoding support methods
 ************************/

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // You should preserve more than is absolutely needed.
    // That way instead of rebuilding the data using methods, you just unpack it.

    // Also, some version information will be helpful,
    // though you will need a plan to actually parse that information at some point if you want to help keep forward compatability.
    [aCoder encodeObject:@(1.0) forKey:@"RenderStemVersionNumber"];

    // Render data.
    // Anything stored in the array *must* also support NSCoding for this to work.
    [aCoder encodeObject:self.renderArray forKey:@"renderArray"];

    // Drawing data.
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.drawOrigin] forKey:@"drawOrigin"];
    [aCoder encodeObject:[NSValue valueWithCGSize:self.drawSize] forKey:@"drawSize"];
    [aCoder encodeObject:[NSValue valueWithCGRect:self.drawBounds] forKey:@"drawBounds"];

    // Parent stem.
    // Should be conditional as it is a weak reference.
    [aCoder encodeConditionalObject:self.parentStem forKey:@"parentStem"];

    // Stem type.
    // Just have it convert the type number into a string value.
    [aCoder encodeObject:[self stringForStemType:self.stemType] forKey:@"stemType"];

    // Value that stores whether the stem root is a large op.
    [aCoder encodeObject:@(self.hasLargeOp) forKey:@"hasLargeOp"];

    // Value that stores whether the stem has supplementary string.
    // Like a radical or other special characters.
    [aCoder encodeObject:@(self.hasSupplementaryData) forKey:@"hasSupplementaryData"];

    // The actual data is stored in an unknown type in order to allow for arrays with multiple renderData later on.
    // Fortunately, arrays also support nscoding, so it should work just fine.
    if (nil != self.supplementaryData && [self.supplementaryData conformsToProtocol:@protocol(NSCoding)])
    {
        [aCoder encodeObject:self.supplementaryData forKey:@"supplementaryData"];
    }

    // Value that stores whether the stem has an overline to draw.
    // Used for radicals, mainly.
    [aCoder encodeObject:@(self.hasOverline) forKey:@"hasOverline"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.overlineStartPoint] forKey:@"overlineStartPoint"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.overlineEndPoint] forKey:@"overlineEndPoint"];

    [aCoder encodeObject:@(self.hasSupplementalLine) forKey:@"hasSupplementalLine"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.supplementalLineStartPoint] forKey:@"supplementalLineStartPoint"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.supplementalLineEndPoint] forKey:@"supplementalLineEndPoint"];

    [aCoder encodeObject:@(self.hasStoredCharacterData) forKey:@"hasStoredCharacterData"];
    [aCoder encodeObject:self.storedCharacterData forKey:@"storedCharacterData"];
    [aCoder encodeObject:@(self.hasAccentCharacter) forKey:@"hasAccentCharacter"];
    [aCoder encodeObject:@(self.useAlign) forKey:@"useAlign"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self)
    {
        NSNumber *versionNumber = [aDecoder decodeObjectForKey:@"RenderStemVersionNumber"];
        if (nil != versionNumber && versionNumber.doubleValue >= 1.0 && versionNumber.doubleValue < 2.0)
        {
            // Render data.
            // Anything stored in the array *must* also support NSCoding for this to work.
            self->_renderArray = [aDecoder decodeObjectForKey:@"renderArray"];

            // Drawing data.
            self->_drawOrigin = [(NSValue *)[aDecoder decodeObjectForKey:@"drawOrigin"] CGPointValue];
            self->_drawSize = [(NSValue *)[aDecoder decodeObjectForKey:@"drawSize"] CGSizeValue];
            self->_drawBounds = [(NSValue *)[aDecoder decodeObjectForKey:@"drawBounds"] CGRectValue];

            // Parent stem.
            // Should be conditional as it is a weak reference.
            self->_parentStem = [aDecoder decodeObjectForKey:@"parentStem"];

            // Stem type.
            // Just have it convert the type given into a type value.
            self->_stemType = [self stemTypeWithString:[aDecoder decodeObjectForKey:@"stemType"]];

            // Value that stores whether the stem root is a large op.
            self->_hasLargeOp = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasLargeOp"] boolValue];

            // Value that stores whether the stem has supplementary string.
            // Like a radical or other special characters.
            self->_hasSupplementaryData = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasSupplementaryData"] boolValue];

            // The actual data is stored in an unknown type in order to allow for arrays with multiple renderData later on.
            // Fortunately, arrays also support nscoding, so it should work just fine.
            self->_supplementaryData = [aDecoder decodeObjectForKey:@"supplementaryData"];

            // Value that stores whether the stem has an overline to draw.
            // Used for radicals, mainly.
            self->_hasOverline = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasOverline"] boolValue];
            self->_overlineStartPoint = [(NSValue *)[aDecoder decodeObjectForKey:@"overlineStartPoint"] CGPointValue];
            self->_overlineEndPoint = [(NSValue *)[aDecoder decodeObjectForKey:@"overlineEndPoint"] CGPointValue];

            self->_hasSupplementalLine = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasSupplementalLine"] boolValue];
            self->_supplementalLineStartPoint = [(NSValue *)[aDecoder decodeObjectForKey:@"supplementalLineStartPoint"] CGPointValue];
            self->_supplementalLineEndPoint = [(NSValue *)[aDecoder decodeObjectForKey:@"supplementalLineEndPoint"] CGPointValue];

            self->_hasStoredCharacterData = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasStoredCharacterData"] boolValue];
            self->_storedCharacterData = [aDecoder decodeObjectForKey:@"storedCharacterData"];
            NSNumber *useAlignNum = [aDecoder decodeObjectForKey:@"useAlign"];
            if (nil != useAlignNum)
            {
                self->_useAlign = [useAlignNum intValue];
            }
            else
            {
                self->_useAlign = viewAlignAuto;
            }

            NSNumber *hasAccentNum = [aDecoder decodeObjectForKey:@"hasAccentCharacter"];
            if (nil != hasAccentNum)
            {
                self->_hasAccentCharacter = [hasAccentNum boolValue];
            }
            else
            {
                self->_hasAccentCharacter = NO;
            }
        }
    }

    return self;
}

// Used internally to code and decode the stem type as a string.
- (NSString *)stringForStemType: (EQRenderStemType)stemType
{
    if (stemType == stemTypeUnassigned)
    {
        return @"stemTypeUnassigned";
    }
    else if (stemType == stemTypeRoot)
    {
        return @"stemTypeRoot";
    }
    else if (stemType == stemTypeRow)
    {
        return @"stemTypeRow";
    }
    else if (stemType == stemTypeSup)
    {
        return @"stemTypeSup";
    }
    else if (stemType == stemTypeSub)
    {
        return @"stemTypeSub";
    }
    else if (stemType == stemTypeSubSup)
    {
        return @"stemTypeSubSup";
    }
    else if (stemType == stemTypeFraction)
    {
        return @"stemTypeFraction";
    }
    else if (stemType == stemTypeBinomial)
    {
        return @"stemTypeBinomial";
    }
    else if (stemType == stemTypeUnder)
    {
        return @"stemTypeUnder";
    }
    else if (stemType == stemTypeOver)
    {
        return @"stemTypeOver";
    }
    else if (stemType == stemTypeUnderOver)
    {
        return @"stemTypeUnderOver";
    }
    else if (stemType == stemTypeSqRoot)
    {
        return @"stemTypeSqRoot";
    }
    else if (stemType == stemTypeNRoot)
    {
        return @"stemTypeNRoot";
    }
    else if (stemType == stemTypeMatrixCell)
    {
        return @"stemTypeMatrixCell";
    }
    else if (stemType == stemTypeMatrixRow)
    {
        return @"stemTypeMatrixRow";
    }
    else if (stemType == stemTypeMatrix)
    {
        return @"stemTypeMatrix";
    }

    return @"stemTypeUnassigned";
}

- (EQRenderStemType) stemTypeWithString: (NSString *)typeString
{
    if ([typeString isEqualToString:@"stemTypeUnassigned"])
    {
        return stemTypeUnassigned;
    }
    else if ([typeString isEqualToString:@"stemTypeRoot"])
    {
        return stemTypeRoot;
    }
    else if ([typeString isEqualToString:@"stemTypeRow"])
    {
        return stemTypeRow;
    }
    else if ([typeString isEqualToString:@"stemTypeSup"])
    {
        return stemTypeSup;
    }
    else if ([typeString isEqualToString:@"stemTypeSub"])
    {
        return stemTypeSub;
    }
    else if ([typeString isEqualToString:@"stemTypeSubSup"])
    {
        return stemTypeSubSup;
    }
    else if ([typeString isEqualToString:@"stemTypeFraction"])
    {
        return stemTypeFraction;
    }
    else if ([typeString isEqualToString:@"stemTypeBinomial"])
    {
        return stemTypeBinomial;
    }
    else if ([typeString isEqualToString:@"stemTypeUnder"])
    {
        return stemTypeUnder;
    }
    else if ([typeString isEqualToString:@"stemTypeOver"])
    {
        return stemTypeOver;
    }
    else if ([typeString isEqualToString:@"stemTypeUnderOver"])
    {
        return stemTypeUnderOver;
    }
    else if ([typeString isEqualToString:@"stemTypeSqRoot"])
    {
        return stemTypeSqRoot;
    }
    else if ([typeString isEqualToString:@"stemTypeNRoot"])
    {
        return stemTypeNRoot;
    }
    else if ([typeString isEqualToString:@"stemTypeMatrixCell"])
    {
        return stemTypeMatrixCell;
    }
    else if ([typeString isEqualToString:@"stemTypeMatrixRow"])
    {
        return stemTypeMatrixRow;
    }
    else if ([typeString isEqualToString:@"stemTypeMatrix"])
    {
        return stemTypeMatrix;
    }

    return stemTypeUnassigned;
}

@end

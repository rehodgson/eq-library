//
//  EQRenderEquation.m
//  EQ Writer 2
//
//  Created by Raymond Hodgson on 10/2/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <CoreText/CoreText.h>
#import "EQRenderEquation.h"
#import "EQRenderData.h"
#import "EQRenderStretchyBracers.h"
#import "EQRenderFracStem.h"
#import "EQRenderFontDictionary.h"
#import "EQRenderTypesetter.h"

@interface EQRenderEquation()

@property (strong, nonatomic) NSMutableArray *equationLayoutData;

@end

@implementation EQRenderEquation

- (id)init
{
    self = [super init];
    if (self)
    {
        self->_equationLines = [[NSMutableArray alloc] init];
        self->_equationStems = [[NSMutableArray alloc] init];
        self->_equationLayoutData = [[NSMutableArray alloc] init];
        self->_usePDFMode = NO;
        self->_pdfScale = 1.0;
        self->_drawSize = CGSizeZero;
        self->_shouldFlipContext = NO;
    }
    return self;
}

- (id)initWithEquationLines: (NSArray *)equationLines andEquationStems: (NSArray *)equationStems
{
    self = [super init];
    if (self)
    {
        if (nil != equationLines)
        {
            self->_equationLines = [[NSMutableArray alloc] initWithArray:equationLines];
        }
        else
        {
            self->_equationLines = nil;
        }

        if (nil != equationStems)
        {
            self->_equationStems = [[NSMutableArray alloc] initWithArray:equationStems];
        }
        else
        {
            self->_equationStems = nil;
        }

        self->_equationLayoutData = [[NSMutableArray alloc] init];
        self->_usePDFMode = NO;
        self->_pdfScale = 1.0;
        self->_drawSize = CGSizeZero;
    }

    return self;
}

- (CGSize)computeInlineSize
{
    if (nil == self.equationLines || self.equationLines.count == 0)
        return CGSizeZero;

    CGSize trackSize = CGSizeZero;

    for (NSArray *renderArray in self.equationLines)
    {
        for (EQRenderData *renderData in renderArray)
        {
            CGRect useBounds = renderData.imageBounds;
            trackSize.width += useBounds.size.width;
            trackSize.height = MAX(trackSize.height, useBounds.size.height);
        }
    }

    return trackSize;
}


// Computes the rect needed to enclose all of the renderData.
- (CGRect)getBoundingFrameWithData: (NSArray *)dataArray
{
    if (nil == dataArray || dataArray.count == 0)
        return CGRectNull;

    CGRect returnRect = CGRectMake(0.0, 0.0, 44.0, 10.0);
    for (EQRenderData *renderData in dataArray)
    {
        // Get the geometric data.
        CGPoint useOrigin = renderData.drawOrigin;
        CGRect useBounds;
        if (renderData.hasStretchyCharacterData)
        {
            useBounds = renderData.imageBoundsWithStretchyData;
        }
        else
        {
            useBounds = renderData.imageBounds;
        }
        useBounds.origin = useOrigin;

        // Use the smallest amount as the enclosing origin.
        useOrigin.x = MIN(returnRect.origin.x, useOrigin.x);
        useOrigin.y = MIN(returnRect.origin.y, useOrigin.y);

        // Compute the X and Y enclosing locations.
        CGFloat maxX = CGRectGetMaxX(useBounds);
        CGFloat maxY = CGRectGetMaxY(useBounds);

        // Increase the return rect width, if needed.
        if ((useOrigin.x + returnRect.size.width) < maxX)
        {
            returnRect.size.width += maxX - (useOrigin.x + returnRect.size.width);
        }

        // Increase the return rect height, if needed.
        if ((useOrigin.y + returnRect.size.height) < maxY)
        {
            returnRect.size.height += maxY - (useOrigin.y + returnRect.size.height);
        }
    }
    return returnRect;
}

- (void)layoutEquationLines
{
    CGPoint trackOrigin = CGPointZero;
    CGSize trackSize = CGSizeZero;
    int equationLineCounter = 0;

    NSMutableArray *offsetArray = [[NSMutableArray alloc] init];
    NSMutableArray *leftArray = [[NSMutableArray alloc] init];

    for (NSArray *equationLine in self.equationLines)
    {
        CGRect viewFrame = [self getBoundingFrameWithData:equationLine];
        CGFloat storedAlignOffset = 0.0;
        RenderViewAlign storedAlignment = viewAlignAuto;

        if (equationLineCounter < self.equationLayoutData.count)
        {
            NSArray *equationLayoutArray = self.equationLayoutData[equationLineCounter];
            NSValue *equationLineFrame = equationLayoutArray[0];
            viewFrame = equationLineFrame.CGRectValue;

            NSNumber *equationViewAlign = equationLayoutArray[2];
            storedAlignment = equationViewAlign.intValue;
        }

        if (CGPointEqualToPoint(trackOrigin, CGPointZero))
        {
            trackOrigin = viewFrame.origin;
            // This can happen if you have removed the original first line
            // and need to adjust the position of the new equation line.
            if (roundf(trackOrigin.y) != 20.0)
            {
                trackOrigin.y = 20.0;
            }
        }

        storedAlignOffset = 0.0;
        CGFloat xOffset = [self findAlignOffsetForEquationLine:equationLine];
        if (storedAlignment == viewAlignAuto && xOffset != 0)
        {
            xOffset = floorf(xOffset);
            NSArray *offsetData = @[@(equationLineCounter), @(xOffset)];
            [offsetArray addObject:offsetData];
        }
        else
        {
            [leftArray addObject:@(equationLineCounter)];
        }

        if (equationLineCounter == 0)
        {
            trackOrigin.y += 20.0;
        }
        viewFrame.origin = trackOrigin;
        viewFrame.origin.y = roundf(viewFrame.origin.y);
        CGRect storedViewFrame = viewFrame;
        trackOrigin.y += viewFrame.size.height;
        trackSize.height += viewFrame.size.height;
        trackSize.width = MAX(trackSize.width, (viewFrame.origin.x + viewFrame.size.width + 0.5 * xOffset));

        NSArray *updatedLayoutArray = @[[NSValue valueWithCGRect:storedViewFrame], @(storedAlignOffset), @(storedAlignment)];
        self.equationLayoutData[equationLineCounter] = updatedLayoutArray;

        equationLineCounter ++;
    }

    if (leftArray.count > 0)
    {
        [self setAlignmentLeftWithArray:leftArray];
    }

    if (offsetArray.count > 0)
    {
        [self adjustAlignmentWithArray:offsetArray];
    }

    trackSize.width = ceilf(trackSize.width);
    trackSize.height = ceilf(trackSize.height);

    if (trackSize.width < 40.0)
    {
        trackSize.width = 40.0;
    }

    if (trackSize.height < 40.0)
    {
        trackSize.height = 40.0;
    }
/*
    // You need to add some to the height to account for the fact that the origin is in the top left,
    // but the equation's origin is not otherwise you will fail to hit test equations at the bottom of the view.
    trackSize.width += 40.0;
    trackSize.height += 40.0;
*/
    self.drawSize = trackSize;
}

- (void)drawEquationLinesInRect:(CGRect)useRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Return if unable to create the context for some reason.
    if (context == NULL || context == nil)
    {
        return;
    }

    if (CGSizeEqualToSize(self.drawSize, CGSizeZero))
    {
        [self layoutEquationLines];
    }

    CGContextSetShouldAntialias(context, YES);
    CGContextSetShouldSmoothFonts(context, YES);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, useRect.origin.x, useRect.origin.y);
    CGContextScaleCTM(context, self.pdfScale, self.pdfScale);

    int viewCounter = 0;
    CGFloat heightDelta = -10.0;
    CGFloat widthDelta = 30.0;

    for (NSArray *equationLine in self.equationLines)
    {
        NSArray *equationLayoutArray = self.equationLayoutData[viewCounter];
        if (nil == equationLayoutArray)
            continue;

        NSValue *equationLineFrame = equationLayoutArray[0];
        CGRect viewFrame = equationLineFrame.CGRectValue;

        CGRect curRect = viewFrame;
        curRect.origin.y -= heightDelta;
        curRect.origin.x += widthDelta;
        curRect = CGRectIntegral(curRect);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, curRect.origin.x, curRect.origin.y);

        [self drawSingleLine:equationLine];

        CGContextRestoreGState(context);
        viewCounter ++;
    }
    CGContextRestoreGState(context);
}

- (void)drawSingleLine: (NSArray *)equationLine
{
    // Flip context.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGFloat contextCoeff = 1.0;
    if (self.shouldFlipContext)
    {
        CGContextScaleCTM(context, 1.0, -1.0);
        contextCoeff = -1.0;
    }

    // Loop through the render array and draw each render data.
    // Store rendered fracStems so you don't repeatedly draw lines for the same one.
    NSMutableArray *fracArray = [[NSMutableArray alloc] initWithCapacity:equationLine.count];
    NSMutableArray *nRootArray = [[NSMutableArray alloc] initWithCapacity:equationLine.count];

    for (EQRenderData *viewRenderData in equationLine)
    {
        NSAttributedString *renderString = viewRenderData.renderString;

        if (nil != renderString && renderString.length > 0)
        {
            // Retrieve the drawPoint as well.
            CGPoint drawPoint = viewRenderData.drawOrigin;
            if (self.shouldFlipContext)
            {
                drawPoint.y *= contextCoeff;
            }

            // Check to see if any of the characters need to be replaced with stretchy equivalents.
            // May need to expand this for extender character data.
            if (viewRenderData.hasStretchyCharacterData == YES)
            {
                renderString = [viewRenderData renderStringWithStretchyCharacters];
            }
            [self drawRenderString:renderString atPoint:drawPoint inContext:context];
            viewRenderData.needsRedrawn = NO;
        }
        if ([viewRenderData containsStretchyDescenders] == YES)
        {
            NSArray *stretchyDescenders = [viewRenderData getStretchyDescenders];
            if (nil != stretchyDescenders && stretchyDescenders.count > 0)
            {
                // It checks the type of the object and acts accordingly.
                for (id stretchyDescenderObj in stretchyDescenders)
                {
                    if ([stretchyDescenderObj isKindOfClass:[EQRenderData class]])
                    {
                        EQRenderData *stretchyDescenderData = (EQRenderData *)stretchyDescenderObj;
                        NSAttributedString *stretchyStr = stretchyDescenderData.renderString;
                        CGPoint stretchyDrawPoint = stretchyDescenderData.stretchyDescenderPoint;
                        stretchyDrawPoint.x = stretchyDescenderData.drawOrigin.x;
                        if (self.shouldFlipContext)
                        {
                            stretchyDrawPoint.y *= contextCoeff;
                        }

                        [self drawRenderString:stretchyStr atPoint:stretchyDrawPoint inContext:context];
                    }
                    else if ([stretchyDescenderObj isKindOfClass:[EQRenderStretchyBracers class]])
                    {
                        EQRenderStretchyBracers *stretchyBracerData = (EQRenderStretchyBracers *)stretchyDescenderObj;
                        NSArray *stretchyDrawArray = [stretchyBracerData stretchyDrawArrayInContext:context];
                        if (nil != stretchyDrawArray)
                        {
                            for (NSArray *drawArray in stretchyDrawArray)
                            {
                                NSAttributedString *stretchyStr = drawArray[0];
                                CGPoint stretchyDrawPoint = [(NSValue *)drawArray[1] CGPointValue];
                                if (self.shouldFlipContext)
                                {
                                    stretchyDrawPoint.y *= contextCoeff;
                                }
                                [self drawRenderString:stretchyStr atPoint:stretchyDrawPoint inContext:context];
                            }
                        }
                    }
                }
            }
        }
        if (viewRenderData.usesStretchyExtenders == YES)
        {
            NSArray *stretchyExtenders = [viewRenderData getStretchyExtenders];
            if (nil != stretchyExtenders && stretchyExtenders.count > 0)
            {
                // It checks the type of the object and acts accordingly.
                for (id stretchyDescenderObj in stretchyExtenders)
                {
                    // Don't bother checking for renderData as they should not be mixed here.
                    if ([stretchyDescenderObj isKindOfClass:[EQRenderStretchyBracers class]])
                    {
                        EQRenderStretchyBracers *stretchyBracerData = (EQRenderStretchyBracers *)stretchyDescenderObj;
                        NSArray *stretchyDrawArray = [stretchyBracerData stretchyDrawArrayInContext:context];
                        if (nil != stretchyDrawArray)
                        {
                            for (NSArray *drawArray in stretchyDrawArray)
                            {
                                NSAttributedString *stretchyStr = drawArray[0];
                                CGPoint stretchyDrawPoint = [(NSValue *)drawArray[1] CGPointValue];
                                stretchyDrawPoint.y += viewRenderData.drawOrigin.y;
                                if (self.shouldFlipContext)
                                {
                                    stretchyDrawPoint.y *= contextCoeff;
                                }
                                [self drawRenderString:stretchyStr atPoint:stretchyDrawPoint inContext:context];
                            }
                        }
                    }
                }
            }
        }
        if (nil != [viewRenderData getFractionBarParent])
        {
            EQRenderFracStem *fracParent = (EQRenderFracStem *)[viewRenderData getFractionBarParent];
            if (fracParent.lineThickness > 0.0 && ![fracArray containsObject:fracParent])
            {
                [fracArray addObject:fracParent];

                // Test for collision. An edge case caused by a resize adjustment in the first frac you add.
                // Should only use first child.

                CGPoint testPoint = fracParent.startLinePoint;
                if ([viewRenderData isEqual:[fracParent getFirstChild]] && testPoint.y < viewRenderData.drawOrigin.y)
                {
                    testPoint.y = viewRenderData.drawOrigin.y + ABS(fracParent.drawOrigin.y - testPoint.y) + 4.0 * fracParent.lineThickness;
                }

                // Begin line draw.
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, floor(fracParent.startLinePoint.x), contextCoeff * floor(testPoint.y));
                CGContextAddLineToPoint(context, floor(fracParent.endLinePoint.x), contextCoeff * floor(testPoint.y));
                CGContextSetLineWidth(context, fracParent.lineThickness);
                CGContextSetCMYKStrokeColor(context, 0.0, 0.0, 0.0, 1.0, 1.0);
                CGContextStrokePath(context);
                // End line draw.
            }
        }
        if (nil != [viewRenderData getNRootParent])
        {
            EQRenderStem *nRootParent = (EQRenderStem *)[viewRenderData getNRootParent];
            if (![nRootArray containsObject:nRootParent] && nRootParent.hasOverline)
            {
                [nRootArray addObject:nRootParent];

                CGPoint suppleStart = nRootParent.supplementalLineStartPoint;
                CGPoint suppleEnd = nRootParent.supplementalLineEndPoint;
                CGPoint overLineStart = nRootParent.overlineStartPoint;
                CGPoint overLineEnd = nRootParent.overlineEndPoint;

                // May need to add another line to expand the radical symbol out a bit.
                if (nRootParent.hasSupplementalLine == YES)
                {
                    // These seem to be related to differences between the TTF and the OTF fonts.
                    // The radical doesn't match in the same place, though it could be something else.
                    if (self.usePDFMode == YES)
                    {
                        suppleStart.x -= 0.25;
                        overLineStart.y += 0.5;
                        overLineEnd.y += 0.5;
                    }
                    else
                    {
                        overLineStart.y = floorf(overLineStart.y);
                        overLineEnd.y = floorf(overLineEnd.y);
                    }
                    // Begin line draw.
                    CGContextMoveToPoint(context, suppleStart.x, contextCoeff * suppleStart.y);
                    CGContextAddLineToPoint(context, suppleEnd.x, contextCoeff * suppleEnd.y);
                    CGContextSetLineWidth(context, 1.25);
                    CGContextSetCMYKStrokeColor(context, 0.0, 0.0, 0.0, 1.0, 1.0);
                    CGContextStrokePath(context);
                    // End line draw.
                }

                // Begin line draw.
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, overLineStart.x, contextCoeff * overLineStart.y);
                CGContextAddLineToPoint(context, overLineEnd.x, contextCoeff * overLineEnd.y);
                CGContextSetLineWidth(context, 1.75);
                CGContextStrokePath(context);
                // End line draw.
            }
        }
    }
    CGContextRestoreGState(context);
}

- (void)drawRenderString:(NSAttributedString *)renderString atPoint: (CGPoint)drawPoint inContext: (CGContextRef)context
{
    if (nil != renderString && renderString.length > 0)
    {
        NSAttributedString *useRenderString = renderString;
        if (self.usePDFMode == YES)
        {
            useRenderString = [EQRenderFontDictionary convertAttributedStringForPDF:useRenderString];
        }
        // Create CTLine from attributed string.
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)useRenderString);
        CGContextSaveGState(context);

        // Draw the line at the given point.
        CGContextSetTextPosition(context, floor( drawPoint.x ), floor(drawPoint.y));
        CTLineDraw(line, context);
        CFRelease(line);

        CGContextRestoreGState(context);
    }
}

/**************************************
 * Equation Alignment support methods *
 **************************************/

- (CGFloat)findAlignOffsetForEquationLine: (NSArray *)equationLine
{
    CGFloat xOffset = 0;
    NSCharacterSet *equalityChars = [EQRenderTypesetter getEqualityCharacterSet];

    NSRange storedRange = NSMakeRange(NSNotFound, 0);
    EQRenderData *foundData = nil;

    for (id renderObj in equationLine)
    {
        // For now, naively grab the first item with a match.
        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderData = (EQRenderData *)renderObj;
            if (renderData.renderString == nil || renderData.renderString.length == 0)
                continue;

            NSRange testRange = [renderData.renderString.string rangeOfCharacterFromSet:equalityChars];
            // For now, we are only including children of root stems in the search.
            if (nil != renderData.parentStem && renderData.parentStem.stemType == stemTypeRoot && testRange.location != NSNotFound)
            {
                foundData = renderData;
                storedRange = testRange;
                break;
            }
        }
    }
    if (nil != foundData && storedRange.location != NSNotFound)
    {
        // Regular case, caret somewhere within our text content range.
        // Create CTLine from attributed string.
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)foundData.renderString);
        xOffset = CTLineGetOffsetForStringIndex(line, storedRange.location, NULL);
        CFRelease(line);
        xOffset += foundData.drawOrigin.x;
    }

    return xOffset;
}

- (void)adjustAlignmentWithArray: (NSMutableArray *)offsetArray
{
    if (nil == offsetArray || offsetArray.count == 0)
        return;

    CGFloat maxPosOffset = 6.0 * kDEFAULT_FONT_SIZE;
    CGFloat maxNegOffset = -2.25 * kDEFAULT_FONT_SIZE;

    NSMutableArray *alignDataArray = [[NSMutableArray alloc] init];
    NSMutableArray *alignPositions = [[NSMutableArray alloc] init];

    for (NSArray *alignData in offsetArray)
    {
        NSInteger viewTag = [(NSNumber *)alignData[0] integerValue];
        CGFloat xOffset = [(NSNumber *)alignData[1] floatValue];
        NSArray *equationLayoutArray = self.equationLayoutData[viewTag];
        if (nil == equationLayoutArray)
            return;

        if (alignPositions.count == 0)
        {
            // Update the array containing all views that are near each other.
            NSMutableArray *newDataArray = [[NSMutableArray alloc] initWithArray:@[alignData]];
            [alignDataArray addObject:newDataArray];

            // Update the align positions array with the current view data.
            [alignPositions addObject:alignData];
        }
        else
        {
            BOOL posMatches = NO;
            int posCounter = 0;

            for (NSArray *testAlignData in alignPositions)
            {
                NSInteger testTag = [(NSNumber *)testAlignData[0] integerValue];
                CGFloat testOffset = [(NSNumber *)testAlignData[1] floatValue];

                CGFloat locDelta = ABS(viewTag - testTag);
                CGFloat offsetDelta = testOffset - xOffset;
                if (locDelta < 2 && ((offsetDelta >= 0 && offsetDelta <= maxPosOffset) || (offsetDelta < 0 && offsetDelta >= maxNegOffset)))
                {
                    posMatches = YES;

                    // Update the array containing all views that are near each other.
                    NSMutableArray *updateDataArray = alignDataArray[posCounter];
                    [updateDataArray addObject:alignData];

                    // Update the align positions array with the current view tag.
                    alignPositions[posCounter] = @[@(viewTag), @(testOffset)];
                    break;
                }
                posCounter ++;
            }

            if (posMatches == NO)
            {
                // Update the array containing all views that are near each other.
                NSMutableArray *newDataArray = [[NSMutableArray alloc] initWithArray:@[alignData]];
                [alignDataArray addObject:newDataArray];

                // Update the align positions array with the current view data.
                [alignPositions addObject:alignData];
            }
        }
    }

    if (alignDataArray.count == 0)
        return;

    // Sort the data so that the left most offset is the first value.
    for (NSMutableArray *positionDataArray in alignDataArray)
    {
        [positionDataArray sortUsingComparator:^NSComparisonResult(NSArray *alignData1, NSArray *alignData2)
         {
             CGFloat xOffset1 = [(NSNumber *)alignData1[1] floatValue];
             CGFloat xOffset2 = [(NSNumber *)alignData2[1] floatValue];
             if (xOffset1 < xOffset2)
             {
                 return NSOrderedDescending;
             }
             else if (xOffset1 > xOffset2)
             {
                 return NSOrderedAscending;
             }
             else
             {
                 return NSOrderedSame;
             }
         }];
    }
    // Loop through the array of grouped positions.
    // The first offset in each array is assumed to be the align position.
    for (NSMutableArray *positionDataArray in alignDataArray)
    {
        CGFloat useOffset = 0;
        BOOL offsetFound = NO;
        for (NSArray *alignData in positionDataArray)
        {
            NSInteger viewTag = [(NSNumber *)alignData[0] integerValue];
            CGFloat xOffset = [(NSNumber *)alignData[1] floatValue];
            NSArray *equationLayoutArray = self.equationLayoutData[viewTag];
            NSValue *equationLineFrame = equationLayoutArray[0];
            CGRect viewFrame = equationLineFrame.CGRectValue;

            NSNumber *equationAlignOffset = equationLayoutArray[1];
            CGFloat storedAlignOffset = equationAlignOffset.floatValue;

            NSNumber *equationViewAlign = equationLayoutArray[2];
            NSInteger storedAlignment = equationViewAlign.integerValue;

            if (offsetFound == NO)
            {
                offsetFound = YES;
                useOffset = xOffset;
                CGRect alignRect = viewFrame;
                alignRect.origin.x = 0;
                viewFrame = alignRect;
            }
            else
            {
                CGFloat xDelta = useOffset - xOffset;
                CGRect alignRect = viewFrame;
                alignRect.origin.x = xDelta;
                viewFrame = alignRect;
                storedAlignOffset = xDelta;
            }
            NSArray *updatedLayoutArray = @[[NSValue valueWithCGRect:viewFrame], @(storedAlignOffset), @(storedAlignment)];
            self.equationLayoutData[viewTag] = updatedLayoutArray;
        }
    }
}

- (void)setAlignmentLeftWithArray: (NSMutableArray *)leftArray
{
    if (nil == leftArray || leftArray.count == 0)
        return;

    for (NSNumber *viewTag in leftArray)
    {
        NSArray *equationLayoutArray = self.equationLayoutData[viewTag.intValue];
        if (nil != equationLayoutArray)
        {
            NSValue *equationLineFrame = equationLayoutArray[0];
            CGRect viewFrame = equationLineFrame.CGRectValue;

            NSNumber *equationAlignOffset = equationLayoutArray[1];
            CGFloat storedAlignOffset = equationAlignOffset.floatValue;

            NSNumber *equationViewAlign = equationLayoutArray[2];
            NSInteger storedAlignment = equationViewAlign.integerValue;

            CGRect subViewFrame = viewFrame;
            subViewFrame.origin.x = 0.0;
            viewFrame = subViewFrame;

            NSArray *updatedLayoutArray = @[[NSValue valueWithCGRect:viewFrame], @(storedAlignOffset), @(storedAlignment)];
            self.equationLayoutData[viewTag.intValue] = updatedLayoutArray;
        }
    }
}

@end

//
//  EQRenderFracStem.m
//  eq-library
//
//  Created by Raymond Hodgson on 11/4/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "EQRenderFracStem.h"
#import "EQRenderData.h"
#import "EQRenderTypesetter.h"
#import "EQRenderFontDictionary.h"
#import "EQRenderLayout.h"

@implementation EQRenderFracStem

- (id) init
{
    self = [super init];
    if (self)
    {
        self->_lineThickness = 1.25;
        self->_startLinePoint = CGPointZero;
        self->_endLinePoint = CGPointZero;
        self.stemType = stemTypeFraction;
    }

    return self;
}

- (id) initWithObject:(id)object
{
    self = [super initWithObject:object];
    if (self)
    {
        self->_lineThickness = 1.25;
        self->_startLinePoint = CGPointZero;
        self->_endLinePoint = CGPointZero;
        self.stemType = stemTypeFraction;
    }

    return self;
}

- (id) initWithObject:(id)object andStemType:(EQRenderStemType)stemType
{
    self = [super initWithObject:object andStemType:stemTypeFraction];
    if (self)
    {
        self->_lineThickness = 1.25;
        self->_startLinePoint = CGPointZero;
        self->_endLinePoint = CGPointZero;
    }

    return self;
}

- (void)layoutChildren
{
    if (self.renderArray.count < 2)
    {
        // Should always update bounds after calling this method.
        [self updateBounds];
        return;
    }

    id numObj = [self.renderArray objectAtIndex:0];
    id denObj = [self.renderArray objectAtIndex:1];

    // Compute the sizes you will use for the numerator and denominator.
    // Will need to have it check if you are using a reduced font size later.
    CGSize numSize;
    CGSize denSize;
    CGRect numTypoBounds;
    CGRect denTypeBounds;

    // Initialize some variables here. Values depend upon whether you are using renderData or renderStem.
    UIFont *drawFont;

    // Compute an additional adjustment for caps and descenders.
    BOOL numHasDescender = NO;
    BOOL denomHasCapOrNumber = NO;
    BOOL denomHasDescender = NO;
    BOOL ignoreNumDescent = NO;
    BOOL denContainsOverline = NO;
    BOOL denContainsStretchyBracers = NO;
    BOOL canAdjustNumWidth = NO;
    BOOL canAdjustDenWidth = NO;
    NSCharacterSet *capAndNumberSet = [EQRenderTypesetter getCapAndNumberCharacterSet];
    NSCharacterSet *descenderSet = [EQRenderTypesetter getDescenderCharacterSet];

    // Compute an additional adjustment for nested stems.
    CGFloat numAdjustHeight = 0.0;
    CGFloat denAdjustHeight = 0.0;

    if ([numObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *numData = (EQRenderData *)numObj;
        numSize = numData.boundingRectImage.size;

        if (numData.renderString.length > 0)
        {
            drawFont = [numData.renderString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
        }
        else
        {
            drawFont = [UIFont fontWithName:kDEFAULT_FONT size:kDEFAULT_FONT_SIZE];
        }
        numHasDescender = [numData.renderString.string rangeOfCharacterFromSet:descenderSet].location != NSNotFound;
        numTypoBounds = numData.typographicBounds;
        if (self.lineThickness == 0.0 && numSize.width <= 2.0 * kDEFAULT_FONT_SIZE)
        {
            canAdjustNumWidth = YES;
        }
    }
    else if ([numObj isKindOfClass:[EQRenderStem class]])
    {
        drawFont = [UIFont fontWithName:kDEFAULT_FONT size:kDEFAULT_FONT_SIZE];

        EQRenderStem *numStem = (EQRenderStem *)numObj;
        numStem.drawOrigin = self.drawOrigin;
        [numStem layoutChildren];

        CGPoint testPoint = [EQRenderLayout findLowestChildOrigin:numStem];
        if (numStem.stemType == stemTypeNRoot || numStem.stemType == stemTypeSqRoot)
        {
            testPoint.y = MIN(testPoint.y, [numStem radicalLowerBounds]);
        }
        else if (numStem.hasSupplementaryData == YES)
        {
            testPoint.y = MIN(testPoint.y, [numStem supplementalLowerBounds]);
        }

        if (testPoint.y > numStem.drawOrigin.y)
        {
            numAdjustHeight = testPoint.y - numStem.drawOrigin.y;
        }

        // Need to test for stretchy bracers as they hang down a bit below the normal positioning.
        CGPoint testDescender = [numStem findChildDescenderPoint];
        if (!CGPointEqualToPoint(testDescender, CGPointZero) && (testDescender.y + 6.0) > testPoint.y
            && testDescender.y > numStem.drawOrigin.y)
        {
            numAdjustHeight += (testDescender.y + 6.0) - testPoint.y;
        }

        numSize = numStem.drawSize;
        numTypoBounds = numStem.drawBounds;
        // Should ignore descent for sups.
        // They are already accounted for in layout.
        ignoreNumDescent = [numStem shouldIgnoreDescent];

        if (self.lineThickness == 0.0 && numSize.width <= 2.0 * kDEFAULT_FONT_SIZE)
        {
            canAdjustNumWidth = [numStem testRowRenderChildren];
        }
    }
    else return;

    if ([denObj isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *denData = (EQRenderData *)denObj;
        denSize = denData.boundingRectImage.size;
        denomHasCapOrNumber = [denData.renderString.string rangeOfCharacterFromSet:capAndNumberSet].location != NSNotFound;
        denomHasDescender = [denData.renderString.string rangeOfCharacterFromSet:descenderSet].location != NSNotFound;
        denTypeBounds = denData.typographicBounds;
        if (self.lineThickness == 0.0 && denSize.width <= 2.0 * kDEFAULT_FONT_SIZE)
        {
            canAdjustDenWidth = YES;
        }
    }
    else if ([denObj isKindOfClass:[EQRenderStem class]])
    {
        EQRenderStem *denStem = (EQRenderStem *)denObj;
        denStem.drawOrigin = self.drawOrigin;
        [denStem layoutChildren];

        CGPoint testPoint = [EQRenderLayout findHighestChildOrigin:denStem];
        if (testPoint.y < denStem.drawOrigin.y)
        {
            denAdjustHeight = testPoint.y - denStem.drawOrigin.y;
        }

        // Need to test for sqrt (and other overlines) as they hang above the normal positioning.
        CGPoint testOverline = [denStem findChildOverlinePoint];
        if (!CGPointEqualToPoint(testOverline, CGPointZero) && testOverline.y < testPoint.y && testOverline.y < denStem.drawOrigin.y)
        {
            denContainsOverline = YES;
            denAdjustHeight -= testPoint.y - testOverline.y;
        }

        // Need to test for stretchy bracers as they hang down a bit below the normal positioning.
        // Just add a set amount as you would have to find the exact height to compute the adjustment otherwise.
        CGPoint testDescender = [denStem findChildDescenderPoint];
        if (!CGPointEqualToPoint(testDescender, CGPointZero))
        {
            denContainsStretchyBracers = YES;
        }

        denSize = denStem.drawSize;
        denTypeBounds = denStem.drawBounds;

        if (self.lineThickness == 0.0 && denSize.width <= 2.0 * kDEFAULT_FONT_SIZE)
        {
            canAdjustDenWidth = [denStem testRowRenderChildren];
        }
    }
    else return;

    CGFloat useThickness = self.lineThickness;

    // Convert negative values to zero.
    useThickness < 0.0 ? useThickness = 0.0 : useThickness;

    // Zero thickness values should still have some size adjustment.
    useThickness == 0.0 ? useThickness = 0.75 : useThickness;

    // Set up a default size if the size you are using is zero.
    // This can happen if the num or den is an empty renderData.
    if (CGSizeEqualToSize(numSize, CGSizeZero))
    {
        numSize = CGSizeMake(6.75, 16.25);
    }
    if (CGSizeEqualToSize(denSize, CGSizeZero))
    {
        denSize = CGSizeMake(6.75, 16.25);
    }

    // Need to also adjust the default size if the den bounds is empty.
    // I have no idea why this is needed, but it seems to be.
    if (CGSizeEqualToSize(numTypoBounds.size, CGSizeZero))
    {
        numTypoBounds.size = numSize;
    }
    if (CGSizeEqualToSize(denTypeBounds.size, CGSizeZero))
    {
        denTypeBounds.size = denSize;
        denTypeBounds.size.height *= 2;
    }

    // Compute the bounds you will use for the fraction.
    // Set up a minimum size for the width and height.
    numSize.width = MAX( numSize.width, 3.0);
    numSize.height = MAX( numSize.height, 9.0);
    denSize.width = MAX( denSize.width, 3.0);
    denSize.height = MAX( denSize.height, 9.0);

    CGSize fracBounds;
    fracBounds.width = MAX( numSize.width, denSize.width );
    fracBounds.height = numSize.height + denSize.height + 7 * useThickness;

    // Compute the font metrics used by the layout algorithm.

    CGFloat useFontSize = drawFont.pointSize;
    CGFloat useXHeight = drawFont.xHeight;
    CGFloat useDescent = drawFont.descender;
    CGFloat useAscent = drawFont.ascender;
    CGFloat storedMathAxisValue = useXHeight - 3.0 * 0.1 * kDEFAULT_FONT_SIZE * (useFontSize / kDEFAULT_FONT_SIZE);

    // Find out whether you are a nested stem or not.
    BOOL useSmaller = [self.parentStem useSmallFontForChild:self];

    // Use less thickness when you are in a nested stem.
    // Also, the denominator is sometimes dropped too far down in nested fractions.
    CGFloat adjustFactor = 3.5;
    if (useSmaller == YES)
    {
        adjustFactor = 3.0;
    }

    // Apply the formula to compute the vertical offsets.
    // See open math metrics #2, pg. 1007.
    CGFloat numOffset = storedMathAxisValue + adjustFactor * useThickness + 0.7 * useDescent;
    CGFloat denOffset = storedMathAxisValue + adjustFactor * useThickness + 0.7 * useAscent;

    // Fractions are centered, so compute the horizontal offset here.
    CGFloat numXAdjust = ABS(fracBounds.width - numSize.width) / 2;
    CGFloat denXAdjust = ABS(fracBounds.width - denSize.width) / 2;

    // Very small adjustments should be ignored (kerning will dominate anyway).
    if (ABS(numXAdjust) < 2.5)
        numXAdjust = 0.0;
    if (ABS(denXAdjust) < 2.5)
        denXAdjust = 0.0;

    // Compute the num and den origins.
    CGPoint numOrigin = self.drawOrigin;
    CGPoint denOrigin = self.drawOrigin;

    // Apply the horizontal offset.
    CGFloat horizontalOffset = 6.0;

    if (self.isBinomialStemType)
    {
        horizontalOffset = 1.0;
    }

    numOrigin.x += numXAdjust + horizontalOffset;
    denOrigin.x += denXAdjust + horizontalOffset;

    // Adjust for binomials with small widths that contain a simple sup/sup stem.
    if (canAdjustNumWidth && canAdjustDenWidth)
    {
        if ([numObj isKindOfClass:[EQRenderStem class]] || [denObj isKindOfClass:[EQRenderStem class]])
        {
            if (numOrigin.x < denOrigin.x)
            {
                numOrigin.x -= 0.1 * kDEFAULT_FONT_SIZE;
                denOrigin.x = numOrigin.x;
            }
            else
            {
                denOrigin.x -= 0.1 * kDEFAULT_FONT_SIZE;
                numOrigin.x = denOrigin.x;
            }
        }
        else
        {
            numOrigin.x -= 0.15 * kDEFAULT_FONT_SIZE;
            denOrigin.x -= 0.15 * kDEFAULT_FONT_SIZE;
        }
    }

    // Apply the vertical offset.
    // Ignore the descent for stem numerators.
    // They should already be accounted for.
    ignoreNumDescent ? useDescent = 0.0: useDescent;
    numOrigin.y -= numOffset - 0.5 * useDescent;
    if (numAdjustHeight != 0.0)
    {
        numOrigin.y -= numAdjustHeight + 0.333 * useDescent;
    }

    denOrigin.y += denOffset;

    // If you are ignoring numerator descent, you also need to adjust the denomin to compensate.
    ignoreNumDescent ? denOrigin.y += 3.0 * useThickness : denOrigin.y;

    if (denAdjustHeight != 0.0)
    {
        denOrigin.y -= denAdjustHeight - 0.333 * useDescent;
    }

    if (numHasDescender)
    {
        numOrigin.y += 0.25 * useDescent;
    }

    // Only adjust denom descender height if there is no cap or number.
    if (denomHasCapOrNumber)
    {
        denOrigin.y -= 0.15 * useDescent;
    }
    else if (denomHasDescender)
    {
        denOrigin.y += 0.15 * useDescent;
    }

    // Compute the adjustment to center the fraction vertically.
    CGFloat fracAdjustHeight = 0.25 * numTypoBounds.size.height;
    fracAdjustHeight == 0.0 ? fracAdjustHeight = 6.0 : fracAdjustHeight;

    // Set it to a max of 10, otherwise it will continually adjust the position of the denominator as the
    // size of the numerator increases.
    fracAdjustHeight = MIN(fracAdjustHeight, 10.0);

    // Shift the entire fraction so that it is centered vertically.
    numOrigin.y -= fracAdjustHeight;
    denOrigin.y -= fracAdjustHeight;

    // Compute the start and end points for the fraction line.
    CGPoint startPoint = self.drawOrigin;
    CGPoint endPoint = self.drawOrigin;
    CGFloat lineLength;
    if (useSmaller == YES)
    {
        lineLength = 9.0;
        startPoint.x += 3.0;
    }
    else
    {
        lineLength = 10.0;
        startPoint.x += 1.0;
    }

    startPoint.y -= storedMathAxisValue + 1.5 * self.lineThickness;
    endPoint.x += fracBounds.width + lineLength;
    endPoint.y = startPoint.y;

    // You can also cause the denominator to not be too far away from the fraction bar by limiting the adjust height ceiling.
    // This establishes an alternate position based on the location of the math axis (and the fraction bar)
    // and the size of the denominator if you are too far from the fraction bar.
    CGFloat testNestedAdjustment = denOrigin.y - startPoint.y - denTypeBounds.size.height;

    if (testNestedAdjustment > -6.0)
    {
        if (denContainsOverline == NO)
        {
            denOrigin.y = startPoint.y + denTypeBounds.size.height - 6.0;
        }
        else
        {
            denOrigin.y = startPoint.y + denTypeBounds.size.height;
        }
    }

    if (denContainsStretchyBracers == YES)
    {
        denOrigin.y += 3.0;
    }

    [numObj setDrawOrigin:numOrigin];
    [denObj setDrawOrigin:denOrigin];

    // Layout the stems again with the new origin.
    if ([numObj isKindOfClass:[EQRenderStem class]])
    {
        [numObj layoutChildren];
    }

    if ([denObj isKindOfClass:[EQRenderStem class]])
    {
        [denObj layoutChildren];
    }

    self.startLinePoint = startPoint;
    self.endLinePoint = endPoint;
    [self updateBounds];
}

- (void)shiftLayoutHorizontally:(CGFloat)xAdjust
{
    [super shiftLayoutHorizontally:xAdjust];

    CGPoint startPoint = self.startLinePoint;
    CGPoint endPoint = self.endLinePoint;
    startPoint.x += xAdjust;
    endPoint.x += xAdjust;
    self.startLinePoint = startPoint;
    self.endLinePoint = endPoint;
}

- (void)shiftChildrenHorizontally:(CGFloat)xAdjust
{
    CGPoint endPoint = self.endLinePoint;
    endPoint.x += xAdjust;
    self.endLinePoint = endPoint;

    [super shiftChildrenHorizontally:xAdjust];
}

// Overrides the parent method so that you can also check the line thickness for fractions.
- (BOOL)isBinomialStemType
{
    if (self.stemType == stemTypeBinomial || (self.stemType == stemTypeFraction && self.lineThickness == 0.0))
        return YES;

    return NO;
}


/************************
 NSCoding support methods
 ************************/

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:@(self.lineThickness) forKey:@"lineThickness"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.startLinePoint] forKey:@"startLinePoint"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.endLinePoint] forKey:@"endLinePoint"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self)
    {
        self->_lineThickness = [(NSNumber *)[aDecoder decodeObjectForKey:@"lineThickness"] floatValue];
        self->_startLinePoint = [(NSValue *)[aDecoder decodeObjectForKey:@"startLinePoint"] CGPointValue];
        self->_endLinePoint = [(NSValue *)[aDecoder decodeObjectForKey:@"endLinePoint"] CGPointValue];
    }

    return self;
}


@end

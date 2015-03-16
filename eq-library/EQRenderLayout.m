//
//  EQRenderLayout.m
//  EQ Editor
//
//  Created by Raymond Hodgson on 09/28/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "EQRenderLayout.h"
#import "EQRenderFontDictionary.h"

@interface EQRenderLayout()

+ (CGPoint)findChildOrigin: (EQRenderStem *)parentStem findLowest: (Boolean)findLowest;

@end

@implementation EQRenderLayout

// Adjusts the vertical or horizontal origin depending upon the stem type.
// Does no adjustment for non-matching types.
+ (EQRenderData *)layoutData: (EQRenderData *)drawData forStemType: (EQRenderStemType)stemType atPoint: (CGPoint)drawOrigin forLocation: (long)dataLoc
{
    if (stemType == stemTypeSup || stemType == stemTypeSub)
    {
        if (dataLoc == 0)
        {
            drawData.drawOrigin = drawOrigin;
        }
        else
        {
            drawOrigin.y = [self adjustDropHeight:drawOrigin.y forStemType:stemType usingData:drawData];

            if (nil != drawData.parentStem && (stemType == stemTypeSub || stemType == stemTypeSup) && drawData.parentStem.hasLargeOp == YES)
            {
                if (stemType == stemTypeSup)
                {
                    drawOrigin.x += 6.0;
                }
                else
                {
                    drawOrigin.x -= 15.0;
                }
            }
            drawData.drawOrigin = drawOrigin;
        }
    }
    else if (stemType == stemTypeSubSup)
    {
        if (dataLoc == 0)
        {
            drawData.drawOrigin = drawOrigin;
        }
        else if (dataLoc == 1)
        {
            drawOrigin.y = [self adjustDropHeight:drawOrigin.y forStemType:stemTypeSubSup usingData:drawData];
            if (nil != drawData.parentStem && drawData.parentStem.hasLargeOp == YES)
            {
                drawOrigin.x -= 9.0;
            }
            drawData.drawOrigin = drawOrigin;
        }
        else
        {
            drawOrigin.y = [self adjustDropHeight:drawOrigin.y forStemType:stemTypeSup usingData:drawData];
            drawData.drawOrigin = drawOrigin;
        }
    }
    else if (stemType == stemTypeUnder || stemType == stemTypeOver)
    {
        // You can compute the Y coordinate just fine, but under/overs
        // require the different widths as they need to be centered.
        if (dataLoc == 0)
        {
            drawData.drawOrigin = drawOrigin;
        }
        else
        {
            drawOrigin.y = [self adjustDropHeight:drawOrigin.y forStemType:stemType usingData:drawData];
            drawData.drawOrigin = drawOrigin;
        }
    }
    else if (stemType == stemTypeUnderOver)
    {
        if (dataLoc == 0)
        {
            drawData.drawOrigin = drawOrigin;
        }
        else if (dataLoc == 1)
        {
            drawOrigin.y = [self adjustDropHeight:drawOrigin.y forStemType:stemTypeUnder usingData:drawData];
            drawData.drawOrigin = drawOrigin;
        }
        else
        {
            drawOrigin.y = [self adjustDropHeight:drawOrigin.y forStemType:stemTypeOver usingData:drawData];
            drawData.drawOrigin = drawOrigin;
        }
    }
    else
    {
        drawData.drawOrigin = drawOrigin;
    }

    return drawData;
}

// Compute the offset for the next location (and also provide a cursor rect, if needed).
+ (CGRect)cursorRectWithData: (EQRenderData *)drawData forStemType: (EQRenderStemType)stemType forLocation: (long)dataLoc smallerBase: (BOOL)baseIsSmaller
{
    if (nil == drawData)
        return CGRectNull;

    CGFloat xOffset = -1.0;
    // This needs to match the isRowStemType check. Otherwise, it may adjust the width by -1.0
    // which is small but noticable.
    if (stemType == stemTypeRoot || stemType == stemTypeRow || stemType == stemTypeMatrixCell)
    {
        xOffset = 0.0;
    }

    if (stemType == stemTypeSup || stemType == stemTypeSubSup)
    {
        // The offset for the space between the base and superior is different from the normal baseline offset.
        // This may need more work if you have multiple character strings, so for now, we'll just ignore that case.
        if (dataLoc == 0 && drawData.renderString.length <= 1)
        {
            if (baseIsSmaller == NO)
            {
                CGFloat xCoord = [EQRenderLayout bestWidthForImageSize:drawData.imageBounds.size andTypographicSize:drawData.typographicBounds.size];
                return CGRectMake(xCoord, 0.0, 3.0, 10.0);
            }
            else
            {
                xOffset = -2.0;
            }
        }
    }

    CGRect returnRect = [drawData cursorRectForStringIndex:drawData.renderString.length];

    // Add some width and height in case we need to actually return a cursor with this.
    if (returnRect.size.width == 0.0)
        returnRect.size.width = 3.0;

    if (returnRect.size.height == 0.0)
        returnRect.size.height = 10.0;
    returnRect.origin.x += xOffset;

    return returnRect;
}


// Italic caps with sups are often too close to the sup location.
// Lowercase italics are often too far, if you adjust for that sizing.
// This method attempts to find a best by using the difference between image and typo sizing.
+ (CGFloat)bestWidthForImageSize: (CGSize)imageSize andTypographicSize: (CGSize)typographicSize
{
    CGFloat returnWidth = imageSize.width;
    CGFloat widthDelta = ABS(typographicSize.width - imageSize.width);
    if (widthDelta > 1.5 && widthDelta <= 3.5)
    {
        returnWidth = MAX(typographicSize.width, imageSize.width) + 1.0;
    }

    return returnWidth;
}


+ (CGFloat)adjustDropHeight: (CGFloat)height forStemType: (EQRenderStemType)stemType usingData: (EQRenderData *)drawData
{
    if (nil == drawData)
        return height;

    CGFloat fontSize;
    CGFloat fontAscender;
    CGFloat fontDescender;
    CGFloat useThickness = 3.0; // This should probably be pulled from somewhere. Shared with fraction, but not always.

    if (drawData.renderString.length == 0)
    {
        if (nil != drawData.parentStem && [drawData.parentStem useSmallFontForChild:drawData])
        {
            fontSize = kDEFAULT_FONT_SIZE_SMALL;
        }
        else
        {
            fontSize = kDEFAULT_FONT_SIZE;
        }
        fontAscender = [EQRenderFontDictionary defaultFontAscentValueWithSize:fontSize];
        fontDescender = [EQRenderFontDictionary defaultFontDescentValueWithSize:fontSize];
    }
    else
    {
        UIFont *drawFont = [drawData.renderString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
        fontSize = drawFont.pointSize;
        fontAscender = drawFont.ascender;
        fontDescender = drawFont.descender;
    }

    if (stemType == stemTypeSup)
    {
        if (nil != drawData.parentStem && drawData.parentStem.hasLargeOp == YES)
        {
            CGFloat superScriptDrop = 0.7 * fontDescender;
            height -= kDEFAULT_FONT_SIZE_LARGE + superScriptDrop;
        }
        else
        {
            // fontSize might not be the best metric once we start using reduced size fonts for the stem here.
            // Equation taken from pg. 5 of open-type-math metrics 2.
            // sigma_13 = 9.0 - 7/10 * ascHeight
            CGFloat superScriptDrop = 0.9 * fontSize - 0.7 * fontAscender;

            // Should likely replace 12.0 with something related to the small font size constant.
            // Or at least pull that in from somewhere if you decide to vary the font size at some point.
            height -= 0.75 * 12.0 + superScriptDrop;
        }
    }
    else if (stemType == stemTypeSub)
    {
        if (nil != drawData.parentStem && drawData.parentStem.hasLargeOp == YES)
        {
            CGFloat subScriptDrop = 0.7 * fontAscender;
            height += subScriptDrop;
        }
        else
        {
            // fontSize might not be the best metric once we start using reduced size fonts for the stem here.
            // Equation taken from pg. 5 of open-type-math metrics 2.
            // sigma_17 = - (8.5 - 2 * 7/10 * ascHeight - 3 * theta)
            CGFloat subScriptDrop = -0.85 * fontSize + 2.0 * 0.7 * fontAscender + 3.0 * 0.1 * fontAscender;

            // Should likely replace 12.0 with something related to the small font size constant.
            // Or at least pull that in from somewhere if you decide to vary the font size at some point.
            height -= 0.75 * 12.0 - subScriptDrop;
        }
    }
    else if (stemType == stemTypeSubSup)
    {
        if (nil != drawData.parentStem && drawData.parentStem.hasLargeOp == YES)
        {
            CGFloat subScriptDrop = 0.7 * fontAscender;
            height += subScriptDrop;
        }
        else
        {
            // fontSize might not be the best metric once we start using reduced size fonts for the stem here.
            // Equation taken from pg. 5 of open-type-math metrics 2.
            // sigma_17 = - (8.5 - 2 * 7/10 * ascHeight - 3 * theta)
            CGFloat subScriptDrop = -0.85 * fontSize + 2.0 * 0.7 * fontAscender + 3.0 * 0.1 * fontAscender;

            // Should likely replace 12.0 with something related to the small font size constant.
            // Or at least pull that in from somewhere if you decide to vary the font size at some point.
            height -= 0.75 * 12.0 - subScriptDrop;
        }
    }
    else if (stemType == stemTypeOver)
    {
        if (nil != drawData.parentStem && drawData.parentStem.hasLargeOp == YES)
        {
            CGFloat superScriptDrop = fontDescender + 3.0 * useThickness;
            height -= kDEFAULT_FONT_SIZE_LARGE + superScriptDrop;
        }
        else
        {
            CGFloat superScriptDrop = fontDescender + 3.0 * useThickness;
            height -= 0.7 * kDEFAULT_FONT_SIZE + superScriptDrop;
        }
    }
    else if (stemType == stemTypeUnder)
    {
        if (nil != drawData.parentStem && drawData.parentStem.hasLargeOp == YES)
        {
            CGFloat subScriptDrop = 0.9 * fontAscender + 4.0 * useThickness;
            height += subScriptDrop;
        }
        else
        {
            CGFloat subScriptDrop = 0.7 * fontAscender + 3.0 * useThickness;
            height += subScriptDrop;
        }
    }
    else if (stemType == stemTypeUnderOver)
    {
        if (nil != drawData.parentStem && drawData.parentStem.hasLargeOp == YES)
        {
            CGFloat superScriptDrop = 0.7 * fontDescender;
            height -= kDEFAULT_FONT_SIZE_LARGE + superScriptDrop;
        }
        else
        {
            // Do nothing for now. Will implement later.
//            NSLog(@"Implement for normal stemTypeUnderOver.");
//            NSAssert(drawData.parentStem.hasLargeOp == YES, @"Can't handle small ops yet.");
        }
    }

    return height;
}

+ (CGPoint)findChildOrigin: (EQRenderStem *)parentStem findLowest: (Boolean)findLowest
{
    CGPoint returnPoint = CGPointZero;
    if (nil == parentStem || nil == parentStem.renderArray || parentStem.renderArray.count == 0)
    {
        return returnPoint;
    }

    int childCounter = 0;
    for (id drawObj in parentStem.renderArray)
    {
        CGPoint testPoint;
        if ([drawObj isKindOfClass:[EQRenderData class]])
        {
            testPoint = [drawObj drawOrigin];
        }
        else if ([drawObj isKindOfClass:[EQRenderStem class]])
        {
            testPoint = [EQRenderLayout findChildOrigin:(EQRenderStem *)drawObj findLowest:findLowest];
        }
        // Shouldn't come across this branch unless we have to introduce a new draw object type.
        else
        {
            testPoint = parentStem.drawOrigin;
        }

        if (childCounter == 0)
        {
            returnPoint = testPoint;
        }
        else if (findLowest == YES && testPoint.y > returnPoint.y)
        {
            returnPoint = testPoint;
        }
        else if (findLowest == NO && testPoint.y < returnPoint.y)
        {
            returnPoint = testPoint;
        }
        childCounter ++;
    }

    return returnPoint;
}

+ (CGPoint)findLowestChildOrigin: (EQRenderStem *)parentStem
{
    return [EQRenderLayout findChildOrigin:parentStem findLowest:YES];
}

+ (CGPoint)findHighestChildOrigin: (EQRenderStem *)parentStem
{
    return [EQRenderLayout findChildOrigin:parentStem findLowest:NO];
}


@end

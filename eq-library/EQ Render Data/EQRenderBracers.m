//
//  EQRenderBracers.m
//  eq-library
//
//  Created by Raymond Hodgson on 04/22/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
//
//  This class handles automatic creation of character data for a stretchy bracer
//  when given the sizing and character string.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */


#import "EQRenderBracers.h"
#import "EQRenderFontDictionary.h"
#import "EQRenderStretchyBracers.h"

@interface EQRenderBracers()

@end


@implementation EQRenderBracers

// Should return nil if unable to build the character data or if the size is large enough you don't need the data.

+ (id)buildDataForBracerCharacter: (NSAttributedString *)bracerCharacter
                       withHeight: (NSNumber *)heightNumber
                      originValue: (NSValue *)useOrigin
{
    if (nil == bracerCharacter || nil == heightNumber)
        return nil;

    CGFloat bracerHeight = [heightNumber floatValue];
    EQRenderData *bracerData = [[EQRenderData alloc] initWithAttributedString:bracerCharacter];

    CGRect bracerImageBounds = [bracerData imageBounds];

    // Not likely to be correctly sized at this point, but worth testing anyway.
    if (bracerImageBounds.size.height >= bracerHeight)
    {
        return nil;
    }

    BOOL useExtenderBracers = NO;
    NSDictionary *currentFontDictionary = [bracerCharacter attributesAtIndex:0 effectiveRange:NULL];
    UIFont *currentFont = currentFontDictionary[NSFontAttributeName];
    CGFloat currentFontSize = currentFont.pointSize;

    // Try and compute the size you need using a simple proportion.
    double rawFontSize = (currentFontSize / bracerImageBounds.size.height) * bracerHeight;
    // Try to round it off a bit, but you may need fractional font sizes to handle this correctly.
    CGFloat newFontSize = floorf(rawFontSize);

    // Try and use a function to pick the correct sym font.
    // This reduces problems with font width from scaling up the glyph
    // as well as issues with anti-aliasing.

    NSString *useFontName = currentFont.fontName;
    CGFloat fontSizeDelta = newFontSize - currentFontSize;
    // Downsize the delta slightly to account for square bracers being larger.
    fontSizeDelta -= 2.0;
    if ([bracerCharacter.string isEqualToString:@"{"] || [bracerCharacter.string isEqualToString:@"}"])
    {
        fontSizeDelta += 5.0;
    }

    CGFloat kernAdjust = 0.0;

    // Need to handle vertical bracers separately as they don't have glyph support in the symbol fonts.
    if ([bracerCharacter.string isEqualToString:@"‖"] || [bracerCharacter.string isEqualToString:@"|"])
    {
        if ([bracerCharacter.string isEqualToString:@"|"])
        {
            useFontName = kALT_GLYPH_FONT;
        }
        else
        {
            useFontName = kDEFAULT_FONT;
        }

        if (newFontSize > 42.0)
        {
            newFontSize = kDEFAULT_FONT_SIZE;
            useExtenderBracers = YES;
            kernAdjust = 6.0;
        }
    }
    else if (fontSizeDelta > 6.0 && fontSizeDelta <= 15.0)
    {
        useFontName = kDEFAULT_SYMBOL_ONE_FONT;
        newFontSize = currentFontSize;
    }
    else if (fontSizeDelta > 15.0 && fontSizeDelta <= 32.0)
    {
        useFontName = kDEFAULT_SYMBOL_TWO_FONT;
        newFontSize = currentFontSize;
    }
    else if (fontSizeDelta > 32.0 && fontSizeDelta <= 50.0)
    {
        useFontName = kDEFAULT_SYMBOL_THREE_FONT;
        newFontSize = currentFontSize;
        kernAdjust = 6.0;
    }
    else if (fontSizeDelta > 50.0)
    {
        useFontName = kDEFAULT_SYMBOL_ONE_FONT;
        useExtenderBracers = YES;
    }

    // Handle kerning here.
    NSNumber *currentKern = currentFontDictionary[NSKernAttributeName];

    // Build the extender bracer object instead at this point.
    if (useExtenderBracers == YES)
    {
        NSNumber *kernValue = @(currentKern.floatValue + kernAdjust);
        EQRenderStretchyBracers *returnBracerData = [[EQRenderStretchyBracers alloc] initWithBracerCharacter:bracerCharacter withHeight:heightNumber useKern:kernValue originValue:useOrigin];
        [returnBracerData buildMetricsDictionary];

        return returnBracerData;
    }

    NSDictionary *newFontDictionary = [EQRenderFontDictionary fontDictWithName:useFontName size:newFontSize kernValue:currentKern.floatValue];
    NSAttributedString *newBracerStr = [[NSAttributedString alloc] initWithString:bracerCharacter.string attributes:newFontDictionary];

    EQRenderData *returnData = [[EQRenderData alloc] initWithAttributedString:newBracerStr];

    // There seems to be a sizing problem with very large bracers.
    // I've manually adjusted the kerning for those to keep the cursor positioning correctly.
    returnData.storedKern = currentKern.floatValue + kernAdjust;
    if (nil != useOrigin)
    {
        returnData.drawOrigin = useOrigin.CGPointValue;
    }

    return returnData;
}

+ (id)addDescenderDataToBracerData: (id)bracerData withDescenderPoint: (CGPoint)descenderPoint
{
    if (nil == bracerData)
        return bracerData;

    if ([bracerData isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *renderData = (EQRenderData *)bracerData;
        renderData.hasStretchyDescenderPoint = YES;
        renderData.stretchyDescenderPoint = descenderPoint;
    }
    else if ([bracerData isKindOfClass:[EQRenderStretchyBracers class]])
    {
        EQRenderStretchyBracers *renderBracers = (EQRenderStretchyBracers *)bracerData;
        renderBracers.hasStretchyDescenderPoint = YES;
        renderBracers.stretchyDescenderPoint = descenderPoint;
    }

    return bracerData;
}

+ (CGFloat)computeNewOffsetForBracerData: (id)bracerData withPreviousOrigin:(CGPoint)prevOrigin
{
    CGFloat xOffset = 0.0;
    if (nil == bracerData)
        return xOffset;

    if ([bracerData isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *renderData = (EQRenderData *)bracerData;
        // Need to use the image bounds as the typographical layout seems to not work correctly here.
        CGRect imageBounds = [renderData imageBounds];
        // Don't bother adjusting if you are not using stretchy bracers.
        if (imageBounds.size.height < 24.0)
        {
            return 0.0;
        }
        CGPoint currentOrigin = renderData.drawOrigin;
        currentOrigin.x += imageBounds.size.width;
        xOffset = currentOrigin.x - prevOrigin.x;
    }
    else if ([bracerData isKindOfClass:[EQRenderStretchyBracers class]])
    {
        // This may need to be added to help compute the correct left adjustment.
        EQRenderStretchyBracers *renderBracer = (EQRenderStretchyBracers *)bracerData;
        // Need to use the image bounds as the typographical layout seems to not work correctly here.
        CGRect imageBounds = [renderBracer computeBounds];
        // Don't bother adjusting if you are not using stretchy bracers.
        if (imageBounds.size.height < 24.0)
        {
            return 0.0;
        }
        xOffset = imageBounds.size.width * 0.4;
    }

    return xOffset;
}

+ (CGFloat)computeKernAdjustmentForBracerData: (id)bracerData
{
    CGFloat kernAdjust = 0.0;
    if (nil == bracerData)
        return kernAdjust;

    if ([bracerData isKindOfClass:[EQRenderData class]])
    {
        EQRenderData *renderData = (EQRenderData *)bracerData;
        CGFloat currentKern = renderData.storedKern;
        if (currentKern >= 6.0)
        {
            return currentKern;
        }
    }
    else if ([bracerData isKindOfClass:[EQRenderStretchyBracers class]])
    {
        EQRenderStretchyBracers *stretchyData = (EQRenderStretchyBracers *)bracerData;
        if ([stretchyData.bracerChar.string isEqualToString:@")"])
        {
            kernAdjust = 0.2 * kDEFAULT_FONT_SIZE;
        }
        else if ([stretchyData.bracerChar.string isEqualToString:@"]"])
        {
            kernAdjust = 0.2 * kDEFAULT_FONT_SIZE;
        }
        else if ([stretchyData.bracerChar.string isEqualToString:@"}"])
        {
            kernAdjust = 0.2 * kDEFAULT_FONT_SIZE;
        }
    }


    return kernAdjust;
}


@end

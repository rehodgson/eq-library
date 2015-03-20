//
//  EQRenderStretchyBracers.m
//  eq-library
//
//  Created by Raymond Hodgson on 07/2/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "EQRenderStretchyBracers.h"
#import "EQRenderFontDictionary.h"

NSString* const kSTRETCHY_BRACER_TYPE_KEY = @"Key containing bracer layout type.";
NSString* const kSTRETCHY_BRACER_TOP_CHAR_KEY = @"Key for top extender character.";
NSString* const kSTRETCHY_BRACER_MID_CHAR_KEY = @"Key for middle extender character.";
NSString* const kSTRETCHY_BRACER_BOT_CHAR_KEY = @"Key for bottom extender character.";
NSString* const kSTRETCHY_BRACER_EXT_CHAR_KEY = @"Key for extender character in complex bracers.";
NSString* const kSTRETCHY_KERN_KEY = @"Key containing amount of post character kerning";

NSString* const kSTRETCHY_GLYPH_KEY = @"Key containing the glyph to draw.";
NSString* const kSTRETCHY_ORIGIN_KEY = @"Key containing the location to draw the glyph.";

@implementation EQRenderStretchyBracers

- (id)initWithBracerCharacter: (NSAttributedString *)bracerChar
                   withHeight: (NSNumber *)heightNumber
                      useKern: (NSNumber *)useKern
                  originValue: (NSValue *)useOrigin
{
    self = [super init];
    if (self)
    {
        self->_bracerChar = bracerChar;
        self->_heightNumber = heightNumber;
        self->_useKern = useKern;
        self->_useOrigin = useOrigin;
        self->_bracerMetricsDict = @{};
        self->_hasStretchyDescenderPoint = NO;
        self->_stretchyDescenderPoint = CGPointZero;
    }

    return self;
}

- (void)buildMetricsDictionary
{
    if (nil == self.bracerChar || self.bracerChar.length == 0)
        return;

    NSDictionary *allMetrics = [EQRenderStretchyBracers getStretchyBracerMetrics];
    NSDictionary *stretchyMetrics = allMetrics[self.bracerChar.string];
    if (nil != stretchyMetrics)
    {
        self.bracerMetricsDict = stretchyMetrics;
    }
}

- (NSAttributedString *)getClearStretchyCharacter
{
    return [self getClearStretchyCharacterWithKern:NO];
}

- (NSAttributedString *)getClearStretchyCharacterWithKern: (BOOL)useKern;
{
    if (self.bracerChar.length == 0)
    {
        return nil;
    }

    NSMutableAttributedString *bracerCharacter = [[NSMutableAttributedString alloc] initWithAttributedString:self.bracerChar];

    NSDictionary *currentAttributes = [bracerCharacter attributesAtIndex:0 effectiveRange:NULL];
    NSMutableDictionary *newAttributes = currentAttributes.mutableCopy;
    newAttributes[NSForegroundColorAttributeName] = [UIColor clearColor];
    if (useKern == YES)
    {
        newAttributes[NSKernAttributeName] = self.useKern;
    }

    NSAttributedString *clearCharacter = [[NSAttributedString alloc] initWithString:bracerCharacter.string attributes:newAttributes];

    return clearCharacter;
}


- (CGRect)computeBounds
{
    return CGRectMake(0.0, 0.0, 0.6 * kDEFAULT_FONT_SIZE, self.heightNumber.floatValue);
}


// stretchyDrawArray will return an array of dictionaries containing the attributed strings
// for each glyph and the location to draw them.
- (NSArray *)stretchyDrawArrayInContext: (CGContextRef)context
{
    NSAssert(context != NULL, @"ContextRef should not be NULL.");

    if (nil == self.bracerChar || self.bracerChar.length == 0 || self.bracerMetricsDict == nil ||
        nil == self.heightNumber || self.heightNumber.floatValue <= 0.0 || nil == self.useOrigin)
    {
        return nil;
    }

    // Retrieve the values you will need to render the extender bracer.
    NSNumber *stretchyTypeNum = self.bracerMetricsDict[kSTRETCHY_BRACER_TYPE_KEY];
    StretchyBracerType stretchyType = stretchyTypeNum.intValue;

    // These values should not be nil but can be "".
    NSString *topStr = self.bracerMetricsDict[kSTRETCHY_BRACER_TOP_CHAR_KEY];
    NSString *midStr = self.bracerMetricsDict[kSTRETCHY_BRACER_MID_CHAR_KEY];
    NSString *botStr = self.bracerMetricsDict[kSTRETCHY_BRACER_BOT_CHAR_KEY];
    NSString *extStr = self.bracerMetricsDict[kSTRETCHY_BRACER_EXT_CHAR_KEY];

    // Retrieve the kern number here if we decide we need it.

    // Initialize the frames for these characters.
    // Some of them will not be needed depending on the bracer type.
    CGRect topRect = CGRectZero;
    NSValue *topVal = [NSValue valueWithCGRect:topRect];

    CGRect midRect = CGRectZero;
    NSValue *midVal = [NSValue valueWithCGRect:midRect];

    CGRect botRect = CGRectZero;
    NSValue *botVal = [NSValue valueWithCGRect:botRect];

    CGRect extRect = CGRectZero;
    NSValue *extVal = [NSValue valueWithCGRect:extRect];

    NSArray *glyphStrings = @[topStr, midStr, botStr, extStr];
    NSMutableArray *glyphRects = [[NSMutableArray alloc] initWithArray: @[topVal, midVal, botVal, extVal]];

    NSDictionary *symDict = [EQRenderFontDictionary symOneFontDictionaryWithSize:kDEFAULT_FONT_SIZE];

    // Compute the sizes you will need for glyph layout.
    for (int i = 0; i < glyphStrings.count; i++)
    {
        NSString *glyphStr = glyphStrings[i];
        if ([glyphStr isEqualToString:@""])
        {
            continue;
        }

        NSAttributedString *glyphAttrStr = [[NSAttributedString alloc] initWithString:glyphStr attributes:symDict];
        CTLineRef glyphLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)glyphAttrStr);
        CGRect glyphImageBounds = CTLineGetImageBounds(glyphLine, context);
        glyphImageBounds.origin = CGPointZero;
        CFRelease(glyphLine);
        glyphRects[i] = [NSValue valueWithCGRect:glyphImageBounds];
    }

    // Push the updated sizes back into the variables.
    topRect = [(NSValue *)glyphRects[0] CGRectValue];
    midRect = [(NSValue *)glyphRects[1] CGRectValue];
    botRect = [(NSValue *)glyphRects[2] CGRectValue];
    extRect = [(NSValue *)glyphRects[3] CGRectValue];

    // Determine whether you should use the extender or not.
    // Remember that the rects for missing glyphs should be size zero.
    BOOL shouldUseExtender = YES;
    CGFloat baseStretchyHeight = ceil(topRect.size.height + midRect.size.height + botRect.size.height);
    CGFloat heightDelta = self.heightNumber.floatValue - baseStretchyHeight;

    if (heightDelta <= 0)
    {
        shouldUseExtender = NO;
    }

    // Compute the start point for the extender bracer.
    CGPoint drawOrigin = self.useOrigin.CGPointValue;

    if (self.hasStretchyDescenderPoint)
    {
        drawOrigin.y = self.stretchyDescenderPoint.y;
    }

    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    if (stretchyType == bracerTypeTopMidBottom)
    {
        NSAttributedString *botAttrStr = [[NSAttributedString alloc] initWithString:botStr attributes:symDict];
        NSAttributedString *midAttrStr = [[NSAttributedString alloc] initWithString:midStr attributes:symDict];
        NSAttributedString *topAttrStr = [[NSAttributedString alloc] initWithString:topStr attributes:symDict];

        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y + 3.0)));
        [returnArray addObject:@[botAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
        drawOrigin.y -= ceil(botRect.size.height - 1.0);
        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));

        [returnArray addObject:@[midAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
        drawOrigin.y -= ceil(midRect.size.height - 1.0);
        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));

        if (shouldUseExtender == YES)
        {
            // Compute how many times you need to add the extender.
            CGFloat testExtender = heightDelta / midRect.size.height;
            NSInteger testExtFloor = floorf(testExtender);
            CGFloat remainder = testExtender - testExtFloor;
            if (remainder >= 0.9)
            {
                testExtFloor++;
            }
            else if (remainder > 0.1 && remainder < 0.9)
            {
                drawOrigin.y += 0.5 * midRect.size.height;
                testExtFloor ++;
            }

            // Add the extender.
            for (NSInteger i = 0; i < testExtFloor; i++)
            {
                [returnArray addObject:@[midAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
                drawOrigin.y -= ceil(midRect.size.height - 1.0);
                drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));
            }
            drawOrigin.y += 1.0;
        }

        [returnArray addObject:@[topAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
    }
    else if (stretchyType == bracerTypeTopBottom)
    {
        NSAttributedString *botAttrStr = [[NSAttributedString alloc] initWithString:botStr attributes:symDict];
        NSAttributedString *topAttrStr = [[NSAttributedString alloc] initWithString:topStr attributes:symDict];

        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));
        [returnArray addObject:@[botAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
        drawOrigin.y -= ceil(botRect.size.height - 1.0);
        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));

        if (shouldUseExtender == YES)
        {
            // Compute how many times you need to add the extender.
            CGFloat testExtender = heightDelta / botRect.size.height;
            NSInteger testExtFloor = floorf(testExtender);
            CGFloat remainder = testExtender - testExtFloor;
            if (remainder >= 0.9)
            {
                testExtFloor++;
            }
            else if (remainder > 0.1 && remainder < 0.9)
            {
                drawOrigin.y += 0.5 * botRect.size.height;
                testExtFloor ++;
            }

            // Add the extender.
            for (NSInteger i = 0; i < testExtFloor; i++)
            {
                [returnArray addObject:@[botAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
                drawOrigin.y -= ceil(botRect.size.height - 1.0);
                drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));
            }
            drawOrigin.y += 1.0;
        }

        [returnArray addObject:@[topAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
    }
    else if (stretchyType == bracerTypeMidBottom)
    {
        NSAttributedString *botAttrStr = [[NSAttributedString alloc] initWithString:botStr attributes:symDict];
        NSAttributedString *midAttrStr = [[NSAttributedString alloc] initWithString:midStr attributes:symDict];

        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));
        [returnArray addObject:@[botAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
        drawOrigin.y -= ceil(botRect.size.height - 1.0);
        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));

        if (shouldUseExtender == YES)
        {
            // Compute how many times you need to add the extender.
            CGFloat testExtender = heightDelta / midRect.size.height;
            NSInteger testExtFloor = floorf(testExtender);
            CGFloat remainder = testExtender - testExtFloor;
            if (remainder >= 0.9)
            {
                testExtFloor++;
            }
            else if (remainder > 0.1 && remainder < 0.9)
            {
                drawOrigin.y += 0.5 * midRect.size.height;
                testExtFloor ++;
            }

            // Add the extender.
            for (NSInteger i = 0; i < testExtFloor; i++)
            {
                [returnArray addObject:@[midAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
                drawOrigin.y -= ceil(midRect.size.height - 1.0);
                drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));
            }
            drawOrigin.y += 1.0;
        }
    }
    else if (stretchyType == bracerTypeTopMidBottomExt)
    {
        NSAttributedString *botAttrStr = [[NSAttributedString alloc] initWithString:botStr attributes:symDict];
        NSAttributedString *midAttrStr = [[NSAttributedString alloc] initWithString:midStr attributes:symDict];
        NSAttributedString *topAttrStr = [[NSAttributedString alloc] initWithString:topStr attributes:symDict];
        NSAttributedString *extAttrStr = [[NSAttributedString alloc] initWithString:extStr attributes:symDict];
        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y + 3.0)));
        [returnArray addObject:@[botAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
        drawOrigin.y -= ceil(botRect.size.height - 1.0);
        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));

        if (shouldUseExtender == YES)
        {
            // Compute how many times you need to add the extender.
            CGFloat testExtender = heightDelta / (2 * extRect.size.height);
            NSInteger testExtFloor = floorf(testExtender);
            CGFloat remainder = testExtender - testExtFloor;
            BOOL adjustFlag = NO;
            CGFloat adjustValue = 0;
            if (remainder >= 0.25 && remainder < 0.6)
            {
                adjustFlag = YES;
                testExtFloor ++;
                adjustValue = 0.25;
                drawOrigin.y += adjustValue * extRect.size.height;
            }
            else if (remainder < 0.25)
            {
                adjustFlag = YES;
                testExtFloor ++;
                adjustValue = 0.25;
                drawOrigin.y += 0.5 * extRect.size.height;
            }
            else if (remainder >= 0.6)
            {
                testExtFloor ++;
                drawOrigin.y += 0.5 * extRect.size.height;
            }

            // Add the extender.
            for (NSInteger i = 0; i < testExtFloor; i++)
            {
                [returnArray addObject:@[extAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
                drawOrigin.y -= ceil(extRect.size.height - 1.0);
                drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));
            }

            if (adjustFlag)
            {
                drawOrigin.y += adjustValue * extRect.size.height;
            }
            else
            {
                drawOrigin.y += 1.0;
            }
        }

        [returnArray addObject:@[midAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
        drawOrigin.y -= ceil(midRect.size.height - 1.0);
        drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));

        if (shouldUseExtender == YES)
        {
            // Compute how many times you need to add the extender.
            CGFloat testExtender = heightDelta / (2 * extRect.size.height);
            NSInteger testExtFloor = floorf(testExtender);
            CGFloat remainder = testExtender - testExtFloor;
            BOOL adjustFlag = NO;
            CGFloat adjustValue = 0;
            if (remainder >= 0.25 && remainder < 0.6)
            {
                adjustFlag = YES;
                testExtFloor ++;
                adjustValue = 0.25;
                drawOrigin.y += adjustValue * extRect.size.height;
            }
            else if (remainder < 0.25)
            {
                adjustFlag = YES;
                testExtFloor ++;
                adjustValue = 0.5;
                drawOrigin.y += 0.25 * extRect.size.height;
            }
            else if (remainder >= 0.6)
            {
                testExtFloor ++;
           }

            // Add the extender.
            for (NSInteger i = 0; i < testExtFloor; i++)
            {
                [returnArray addObject:@[extAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
                drawOrigin.y -= ceil(extRect.size.height - 1.0);
                drawOrigin = CGPointMake(floor(drawOrigin.x), floor((drawOrigin.y)));
            }

            if (adjustFlag)
            {
                drawOrigin.y += adjustValue * extRect.size.height;
            }
            else
            {
                drawOrigin.y += 1.0;
            }
        }

        [returnArray addObject:@[topAttrStr, [NSValue valueWithCGPoint:drawOrigin]]];
    }

    if (returnArray.count == 0)
    {
        return nil;
    }

    return returnArray;
}


/***********************
 * Begin Class methods *
 ***********************/

+ (NSDictionary *)getStretchyBracerMetrics
{
    NSMutableDictionary *stretchyReturnDict = [[NSMutableDictionary alloc] init];

    // Build the sub-dictionary for each supported character key.

    NSString *topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x239B]; //left paren top - 239B
    NSString *midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x239C]; //left paren mid - 239C
    NSString *botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x239D]; //left paren bottom - 239D
    NSString *extStr = @"";
    NSNumber *kernNum = @0.0;
    stretchyReturnDict[@"("] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x239E]; //right paren top - 239E
    midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x239F]; //right paren mid - 239F
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A0]; //right paren bottom - 23A0
    extStr = @"";
    stretchyReturnDict[@")"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A1]; //left sqbrack top - 23A1
    midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A2]; //left sqbrack mid - 23A2
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A3]; //left sqbrack bottom - 23A3
    extStr = @"";
    stretchyReturnDict[@"["] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A4]; //right sqbrack top - 23A4
    midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A5]; //right sqbrack mid - 23A5
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A6]; //right sqbrack bottom - 23A6
    extStr = @"";
    stretchyReturnDict[@"]"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A1]; //left sqbrack top - 23A1
    midStr = @"";
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A2]; //left sqbrack mid - 23A2
    extStr = @"";
    stretchyReturnDict[@"⌈"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A4]; //right sqbrack top - 23A4
    midStr = @"";
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A5]; //right sqbrack mid - 23A6
    extStr = @"";
    stretchyReturnDict[@"⌉"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = @"";
    midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A2]; //left sqbrack mid - 23A2
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A3]; //left sqbrack bottom - 23A3
    extStr = @"";
    stretchyReturnDict[@"⌊"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = @"";
    midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A5]; //right sqbrack mid - 23A5
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A6]; //right sqbrack bottom - 23A6
    extStr = @"";
    stretchyReturnDict[@"⌋"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A7]; //left curly top - 23A7
    midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A8]; //left curly mid - 23A8
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23A9]; //left curly bottom - 23A9
    extStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23AA]; //curly ext - 23AA
    stretchyReturnDict[@"{"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottomExt),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };


    topStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23AB]; //right curly top - 0x23AB
    midStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23AC]; //right curly mid - 0x23AC
    botStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23AD]; //right curly bottom - 0x23AD
    extStr = [NSString stringWithFormat:@"%C",(unsigned short)0x23AA]; //curly ext - 23AA
    stretchyReturnDict[@"}"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottomExt),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };

    topStr = @"⎢";
    midStr = @"⎢";
    botStr = @"⎢";
    extStr = @"";
    stretchyReturnDict[@"|"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };

    topStr = @"‖";
    midStr = @"‖";
    botStr = @"‖";
    extStr = @"";
    stretchyReturnDict[@"‖"] = @{ kSTRETCHY_BRACER_TYPE_KEY: @(bracerTypeTopMidBottom),
                                  kSTRETCHY_BRACER_TOP_CHAR_KEY: topStr,
                                  kSTRETCHY_BRACER_MID_CHAR_KEY: midStr,
                                  kSTRETCHY_BRACER_BOT_CHAR_KEY: botStr,
                                  kSTRETCHY_BRACER_EXT_CHAR_KEY: extStr,
                                  kSTRETCHY_KERN_KEY: kernNum };

    return stretchyReturnDict.copy;
}

@end

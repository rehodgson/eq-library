//
//  EQRenderFontDictionary.m
//  EQ Editor Lite
//
//  Created by Raymond Hodgson on 12/10/12.
//  Copyright (c) 2012-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "EQRenderFontDictionary.h"

// Default font name constants.
NSString* const kDEFAULT_FONT = @"STIXGeneral-Regular";
NSString* const kDEFAULT_BOLD_FONT = @"STIXGeneral-Bold";
NSString* const kDEFAULT_ITALIC_FONT = @"STIXGeneral-Italic";
NSString* const kDEFAULT_BOLD_ITALIC_FONT = @"STIXGeneral-BoldItalic";
NSString* const kDEFAULT_SYMBOL_ONE_FONT = @"STIXSizeOneSym-Regular";
NSString* const kDEFAULT_SYMBOL_TWO_FONT = @"STIXSizeTwoSym-Regular";
NSString* const kDEFAULT_SYMBOL_THREE_FONT = @"STIXSizeThreeSym-Regular";
NSString* const kDEFAULT_SYMBOL_FOUR_FONT = @"STIXSizeFourSym-Regular";
NSString* const kDEFAULT_SYMBOL_ONE_FONT_EXT = @"STIXSizeOneSymExtended";
NSString* const kALT_GLYPH_FONT = @"Georgia";

// TTF font name constants.

NSString* const kDEFAULT_FONT_TTF = @"STIXGeneralTTF";
NSString* const kDEFAULT_BOLD_FONT_TTF = @"STIXGeneralTTF-Bold";
NSString* const kDEFAULT_ITALIC_FONT_TTF = @"STIXGeneralTTF-Italic";
NSString* const kDEFAULT_BOLD_ITALIC_FONT_TTF = @"STIXGeneralTTF-BoldItalic";
NSString* const kDEFAULT_SYMBOL_ONE_FONT_TTF = @"STIXttfSize1Symbols";
NSString* const kDEFAULT_SYMBOL_TWO_FONT_TTF = @"STIXttfSize2Symbols";
NSString* const kDEFAULT_SYMBOL_THREE_FONT_TTF = @"STIXttfSize3Symbols";
NSString* const kDEFAULT_SYMBOL_FOUR_FONT_TTF = @"STIXttfSize4Symbols";

// Default font size constants.
CGFloat const kDEFAULT_FONT_SIZE = 24.0;
CGFloat const kDEFAULT_FONT_SIZE_SMALL = 18.0;
CGFloat const kDEFAULT_FONT_SIZE_SMALLER = 15.0;
CGFloat const kDEFAULT_FONT_SIZE_LARGE = 32.0;
CGFloat const kDEFAULT_FONT_SIZE_LARGE_INTEGRAL = 40.0;

// Custom Font attribute constants.
NSString* const kSUM_OP_CHARACTER = @"SumOpAttribute";
NSString* const kUSER_STYLED_TEXT = @"UserStyledAttribute";
NSString* const kUSES_PLAIN_TEXT = @"PlainTextStyleAttribute";

// Font variant character constants.
NSString* const kCHAR_LOOKUP_FILE_NAME = @"MacroCharLookupFile";
NSString* const kSCRIPT_CHAR_DICTIONARY_KEY = @"kMacroScriptCharDictionary";
NSString* const kFRAKTUR_CHAR_DICTIONARY_KEY = @"kMacroFrakturCharDictionary";
NSString* const kDOUBLE_STR_CHAR_DICTIONARY_KEY = @"kMacroDoubleStrCharDictionary";


// Object implementation.
@implementation EQRenderFontDictionary

+ (NSDictionary *)fontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue
{
    NSAssert( (nil != fontName && useSize > 0), @"Invalid parameters for font dictionary.");
    UIFont *font = [UIFont fontWithName:fontName size:useSize];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSKernAttributeName: @(kernValue)};
    
    return attributes;
}

+ (NSDictionary *)sumOpFontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue
{
    NSAssert( (nil != fontName && useSize > 0), @"Invalid parameters for font dictionary.");
    UIFont *font = [UIFont fontWithName:fontName size:useSize];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSKernAttributeName: @(kernValue), kSUM_OP_CHARACTER: @(TRUE)};

    return attributes;
}

+ (NSDictionary *)userStyledFontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue
{
    NSAssert( (nil != fontName && useSize > 0), @"Invalid parameters for font dictionary.");
    UIFont *font = [UIFont fontWithName:fontName size:useSize];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSKernAttributeName: @(kernValue), kUSER_STYLED_TEXT: @(TRUE)};

    return attributes;
}

+ (NSDictionary *)plainTextFontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue
{
    NSAssert( (nil != fontName && useSize > 0), @"Invalid parameters for font dictionary.");
    UIFont *font = [UIFont fontWithName:fontName size:useSize];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSKernAttributeName: @(kernValue), kUSES_PLAIN_TEXT: @(TRUE)};

    return attributes;
}


+ (NSDictionary *)preferredFontBodyDictionaryWithSize: (CGFloat)useSize
{
    UIFontDescriptor *preferred = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFont *font = [UIFont fontWithDescriptor:preferred size:useSize];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSKernAttributeName: @(0.0f)};
    return attributes;
}

+ (NSDictionary *)preferredFontBodyItalicDictionaryWithSize: (CGFloat)useSize
{
    UIFontDescriptor *preferred = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *italicPref = [preferred fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFont *font = [UIFont fontWithDescriptor:italicPref size:useSize];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSKernAttributeName: @(0.0f)};
    return attributes;
}


+ (NSDictionary *)defaultFontDictionaryWithSize: (CGFloat)useSize
{
    return [self fontDictWithName:kDEFAULT_FONT size:useSize kernValue:0.0];
}

+ (NSDictionary *)defaultItalicFontDictionaryWithSize: (CGFloat)useSize
{
    return [self fontDictWithName:kDEFAULT_ITALIC_FONT size:useSize kernValue:1.75];        
}

+ (NSDictionary *)symOneFontDictionaryWithSize: (CGFloat) useSize
{
    return [self fontDictWithName:kDEFAULT_SYMBOL_ONE_FONT size:useSize kernValue:0.0];        
}

+ (CGFloat)defaultFontAscentValueWithSize: (CGFloat)useSize
{
    UIFont *font = [UIFont fontWithName:kDEFAULT_FONT size:useSize];

    return font.ascender;
}

+ (CGFloat)defaultFontDescentValueWithSize: (CGFloat)useSize
{
    UIFont *font = [UIFont fontWithName:kDEFAULT_FONT size:useSize];
    
    return font.descender;
}

+ (CGFloat)defaultFontXHeightValueWithSize: (CGFloat)useSize
{
    UIFont *font = [UIFont fontWithName:kDEFAULT_FONT size:useSize];

    return font.xHeight;
}

+ (EQfontMetrics)defaultFontEQMetricsWithSize: (CGFloat)useSize
{
    EQfontMetrics returnMetrics;
    returnMetrics.fontAscentValue = 0.0;
    returnMetrics.fontXHeightValue = 0.0;
    
    UIFont *afont = [UIFont fontWithName:kDEFAULT_FONT size:useSize];
    
    returnMetrics.fontAscentValue = afont.ascender;
    returnMetrics.fontXHeightValue = afont.xHeight;
    
    return returnMetrics;
}

+ (NSAttributedString *)convertAttributedStringForPDF: (NSAttributedString *)convertString
{
    if (nil == convertString || convertString.length == 0)
        return convertString;

    NSMutableAttributedString *returnString = convertString.mutableCopy;
    [returnString enumerateAttributesInRange:NSMakeRange(0, returnString.length) options:0
                                  usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
    {
        UIFont *aFont = attrs[NSFontAttributeName];
        NSString *fontName = aFont.fontName;
        CGFloat fontSize = aFont.pointSize;
        NSMutableDictionary *newDict = attrs.mutableCopy;
        UIFont *ttfFont = nil;
        if ([fontName isEqualToString:kDEFAULT_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kDEFAULT_ITALIC_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_ITALIC_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kDEFAULT_BOLD_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_BOLD_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kDEFAULT_BOLD_ITALIC_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_BOLD_ITALIC_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kDEFAULT_SYMBOL_ONE_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_SYMBOL_ONE_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kDEFAULT_SYMBOL_TWO_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_SYMBOL_TWO_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kDEFAULT_SYMBOL_THREE_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_SYMBOL_THREE_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kDEFAULT_SYMBOL_FOUR_FONT])
        {
            ttfFont = [UIFont fontWithName:kDEFAULT_SYMBOL_FOUR_FONT_TTF size:fontSize];
        }
        else if ([fontName isEqualToString:kALT_GLYPH_FONT])
        {
            ttfFont = aFont;
        }
        else
        {
            // Need this for now, but there shouldn't be any fonts that are unaccounted for at this point.
            NSLog(@"Error: Missing PDF conversion for font named: %@", fontName);
        }
        if (nil != ttfFont)
        {
            NSNumber *kernValue = newDict[NSKernAttributeName];
            [newDict setValue:ttfFont forKey:NSFontAttributeName];
            [newDict setValue:kernValue forKey:NSKernAttributeName];
            NSDictionary *useDict = [[NSDictionary alloc] initWithDictionary:newDict];
            [returnString setAttributes:useDict range:range];
        }
    }];

    return [[NSAttributedString alloc] initWithAttributedString:returnString];
}

+ (NSDictionary *)getCharDictionaryWithKey: (NSString *)dictKey
{
    if (nil == dictKey || dictKey.length == 0)
        return nil;

    NSString *dictPath = [[NSBundle mainBundle] pathForResource:kCHAR_LOOKUP_FILE_NAME ofType:@"plist"];
    NSDictionary *lookupDict = [[NSDictionary alloc] initWithContentsOfFile:dictPath];

    NSDictionary *charDict = lookupDict[dictKey];
    if (nil == charDict || charDict.count == 0)
        return nil;

    return charDict;
}



@end

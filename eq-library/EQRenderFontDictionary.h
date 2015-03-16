//
//  EQRenderFontDictionary.h
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

#import <Foundation/Foundation.h>

// Default font name constants.
extern NSString* const kDEFAULT_FONT;
extern NSString* const kDEFAULT_BOLD_FONT;
extern NSString* const kDEFAULT_ITALIC_FONT;
extern NSString* const kDEFAULT_BOLD_ITALIC_FONT;
extern NSString* const kDEFAULT_SYMBOL_ONE_FONT;
extern NSString* const kDEFAULT_SYMBOL_TWO_FONT;
extern NSString* const kDEFAULT_SYMBOL_THREE_FONT;
extern NSString* const kDEFAULT_SYMBOL_FOUR_FONT;
extern NSString* const kDEFAULT_SYMBOL_ONE_FONT_EXT;
extern NSString* const kALT_GLYPH_FONT;

// Default font size constants.
extern CGFloat const kDEFAULT_FONT_SIZE;
extern CGFloat const kDEFAULT_FONT_SIZE_SMALL;
extern CGFloat const kDEFAULT_FONT_SIZE_SMALLER;
extern CGFloat const kDEFAULT_FONT_SIZE_LARGE;
extern CGFloat const kDEFAULT_FONT_SIZE_LARGE_INTEGRAL;

// Custom Font attribute constants.
extern NSString* const kSUM_OP_CHARACTER;
extern NSString* const kUSER_STYLED_TEXT;
extern NSString* const kUSES_PLAIN_TEXT;

// Font variant character constants.
extern NSString* const kCHAR_LOOKUP_FILE_NAME;
extern NSString* const kSCRIPT_CHAR_DICTIONARY_KEY;
extern NSString* const kFRAKTUR_CHAR_DICTIONARY_KEY;
extern NSString* const kDOUBLE_STR_CHAR_DICTIONARY_KEY;

// Struct to store font metrics.
typedef struct EQfontMetrics
{
    CGFloat fontAscentValue;
    CGFloat fontXHeightValue;
} EQfontMetrics;

// Object interface.
@interface EQRenderFontDictionary : NSObject

+ (NSDictionary *)fontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue;
+ (NSDictionary *)sumOpFontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue;
+ (NSDictionary *)userStyledFontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue;
+ (NSDictionary *)plainTextFontDictWithName: (NSString *)fontName size: (CGFloat)useSize kernValue: (CGFloat)kernValue;

+ (NSDictionary *)preferredFontBodyDictionaryWithSize: (CGFloat)useSize;
+ (NSDictionary *)preferredFontBodyItalicDictionaryWithSize: (CGFloat)useSize;
+ (NSDictionary *)defaultFontDictionaryWithSize: (CGFloat)useSize;
+ (NSDictionary *)defaultItalicFontDictionaryWithSize: (CGFloat)useSize;
+ (NSDictionary *)symOneFontDictionaryWithSize: (CGFloat) useSize;

+ (CGFloat)defaultFontAscentValueWithSize: (CGFloat)useSize;
+ (CGFloat)defaultFontDescentValueWithSize: (CGFloat)useSize;
+ (CGFloat)defaultFontXHeightValueWithSize: (CGFloat)useSize;
+ (EQfontMetrics)defaultFontEQMetricsWithSize: (CGFloat)useSize;

+ (NSAttributedString *)convertAttributedStringForPDF: (NSAttributedString *)convertString;
+ (NSDictionary *)getCharDictionaryWithKey: (NSString *)dictKey;

@end

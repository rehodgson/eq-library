//
//  EQRenderStretchyBracers.h
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

#import <Foundation/Foundation.h>

extern NSString* const kSTRETCHY_BRACER_TYPE_KEY;
extern NSString* const kSTRETCHY_BRACER_TOP_CHAR_KEY;
extern NSString* const kSTRETCHY_BRACER_MID_CHAR_KEY;
extern NSString* const kSTRETCHY_BRACER_BOT_CHAR_KEY;
extern NSString* const kSTRETCHY_BRACER_EXT_CHAR_KEY;
extern NSString* const kSTRETCHY_KERN_KEY;

extern NSString* const kSTRETCHY_GLYPH_KEY;
extern NSString* const kSTRETCHY_ORIGIN_KEY;

typedef enum
{
    bracerTypeEmpty,
    bracerTypeTopMidBottom,
    bracerTypeTopBottom,
    bracerTypeMidBottom,
    bracerTypeTopMidBottomExt,
} StretchyBracerType;

// This class is used to store and layout very large bracers which may require multiple glyphs to represent a single logical character.

@interface EQRenderStretchyBracers : NSObject

@property (strong, nonatomic) NSAttributedString *bracerChar;
@property (strong, nonatomic) NSNumber *heightNumber;
@property (strong, nonatomic) NSNumber *useKern;
@property (strong, nonatomic) NSValue *useOrigin;
@property (strong, nonatomic) NSDictionary *bracerMetricsDict;

@property (nonatomic) Boolean hasStretchyDescenderPoint;
@property (nonatomic) CGPoint stretchyDescenderPoint;

- (id)initWithBracerCharacter: (NSAttributedString *)bracerChar
                   withHeight: (NSNumber *)heightNumber
                      useKern: (NSNumber *)useKern
                  originValue: (NSValue *)useOrigin;

- (void)buildMetricsDictionary;
- (NSAttributedString *)getClearStretchyCharacter;
- (NSAttributedString *)getClearStretchyCharacterWithKern: (BOOL)useKern;
- (NSArray *)stretchyDrawArrayInContext: (CGContextRef)context;
- (CGRect)computeBounds;

+ (NSDictionary *)getStretchyBracerMetrics;

@end

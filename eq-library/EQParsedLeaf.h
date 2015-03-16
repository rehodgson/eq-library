//
//  EQParsedLeaf.h
//  EQ Editor
//
//  Created by Raymond Hodgson on 06/5/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DDXML.h"

typedef enum
{
    leafTypeUnknown,
    leafTypeMI,
    leafTypeMO,
    leafTypeMN,
    leafTypeMText,
    leafTypeMSpace,
} ParsedLeafType;

typedef enum
{
    normalVariant,
    boldVariant,
    italicVariant,
    boldItalicVariant,
    doubleStruckVariant,
    boldFrakturVariant,
    scriptVariant,
    boldScriptVariant,
    frakturVariant,
    sansSerifVariant,
    boldSansSerifVariant,
    sansSerifItalicVariant,
    sansSerifBoldItalicVariant,
    monospaceVariant,
} MathVariantType;

@interface EQParsedLeaf : NSObject

@property (strong, nonatomic) NSString *parsedStr;
@property (nonatomic) ParsedLeafType parsedType;
@property (nonatomic) NSRange parsedRange;
@property (nonatomic) BOOL hasStretchyAttr;
@property (nonatomic) BOOL hasLargeOpAttr;
@property (nonatomic) MathVariantType mathVariant;
@property (nonatomic) CGFloat widthSpace;

- (id)initWithString: (NSString *)string type: (ParsedLeafType)type andRange: (NSRange)range;
- (DDXMLElement *)buildElement;
- (void)mergeWithLeaf: (EQParsedLeaf *)mergeLeaf;
+ (MathVariantType)getMathVariantForString: (NSString *)variantStr;

@end

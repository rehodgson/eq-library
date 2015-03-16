//
//  EQParsedLeaf.m
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

#import "EQParsedLeaf.h"
#import "DDXMLElementAdditions.h"
#import "EQXMLConstants.h"
#import "EQRenderTypesetter.h"

@implementation EQParsedLeaf

- (id)init
{
    self = [super init];
    if (self)
    {
        self->_parsedStr = nil;
        self->_parsedType = leafTypeUnknown;
        self->_parsedRange = NSMakeRange(NSNotFound, 0);
        self->_mathVariant = normalVariant;
        self->_widthSpace = 0.0;
    }
    return self;
}

- (id)initWithString: (NSString *)string type: (ParsedLeafType)type andRange: (NSRange)range
{
    self = [super init];
    if (self)
    {
        self->_parsedStr = string;
        self->_parsedType = type;
        self->_parsedRange = range;
        self->_mathVariant = normalVariant;
        self->_widthSpace = 0.0;
    }

    return self;
}

- (DDXMLElement *)buildElement
{
    if (nil == self.parsedStr)
    {
        return nil;
    }

    NSSet *stretchyCharacters = [EQRenderTypesetter getStretchyBracerCharacters];

    DDXMLElement *returnElement = nil;
    if (self.parsedType == leafTypeMI)
    {
        returnElement = [DDXMLElement elementWithName:kMI_LEAF stringValue:self.parsedStr];
    }
    else if (self.parsedType == leafTypeMN)
    {
        returnElement = [DDXMLElement elementWithName:kMN_LEAF stringValue:self.parsedStr];
    }
    else if (self.parsedType == leafTypeMO)
    {
        returnElement = [DDXMLElement elementWithName:kMO_LEAF stringValue:self.parsedStr];
    }
    else if (self.parsedType == leafTypeMSpace)
    {
        returnElement = [DDXMLElement elementWithName:kMSPACE_LEAF stringValue:@""];
        [returnElement addAttributeWithName:kWIDTH_SP_ATTR stringValue:[NSString stringWithFormat:@"%.3f em", self.widthSpace]];
    }
    else if (self.parsedType == leafTypeMText)
    {
        returnElement = [DDXMLElement elementWithName:kMTEXT_LEAF stringValue:self.parsedStr];
    }
    else if (self.parsedType == leafTypeUnknown)
    {
        NSLog(@"Unknown type found.");
    }

    if (nil != returnElement)
    {
        if (self.hasStretchyAttr)
        {
            [returnElement addAttributeWithName:kMSTRETCHY_ATTR stringValue:@"true"];
        }
        else if (self.parsedType == leafTypeMO && [stretchyCharacters containsObject:self.parsedStr])
        {
            [returnElement addAttributeWithName:kMSTRETCHY_ATTR stringValue:@"false"];
        }
        if (self.hasLargeOpAttr)
        {
            [returnElement addAttributeWithName:kMLARGE_OP_ATTR stringValue:@"true"];
        }
        if ((self.parsedType == leafTypeMI && self.mathVariant != italicVariant) ||
            (self.parsedType != leafTypeMI && self.mathVariant != normalVariant))
        {
            [returnElement addAttributeWithName:kMATH_VARIANT_ATTR stringValue:[self getStringForMathVariant:self.mathVariant]];
        }
    }

    return returnElement;
}

// Just fails silently.
- (void)mergeWithLeaf: (EQParsedLeaf *)mergeLeaf
{
    if (nil == mergeLeaf || self.parsedType != mergeLeaf.parsedType)
        return;

    if (mergeLeaf.parsedStr == nil || self.parsedStr == nil)
        return;

    self.parsedStr = [self.parsedStr stringByAppendingString:mergeLeaf.parsedStr];
    NSRange newRange = self.parsedRange;
    newRange.length += mergeLeaf.parsedRange.length;
    self.parsedRange = newRange;
}

/*
 From the MathML recommendation:
    normal | bold | italic | bold-italic | double-struck | bold-fraktur | script | bold-script | fraktur | sans-serif | bold-sans-serif 
    | sans-serif-italic | sans-serif-bold-italic | monospace
 */
- (NSString *)getStringForMathVariant: (MathVariantType)mathVariant
{
    if (mathVariant == normalVariant)
    {
        return @"normal";
    }
    else if (mathVariant == boldVariant)
    {
        return @"bold";
    }
    else if (mathVariant == italicVariant)
    {
        return @"italic";
    }
    else if (mathVariant == boldItalicVariant)
    {
        return @"bold-italic";
    }
    else if (mathVariant == doubleStruckVariant)
    {
        return @"double-struck";
    }
    else if (mathVariant == boldFrakturVariant)
    {
        return @"bold-fraktur";
    }
    else if (mathVariant == scriptVariant)
    {
        return @"script";
    }
    else if (mathVariant == boldScriptVariant)
    {
        return @"bold-script";
    }
    else if (mathVariant == frakturVariant)
    {
        return @"fraktur";
    }
    else if (mathVariant == sansSerifVariant)
    {
        return @"sans-serif";
    }
    else if (mathVariant == boldSansSerifVariant)
    {
        return @"bold-sans-serif";
    }
    else if (mathVariant == sansSerifItalicVariant)
    {
        return @"sans-serif-italic";
    }
    else if (mathVariant == sansSerifBoldItalicVariant)
    {
        return @"sans-serif-bold-italic";
    }
    else if (mathVariant == monospaceVariant)
    {
        return @"monospace";
    }
    return nil;
}

+ (MathVariantType)getMathVariantForString: (NSString *)variantStr
{
    NSDictionary *variantDict = @{@"normal":@(normalVariant),
                                  @"bold":@(boldVariant),
                                  @"italic":@(italicVariant),
                                  @"bold-italic":@(boldItalicVariant),
                                  @"double-struck":@(doubleStruckVariant),
                                  @"bold-fraktur":@(boldFrakturVariant),
                                  @"script":@(scriptVariant),
                                  @"bold-script":@(boldScriptVariant),
                                  @"fraktur":@(frakturVariant),
                                  @"sans-serif":@(sansSerifVariant),
                                  @"bold-sans-serif":@(boldSansSerifVariant),
                                  @"sans-serif-italic":@(sansSerifItalicVariant),
                                  @"sans-serif-bold-italic":@(sansSerifBoldItalicVariant),
                                  @"monospace":@(monospaceVariant) };

    NSNumber *testVariantNum = [variantDict valueForKey:variantStr];
    if (nil != testVariantNum)
    {
        return testVariantNum.intValue;
    }

    return normalVariant;
}

@end

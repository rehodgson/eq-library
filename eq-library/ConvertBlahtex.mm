//
//  ConvertBlahtex.m
//  EQ Writer 2
//
//  Created by Raymond Hodgson on 10/1/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "ConvertBlahtex.h"
#import "Interface.h"

@implementation ConvertBlahtex

// This is generally used for TeX->MathML->EQ Library imaging, which will have a better sizing algorithm overall.
// An example use case would be converting TeX to MathML while creating a PDF or PNG file.
+ (NSString *)convertTexToMML: (NSString *)inputStr isInline: (BOOL)isInline
{
    return [self convertTexToMML:inputStr isInline:isInline suppressStretchy:YES checkForDisplay:NO];
}

// This is needed for straight TeX->MathML conversions, which don't go through the EQ Library to size the bracers.
// An example use case would be converting TeX in HTML or ePub into MathML.
+ (NSString *)convertTexToMML: (NSString *)inputStr isInline: (BOOL)isInline suppressStretchy: (BOOL)suppressStretchy checkForDisplay:(BOOL)checkDisplay
{
    if (nil == inputStr || inputStr.length == 0)
    {
        return @"";
    }

    inputStr = [self stripMathDelimsFromString:inputStr];

    // Check for display is called to ensure that display style is used in the MathML output.
    // Important when rendering ePubs in iBooks.
    if (checkDisplay == YES && isInline == NO)
    {
        NSString *prefixStr = @"\\displaystyle";
        NSRange displayStyleRange = [inputStr rangeOfString:prefixStr options:NSCaseInsensitiveSearch];
        if (displayStyleRange.location == NSNotFound)
        {
            inputStr = [NSString stringWithFormat:@"%@ %@", prefixStr, inputStr];
        }
    }

    try
    {
        blahtex::Interface convertInterface;
        convertInterface.mMathmlOptions.mSpacingControl = blahtex::MathmlOptions::cSpacingControlRelaxed;
        convertInterface.mEncodingOptions.mMathmlEncoding = blahtex::EncodingOptions::cMathmlEncodingRaw;
        convertInterface.ProcessInput(NSStringToStringW(inputStr));
        std::wstring outputStr = convertInterface.GetMathml();
        NSString *returnStr = StringWToNSString(outputStr);

        returnStr = [self addMathMLWrapperToString:returnStr isInline:isInline];
        if (suppressStretchy == YES)
        {
            returnStr = [self stripStretchyAttributesFromString:returnStr];
        }
        return returnStr;
    }
    catch (blahtex::Exception& e)
    {
        NSString *errStr = StringWToNSString(e.GetCode());

        NSLog(@"Caught an exception and supressing it. Will return string with error.");
        NSLog(@"Exception description: %@", errStr);
        NSString *displayStr = @"block";
        if (isInline)
            displayStr = @"inline";

        // Search for a nonASCII character as well, since this is a common parsing error.
        NSCharacterSet *nonASCII = [[NSCharacterSet characterSetWithRange:NSMakeRange(0, 128)] invertedSet];
        NSRange nonASCIIRange = [inputStr rangeOfCharacterFromSet:nonASCII];
        if (nonASCIIRange.location != NSNotFound)
        {
            NSString *offendingCharacter = [inputStr substringWithRange:nonASCIIRange];
            errStr = [NSString stringWithFormat:@"Non ascii character \"%@\" found at location %lu.", offendingCharacter, (unsigned long)nonASCIIRange.location];
            NSLog(@"%@", errStr);
        }

        NSString *returnStr = [NSString stringWithFormat:@"<math display=\"%@\"><mtext>TeX conversion error: %@</mtext></math>", displayStr, errStr];
        return returnStr;
    }

    return @"";
}

+ (NSString *)stripMathDelimsFromString: (NSString *)inputStr
{
    if ([inputStr hasPrefix:@"\\["] || [inputStr hasPrefix:@"\\("] || [inputStr hasPrefix:@"$$"])
    {
        inputStr = [inputStr substringFromIndex:2];
    }

    if ([inputStr hasPrefix:@"$"])
    {
        inputStr = [inputStr substringToIndex:1];
    }

    if ([inputStr hasSuffix:@"\\]"] || [inputStr hasSuffix:@"\\)"])
    {
        inputStr = [inputStr substringWithRange:NSMakeRange(0, (inputStr.length - 2))];
    }

    if ([inputStr hasSuffix:@"$"])
    {
        inputStr = [inputStr substringWithRange:NSMakeRange(0, (inputStr.length - 1))];
    }

    return inputStr;
}

+ (NSString *)stripStretchyAttributesFromString: (NSString *)inputStr
{
    inputStr = [inputStr stringByReplacingOccurrencesOfString:@" stretchy=\"false\"" withString:@""];
    inputStr = [inputStr stringByReplacingOccurrencesOfString:@" stretchy='false'" withString:@""];

    return inputStr;
}

+ (NSString *)addMathMLWrapperToString: (NSString *)outputStr isInline: (BOOL)isInline
{
    if (![outputStr hasPrefix:@"<math"])
    {
        NSString *displayStyle = @"block";
        if (isInline)
        {
            displayStyle = @"inline";
        }
        NSString *prefixStr = [NSString stringWithFormat:@"<math display=\"%@\">", displayStyle];
        outputStr = [prefixStr stringByAppendingString:outputStr];
    }
    if (![outputStr hasSuffix:@"</math>"])
    {
        outputStr = [outputStr stringByAppendingString:@"</math>"];
    }
    return outputStr;
}

std::wstring NSStringToStringW ( NSString* Str )
{
    NSStringEncoding pEncode    =   CFStringConvertEncodingToNSStringEncoding ( kCFStringEncodingUTF32LE );
    NSData* pSData              =   [ Str dataUsingEncoding : pEncode ];

    return std::wstring ( (wchar_t*) [ pSData bytes ], [ pSData length] / sizeof ( wchar_t ) );
}

NSString* StringWToNSString ( const std::wstring& Str )
{
    NSString* pString = [ [ NSString alloc ]
                         initWithBytes : (char*)Str.data()
                         length : Str.size() * sizeof(wchar_t)
                         encoding : CFStringConvertEncodingToNSStringEncoding ( kCFStringEncodingUTF32LE ) ];
    return pString;
}

@end

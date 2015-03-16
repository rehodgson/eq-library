//
//  ConvertMathToImage.m
//  EQ Writer 2
//
//  Created by Raymond Hodgson on 11/4/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "ConvertMathToImage.h"
#import "ConvertBlahtex.h"
#import "EquationViewDataSource.h"
#import "EQXMLImporter.h"
#import "EQRenderEquation.h"

@implementation ConvertMathToImage

+ (UIImage *)convertTeXMathToPNG: (NSString *)mathStr
{
    if ([self mathIsEmpty:mathStr])
        return nil;

    BOOL mathIsInline = [self isInlineMath:mathStr];
    NSString *convertedMathML = [ConvertBlahtex convertTexToMML:mathStr isInline:mathIsInline];
    if (convertedMathML.length == 0)
        return nil;

    return [self convertMathMLToPNG:convertedMathML isInline:mathIsInline];
}

+ (UIImage *)convertMathMLToPNG: (NSString *)mathStr
{
    if ([self mathIsEmpty:mathStr])
        return nil;

    BOOL mathIsInline = [self isInlineMathML:mathStr];

    return [self convertMathMLToPNG:mathStr isInline:mathIsInline];
}


+ (UIImage *)convertMathMLToPNG: (NSString *)mathMLStr isInline: (BOOL)mathIsInline
{
    EquationViewDataSource *newDataSource = [EQXMLImporter populateDataSourceWithXMLString:mathMLStr];
    EQRenderEquation *newEquationData = [newDataSource buildRenderEquation];
    newEquationData.usePDFMode = NO;
    newEquationData.shouldFlipContext = YES;

    // May make this user configurable.
    BOOL useTransparency = YES;

    CGSize scaledSize;
    CGFloat adjustY = 0.0;
    CGFloat adjustX = 0.0;
    if (mathIsInline)
    {
        newEquationData.pdfScale = 0.9;
        [newEquationData layoutEquationLines];
        scaledSize = [newEquationData computeInlineSize];
        adjustY = -12.0;
        adjustX = -35.0;
        scaledSize.width *= 1.5;
        scaledSize.height *= 2.0;
        CGSize testDrawSize = [newEquationData drawSize];
        testDrawSize.height -= 20.0;
        testDrawSize.width -= 30.0;
        if (testDrawSize.width > 90.0)
        {
            testDrawSize.width -= 45.0;
        }
        scaledSize = testDrawSize;
    }
    else
    {
        // Compute the size needed for the new image.
        newEquationData.pdfScale = 1.0;
        [newEquationData layoutEquationLines];

        scaledSize = newEquationData.drawSize;
        scaledSize.width *= newEquationData.pdfScale;
        scaledSize.height *= newEquationData.pdfScale;
        scaledSize.width += 40.0;
    }

    CGRect drawRect = CGRectMake(-20.0 + adjustX, -45.0 + adjustY, scaledSize.width, scaledSize.height);

    UIGraphicsBeginImageContextWithOptions(scaledSize, !useTransparency, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Return if unable to create the context for some reason.
    if (context == NULL || context == nil)
    {
        UIGraphicsEndImageContext();
        return nil;
    }
    CGContextSetShouldAntialias(context, YES);
    CGContextSetShouldSmoothFonts(context, YES);

    UIColor *bkgndColor = [UIColor clearColor];
    if (useTransparency == NO)
    {
        bkgndColor = [UIColor whiteColor];
    }
    // Need to draw some sort of background for it first.
    CGContextSaveGState(context);
    //set alpha to 0, push the fill color:
    CGContextSetAlpha(context, 1.0);

    //add a white rectangle to the background:
    CGContextSetFillColorWithColor(context, bkgndColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, scaledSize.width, scaledSize.height));

    //pop the fill color
    CGContextRestoreGState(context);

    [newEquationData drawEquationLinesInRect:drawRect];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

// Assumes the string is valid, so this method is intended
// to just be a quick check before passing the string to BlahTex.
+ (BOOL)isInlineMath: (NSString *)inputStr
{
    if ([inputStr hasPrefix:@"\\("] || [inputStr hasPrefix:@"$"])
        return YES;

    return NO;
}

+ (BOOL)isInlineMathML: (NSString *)inputStr
{
    NSString *inlineTestStr = @"display=\"inline\"";
    if ([inputStr rangeOfString:inlineTestStr].location != NSNotFound)
    {
        return YES;
    }

    inlineTestStr = @"display='inline'";
    if ([inputStr rangeOfString:inlineTestStr].location != NSNotFound)
    {
        return YES;
    }

    return NO;
}

+ (BOOL)isMathML: (NSString *)inputStr
{
    if ([inputStr hasPrefix:@"<math"] && [inputStr hasSuffix:@"</math>"])
    {
        return YES;
    }

    return NO;
}

+ (BOOL)mathIsEmpty: (NSString *)mathStr
{
    if (mathStr.length == 0)
        return YES;

    NSString *testStr = [mathStr stringByReplacingOccurrencesOfString:@" " withString:@""];

    if ([testStr hasPrefix:@"<math"])
    {
        if (testStr.length <= 5)
            return YES;

        NSRegularExpression *extractMathML = [[NSRegularExpression alloc] initWithPattern:@"<math[^>]*>(.*?)</math>" options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators) error:NULL];
        NSArray *matchesArray = [extractMathML matchesInString:testStr options:0 range:NSMakeRange(0, testStr.length)];
        if (matchesArray.count > 0)
        {
            NSTextCheckingResult *result = matchesArray[0];
            NSRange mathStrRange = [result rangeAtIndex:1];
            if (mathStrRange.length > 0)
            {
                return NO;
            }
            return YES;
        }
    }
    else if ([testStr hasPrefix:@"\\["] && [testStr hasSuffix:@"\\]"])
    {
        if (testStr.length <= 3)
            return YES;

        // Usual LaTeX equation.
        testStr = [testStr substringFromIndex:2];
        testStr = [testStr substringToIndex:(testStr.length - 2)];
        if (testStr.length == 0)
            return YES;
    }

    return NO;
}

@end

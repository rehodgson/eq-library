//
//  ConvertMathToImage.m
//  EQ Writer 2
//
//  Created by Raymond Hodgson on 11/4/14.
//  Copyright (c) 2014 Raymond Hodgson. All rights reserved.
//

#import "ConvertMathToImage.h"
#import "ConvertBlahtex.h"
#import "EquationViewDataSource.h"
#import "EQXMLImporter.h"
#import "EQRenderEquation.h"

@implementation ConvertMathToImage

+ (NSData *)convertTeXMathToPNG: (NSString *)mathStr
{
    if ([self mathIsEmpty:mathStr])
        return nil;

    BOOL mathIsInline = [self isInlineMath:mathStr];
    NSString *convertedMathML = [ConvertBlahtex convertTexToMML:mathStr isInline:mathIsInline];
    if (convertedMathML.length == 0)
        return nil;

    return [self convertMathMLToPNG:convertedMathML isInline:mathIsInline];
}

+ (NSData *)convertMathMLToPNG: (NSString *)mathStr
{
    if ([self mathIsEmpty:mathStr])
        return nil;

    BOOL mathIsInline = [self isInlineMathML:mathStr];

    return [self convertMathMLToPNG:mathStr isInline:mathIsInline];
}


+ (NSData *)convertMathMLToPNG: (NSString *)mathMLStr isInline: (BOOL)mathIsInline
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

    NSData *returnData = UIImagePNGRepresentation(newImage);
    return returnData;
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

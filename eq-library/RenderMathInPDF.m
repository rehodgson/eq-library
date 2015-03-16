//
//  RenderMathInPDF.m
//  eq-library
//
//  Created by Raymond Hodgson on 03/16/15.
//  Copyright (c) 2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "RenderMathInPDF.h"
#import "EQRenderEquation.h"
#import "ConvertBlahtex.h"
#import "EQXMLImporter.h"

@implementation RenderMathInPDF

// This is an example method that may work fine for your needs, but likely won't be correct as-is.
// This method can be broken into different pieces depending on how your code handles layout PDF drawing.
+ (void)drawTeXStr: (NSString *)texStr isInline: (BOOL)isInline atPoint: (CGPoint)drawOrigin
{
    // Again, only include this if you actually use TeX.
    NSString *mathMLStr = [ConvertBlahtex convertTexToMML:texStr isInline:isInline];

    // This calls an XML parser to turn the resulting string into a data source that can be read from to generate draw commands.
    EquationViewDataSource *newDataSource = [EQXMLImporter populateDataSourceWithXMLString:mathMLStr];

    // This is the resulting class which includes all the data to generate the draw commands and code to draw the math equation.
    EQRenderEquation *newEquationData = [newDataSource buildRenderEquation];

    // This is important if you are generating a PDF on iOS as it tells the class to use the TTF files to draw instead of the OTF.
    // OTF fonts are not (currently) added correctly to the resulting PDF and you get missing glyphs.
    newEquationData.usePDFMode = YES;

    // This may need to be YES depending on whether your context uses the default iOS or the CoreGraphics origin.
    // Also, TextKit seems to flip the context on its own when drawing to PDF so telling it to flip a second time undoes that work.
    newEquationData.shouldFlipContext = NO;

    // This will likely need to be adjusted to match the size of the surrounding text or your equation may appear
    // too large or too small compared to the rest of the text.
    // Remember that it draws using vector graphics, so scaling up/down is no big deal.
    newEquationData.pdfScale = 1.0;

    // This tells the class to size and layout the stored math.
    // This has a small amount of overhead but is necessary if you want to find out how big your equation is beforehand.
    // Math is rendered by the library as display equation by default.
    [newEquationData layoutEquationLines];

    // You need to multiply the computed size by any scale factor as the math is not actually scaled until it is draw in the context.
    CGSize scaledSize;
    if (isInline)
    {
        // Uses a different method to compute the size, may not be as accurate.
        // Inline math is "best guess" scaled down version.
        // You can just toss this and use your own code if you like it better.
        CGSize scaledSize = [newEquationData computeInlineSize];
        scaledSize.width *= 0.7;
        scaledSize.height *= 0.7;
    }
    else
    {
        // This is more tested as code base was originally designed to draw display equations.
        // You need to take the scaled size and multiply it
        scaledSize = newEquationData.drawSize;
        scaledSize.width *= newEquationData.pdfScale;
        scaledSize.height *= newEquationData.pdfScale;
    }

    // Resulting frame with the given origin and the computed size.
    CGRect drawFrame = CGRectMake(drawOrigin.x, drawOrigin.y, scaledSize.width, scaledSize.height);

    // This is where the drawing actually occurs.
    // a core graphics context of some sort is *required* at this point.
    [newEquationData drawEquationLinesInRect:drawFrame];
}

@end

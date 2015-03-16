//
//  EQRenderMatrixStem.m
//  EQ Editor
//
//  Created by Raymond Hodgson on 05/6/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "EQRenderMatrixStem.h"
#import "EQRenderMatrixRowStem.h"
#import "EQRenderData.h"
#import "EQRenderFontDictionary.h"

@interface EQRenderMatrixStem()
{
    CGSize storedLayoutSize;
}

- (CGFloat)computeBaseSizeUsingArray: (NSArray *)sizeArray;

@end

@implementation EQRenderMatrixStem

- (id) init
{
    self = [super init];
    if (self)
    {
        self.stemType = stemTypeMatrix;
        self->storedLayoutSize = CGSizeZero;
    }

    return self;
}

- (id) initWithObject:(id)object
{
    self = [super initWithObject:object];
    if (self)
    {
        self.stemType = stemTypeMatrix;
        self->storedLayoutSize = CGSizeZero;
    }

    return self;
}

- (id) initWithObject:(id)object andStemType:(EQRenderStemType)stemType
{
    self = [super initWithObject:object andStemType:stemTypeMatrix];
    if (self)
    {
        self.stemType = stemTypeMatrix;
        self->storedLayoutSize = CGSizeZero;
    }

    return self;
}

- (id) initWithStoredCharacterData: (NSString *)storedCharacterData
{
    self = [super init];
    if (self)
    {
        // Parse the stored character data (a string like "2x2") to determine how large to make the matrix.
        if (nil != storedCharacterData && storedCharacterData.length >= 3)
        {
            NSRange parseRange = [storedCharacterData rangeOfString:@"x"];
            if (parseRange.location != NSNotFound && parseRange.location > 0 && (parseRange.location + 1) < storedCharacterData.length)
            {
                NSString *leftString = [storedCharacterData substringToIndex:parseRange.location];
                NSString *rightString = [storedCharacterData substringFromIndex:(parseRange.location + 1)];

                NSInteger leftValue = [leftString integerValue];
                NSInteger rightValue = [rightString integerValue];
                if (leftValue > 0 && rightValue > 0)
                {
                    for (NSInteger i = 0; i < leftValue; i++)
                    {
                        EQRenderMatrixRowStem *newRowStem = [[EQRenderMatrixRowStem alloc] initWithColumns:rightValue];
                        [self appendChild:newRowStem];
                    }
                }
            }
        }
        self.stemType = stemTypeMatrix;
    }

    return self;
}

- (void) addChildDataToRenderArray: (NSMutableArray *)renderData
{
    if (nil != self.renderArray && self.renderArray.count > 0)
    {
        for (id renderObj in self.renderArray)
        {
            // Shouldn't happen, but should just treat this like any other stem.
            if ([renderObj isKindOfClass:[EQRenderData class]])
            {
                [renderData addObject:renderObj];
            }
            else if ([renderObj isKindOfClass:[EQRenderMatrixRowStem class]])
            {
                [(EQRenderMatrixRowStem *)renderObj addChildDataToRenderArray:renderData];
            }
        }
    }
}


- (void)layoutChildren
{
    self->storedLayoutSize = CGSizeZero;

    if (nil == self.renderArray || self.renderArray.count == 0)
    {
        // Should always update bounds after calling this method.
        [self updateBounds];
        return;
    }

    NSArray *boundsArray = [self computeBoundsArrayForChildren];

    if (nil == boundsArray)
    {
        return;
    }

    int childCounter = 0;
    for (id renderObj in self.renderArray)
    {
        if ([renderObj isKindOfClass:[EQRenderMatrixRowStem class]])
        {
            EQRenderMatrixRowStem *matrixRowStem = (EQRenderMatrixRowStem *)renderObj;
            NSAssert(childCounter < boundsArray.count, @"Child location is outside computed bounds array!");
            NSArray *rowBounds = [boundsArray objectAtIndex:childCounter];
            [matrixRowStem updateChildOriginsWithBoundsArray:rowBounds];
            [matrixRowStem layoutChildren];
        }
        else if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)renderObj layoutChildren];
        }
        childCounter ++;
    }

    // Should always update bounds after calling this method.
    [self updateBounds];
}

- (NSArray *)computeBoundsArrayForChildren
{
    if (nil == self.renderArray || self.renderArray.count == 0)
    {
        return nil;
    }

    NSMutableArray *returnArray = [[NSMutableArray alloc] init];

    // Build an array containing the widths and heights of each cell.
    NSMutableArray *columnRectsArray = [[NSMutableArray alloc] init];
    for (id renderObj in self.renderArray)
    {
        if ([renderObj isKindOfClass:[EQRenderMatrixRowStem class]])
        {
            NSMutableArray *columnRects = [(EQRenderMatrixRowStem *)renderObj columnRects];
            [columnRectsArray addObject:columnRects];
        }
        else
        {
            NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
            [columnRectsArray addObject:emptyArray];
        }
    }

    NSMutableArray *colWidthsArray = [[NSMutableArray alloc] init];
    NSMutableArray *rowHeightsArray = [[NSMutableArray alloc] init];

    for (NSMutableArray *columnRects in columnRectsArray)
    {
        int colCounter = 0;
        CGFloat cellHeight = 0.0;

        if (columnRects.count > 0)
        {
            for (NSValue *cellBoundsValue in columnRects)
            {
                CGRect cellBounds = cellBoundsValue.CGRectValue;
                cellHeight = MAX(cellHeight, cellBounds.size.height);

                if (colCounter < colWidthsArray.count)
                {
                    NSNumber *storedColWidth = colWidthsArray[colCounter];
                    if (storedColWidth.floatValue < cellBounds.size.width)
                    {
                        colWidthsArray[colCounter] = @(cellBounds.size.width);
                    }
                }
                else
                {
                    [colWidthsArray addObject:@(cellBounds.size.width)];
                }
                colCounter ++;
            }
        }
        [rowHeightsArray addObject:@(cellHeight)];
    }

    // Call method to compute overall width and height.
    CGFloat baseWidth = [self computeBaseSizeUsingArray:colWidthsArray];
    CGFloat baseHeight = [self computeBaseSizeUsingArray:rowHeightsArray];

    // Use the overall height to adjust the yOffset so that the matrix is centered vertically.
    CGPoint initialOrigin = self.drawOrigin;
    initialOrigin.x += 0.05 * kDEFAULT_FONT_SIZE;

    // If the height is too smaller, it is likely a 1xN matrix which won't need centered vertically
    if (baseHeight > 40.0)
    {
        initialOrigin.y += 0.15 * baseHeight;
    }
    CGFloat currentYLoc = initialOrigin.y;

    CGFloat rowMargin = 0;
    CGFloat colMargin;
    CGFloat leftMargin = 0;
    CGFloat rightMargin = 0;

    // Use the computed width to help determine the spacing and margins around the matrix.
    // Need to compute other row/col margins.
    // Have only finished the last one.
    if (baseWidth > 125)
    {
        colMargin = 0.5 * kDEFAULT_FONT_SIZE;
    }
    else if (baseWidth >= 75)
    {
        colMargin = 0.5 * kDEFAULT_FONT_SIZE;
    }
    else if (baseWidth >= 50)
    {
        colMargin = 0.5 * kDEFAULT_FONT_SIZE;
        rowMargin = -0.25 * kDEFAULT_FONT_SIZE;
        leftMargin = -0.05 * kDEFAULT_FONT_SIZE;
        rightMargin = -0.05 * kDEFAULT_FONT_SIZE;
    }
    else
    {
        colMargin = 0.5 * kDEFAULT_FONT_SIZE;
        rowMargin = -0.25 * kDEFAULT_FONT_SIZE;
        leftMargin = 0.25 * kDEFAULT_FONT_SIZE;
        rightMargin = 0.125 * kDEFAULT_FONT_SIZE;

        // Likely uses a larger bracer size here, which requires a different adjustment.
        if (baseHeight >= 100)
        {
            leftMargin = 0.36 * kDEFAULT_FONT_SIZE;
        }
    }

    CGFloat useWidthSize = 0.0;
    CGFloat useHeightSize = 0.0;

    for (long i = (rowHeightsArray.count - 1); i >= 0; i--)
    {
        NSNumber *storedHeightNumber = rowHeightsArray[i];
        NSArray *currentColRectArray = columnRectsArray[i];
        NSMutableArray *rowBoundsArray = [[NSMutableArray alloc] init];

        CGFloat currentXLoc = initialOrigin.x + leftMargin;
        CGFloat testWidthSize = 0.0;
        int colCounter = 0;
        for (NSNumber *storedWidthNumber in colWidthsArray)
        {
            // If an adjustment was needed due to descenders, the adjustment value was stored here.
            CGRect curCellRect = [(NSValue *)currentColRectArray[colCounter] CGRectValue];
            CGFloat useYLoc = currentYLoc + curCellRect.origin.y;

            CGRect cellBounds = CGRectMake(currentXLoc, useYLoc, storedWidthNumber.floatValue, storedHeightNumber.floatValue);
            [rowBoundsArray addObject:[NSValue valueWithCGRect:cellBounds]];

            currentXLoc += storedWidthNumber.floatValue + colMargin;
            testWidthSize += storedWidthNumber.floatValue + colMargin;
            colCounter ++;
        }

        [returnArray insertObject:rowBoundsArray atIndex:0];
        currentYLoc -= storedHeightNumber.floatValue + rowMargin;

        useWidthSize = MAX(useWidthSize, testWidthSize);
        useHeightSize += storedHeightNumber.floatValue + rowMargin;
    }
    useWidthSize += rightMargin;

    self->storedLayoutSize = CGSizeMake(useWidthSize, useHeightSize);

    return returnArray;
}

- (void)updateBounds
{
    CGRect enclosingRect = [self computeEnclosingRect];
    self.drawSize = enclosingRect.size;

    enclosingRect.origin = CGPointZero;
    self.drawBounds = enclosingRect;
}

- (CGRect)computeEnclosingRect
{
    CGRect returnRect = CGRectZero;

    if (nil == self.renderArray || self.renderArray.count == 0)
        return returnRect;

    returnRect.origin = self.drawOrigin;
    for (id renderObj in self.renderArray)
    {
        CGRect testLeftRect = CGRectZero;
        CGRect testRightRect = CGRectZero;

        if ([renderObj isKindOfClass:[EQRenderMatrixRowStem class]])
        {
            testLeftRect = [(EQRenderMatrixRowStem *)renderObj leftmostChildRect];
            testRightRect = [(EQRenderMatrixRowStem *)renderObj rightmostChildRect];
        }
        else
        {
            continue;
        }

        returnRect.origin.x = MIN(returnRect.origin.x, testLeftRect.origin.x);
        returnRect.origin.y = MIN(returnRect.origin.y, testLeftRect.origin.y);
        CGFloat useRightEdge = MAX(CGRectGetMaxX(returnRect), CGRectGetMaxX(testRightRect));
        CGFloat useTopEdge = MAX(CGRectGetMaxY(returnRect), CGRectGetMaxY(testRightRect));
        returnRect.size.width = useRightEdge - returnRect.origin.x;
        returnRect.size.height = useTopEdge - returnRect.origin.y;
    }

    return returnRect;
}

- (CGFloat)computeBaseSizeUsingArray: (NSArray *)sizeArray
{
    if (nil == sizeArray || sizeArray.count == 0)
        return 0.0;

    CGFloat returnSize = 0.0;

    for (NSNumber *storedSizeNumber in sizeArray)
    {
        returnSize += storedSizeNumber.floatValue;
    }

    return returnSize;
}

- (id)getFirstCellObj
{
    if (nil == self.renderArray || self.renderArray.count == 0)
        return nil;

    id returnObj = nil;

    id firstRowChild = [self getFirstChild];
    if (nil != firstRowChild && [firstRowChild isKindOfClass:[EQRenderMatrixRowStem class]])
    {
        id firstCellChild = [(EQRenderMatrixRowStem *)firstRowChild getFirstChild];
        if (nil != firstCellChild && [firstCellChild isKindOfClass:[EQRenderStem class]]
            && [(EQRenderStem *)firstCellChild stemType] == stemTypeMatrixCell)
        {
            returnObj = [(EQRenderStem *)firstCellChild getFirstChild];
        }
    }

    return returnObj;
}

@end

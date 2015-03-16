//
//  EQRenderMatrixRowStem.m
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

#import "EQRenderMatrixRowStem.h"
#import "EQRenderData.h"
#import "EQRenderLayout.h"

@implementation EQRenderMatrixRowStem

- (id) init
{
    self = [super init];
    if (self)
    {
        self.stemType = stemTypeMatrixRow;
    }

    return self;
}

- (id) initWithObject:(id)object
{
    self = [super initWithObject:object];
    if (self)
    {
        self.stemType = stemTypeMatrixRow;
    }

    return self;
}

- (id) initWithObject:(id)object andStemType:(EQRenderStemType)stemType
{
    self = [super initWithObject:object andStemType:stemTypeMatrixRow];
    if (self)
    {
        self.stemType = stemTypeMatrixRow;
    }

    return self;
}

- (id) initWithColumns: (NSInteger)numOfColumns
{
    self = [super init];
    if (self)
    {
        self.stemType = stemTypeMatrixRow;
        if (numOfColumns > 0)
        {
            for (NSUInteger i = 0; i < numOfColumns; i ++)
            {
                EQRenderData *newDataCell = [[EQRenderData alloc] initWithString:@"0"];
                EQRenderStem *newCellStem = [[EQRenderStem alloc] initWithObject:newDataCell andStemType:stemTypeMatrixCell];
                [self appendChild:newCellStem];
            }
        }
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
            else if ([renderObj isKindOfClass:[EQRenderStem class]])
            {
                EQRenderStem *renderStem = (EQRenderStem *)renderObj;
                if (renderStem.stemType == stemTypeMatrixCell)
                {
                    [renderStem addChildDataToRenderArray:renderData];
                }
            }
        }
    }
}

// This should always be called after you have called updateChildOriginsWithBoundsArray.
// It does nothing to compute the layout of its children directly as that requires that you know
// the column and row sizes.
// Also, doesn't bother with computing the bounds as its sizing is superceded by the parent matrix.

- (void)layoutChildren
{
    if (nil == self.renderArray || self.renderArray.count == 0)
    {
        return;
    }

    for (id renderObj in self.renderArray)
    {
        if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            [(EQRenderStem *)renderObj layoutChildren];
        }
    }
}

- (CGRect)leftmostChildRect
{
    if (nil == self.renderArray || self.renderArray.count == 0)
        return CGRectZero;

    id firstChild = self.getFirstChild;
    if ([firstChild respondsToSelector:@selector(drawOrigin)] && [firstChild respondsToSelector:@selector(drawSize)])
    {
        CGPoint childOrigin = [firstChild drawOrigin];
        CGSize childSize = [firstChild drawSize];

        return CGRectMake(childOrigin.x, childOrigin.y, childSize.width, childSize.height);
    }

    return CGRectZero;
}

- (CGRect)rightmostChildRect
{
    if (nil == self.renderArray || self.renderArray.count == 0)
        return CGRectZero;

    id lastChild = self.getLastChild;
    if ([lastChild respondsToSelector:@selector(drawOrigin)] && [lastChild respondsToSelector:@selector(drawSize)])
    {
        CGPoint childOrigin = [lastChild drawOrigin];
        CGSize childSize = [lastChild drawSize];

        return CGRectMake(childOrigin.x, childOrigin.y, childSize.width, childSize.height);
    }

    return CGRectZero;
}


- (NSMutableArray *)columnRects
{
    if (nil == self.renderArray || self.renderArray.count == 0)
    {
        return nil;
    }

    NSMutableArray *returnArray = [[NSMutableArray alloc] init];

    for (id renderObj in self.renderArray)
    {
        NSValue *newRect = [NSValue valueWithCGRect:CGRectZero];

        // Shouldn't have any renderData objects, but may as well support them.
        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            newRect = [NSValue valueWithCGRect:[(EQRenderData *)renderObj typographicBounds]];
        }
        else if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            CGRect testRect = [(EQRenderStem *)renderObj computeTypographicalLayout];

            // Make sure to also adjust to account for the descenders.
            CGFloat testAdjust = [self adjustForDescenderChildrenInStem:(EQRenderStem *)renderObj];
            testRect.size.height += testAdjust;
            testRect.origin.y -= testAdjust;

            newRect = [NSValue valueWithCGRect:testRect];
        }
        if (CGRectEqualToRect(newRect.CGRectValue, CGRectZero))
        {
            newRect = [NSValue valueWithCGRect:CGRectMake(0, 0, 13.5, 36)];
        }

        [returnArray addObject:newRect];
    }

    return returnArray;
}

// Computes the difference between the origin and its lowest descender.
// Important for matrix layout as you need to adjust the layout for each row to account for descenders.
- (CGFloat)adjustForDescenderChildrenInStem: (EQRenderStem *)parentStem
{
    if (nil == parentStem || nil == parentStem.renderArray || parentStem.renderArray.count == 0)
        return 0.0;

    CGFloat adjustValue = 0.0;
    for (id renderObj in parentStem.renderArray)
    {
        CGFloat testValue = 0.0;
        if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            EQRenderStem *renderStem = (EQRenderStem *)renderObj;
            if (renderStem.isStemWithDescender)
            {
                CGPoint testDescender = [EQRenderLayout findLowestChildOrigin:renderStem];
                if (testDescender.y > renderStem.drawOrigin.y)
                {
                    testValue = testDescender.y - renderStem.drawOrigin.y;
                }
            }
        }
        adjustValue = MAX(adjustValue, testValue);
    }
    return adjustValue;
}

// Update your children when given an array with the proposed origin and width.
// This is compared to the typographical width so that each origin is centered horizontally.

- (void)updateChildOriginsWithBoundsArray: (NSArray *)boundsArray
{
    if (nil == boundsArray || boundsArray.count == 0)
        return;

    NSUInteger childCounter = 0;
    for (id renderObj in self.renderArray)
    {
        // Test to make sure it is in bounds.
        NSAssert(childCounter < boundsArray.count, @"Bounds array and number of children do not match!");

        NSValue *boundsRectValue = [boundsArray objectAtIndex:childCounter];
        NSAssert([boundsRectValue isKindOfClass:[NSValue class]], @"Bounds array must contain only NSValue objects.");

        CGRect boundsRect = boundsRectValue.CGRectValue;
        CGPoint proposedOrigin = boundsRect.origin;
        CGSize columnSize = boundsRect.size;

        CGRect childBounds = CGRectZero;

        if ([renderObj isKindOfClass:[EQRenderData class]])
        {
            childBounds = [(EQRenderData *)renderObj typographicBounds];
        }
        else if ([renderObj isKindOfClass:[EQRenderStem class]])
        {
            childBounds = [(EQRenderStem *)renderObj computeTypographicalLayout];
        }

        if ((childBounds.size.width + 3) >= columnSize.width)
        {
            [renderObj setDrawOrigin:proposedOrigin];
        }
        else
        {
            CGFloat widthAdjust = childBounds.size.width;
            widthAdjust <= 0.0 ? widthAdjust = 6.0: widthAdjust;
            CGFloat xOffset = ABS(columnSize.width - widthAdjust) / 2.0;
            proposedOrigin.x += xOffset;
            [renderObj setDrawOrigin:proposedOrigin];
        }

        childCounter ++;
    }
}

- (void)updateBounds
{

}


@end

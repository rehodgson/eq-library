//
//  EQTextRange.m
//  eq-library
//
//  Created by Raymond Hodgson on 31/08/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "EQTextRange.h"

@implementation EQTextRange

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_dataLoc = 0;
        self->_equationLoc = 0;
        self->_range = NSMakeRange(NSNotFound, 0);
    }

    return self;
}

- (id)copy
{
    id copy = [[[self class] alloc] init];

    if (copy)
    {
        [copy setDataLoc:self->_dataLoc];
        [copy setEquationLoc:self->_equationLoc];
        [copy setRange:self->_range];
    }

    return copy;
}


// Syntactic sugar that converts internal start location into a textPosition before returning.
- (EQTextPosition *)textPosition
{
    return [EQTextPosition textPositionWithIndex:self.range.location andLocation:self.dataLoc andEquationLoc:self.equationLoc];
}

// Syntactic sugar that converts internal end location into a textPosition before returning.
- (EQTextPosition *)endPosition
{
    if (self.range.location == NSNotFound)
        return [EQTextPosition textPositionWithIndex:self.range.location andLocation:self.dataLoc andEquationLoc:self.equationLoc];

    NSInteger index = self.range.location + self.range.length;
    return [EQTextPosition textPositionWithIndex:index andLocation:self.dataLoc andEquationLoc:self.equationLoc];
}

+ (EQTextRange *)textRangeWithRange: (NSRange) range andLocation: (NSUInteger)dataLoc andEquationLoc: (NSUInteger)equationLoc
{
    EQTextRange *newRange = [[EQTextRange alloc] init];
    newRange.range = range;
    newRange.dataLoc = dataLoc;
    newRange.equationLoc = equationLoc;

    return newRange;
}


+ (EQTextRange *) textRangeWithPosition:(EQTextPosition *)position
{
    EQTextRange *newRange = [[EQTextRange alloc] init];
    newRange.dataLoc = position.dataLoc;
    newRange.range = NSMakeRange(position.index, 0);
    newRange.equationLoc = position.equationLoc;

    return newRange;
}

+ (NSComparisonResult) compareTextRange: (EQTextRange *)firstRange toRange: (EQTextRange *)secondRange
{
    if (firstRange.equationLoc < secondRange.equationLoc)
        return NSOrderedAscending;
    else if (firstRange.equationLoc > secondRange.equationLoc)
        return NSOrderedDescending;

    if (firstRange.dataLoc < secondRange.dataLoc)
        return NSOrderedAscending;
    else if (firstRange.dataLoc > secondRange.dataLoc)
        return NSOrderedDescending;

    if (firstRange.range.location < secondRange.range.location)
        return NSOrderedAscending;
    else if (firstRange.range.location > secondRange.range.location)
        return NSOrderedDescending;

    return NSOrderedSame;
}


- (UITextPosition *)start
{
    return [EQTextPosition textPositionWithIndex:self.range.location andLocation:self.dataLoc andEquationLoc:self.equationLoc];
}

- (UITextPosition *)end
{
    return [EQTextPosition textPositionWithIndex:(self.range.location + self.range.length) andLocation:self.dataLoc andEquationLoc:self.equationLoc];
}

- (BOOL)isEmpty
{
    return (self.range.length == 0);
}

/************************
 NSCoding support methods
 ************************/

/*
 @property (nonatomic) NSRange range;
 @property (nonatomic) NSUInteger dataLoc;
 @property (nonatomic) NSUInteger equationLoc;
 */

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(1.0) forKey:@"TextRangeVersionNumber"];

    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeObject:@(self.dataLoc) forKey:@"dataLoc"];
    [aCoder encodeObject:@(self.equationLoc) forKey:@"equationLoc"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self)
    {
        NSNumber *versionNumber = [aDecoder decodeObjectForKey:@"TextRangeVersionNumber"];
        if (nil != versionNumber && versionNumber.doubleValue >= 1.0 && versionNumber.doubleValue < 2.0)
        {
            self->_range = [(NSValue *)[aDecoder decodeObjectForKey:@"range"] rangeValue];
            self->_dataLoc = [(NSNumber *)[aDecoder decodeObjectForKey:@"dataLoc"] unsignedIntegerValue];
            self->_equationLoc = [(NSNumber *)[aDecoder decodeObjectForKey:@"equationLoc"] unsignedIntegerValue];
        }
    }

    return self;
}


@end

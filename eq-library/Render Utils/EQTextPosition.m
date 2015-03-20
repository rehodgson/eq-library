//
//  EQTextPosition.m
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

#import "EQTextPosition.h"

@implementation EQTextPosition

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_dataLoc = 0;
        self->_index = 0;
        self->_equationLoc = 0;
    }
    
    return self;
}

- (id)copy
{
    id copy = [[[self class] alloc] init];

    if (copy)
    {
        [copy setIndex:self->_index];
        [copy setDataLoc:self->_dataLoc];
        [copy setEquationLoc:self->_equationLoc];
    }

    return copy;
}

+ (EQTextPosition *)textPositionWithIndex:(NSUInteger)index andLocation:(NSUInteger)dataLoc andEquationLoc:(NSUInteger)equationLoc
{
    EQTextPosition *newPos = [[EQTextPosition alloc] init];
    newPos.index = index;
    newPos.dataLoc = dataLoc;
    newPos.equationLoc = equationLoc;

    return newPos;
}

+ (NSComparisonResult)compareTextPosition:(EQTextPosition *)position toPosition:(EQTextPosition *)other
{
    // Compare equation locations first.
    if (position.equationLoc < other.equationLoc)
        return NSOrderedAscending;

    if (position.equationLoc > other.equationLoc)
        return NSOrderedDescending;

    // Compare data locations next.
    if (position.dataLoc < other.dataLoc)
        return NSOrderedAscending;

    if (position.dataLoc > other.dataLoc)
        return NSOrderedDescending;

    // Data positions are equal, so compare indexes.
    if (position.index < other.index) {
        return NSOrderedAscending;
    }
    if (position.index > other.index) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}



/************************
 NSCoding support methods
 ************************/

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(1.0) forKey:@"TextPositionVersionNumber"];

    [aCoder encodeObject:@(self.index) forKey:@"index"];
    [aCoder encodeObject:@(self.dataLoc) forKey:@"dataLoc"];
    [aCoder encodeObject:@(self.equationLoc) forKey:@"equationLoc"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self)
    {
        NSNumber *versionNumber = [aDecoder decodeObjectForKey:@"TextPositionVersionNumber"];
        if (nil != versionNumber && versionNumber.doubleValue >= 1.0 && versionNumber.doubleValue < 2.0)
        {
            self->_index = [(NSNumber *)[aDecoder decodeObjectForKey:@"index"] unsignedIntegerValue];
            self->_dataLoc = [(NSNumber *)[aDecoder decodeObjectForKey:@"dataLoc"] unsignedIntegerValue];
            self->_equationLoc = [(NSNumber *)[aDecoder decodeObjectForKey:@"equationLoc"] unsignedIntegerValue];
        }
    }

    return self;
}


@end

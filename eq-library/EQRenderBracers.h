//
//  EQRenderBracers.h
//  eq-library
//
//  Created by Raymond Hodgson on 04/22/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
//
//  This class handles automatic creation of character data for a stretchy bracer
//  when given the sizing and character string.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <Foundation/Foundation.h>

#import "EQRenderData.h"

// This class is used to support bracer drawing, including determining the correct size of bracers and laying them out correctly.
// It is separate from the "stretchy" bracer class which renders very large bracers by combining multiple glyphs to represent
// a single logical character.

@interface EQRenderBracers : NSObject

+ (id)buildDataForBracerCharacter: (NSAttributedString *)bracerCharacter
                       withHeight: (NSNumber *)heightNumber
                      originValue: (NSValue *)useOrigin;

+ (id)addDescenderDataToBracerData: (id)bracerData withDescenderPoint: (CGPoint)descenderPoint;

+ (CGFloat)computeNewOffsetForBracerData: (id)bracerData withPreviousOrigin: (CGPoint)prevOrigin;
+ (CGFloat)computeKernAdjustmentForBracerData: (id)bracerData;

@end

//
//  EQRenderEquation.h
//  eq-library
//
//  Created by Raymond Hodgson on 10/2/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <Foundation/Foundation.h>

// This class is used to store the resulting equation data and draw that data in a graphics context.
// See documentation for more details on some of the different methods.
@interface EQRenderEquation : NSObject

@property (strong, nonatomic) NSMutableArray *equationLines;
@property (strong, nonatomic) NSMutableArray *equationStems;
@property (nonatomic) BOOL usePDFMode;
@property (nonatomic) float pdfScale;
@property (nonatomic) CGSize drawSize;
@property (nonatomic) BOOL shouldFlipContext;

- (id)initWithEquationLines: (NSArray *)equationLines andEquationStems: (NSArray *)equationStems;
- (void)layoutEquationLines;
- (void)drawEquationLinesInRect: (CGRect)useRect;
- (CGSize)computeInlineSize;

@end

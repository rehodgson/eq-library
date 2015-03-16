//
//  EquationViewDataSource.h
//  EQ Writer 2
//
//  Created by Raymond Hodgson on 31/08/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
//
//  **Note** This is a stripped down version suitable for including
//  as a separate render engine for MathML.
//  Support for UITouch I/O and Undo/Redo has been removed.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <Foundation/Foundation.h>
#import "EquationViewDataSourceProtocol.h"
#import "EQTextPosition.h"
#import "EQTextRange.h"
#import "EQRenderTypesetter.h"
#import "EQRenderStem.h"
#import "EQRenderEquation.h"

@interface EquationViewDataSource : NSObject <EquationViewDataSource, EQTypesetterDelegate, NSCoding>
{
    EQTextRange *markedTextRange;
    EQTextRange *selectedTextRange;
    EQRenderStem *rootRenderStem;

    NSMutableArray *equationLines;
    NSMutableArray *equationStems;
    NSUInteger activeEquationLine;
    NSMutableArray *renderData;
}

@property (strong, nonatomic) EQRenderTypesetter *typesetter;

@property (strong, readonly) NSDictionary *activeStyle;
@property (readonly) RenderViewAlign activeAlignment;

- (EQRenderEquation *)buildRenderEquation;

@end

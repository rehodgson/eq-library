//
//  EquationViewDataSourceProtocol.h
//  EQ Writer 2
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
#import "EQTextPosition.h"
#import "EQTextRange.h"

@protocol EquationViewDataSource

- (void)sendViewNeedsReloaded;
- (void)sendEditingWillBegin;
- (void)sendEditingDidBegin;
- (void)sendEditingWillEnd;
- (void)sendEditingDidEnd;

- (Boolean) hasData;
- (void) addData: (id)newData;
- (void) clearData;

- (void) deleteBackward;

- (EQTextPosition *)beginningOfDocument;
- (EQTextPosition *)endOfDocument;

- (EQTextRange *)getMarkedTextRange;
- (void)setMarkedText: (NSString *)markedText selectedRange:(NSRange)selectedRange;
- (EQTextRange *)getSelectedTextRange;
- (void)setSelectedTextRange: (EQTextRange *)textRange;

- (NSString *)textForRange: (EQTextRange *)textRange;
- (void)replaceDataInRange: (EQTextRange *)textRange withData: (id)data;

- (EQTextPosition *)positionFromPosition: (EQTextPosition *)textPosition offset:(NSInteger)offset;
- (EQTextPosition *)closestSafePositionFromPosition: (EQTextPosition *)textPosition offset:(NSInteger)offset;
- (NSInteger)offsetFromPosition: (EQTextPosition *)from toPosition:(EQTextPosition *)toPosition;
- (EQTextRange *)textRangeFromPosition: (EQTextPosition *)fromPosition toPosition:(EQTextPosition *)toPosition;

- (EQTextRange *)textRangeByExtendingPosition: (EQTextPosition *) textPosition inDirection: (UITextLayoutDirection)direction;
- (NSComparisonResult)compareTextPosition: (EQTextPosition *)position toPosition: (EQTextPosition *)other;
- (EQTextPosition *)textPositionWithinRange: (EQTextRange *)range farthestInDirection: (UITextLayoutDirection)direction;

- (NSDictionary *)textStylingAtPosition: (EQTextPosition *)position;
- (void)unmarkText;

// Custom methods to aid in getting selections.
- (EQTextRange *)getNearestWordOrSelectionAtPosition: (EQTextPosition *)textPosition;

// Equation style methods.
- (void)sendUpdateStyle: (NSDictionary *)styleDictionary;
- (NSDictionary *)activeStyle;

@end

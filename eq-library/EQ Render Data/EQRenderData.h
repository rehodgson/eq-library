//
//  EQRenderData.h
//  eq-library
//
//  Created by Raymond Hodgson on 2/09/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
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
#import "EQRenderStem.h"

// The is the base "Leaf" class of the data tree.
// It stores the styled attributed string and a draw location.
// It also has methods to compute the actual draw size and other typographic data.

@interface EQRenderData : NSObject <NSCoding>

// Properties
@property (strong, nonatomic) NSMutableAttributedString *renderString;

@property (nonatomic) CGPoint baselineOrigin;
@property (nonatomic) CGPoint drawOrigin;
@property (nonatomic) CGSize drawSize;

@property (nonatomic) CGRect boundingRectTypographic;
@property (nonatomic) CGRect boundingRectImage;
@property (nonatomic) Boolean needsRedrawn;
@property (nonatomic) Boolean containsSelection;
@property (nonatomic) Boolean hasAutoReplacedSpace;
@property (nonatomic) Boolean hasStretchyCharacterData;
@property (nonatomic) Boolean hasStretchyDescenderPoint;
@property (nonatomic) CGPoint stretchyDescenderPoint;
@property (nonatomic) CGFloat storedKern;

@property (weak, nonatomic) EQRenderStem *parentStem;

// Methods
- (id)initWithString: (NSString *)aString;
- (id)initWithAttributedString: (NSAttributedString *)attrStr;
- (void)replaceCharactersInRange: (EQTextRange *)range withText: (NSString *)text;
- (void)deleteCharactersInRange: (EQTextRange *)range;
- (void)appendString: (NSString *)aString;
- (void)replaceRenderStringWithNewString: (NSString *)aString;
- (void)replaceCharactersAndAttributesInRange: (EQTextRange *)range withAttributedString: (NSAttributedString *)aString;
- (void)insertText: (NSString *)text atPosition: (EQTextPosition *)position;
- (void)insertAttributedString: (NSAttributedString *)attrString atPosition: (EQTextPosition *)position;

- (CGRect)imageBoundsInContext: (CGContextRef)context;
- (CGRect)imageBounds;
- (CGRect)imageBoundsWithStretchyData;

- (CGRect)typographicBounds;
- (CGRect)typographicBoundsWithStretchyData;
- (CGRect)cursorRectForStringIndex: (NSUInteger)index;

- (Boolean)shouldUseSmaller;
- (id)getFractionBarParent;
- (id)getNRootParent;

- (void)resetStretchyCharacterData;
- (void)addStretchyCharacterData: (id)stretchyData forTextRange: (EQTextRange *)stretchyDataRange;

- (NSAttributedString *)renderStringWithStretchyCharacters;
- (CGFloat)adjustKernForTextPosition: (EQTextPosition *)textPosition;

- (NSAttributedString *)getClearStretchyCharacter;
- (Boolean)containsStretchyDescenders;
- (Boolean)usesStretchyExtenders;
- (NSArray *)getStretchyExtenders;
- (NSArray *)getStretchyDescenders;
- (NSArray *)getStretchyRanges;

- (void)shiftLayoutHorizontally: (CGFloat)xAdjust;
- (void)mergeWithRenderData: (EQRenderData *)mergeData;

@end

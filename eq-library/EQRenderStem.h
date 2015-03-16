//
//  EQRenderStem.h
//  EQ Editor
//
//  Created by Raymond Hodgson on 09/27/13.
//  Copyright (c) 2013-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef enum
{
    viewAlignAuto,
    viewAlignLeft,
    viewAlignCenter,
} RenderViewAlign;

typedef enum
{
    stemTypeUnassigned,
    stemTypeRoot,
    stemTypeRow,
    stemTypeSup,
    stemTypeSub,
    stemTypeSubSup,
    stemTypeFraction,
    stemTypeBinomial,
    stemTypeUnder,
    stemTypeOver,
    stemTypeUnderOver,
    stemTypeSqRoot,
    stemTypeNRoot,
    stemTypeMatrixCell,
    stemTypeMatrixRow,
    stemTypeMatrix,
} EQRenderStemType;

@interface EQRenderStem : NSObject <NSCoding>

@property (nonatomic) CGPoint drawOrigin;
@property (nonatomic) CGSize drawSize;
@property (nonatomic) CGRect drawBounds;

// This array can store either renderData or nested renderStems.
@property (strong, nonatomic) NSMutableArray *renderArray;

// This is a weak pointer to parentStem.
// Can be nil when root or not in the render tree yet.
@property (weak, nonatomic) EQRenderStem *parentStem;

// Value that stores the type of stem based on the enum.
@property (nonatomic) EQRenderStemType stemType;

// Value that stores whether the stem root is a large op.
@property (nonatomic) BOOL hasLargeOp;

// Value that stores whether the stem has supplementary string.
// Like a radical or other special characters.
@property (nonatomic) BOOL hasSupplementaryData;
@property (strong, nonatomic) id supplementaryData;

// Value that stores whether the stem has an overline to draw.
// Used for radicals, mainly.
@property (nonatomic) BOOL hasOverline;
@property (nonatomic) CGPoint overlineStartPoint;
@property (nonatomic) CGPoint overlineEndPoint;

@property (nonatomic) BOOL hasSupplementalLine;
@property (nonatomic) CGPoint supplementalLineStartPoint;
@property (nonatomic) CGPoint supplementalLineEndPoint;

@property (nonatomic) RenderViewAlign useAlign;
@property (nonatomic) BOOL hasAccentCharacter;

// Value that is used to store things like the root value in n-roots.
@property (nonatomic) BOOL hasStoredCharacterData;
@property (strong, nonatomic) NSString *storedCharacterData;
- (void)updateSupplementaryData;


// Custom init methods.
- (id)initWithObject: (id)object;
- (id)initWithObject: (id)object andStemType: (EQRenderStemType)stemType;

// Custom add methods.
// Sets the parent if the child stem responds to setParentStem: selector.
- (void)appendChild: (id)newChildStem;
- (void)insertChild: (id)newChildStem atLoc: (NSUInteger)loc;

// This will replace existing children and returns without executing if location is out of bounds.
// Sets the parent if the child stem responds to setParentStem: selector.
- (void)setChild: (id)newChildStem atLoc: (NSUInteger)loc;

- (NSUInteger)getLocForChild: (id)child;
- (NSUInteger)getInitialCursorLoc;
- (NSUInteger)getLastCursorLoc;

- (id)getFirstChild;
- (id)getLastChild;
- (id)getPreviousSiblingForChild: (id)child;
- (id)getNextSiblingForChild: (id)child;
- (id)getFirstDescendent;
- (id)getLastDescendent;

- (void)removeChild: (id)childToRemove;

- (void)layoutChildren;
- (void)updateBounds;
- (CGRect)computeImageBounds;
- (CGRect)computeTypographicalLayout;
- (CGPoint)initialChildOrigin;
- (CGFloat)supplementalLowerBounds;
- (CGFloat)radicalLowerBounds;
- (CGFloat)computeLeftAdjustment;

- (Boolean)useSmallFontForChild: (id)child;
- (Boolean)shouldUseSmaller;
- (Boolean)shouldUseSmallest;

- (BOOL)isRowStemType;
- (BOOL)isRootStemType;
- (BOOL)isSupStemType;
- (BOOL)isStemWithDescender;
- (BOOL)isBinomialStemType;
- (BOOL)isLargeOpStemType;
- (id)getFractionBarParent;
- (id)getNRootParent;
- (BOOL)hasChildType: (EQRenderStemType)stemType;
- (BOOL)hasOnlyRenderDataChildren;
- (BOOL)testRowRenderChildren;
- (BOOL)shouldIgnoreDescent;
- (NSString *)nestedStretchyBracerCheck;
- (NSAttributedString *)nestedAttributedStretchyBracerCheck;
- (void)resetNestedStretchyData;
- (void)adjustLayoutForNestedStretchyDataWithBracerData: (id)bracerData;

- (void)shiftLayoutHorizontally: (CGFloat)xAdjust;
- (void)shiftChildrenHorizontally: (CGFloat)xAdjust;
- (void)shiftChildrenAfter: (id)startChild horizontally: (CGFloat)xAdjust;
- (CGPoint)findChildOverlinePoint;
- (CGPoint)findChildDescenderPoint;

- (void)addChildDataToRenderArray: (NSMutableArray *)renderData;
- (void)removeChildDataFromRenderArray: (NSMutableArray *)renderData;

@end

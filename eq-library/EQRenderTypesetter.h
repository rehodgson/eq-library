//
//  EQRenderTypesetter.h
//  EQ Editor
//
//  Created by Raymond Hodgson on 16/09/13.
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
#import "EQRenderData.h"
#import "EQRenderStem.h"

extern NSString* const kRENDER_TYPESETTER_WILL_CHANGE_MARKED_NOTIFICATION;
extern NSString* const kRENDER_TYPESETTER_DID_CHANGE_MARKED_NOTIFICATION;
extern NSString* const kRENDER_TYPESETTER_WILL_CHANGE_SELECTED_NOTIFICATION;
extern NSString* const kRENDER_TYPESETTER_DID_CHANGE_SELECTED_NOTIFICATION;
extern NSString* const kRENDER_TYPESETTER_WILL_CHANGE_TEXT_NOTIFICATION;
extern NSString* const kRENDER_TYPESETTER_DID_CHANGE_TEXT_NOTIFICATION;

@protocol EQTypesetterDelegate;

@interface EQRenderTypesetter : NSObject
{
    NSDictionary *binomialOperations;
    NSDictionary *unaryOperations;
    NSSet *leftBracketCharacters;
    NSSet *rightBracketCharacters;
    NSSet *trailingCharacterSet;
    NSSet *functionNames;
    NSCharacterSet *binomialCharacterSet;
    NSCharacterSet *greekCharacterSet;
}

@property (weak, nonatomic) id <EQTypesetterDelegate> typesetterDelegate;

- (void) addData: (id)newData;
- (void) replaceDataInRange: (EQTextRange *)textRange withData: (id)data;
- (void) deleteBackward;

- (NSDictionary *)getSelectionStyle;
- (void)applyStyleToSelection: (NSDictionary *)applyStyle;

- (NSString *)parseTextForOperation: (NSString *)text atSelectionLoc: (NSRange)selectionLoc
                 inAttributedString:(NSMutableAttributedString *)inputString useSmaller: (Boolean)useSmaller withData: (EQRenderData *)selectedData;
- (void)applyMathStyleToAttributedString: (NSMutableAttributedString *)inputString
                                 inRange: (NSRange)useRange useSmaller: (Boolean)useSmaller parentSmaller: (Boolean)parentSmaller;
- (void)kernMathInAttributedString: (NSMutableAttributedString *)inputString;

// Used to handle layout and sizing of renderData.
- (void)sizeRenderData: (NSArray *)renderData;
- (void)layoutRenderStemsFromRoot: (EQRenderStem *)rootRenderStem;

// Used to initialize operator dictionaries and also may be referred to by other classes.
// May need to move some of these into a separate class.
+ (NSDictionary *)getBinomialOperators;
+ (NSDictionary *)getUnaryOperators;
+ (NSSet *)getLeftBracketCharacters;
+ (NSSet *)getRightBracketCharacters;
+ (NSSet *)getTrailingCharacters;
+ (NSSet *)getDescenderCharacters;
+ (NSSet *)getItalicAdjustCharacters;
+ (NSSet *)getLeftTrailingCharacters;
+ (NSCharacterSet *)getDescenderCharacterSet;
+ (NSCharacterSet *)getCapAndNumberCharacterSet;
+ (NSSet *)getStretchyBracerCharacters;
+ (NSSet *)getLeftStretchyBracerCharacters;
+ (NSSet *)getRightStretchyBracerCharacters;
+ (NSSet *)getVerticalStretchyBracerCharacters;
+ (NSCharacterSet *)getOperatorCharacterSet;
+ (NSCharacterSet *)getLargeOpCharacterSet;
+ (NSCharacterSet *)getSumOpCharacterSet;
+ (NSCharacterSet *)getNumberCharacterSet;
+ (NSCharacterSet *)getStretchyBracerSet;
+ (NSCharacterSet *)getGreekCapCharacterSet;
+ (NSCharacterSet *)getGreekLowerCaseCharacterSet;
+ (NSCharacterSet *)getGreekCharacterSet;
+ (NSCharacterSet *)getBracerCharacterSet;
+ (NSCharacterSet *)getMiscIdentifierCharacterSet;
+ (NSCharacterSet *)getMiscNumericCharacterSet;
+ (NSCharacterSet *)getMiscOperatorCharacterSet;
+ (NSCharacterSet *)getEqualityCharacterSet;
+ (NSCharacterSet *)getUncommonOperatorCharacterSet;
+ (NSCharacterSet *)getGeometryCharacterSet;
+ (NSCharacterSet *)getArrowCharacters;
+ (NSCharacterSet *)getScriptCharacters;
+ (NSCharacterSet *)getFrakturCharacters;
+ (NSCharacterSet *)getBlackboardCharacters;
+ (NSCharacterSet *)getAccentOpCharacters;
+ (NSSet *)getFunctionNames;

@end


@protocol EQTypesetterDelegate

- (NSMutableArray *) getRenderData;
- (NSMutableArray *) getRenderDataForRootStem: (EQRenderStem *)rootStem;
- (void) updateRenderDataAddObject: (id)object;
- (void) updateRenderData: (id)object atLocation: (NSUInteger)location;
- (void) updateRenderData: (NSArray *)newRenderData;

- (EQRenderStem *)getRootStem;
- (void)replaceRootWithStem: (EQRenderStem *)newRootStem;
- (void)addNewEquationLine;

// Since we're working directly with the internals,
// you should just tell the delegate you are finished updating and can now redraw.
- (void) sendFinishedUpdating;

- (NSDictionary *)storedStyle;

- (EQTextRange *)getMarkedTextRange;
- (void)sendUpdateMarkedTextRange: (EQTextRange *)textRange;
- (EQTextRange *)getSelectedTextRange;
- (void)sendUpdateSelectedTextRange: (EQTextRange *)textRange;
- (void)unmarkText;
- (Boolean) hasData;
- (void)handleDeleteBackwardOnEmptyEquation;

@end

//
//  EQRenderData.m
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

#import <CoreText/CoreText.h>
#import "EQRenderData.h"
#import "EQRenderFontDictionary.h"
#import "EQRenderFracStem.h"
#import "EQRenderStretchyBracers.h"

@interface EQRenderData()
{
    NSMutableArray *stretchyCharacterData;
}

- (void)initializeStretchyCharacterArray;
- (CGRect)computeCursorRectForStringIndex: (NSUInteger)index inAttributedString: (NSAttributedString *)renderString;

@end

@implementation EQRenderData

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self->_renderString = [[NSMutableAttributedString alloc] init];

        self->_baselineOrigin = CGPointZero;
        self->_drawOrigin = CGPointZero;
        self->_drawSize = CGSizeZero;
        self->_needsRedrawn = YES;
        self->_containsSelection = NO;

        self->_boundingRectTypographic = CGRectZero;
        self->_boundingRectImage = CGRectZero;
        self->_hasAutoReplacedSpace = NO;

        self->_hasStretchyCharacterData = NO;
        self->stretchyCharacterData = nil;
        self->_hasStretchyDescenderPoint = NO;
        self->_stretchyDescenderPoint = CGPointZero;
        self->_storedKern = 0.0;
    }
    
    return self;
}

- (id)initWithString: (NSString *)aString
{
    self = [self init];

    if (self)
    {
        NSDictionary *defaultDict = [EQRenderFontDictionary defaultFontDictionaryWithSize:kDEFAULT_FONT_SIZE];
        self->_renderString = [[NSMutableAttributedString alloc] initWithString:aString attributes:defaultDict];
    }

    return self;
}

- (id)initWithAttributedString: (NSAttributedString *)attrStr
{
    self = [self init];
    if (self)
    {
        self->_renderString = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    }
    return self;
}


- (void)deleteCharactersInRange: (EQTextRange *)range
{
    if (range.range.location == NSNotFound || self->_renderString.length == 0)
        return;
    if (range.range.location + range.range.length > self->_renderString.length)
        return;
    [self->_renderString deleteCharactersInRange:range.range];
    self.needsRedrawn = YES;
}

- (void)replaceCharactersInRange: (EQTextRange *)range withText: (NSString *)text
{
    if (range.range.location == NSNotFound || nil == text || self->_renderString.length == 0)
        return;
    if (range.range.location + range.range.length > self->_renderString.length)
        return;
    [self->_renderString replaceCharactersInRange:range.range withString:text];
    self.needsRedrawn = YES;
}

- (void)replaceCharactersAndAttributesInRange: (EQTextRange *)range withAttributedString: (NSAttributedString *)aString
{
    if (range.range.location == NSNotFound || nil == aString || self->_renderString.length == 0)
        return;
    if (range.range.location + range.range.length > self->_renderString.length)
        return;
    [self->_renderString replaceCharactersInRange:range.range withAttributedString:aString];
    self.needsRedrawn = YES;
}

// Turns it into an attributed string with defaults.
// Then appends it to the current data string.
- (void)appendString: (NSString *)aString
{
    NSDictionary *defaultDict = [EQRenderFontDictionary defaultFontDictionaryWithSize:kDEFAULT_FONT_SIZE];
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:aString attributes:defaultDict];
    [self->_renderString appendAttributedString:newString];
    self.needsRedrawn = YES;
}

- (void)replaceRenderStringWithNewString: (NSString *)aString
{
    if (nil == aString)
        return;

    NSDictionary *defaultDict = [EQRenderFontDictionary defaultFontDictionaryWithSize:kDEFAULT_FONT_SIZE];
    self.renderString = [[NSMutableAttributedString alloc] initWithString:aString attributes:defaultDict];
    self.needsRedrawn = YES;
}


- (void)insertText: (NSString *)text atPosition: (EQTextPosition *)position
{
    if (position.index == NSNotFound)
        return;

    if (position.index >= self->_renderString.length)
    {
        [self appendString:text];
        return;
    }

    NSDictionary *defaultDict = [EQRenderFontDictionary defaultFontDictionaryWithSize:kDEFAULT_FONT_SIZE];
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:text attributes:defaultDict];
    [self->_renderString insertAttributedString:newString atIndex:position.index];
    self.needsRedrawn = YES;
}

- (void)insertAttributedString: (NSAttributedString *)attrString atPosition: (EQTextPosition *)position
{
    if (position.index == NSNotFound)
        return;

    if (position.index >= self->_renderString.length)
    {
        [self->_renderString appendAttributedString:attrString];
        return;
    }

    [self->_renderString insertAttributedString:attrString atIndex:position.index];
    self.needsRedrawn = YES;
}

// Use this when calling from an active graphics context.
- (CGRect)imageBoundsInContext: (CGContextRef)context withAttributedString: (NSAttributedString *)renderString
{
    if (nil == renderString || renderString.length == 0)
        return CGRectZero;

    NSAttributedString *testCopy = [renderString copy];
    CTLineRef testLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)testCopy);
    CGRect imageBounds = CTLineGetImageBounds(testLine, context);
    CGFloat ascent, descent;
    double lineWidth = CTLineGetTypographicBounds(testLine, &ascent, &descent, NULL);
    imageBounds.origin = CGPointZero;
    CFRelease(testLine);

    // The typographic bounds may be larger if there is a large amount of whitespace in the line.
    // The image bounds should make an adjustment for that, though the height should be retained.
    CGFloat typoDelta = lineWidth - imageBounds.size.width;
    if (typoDelta > 20.0)
    {
        imageBounds.size.width += typoDelta;
    }

    return imageBounds;
}

// Use this when calling from an active graphics context.
- (CGRect)imageBoundsInContext: (CGContextRef)context
{
    return [self imageBoundsInContext:context withAttributedString:self.renderString];
}

// Use this to compute the size when you do not have an active graphics context.
- (CGRect)computeImageBoundsUseStretchy: (BOOL)useStretchy
{
    if (nil == self.renderString || self.renderString.length == 0)
        return CGRectZero;

    NSAttributedString *useRenderString;
    if (useStretchy == YES)
    {
        useRenderString = [self renderStringWithStretchyCharacters];
    }
    else
    {
        useRenderString = self.renderString;
    }

    CGSize boundingSize = useRenderString.size;
    boundingSize.width += 5.0f;
    boundingSize.height += 5.0f;

    UIGraphicsBeginImageContextWithOptions(boundingSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect imageBounds = [self imageBoundsInContext:context withAttributedString:useRenderString];

    UIGraphicsEndImageContext();

    return imageBounds;
}

- (CGRect)imageBounds
{
    return [self computeImageBoundsUseStretchy:NO];
}

- (CGRect)imageBoundsWithStretchyData
{
    return [self computeImageBoundsUseStretchy:YES];
}

// Returns a rect at origin 0,0 containing the typographical width and height of the line.
- (CGRect)computeTypographicBoundsUseStretchy: (BOOL)useStretchy
{
    if (nil == self.renderString || self.renderString.length == 0)
        return CGRectZero;

    CGRect returnRect = CGRectZero;

    NSAttributedString *useRenderString;
    if (useStretchy == YES)
    {
        useRenderString = [self renderStringWithStretchyCharacters];
    }
    else
    {
        useRenderString = self.renderString;
    }

    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)useRenderString);
    CGFloat ascent, descent;
    double lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
    CFRelease(line);

    CGFloat useWidth = (CGFloat)lineWidth;
    returnRect.size.width = useWidth;

    CGFloat useHeight = ascent + descent;
    returnRect.size.height = useHeight;

    return returnRect;
}

// Calls the internal compute with NO to indicate that you ignore internal stretchy data.
- (CGRect)typographicBounds
{
    return [self computeTypographicBoundsUseStretchy:NO];
}

// Calls the internal compute with YES to indicate that you use internal stretchy data.
- (CGRect)typographicBoundsWithStretchyData
{
    return [self computeTypographicBoundsUseStretchy:YES];
}

// Calls an internal method to compute it with self.renderString;
- (CGRect)cursorRectForStringIndex: (NSUInteger)index
{
    return [self computeCursorRectForStringIndex:index inAttributedString:self.renderString];
}

// An internal method used to compute the cursor rect.
// This can be called with any attrbuted string and is also used to compute adjustments for stretchy characters.
- (CGRect)computeCursorRectForStringIndex: (NSUInteger)index inAttributedString: (NSAttributedString *)renderString
{
    if (renderString.length == 0)
        return CGRectZero;

    // Regular case, caret somewhere within our text content range.
    // Create CTLine from attributed string.
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)renderString);
    CFRange range = CTLineGetStringRange(line);

    if (index <= 0)
        index = 0;

    if (index > range.length)
        index = range.length;

    CGFloat xPos = CTLineGetOffsetForStringIndex(line, index, NULL);
    CGFloat ascent, descent;
    CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
    CFRelease(line);
    CGRect returnRect = CGRectMake(xPos, 0, 3, ascent);

    return returnRect;
}

- (Boolean)shouldUseSmaller
{
    if (nil == self.parentStem)
        return NO;

    return [self.parentStem useSmallFontForChild:self];
}

// Used to get the correct parent (or grandparent) to use for drawing the fraction.
- (id)getFractionBarParent
{
    if (nil != self.parentStem && [self.parentStem isKindOfClass:[EQRenderFracStem class]])
    {
        return self.parentStem;
    }
    else if (nil != self.parentStem)
    {
        return [self.parentStem getFractionBarParent];
    }

    return nil;
}

- (id)getNRootParent
{
    if (nil != self.parentStem && (self.parentStem.stemType == stemTypeSqRoot || self.parentStem.stemType == stemTypeNRoot) )
    {
        return self.parentStem;
    }
    else if (nil != self.parentStem)
    {
        return [self.parentStem getNRootParent];
    }

    return nil;
}

- (void)initializeStretchyCharacterArray
{
    self->stretchyCharacterData = [[NSMutableArray alloc] initWithCapacity:self.renderString.length];
}

- (void)resetStretchyCharacterData
{
    self.hasStretchyCharacterData = NO;
    self->stretchyCharacterData = nil;
    self.storedKern = 0.0;
    self.hasStretchyDescenderPoint = NO;
    self.stretchyDescenderPoint = CGPointZero;
}

- (void)addStretchyCharacterData: (id)stretchyData forTextRange: (EQTextRange *)stretchyDataRange
{
    if (nil == stretchyData || stretchyDataRange.range.location + stretchyDataRange.range.length > self.renderString.length)
        return;

    if (nil == self->stretchyCharacterData)
    {
        // Make this a separate method in case you need to do more stuff in the background later.
        [self initializeStretchyCharacterArray];
    }

    NSArray *stretchyDataArray = @[stretchyData, stretchyDataRange];
    [self->stretchyCharacterData addObject:stretchyDataArray];
}


// Build a different render string with all the stretchy characters substituted in (as clear characters).
// This will allow you to layout the surrounding characters correctly while also adjusting the vertical location
// if you have a character that needs to be moved to match descenders inside the stretchy pair.

- (NSAttributedString *)renderStringWithStretchyCharacters
{
    if (nil == self->stretchyCharacterData || self->stretchyCharacterData.count == 0 || self.renderString.length == 0)
        return self.renderString;

    NSMutableAttributedString *returnString = [[NSMutableAttributedString alloc] initWithAttributedString:self.renderString];
    for (NSArray *stretchyDataArray in stretchyCharacterData)
    {
        if (nil != stretchyDataArray && stretchyDataArray.count == 2)
        {
            id stretchyData = stretchyDataArray[0];
            EQTextRange *stretchyDataRange = stretchyDataArray[1];
            if (stretchyDataRange.range.location + stretchyDataRange.range.length <= returnString.length)
            {
                if ([stretchyData isKindOfClass:[EQRenderData class]])
                {
                    EQRenderData *renderStretchy = (EQRenderData *)stretchyData;
                    if (renderStretchy.hasStretchyDescenderPoint)
                    {
                        NSAttributedString *clearStretchy = [renderStretchy getClearStretchyCharacter];
                        if (nil != clearStretchy)
                        {
                            [returnString replaceCharactersInRange:stretchyDataRange.range withAttributedString:clearStretchy];
                        }
                    }
                    else
                    {
                        [returnString replaceCharactersInRange:stretchyDataRange.range withAttributedString:renderStretchy.renderString];
                    }
                }
                else if ([stretchyData isKindOfClass:[EQRenderStretchyBracers class]])
                {
                    EQRenderStretchyBracers *bracerData = (EQRenderStretchyBracers *)stretchyData;
                    if (bracerData.hasStretchyDescenderPoint)
                    {
                        NSAttributedString *clearStretchy = [bracerData getClearStretchyCharacter];
                        if (nil != clearStretchy)
                        {
                            [returnString replaceCharactersInRange:stretchyDataRange.range withAttributedString:clearStretchy];
                        }
                    }
                    else if ([bracerData.bracerChar.string isEqualToString:@"|"] || [bracerData.bracerChar.string isEqualToString:@"‖"])
                    {
                        NSAttributedString *clearStretchy = [bracerData getClearStretchyCharacterWithKern:YES];
                        if (nil != clearStretchy)
                        {
                            [returnString replaceCharactersInRange:stretchyDataRange.range withAttributedString:clearStretchy];
                        }
                    }
                    else
                    {
                        [returnString replaceCharactersInRange:stretchyDataRange.range withAttributedString:bracerData.bracerChar];
                    }
                }
            }
        }
    }

    return returnString;
}

- (CGFloat)adjustKernForTextPosition: (EQTextPosition *)textPosition
{
    if (nil == self->stretchyCharacterData || self->stretchyCharacterData.count == 0 || self.renderString.length == 0)
        return 0.0;

    if (textPosition.index > self.renderString.length)
        return 0.0;

    CGFloat adjustKern = 0.0;
    for (NSArray *stretchyDataArray in stretchyCharacterData)
    {
        if (nil != stretchyDataArray && stretchyDataArray.count == 2)
        {
            id stretchyData = stretchyDataArray[0];
            EQTextRange *stretchyDataRange = stretchyDataArray[1];
            if (stretchyDataRange.range.location < textPosition.index)
            {
                if ([stretchyData isKindOfClass:[EQRenderData class]])
                {
                    EQRenderData *renderStretchy = (EQRenderData *)stretchyData;
                    adjustKern += renderStretchy.storedKern;
                }
            }
        }
    }

    return adjustKern;
}

- (NSAttributedString *)getClearStretchyCharacter
{
    if (self.renderString.length == 0)
    {
        return nil;
    }

    NSMutableAttributedString *bracerCharacter = [[NSMutableAttributedString alloc] initWithAttributedString:self.renderString];

    NSDictionary *currentAttributes = [bracerCharacter attributesAtIndex:0 effectiveRange:NULL];
    NSMutableDictionary *newAttributes = currentAttributes.mutableCopy;
    newAttributes[NSForegroundColorAttributeName] = [UIColor clearColor];
    NSAttributedString *clearCharacter = [[NSAttributedString alloc] initWithString:bracerCharacter.string attributes:newAttributes];

    return clearCharacter;
}

// Returns true if one of the internal stretchy character data points also has a stored descender point.
- (Boolean)containsStretchyDescenders
{
    if (self.hasStretchyCharacterData == NO || nil == self->stretchyCharacterData
        || self->stretchyCharacterData.count == 0 || self.renderString.length == 0)
    {
        return NO;
    }

    for (NSArray *stretchyDataArray in stretchyCharacterData)
    {
        id stretchyData = stretchyDataArray[0];
        if ([stretchyData isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderStretchy = (EQRenderData *)stretchyData;
            if (renderStretchy.hasStretchyDescenderPoint == YES)
            {
                return YES;
            }
        }
        else if ([stretchyData isKindOfClass:[EQRenderStretchyBracers class]])
        {
            EQRenderStretchyBracers *renderStretchy = (EQRenderStretchyBracers *)stretchyData;
            if (renderStretchy.hasStretchyDescenderPoint == YES)
            {
                return YES;
            }
        }
    }

    return NO;
}

- (Boolean)usesStretchyExtenders
{
    if (self.hasStretchyCharacterData == NO || nil == self->stretchyCharacterData
        || self->stretchyCharacterData.count == 0 || self.renderString.length == 0)
    {
        return NO;
    }
    for (NSArray *stretchyDataArray in stretchyCharacterData)
    {
        id stretchyData = stretchyDataArray[0];
        if ([stretchyData isKindOfClass:[EQRenderStretchyBracers class]])
        {
            EQRenderStretchyBracers *renderStretchy = (EQRenderStretchyBracers *)stretchyData;
            if (renderStretchy.hasStretchyDescenderPoint == NO)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (NSArray *)getStretchyExtenders
{
    if (self.hasStretchyCharacterData == NO || nil == self->stretchyCharacterData
        || self->stretchyCharacterData.count == 0 || self.renderString.length == 0)
    {
        return nil;
    }

    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSAttributedString *stretchyAttributedStr = [self renderStringWithStretchyCharacters];
    for (NSArray *stretchyDataArray in stretchyCharacterData)
    {
        id stretchyData = stretchyDataArray[0];
        if ([stretchyData isKindOfClass:[EQRenderStretchyBracers class]])
        {
            EQRenderStretchyBracers *renderStretchy = (EQRenderStretchyBracers *)stretchyData;
            if (renderStretchy.hasStretchyDescenderPoint == NO)
            {
                EQTextRange *stretchyDataRange = stretchyDataArray[1];
                CGRect updatedStretchyRect = [self computeCursorRectForStringIndex:stretchyDataRange.range.location
                                                                inAttributedString:stretchyAttributedStr];
                CGPoint updatedStretchyOrigin = updatedStretchyRect.origin;
                updatedStretchyOrigin.x += self.drawOrigin.x;
                renderStretchy.useOrigin = [NSValue valueWithCGPoint:updatedStretchyOrigin];
                [returnArray addObject:renderStretchy];
            }
        }
    }

    if (returnArray.count == 0)
        return nil;

    return returnArray;
}


- (NSArray *)getStretchyDescenders
{
    if (self.hasStretchyCharacterData == NO || nil == self->stretchyCharacterData
        || self->stretchyCharacterData.count == 0 || self.renderString.length == 0)
    {
        return nil;
    }
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSAttributedString *stretchyAttributedStr = [self renderStringWithStretchyCharacters];
    for (NSArray *stretchyDataArray in stretchyCharacterData)
    {
        id stretchyData = stretchyDataArray[0];
        if ([stretchyData isKindOfClass:[EQRenderData class]])
        {
            EQRenderData *renderStretchy = (EQRenderData *)stretchyData;
            EQTextRange *stretchyDataRange = stretchyDataArray[1];
            if (renderStretchy.hasStretchyDescenderPoint == YES)
            {
                CGRect updatedStretchyRect = [self computeCursorRectForStringIndex:stretchyDataRange.range.location
                                                                inAttributedString:stretchyAttributedStr];
                CGPoint updatedStretchyOrigin = updatedStretchyRect.origin;
                updatedStretchyOrigin.x += self.drawOrigin.x;
                renderStretchy.drawOrigin = updatedStretchyOrigin;
                [returnArray addObject:renderStretchy];
            }
        }
        else if ([stretchyData isKindOfClass:[EQRenderStretchyBracers class]])
        {
            EQRenderStretchyBracers *renderStretchy = (EQRenderStretchyBracers *)stretchyData;
            EQTextRange *stretchyDataRange = stretchyDataArray[1];
            if (renderStretchy.hasStretchyDescenderPoint == YES)
            {
                CGRect updatedStretchyRect = [self computeCursorRectForStringIndex:stretchyDataRange.range.location
                                                                inAttributedString:stretchyAttributedStr];
                CGPoint updatedStretchyOrigin = updatedStretchyRect.origin;
                updatedStretchyOrigin.x += self.drawOrigin.x;
                renderStretchy.useOrigin = [NSValue valueWithCGPoint:updatedStretchyOrigin];
                [returnArray addObject:renderStretchy];
            }
        }
    }

    if (returnArray.count == 0)
        return nil;

    return returnArray;
}

- (NSArray *)getStretchyRanges
{
    if (self.hasStretchyCharacterData == NO || nil == self->stretchyCharacterData
        || self->stretchyCharacterData.count == 0 || self.renderString.length == 0)
    {
        return nil;
    }

    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSArray *stretchyDataArray in stretchyCharacterData)
    {
        EQTextRange *stretchyDataRange = stretchyDataArray[1];
        NSValue *addRange = [NSValue valueWithRange:stretchyDataRange.range];
        [returnArray addObject:addRange];
    }
    if (returnArray.count == 0)
        return nil;

    [returnArray sortUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        if (obj1.rangeValue.location < obj2.rangeValue.location)
        {
            return NSOrderedAscending;
        }
        else if (obj1.rangeValue.location > obj2.rangeValue.location)
        {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return returnArray;
}

- (void)shiftLayoutHorizontally: (CGFloat)xAdjust
{
    CGPoint renderOrigin = self.drawOrigin;
    renderOrigin.x += xAdjust;
    self.drawOrigin = renderOrigin;

    if (self.hasStretchyCharacterData && nil != self->stretchyCharacterData && stretchyCharacterData.count > 0)
    {
        for (NSArray *stretchyDataArray in stretchyCharacterData)
        {
            if (nil != stretchyDataArray && stretchyDataArray.count == 2)
            {
                id stretchyData = stretchyDataArray[0];
                if ([stretchyData isKindOfClass:[EQRenderData class]])
                {
                    [(EQRenderData *)stretchyData shiftLayoutHorizontally:xAdjust];
                }
            }
        }
    }

    if (self.hasStretchyDescenderPoint)
    {
        CGPoint newOrigin = self.stretchyDescenderPoint;
        newOrigin.x += xAdjust;
        self.stretchyDescenderPoint = newOrigin;
    }
}

// This method should only be used to join two adjacent sibling data that used to be separated by a third renderStem.
// It will assume the first sibling's parent and useSmaller data is what you want.
- (void)mergeWithRenderData: (EQRenderData *)mergeData
{
    if (nil == mergeData || mergeData.renderString.length == 0)
        return;

    // You are copying all of the necessary character data and ignoring everything else.
    // Let the layout function rebuild the stretchy character data and resize everything.
    [self.renderString appendAttributedString:mergeData.renderString];
    [self resetStretchyCharacterData];
    self.needsRedrawn = YES;
}


/************************
 NSCoding support methods
 ************************/

/*
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
*/

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // You should preserve more than is absolutely needed.
    // That way instead of rebuilding the data using methods, you just unpack it.

    // Also, some version information will be helpful,
    // though you will need a plan to actually parse that information at some point if you want to help keep forward compatability.
    [aCoder encodeObject:@(1.0) forKey:@"RenderDataVersionNumber"];

    // renderString.
    [aCoder encodeObject:self.renderString forKey:@"renderString"];

    // Drawing data.
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.baselineOrigin] forKey:@"baselineOrigin"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.drawOrigin] forKey:@"drawOrigin"];
    [aCoder encodeObject:[NSValue valueWithCGSize:self.drawSize] forKey:@"drawSize"];

    [aCoder encodeObject:[NSValue valueWithCGRect:self.boundingRectTypographic] forKey:@"boundingRectTypographic"];
    [aCoder encodeObject:[NSValue valueWithCGRect:self.boundingRectImage] forKey:@"boundingRectImage"];

    // Local tracking data.
    // Some of this may not be needed, strictly speaking.
    [aCoder encodeObject:@(self.containsSelection) forKey:@"containsSelection"];
    [aCoder encodeObject:@(self.hasAutoReplacedSpace) forKey:@"hasAutoReplacedSpace"];
    [aCoder encodeObject:@(self.storedKern) forKey:@"storedKern"];

    // Parent stem.
    // Should be conditional as it is a weak reference.
    [aCoder encodeConditionalObject:self.parentStem forKey:@"parentStem"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self)
    {
        NSNumber *versionNumber = [aDecoder decodeObjectForKey:@"RenderDataVersionNumber"];
        if (nil != versionNumber && versionNumber.doubleValue >= 1.0 && versionNumber.doubleValue < 2.0)
        {
            // Likely need to add other support for other version numbers when the time comes.
            self->_renderString = [aDecoder decodeObjectForKey:@"renderString"];

            // Drawing data.

            self->_baselineOrigin = [(NSValue *)[aDecoder decodeObjectForKey:@"baselineOrigin"] CGPointValue];
            self->_drawOrigin = [(NSValue *)[aDecoder decodeObjectForKey:@"drawOrigin"] CGPointValue];
            self->_drawSize = [(NSValue *)[aDecoder decodeObjectForKey:@"drawSize"] CGSizeValue];

            self->_boundingRectTypographic = [(NSValue *)[aDecoder decodeObjectForKey:@"boundingRectTypographic"] CGRectValue];
            self->_boundingRectImage = [(NSValue *)[aDecoder decodeObjectForKey:@"boundingRectImage"] CGRectValue];

            // Local tracking data.
            // Some of this may not be needed, strictly speaking.
            self->_containsSelection = [(NSNumber *)[aDecoder decodeObjectForKey:@"containsSelection"] boolValue];
            self->_hasAutoReplacedSpace = [(NSNumber *)[aDecoder decodeObjectForKey:@"hasAutoReplacedSpace"] boolValue];
            self->_storedKern = [(NSNumber *)[aDecoder decodeObjectForKey:@"storedKern"] floatValue];

            // Parent stem.
            // It is conditional, which means it will be nil if the object wasn't stored.
            // This is okay as long as you know it's possible to be nil and check on it.
            self->_parentStem = [aDecoder decodeObjectForKey:@"parentStem"];
        }
    }

    return self;
}

@end

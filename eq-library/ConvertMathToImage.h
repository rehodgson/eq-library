//
//  ConvertMathToImage.h
//  EQ Writer 2
//
//  Created by Raymond Hodgson on 11/4/14.
//  Copyright (c) 2014 Raymond Hodgson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertMathToImage : NSObject

+ (NSData *)convertTeXMathToPNG: (NSString *)mathStr;
+ (NSData *)convertMathMLToPNG: (NSString *)mathStr;

+ (BOOL)isInlineMath: (NSString *)inputStr;
+ (BOOL)isInlineMathML: (NSString *)inputStr;

+ (BOOL)isMathML: (NSString *)inputStr;
+ (BOOL)mathIsEmpty: (NSString *)mathStr;

@end

//
//  ConvertMathToImage.h
//  eq-library
//
//  Created by Raymond Hodgson on 11/4/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// This class is included partially as a demonstration/example.
// It should handle most use cases but you can tweak the code as needed.

@interface ConvertMathToImage : NSObject

+ (UIImage *)convertTeXMathToPNG: (NSString *)mathStr;
+ (UIImage *)convertMathMLToPNG: (NSString *)mathStr;

+ (BOOL)isInlineMath: (NSString *)inputStr;
+ (BOOL)isInlineMathML: (NSString *)inputStr;

+ (BOOL)isMathML: (NSString *)inputStr;
+ (BOOL)mathIsEmpty: (NSString *)mathStr;

@end

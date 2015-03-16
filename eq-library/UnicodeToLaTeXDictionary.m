//
//  UnicodeToLaTeXDictionary.m
//  EQ Editor
//
//  Created by Raymond Hodgson on 08/25/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#import "UnicodeToLaTeXDictionary.h"

// Unicode to LaTeX dictionary constants.
NSString* const kUNICODE_DICT_FILE_NAME = @"unicode-latex-dictionary";
NSString* const kUNICODE_DICT_LOOKUP_KEY = @"kUnicodeToLatexDictionary";

@implementation UnicodeToLaTeXDictionary

- (id)init
{
    self = [super init];
    if (self)
    {
        self->_useDictionary = [[NSDictionary alloc] init];
    }
    return self;
}

- (id)initWithDictionary: (NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self->_useDictionary = dictionary;
    }
    return self;
}

// Created a shared instance to prevent loading the plist file multiple times.
// Much better alternative to passing a single variable back through over and over.
+ (UnicodeToLaTeXDictionary *)sharedInstance
{
    static dispatch_once_t once;
    static UnicodeToLaTeXDictionary * sharedInstance;
    dispatch_once(&once, ^{
        NSString *dictPath = [[NSBundle mainBundle] pathForResource:kUNICODE_DICT_FILE_NAME ofType:@"plist"];
        NSDictionary *lookupDict = [[NSDictionary alloc] initWithContentsOfFile:dictPath];

        NSDictionary *charDict = lookupDict[kUNICODE_DICT_LOOKUP_KEY];
        sharedInstance = [[self alloc] initWithDictionary:charDict];
    });
    return sharedInstance;
}

@end

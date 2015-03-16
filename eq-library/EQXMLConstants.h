//
//  EQXMLConstants.h
//  eq-library
//
//  Created by Raymond Hodgson on 06/25/14.
//  Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
/*

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

// This class stores all the string constants containing the name of mathML elements and attributes.
// The .m file should only be used in a single place, but include the .h file as needed.

#import <Foundation/Foundation.h>

extern NSString* const kMSUP_STEM;
extern NSString* const kMSUB_STEM;
extern NSString* const kMSUBSUP_STEM;
extern NSString* const kMFRAC_STEM;
extern NSString* const kMOVER_STEM;
extern NSString* const kMUNDER_STEM;
extern NSString* const kMUNDEROVER_STEM;
extern NSString* const kMROW_STEM;
extern NSString* const kMSTYLE_STEM;
extern NSString* const kMSQRT_STEM;
extern NSString* const kMROOT_STEM;
extern NSString* const kMTABLE_STEM;
extern NSString* const kMTROW_STEM;
extern NSString* const kMTD_STEM;
extern NSString* const kMATH_STEM;

// MathML attribute name constants
extern NSString* const kLINE_THICKNESS_ATTRIB;

// MathML Element name constants.
extern NSString* const kMI_LEAF;
extern NSString* const kMO_LEAF;
extern NSString* const kMN_LEAF;
extern NSString* const kMTEXT_LEAF;
extern NSString* const kMSPACE_LEAF;

// MathML Attribute name constants.
extern NSString* const kMSTRETCHY_ATTR;
extern NSString* const kMLARGE_OP_ATTR;
extern NSString* const kMATH_VARIANT_ATTR;
extern NSString* const kWIDTH_SP_ATTR;
extern NSString* const kRSPACE_ATTR;

// Other XML Constants
extern NSString* const kDIV_ELEMENT_NAME;
extern NSString* const kHTML_ELEMENT_NAME;
extern NSString* const kHTML_BODY_ELEMENT_NAME;

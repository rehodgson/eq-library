//
//  EQXMLImporter.m
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

#import "EQXMLImporter.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "EQXMLConstants.h"
#import "EQRenderFontDictionary.h"
#import "EquationViewDataSource.h"
#import "EQRenderTypesetter.h"
#import "EQInputData.h"
#import "EQStyleConstants.h"
#import "EQParsedLeaf.h"

typedef enum
{
    elementTypeUnknown,
    elementTypeStem,
    elementTypeLeaf,
    elementTypeRoot,
    elementTypeDiv,
    elementTypeHtml,
    elementTypeHtmlBody,
} elementType;

@implementation EQXMLImporter

// This will attempt to parse the given XML data and then call an internal method to populate a data source with the XML tree.
+ (EquationViewDataSource *)populateDataSourceWithXMLData: (NSData *)xmlData
{
    if (nil == xmlData)
    {
        return nil;
    }

    NSError *err = nil;
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&err];

    //Handle Parsing error.
    if (xmlDoc == nil || xmlDoc.rootElement.childCount <= 0)
    {
        [self handleError:err withMessage:@"Parsing error."];
        return nil;
    }

    EquationViewDataSource *returnDataSource = [self buildDataSourceFromXML:xmlDoc];

    return returnDataSource;
}

// This will attempt to open a file containing MathML data and then call an internal method to populate a data source with the XML tree.
+ (EquationViewDataSource *)populateDataSourceWithXML: (NSURL *)fileURL;
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
    {
        NSLog(@"Error: Import file does not exist.");
        return nil;
    }

    NSError* err = nil;

    NSString* newEquData = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&err];

    if (nil == newEquData)
    {
        [self handleError:err withMessage:@"Error loading XML string."];
        return nil;
    }

    newEquData = [self filterString:newEquData UsingRegEx:@" xmlns=\"[^\"]*?\"" replaceStr:@""];

    // Filter string will log its own error messages.
    if (nil == newEquData)
    {
        return nil;
    }

    err = nil;

    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithXMLString:newEquData options:0 error:&err];

    //Handle Parsing error.
    if (xmlDoc == nil || xmlDoc.rootElement.childCount <= 0)
    {
        [self handleError:err withMessage:@"Parsing error."];
        return nil;
    }

    EquationViewDataSource *returnDataSource = [self buildDataSourceFromXML:xmlDoc];

    return returnDataSource;
}

// This will attempt to parse the given XML string and use an internal method to populate the datasource with the XML tree.
+ (EquationViewDataSource *)populateDataSourceWithXMLString: (NSString *)xmlStr
{
    if (nil == xmlStr || xmlStr.length == 0)
        return nil;

    xmlStr = [self filterString:xmlStr UsingRegEx:@" xmlns=\"[^\"]*?\"" replaceStr:@""];

    NSError* err = nil;
    DDXMLDocument* xmlDoc = [[DDXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&err];

    //Handle Parsing error.
    if (xmlDoc == nil || xmlDoc.rootElement.childCount <= 0)
    {
        [self handleError:err withMessage:@"Parsing error."];
        return nil;
    }

    EquationViewDataSource *returnDataSource = [self buildDataSourceFromXML:xmlDoc];

    return returnDataSource;
}

// This method creates a new data source and iterates over each child element adding its data to the data source.
+ (EquationViewDataSource *)buildDataSourceFromXML: (DDXMLDocument *)xmlDoc
{
    EquationViewDataSource *returnDataSource = [[EquationViewDataSource alloc] init];
    elementType rootElementType = [self getElementTypeForName:xmlDoc.rootElement.name];

    if (rootElementType == elementTypeDiv)
    {
        [returnDataSource sendEditingWillBegin];
        for (DDXMLElement *rootChild in xmlDoc.rootElement.children)
        {
            if ([rootChild.name isEqualToString:kMATH_STEM])
            {
                [self addMathElement:rootChild toDataSource:returnDataSource];
                [returnDataSource addNewEquationLine];
            }
        }
        [returnDataSource sendEditingWillEnd];
    }
    else if (rootElementType == elementTypeRoot)
    {
        DDXMLElement *rootChild = xmlDoc.rootElement;

        [returnDataSource sendEditingWillBegin];
        [self addMathElement:rootChild toDataSource:returnDataSource];
        [returnDataSource sendEditingWillEnd];
    }
    else if (rootElementType == elementTypeHtml)
    {
        // Need to find the root div instead.
        DDXMLElement *rootDivChild = [self findNestedChildInParent:xmlDoc.rootElement withChildType:elementTypeDiv];
        if (nil != rootDivChild)
        {
            [returnDataSource sendEditingWillBegin];
            for (DDXMLElement *rootChild in rootDivChild.children)
            {
                if ([rootChild.name isEqualToString:kMATH_STEM])
                {
                    [self addMathElement:rootChild toDataSource:returnDataSource];
                    [returnDataSource addNewEquationLine];
                }
            }
            [returnDataSource sendEditingWillEnd];
        }
    }

    return returnDataSource;
}

// This method will examine a child and either add its data to the data source, or iterate over its children to add their data.
+ (void)addMathElement: (DDXMLElement *)rootElement toDataSource: (EquationViewDataSource *)returnDataSource
{
    if (nil == rootElement || nil == returnDataSource || rootElement.childCount == 0)
        return;

    for (DDXMLElement *childElement in rootElement.children)
    {
        elementType childType = [self getElementTypeForName:childElement.name];
        if (childType == elementTypeLeaf)
        {
            [self addLeafElement:childElement toDataSource:returnDataSource];
        }
        else if (childType == elementTypeStem)
        {
            [self addStemElement:childElement toDataSource:returnDataSource];
        }
    }
}

// This method adds the data for a "leaf" element to the data source.
// The element name is parsed and different methods are called depending on the type of element.
+ (void)addLeafElement: (DDXMLElement *)childElement toDataSource: (EquationViewDataSource *)returnDataSource
{
    // Test to see if you need to be in text mode or not.
    BOOL customStyle = NO;
    NSDictionary *defaultDict = @{kSTYLE_TYPE_KEY: @(displayMathStyle), kBOLD_TEXT_KEY: @(NO), kITALIC_TEXT_KEY: @(NO)};
    NSMutableDictionary *styleDict = [[NSMutableDictionary alloc] initWithDictionary: defaultDict];
    NSString *extraSpace = nil;

    if ([childElement.name isEqualToString:kMSPACE_LEAF])
    {
        EQInputData *spaceData = [[EQInputData alloc] initWithStemType:inputTypeSpace];
        [returnDataSource addData:spaceData];
        return;
    }

    if ([childElement.name isEqualToString:kMTEXT_LEAF])
    {
        customStyle = YES;
        styleDict[kSTYLE_TYPE_KEY] = @(textStyle);
    }

    if ([childElement.name isEqualToString:kMO_LEAF])
    {
        // Test for large ops, which may not have the attribute set.
        NSString *testStr = [NSString stringWithString:childElement.stringValue];
        if (testStr.length == 1)
        {
            NSCharacterSet *largeOpSet = [EQRenderTypesetter getLargeOpCharacterSet];
            if ([testStr rangeOfCharacterFromSet:largeOpSet].location != NSNotFound)
            {
                DDXMLNode *largeOpNode = [childElement attributeForName:kMLARGE_OP_ATTR];
                if (nil == largeOpNode)
                {
                    [childElement addAttributeWithName:kMLARGE_OP_ATTR stringValue:@"true"];
                }
                else if (nil == largeOpNode.stringValue || largeOpNode.stringValue.length == 0 || ![largeOpNode.stringValue.lowercaseString isEqualToString:@"true"])
                {
                    // Missing or set to false when it shouldn't be.
                    largeOpNode.stringValue = @"true";
                }
            }
        }
    }

    // Should test variant elements as well as whether it is a sum or a large op.
    if (childElement.attributes.count > 0)
    {
        NSDictionary *attributeDict = [childElement attributesAsDictionary];
        NSString *largeOpStr = [attributeDict valueForKey:kMLARGE_OP_ATTR];
        largeOpStr = largeOpStr.lowercaseString;

        // If there is a valid large op string, parse and add it.
        if (nil != largeOpStr && [largeOpStr isEqualToString:@"true"])
        {
            NSString *inputString = childElement.stringValue;

            // Test to see which dictionary and type you should use.
            NSDictionary *useDict;
            EQInputStemType useInputType;

            NSRange sumOpRange = [inputString rangeOfCharacterFromSet:[EQRenderTypesetter getSumOpCharacterSet]];
            if (sumOpRange.location != NSNotFound)
            {
                useInputType = inputTypeSumOp;
                useDict = [EQRenderFontDictionary sumOpFontDictWithName:kDEFAULT_FONT size:kDEFAULT_FONT_SIZE_LARGE kernValue:12.0];
            }
            else
            {
                useInputType = inputTypeBigOp;
                useDict = [EQRenderFontDictionary fontDictWithName:kDEFAULT_FONT size:kDEFAULT_FONT_SIZE_LARGE_INTEGRAL kernValue:12.0];
            }
            NSDictionary *inputDictionary = @{kEQInputCharacterKey: inputString, kEQInputStyleKey: useDict};
            EQInputData *inputData = [[EQInputData alloc] initWithStemType:useInputType andCharacterData:inputDictionary];
            if (nil != inputData)
            {
                [returnDataSource addData:inputData];
            }
            return;
        }
        // End large op parsing.

        NSString *mathVariantStr = [attributeDict valueForKey:kMATH_VARIANT_ATTR];
        if (nil != mathVariantStr)
        {
            MathVariantType testType = [EQParsedLeaf getMathVariantForString:mathVariantStr];

            // Not all types are supported so only adjust the style for supported types.
            BOOL usedCustomStyle = [self adjustStyleDict:styleDict forMathVariant:testType];
            customStyle = customStyle | usedCustomStyle;
        }

        NSString *rSpaceStr = [attributeDict valueForKey:kRSPACE_ATTR];
        if (nil != rSpaceStr)
        {
            // The input MathML has space after the leaf.
            // For now, just add a normal space, as you can parse the attribute properly later on.
            extraSpace = @" ";
        }
    }

    if (customStyle == YES)
    {
        [returnDataSource sendUpdateStyle:styleDict];
        [returnDataSource addData:childElement.stringValue];
        [returnDataSource sendUpdateStyle:defaultDict];
    }
    else
    {
        if (nil == extraSpace)
        {
            // Most common case, there is no extra padding that needs to be added.
            [returnDataSource addData:childElement.stringValue];
        }
        else
        {
            NSString *paddedStr = [childElement.stringValue stringByAppendingString:extraSpace];
            [returnDataSource addData:paddedStr];
        }
    }
}

// This method examines each "stem" element and adds its children to the data source.
// The children are added differently depending on the parent type.
// Some stem element types recursively call this method as well.
+ (void)addStemElement: (DDXMLElement *)stemElement toDataSource: (EquationViewDataSource *)returnDataSource
{
    if (nil == stemElement || nil == returnDataSource || stemElement.childCount == 0)
        return;

    NSString *stemName = stemElement.name;

    if ([stemName isEqualToString:kMSUP_STEM])
    {
        EQInputData *inputData = [[EQInputData alloc] initWithStemType:inputTypeSup];
        [self addSupStyleStemData:inputData withElement:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMSUB_STEM])
    {
        EQInputData *inputData = [[EQInputData alloc] initWithStemType:inputTypeSub];
        [self addSupStyleStemData:inputData withElement:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMSUBSUP_STEM])
    {
        EQInputData *inputData = [[EQInputData alloc] initWithStemType:inputTypeSub];
        EQInputData *inputData2 = [[EQInputData alloc] initWithStemType:inputTypeSup];
        [self addMultiStemData:inputData andStemData:inputData2 withElement:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMFRAC_STEM])
    {
        EQInputData *inputData = [[EQInputData alloc] initWithStemType:inputTypeFraction];
        [self addBasicStemData:inputData withElement:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMOVER_STEM])
    {
        // For now, assume this is the same as a sub/sup.
        EQInputData *inputData = [[EQInputData alloc] initWithStemType:inputTypeOver];
        [self addSupStyleStemData:inputData withElement:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMUNDER_STEM])
    {
        // For now, assume this is the same as a sub/sup.
        EQInputData *inputData = [[EQInputData alloc] initWithStemType:inputTypeUnder];
        [self addSupStyleStemData:inputData withElement:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMUNDEROVER_STEM])
    {
        EQInputData *inputData = [[EQInputData alloc] initWithStemType:inputTypeUnder];
        EQInputData *inputData2 = [[EQInputData alloc] initWithStemType:inputTypeOver];
        [self addMultiStemData:inputData andStemData:inputData2 withElement:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMROW_STEM] || [stemName isEqualToString:kMSTYLE_STEM])
    {
        [self addRowData:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMSQRT_STEM])
    {
        EQInputData *sqRootData = [[EQInputData alloc] initWithStemType:inputTypeSqRootOp];
        [returnDataSource addData:sqRootData];
        [self addRowData:stemElement toDataSource:returnDataSource];

        EQInputData *returnData = [[EQInputData alloc] initWithStemType:inputTypeReturn];
        [returnDataSource addData:returnData];
    }
    else if ([stemName isEqualToString:kMROOT_STEM])
    {
        if (stemElement.childCount == 2)
        {
            EQInputData *nRootData = [[EQInputData alloc] initWithStemType:inputTypeNRootOp];
            DDXMLElement *indexElement = stemElement.children[1];
            nRootData.storedCharacterData = indexElement.stringValue;
            [returnDataSource addData:nRootData];

            DDXMLElement *baseElement = stemElement.children[0];
            [self addStemChild:baseElement toDataSource:returnDataSource];
        }
    }
    else if ([stemName isEqualToString:kMTABLE_STEM])
    {
        NSUInteger rowCount = stemElement.childCount;
        if (rowCount > 0)
        {
            DDXMLElement *firstRow = stemElement.children[0];
            NSUInteger colCount = firstRow.childCount;
            if (colCount > 0)
            {
                NSString *matrixAddStr = [NSString stringWithFormat:@"%lux%lu", (unsigned long)rowCount, (unsigned long)colCount];
                EQInputData *mTableData = [[EQInputData alloc] initWithStemType:inputTypeMatrixOp];
                mTableData.storedCharacterData = matrixAddStr;
                [returnDataSource addData:mTableData];
                [self addOnlyStemChildrenData:stemElement toDataSource:returnDataSource];
            }
        }
    }
    else if ([stemName isEqualToString:kMTROW_STEM])
    {
        [self addOnlyStemChildrenData:stemElement toDataSource:returnDataSource];
    }
    else if ([stemName isEqualToString:kMTD_STEM])
    {
        // Each matrix is initialized with a "0".
        // You should do a delete backward to take care of that before adding data.
        [returnDataSource deleteBackward];
        [self addRowData:stemElement toDataSource:returnDataSource];

    }
}

+ (void)addStemChild: (DDXMLElement *)childElement toDataSource: (EquationViewDataSource *)returnDataSource useReturn: (BOOL)useReturn
{
    elementType childType = [self getElementTypeForName:childElement.name];
    if (childType == elementTypeLeaf)
    {
        [self addLeafElement:childElement toDataSource:returnDataSource];
        if (useReturn == YES)
        {
            EQInputData *returnData = [[EQInputData alloc] initWithStemType:inputTypeReturn];
            [returnDataSource addData:returnData];
        }
    }
    else if (childType == elementTypeStem)
    {
        [self addStemElement:childElement toDataSource:returnDataSource];
        elementType parentType = [self getElementTypeForName:childElement.parent.name];
        BOOL parentIsRow = [self elementIsRowStyle:childElement.parent.name];

        BOOL impliedRow = (childType == elementTypeStem && parentType == elementTypeStem && !parentIsRow);
        if (useReturn == YES && ([self elementIsRowStyle:childElement.name] || impliedRow))
        {
            EQInputData *returnData = [[EQInputData alloc] initWithStemType:inputTypeReturn];
            [returnDataSource addData:returnData];
        }
    }
}

+ (void)addStemChild: (DDXMLElement *)childElement toDataSource: (EquationViewDataSource *)returnDataSource
{
    [self addStemChild:childElement toDataSource:returnDataSource useReturn:YES];
}


+ (void)addBasicStemData: (EQInputData *)inputData
             withElement: (DDXMLElement *)stemElement
            toDataSource: (EquationViewDataSource *)returnDataSource
{
    [returnDataSource addData:inputData];
    for (DDXMLElement *childElement in stemElement.children)
    {
        [self addStemChild:childElement toDataSource:returnDataSource];
    }
}

+ (void)addSupStyleStemData: (EQInputData *)inputData
                withElement: (DDXMLElement *)stemElement
               toDataSource: (EquationViewDataSource *)returnDataSource
{
    BOOL baseElement = YES;
    for (DDXMLElement *childElement in stemElement.children)
    {
        if (baseElement)
        {
            [self addStemChild:childElement toDataSource:returnDataSource useReturn:NO];
            baseElement = NO;
            [returnDataSource addData:inputData];
        }
        else
        {
            [self addStemChild:childElement toDataSource:returnDataSource];
        }
    }
}

+ (void)addMultiStemData: (EQInputData *)baseData
             andStemData: (EQInputData *)extraData
             withElement: (DDXMLElement *)stemElement
            toDataSource: (EquationViewDataSource *)returnDataSource
{
    if (stemElement.childCount == 3)
    {
        DDXMLElement *baseChild = stemElement.children[0];
        DDXMLElement *firstChild = stemElement.children[1];
        DDXMLElement *lastChild = stemElement.children[2];

        // Assume this is sup style.
        [self addStemChild:baseChild toDataSource:returnDataSource useReturn:NO];
        [returnDataSource addData:baseData];
        [self addStemChild:firstChild toDataSource:returnDataSource];
        [returnDataSource addData:extraData];
        [self addStemChild:lastChild toDataSource:returnDataSource];
    }
}

+ (void)addRowData: (DDXMLElement *)stemElement toDataSource: (EquationViewDataSource *)returnDataSource
{
    for (DDXMLElement *childElement in stemElement.children)
    {
        elementType childType = [self getElementTypeForName:childElement.name];
        if (childType == elementTypeLeaf)
        {
            [self addLeafElement:childElement toDataSource:returnDataSource];
        }
        else if (childType == elementTypeStem)
        {
            [self addStemElement:childElement toDataSource:returnDataSource];
        }
    }
}

+ (void)addOnlyStemChildrenData: (DDXMLElement *)stemElement toDataSource: (EquationViewDataSource *)returnDataSource
{
    for (DDXMLElement *childElement in stemElement.children)
    {
        elementType childType = [self getElementTypeForName:childElement.name];
        if (childType == elementTypeStem)
        {
            [self addStemChild:childElement toDataSource:returnDataSource];
        }
    }
}

+ (DDXMLElement *)findNestedChildInParent: (DDXMLElement *)parentElement withChildType: (elementType)findChildType
{
    for (DDXMLElement *childElement in parentElement.children)
    {
        elementType childType = [self getElementTypeForName:childElement.name];
        if (childType == findChildType)
        {
            return childElement;
        }
        else if (childElement.childCount > 0)
        {
            DDXMLElement *testElement = [self findNestedChildInParent:childElement withChildType:findChildType];
            if (nil != testElement)
            {
                return testElement;
            }
        }
    }

    return nil;
}

+ (elementType)getElementTypeForName: (NSString *)nameStr
{
    if ([nameStr isEqualToString:kMATH_STEM])
    {
        return elementTypeRoot;
    }
    else if ([nameStr isEqualToString:kHTML_ELEMENT_NAME])
    {
        return elementTypeHtml;
    }
    else if ([nameStr isEqualToString:kHTML_BODY_ELEMENT_NAME])
    {
        return elementTypeHtmlBody;
    }
    else if ([nameStr isEqualToString:kDIV_ELEMENT_NAME])
    {
        return elementTypeDiv;
    }
    else if ([nameStr isEqualToString:kMSUP_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMSUB_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMSUBSUP_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMFRAC_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMOVER_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMUNDER_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMUNDEROVER_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMROW_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMSTYLE_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMSQRT_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMROOT_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMTABLE_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMTROW_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMTD_STEM])
    {
        return elementTypeStem;
    }
    else if ([nameStr isEqualToString:kMI_LEAF])
    {
        return elementTypeLeaf;
    }
    else if ([nameStr isEqualToString:kMO_LEAF])
    {
        return elementTypeLeaf;
    }
    else if ([nameStr isEqualToString:kMN_LEAF])
    {
        return elementTypeLeaf;
    }
    else if ([nameStr isEqualToString:kMTEXT_LEAF])
    {
        return elementTypeLeaf;
    }
    else if ([nameStr isEqualToString:kMSPACE_LEAF])
    {
        return elementTypeLeaf;
    }

    return elementTypeUnknown;
}


/*******************
 * Utility Methods *
 *******************/

+ (void)handleError: (NSError *) err withMessage: (NSString *)message
{
    NSLog(@"%@", message);

    if (nil != err)
    {
        NSLog(@"Description: %@", err.localizedDescription);
    }
}

+ (NSString *)filterString: (NSString *)filterStr UsingRegEx: (NSString *)templateStr replaceStr: (NSString *)replaceStr
{
    if (nil == filterStr || nil == templateStr || nil == replaceStr)
        return nil;

    //strip namespace attributes, which are causing problems:
    NSError *err = nil;

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:templateStr options:0 error:&err];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:filterStr
                                                               options:0
                                                                 range:NSMakeRange(0, filterStr.length)
                                                          withTemplate:replaceStr];

    if (nil != err)
    {
        [self handleError:err withMessage:@"Error in regular expression."];
        return nil;
    }

    return modifiedString;
}

+ (BOOL)elementIsRowStyle: (NSString *)elementName
{
    if ([elementName isEqualToString:kMROW_STEM] || [elementName isEqualToString:kMSQRT_STEM]
        || [elementName isEqualToString:kMTD_STEM])
    {
        return YES;
    }
    return NO;
}

+ (BOOL)adjustStyleDict: (NSMutableDictionary *)styleDict forMathVariant: (MathVariantType)mathVariant
{
    BOOL useCustomStyle = NO;

    // Not all types are supported so only adjust the style for supported types.
    if (mathVariant == frakturVariant)
    {
        useCustomStyle = YES;
        styleDict[kSTYLE_TYPE_KEY] = @(frakturStyle);
    }
    else if (mathVariant == scriptVariant)
    {
        useCustomStyle = YES;
        styleDict[kSTYLE_TYPE_KEY] = @(scriptStyle);
    }
    else if (mathVariant == doubleStruckVariant)
    {
        useCustomStyle = YES;
        styleDict[kSTYLE_TYPE_KEY] = @(blackboardStyle);
    }
    else if (mathVariant == italicVariant)
    {
        useCustomStyle = YES;
        styleDict[kITALIC_TEXT_KEY] = @(YES);
    }
    else if (mathVariant == boldVariant)
    {
        useCustomStyle = YES;
        styleDict[kBOLD_TEXT_KEY] = @(YES);
    }
    else if (mathVariant == boldItalicVariant)
    {
        useCustomStyle = YES;
        styleDict[kBOLD_TEXT_KEY] = @(YES);
        styleDict[kITALIC_TEXT_KEY] = @(YES);
    }

    return useCustomStyle;
}

@end

eq-library version 0.9
=======================

 Copyright (c) 2014-2015 Raymond Hodgson. All rights reserved.
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the names of the authors nor the names of their affiliation may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Note that included .plist and other Xcode files are part of "The source" as well.

========================================

eq-library is an open source math rendering library that uses CoreText to draw math for iOS.
A version for MacOS is in the works as well.

----------------
Important Notes:
----------------

1.  The included example uses BlahTeXCore to convert TeX to MathML. This is not a required dependency for the core drawing library.

    Also note that BlahTeX code may require updating to support 64-bit implementations. 
    I have left the warnings in place for the example, but you should resolve them before shipping anything.

2.  KISS XML is required for cases where you want to import MathML equations. It is not a required dependency for the core drawing library.

    Also note that KISS XML may have a couple of instances that should be checked for 64-bit implementations.
    I have left the warnings in place for the example, but you should resolve them before shipping.
    
    A. LibXML 2 is required as a dependency for KISS XML. If you're not using KISS XML, you don't need it include it.


3. STIX Fonts are required for drawing and it will throw an runtime exception when trying to render the equation if it can not find these fonts.

    Note that I have included TTF versions of the STIX fonts that I converted using TTX/Fonttools (https://github.com/behdad/fonttools/).
    These versions are necessary when producing PDFs for iOS as the OTF versions for STIX are not included in the PDF output.

    From what I understand, this is an Apple-side issue. There is a specific property in EQRenderEquation "usePDFMode" which should be set to "TRUE" 
    to ensure that it switches fonts correctly when drawing in a PDF context.

4. Apologia: This code is part of a larger equation editor app. The original goal was to render math live while the users types into a UITextInput subclass.

    A. This means some of the code may seem convoluted for an app that is just supposed to take MathML->PNG or PDF. Sorry about that.

    B. This means that some of the choices are not as good as the output from some flavor of TeX rendering. 
    The flip-side is that it uses fewer resources as it does not require a large font install and scripting parser.
    
    C. Support for inline equations is not great. I may go back and handle proper support for inlines in a future version.
    This is an excellent project idea for anyone else who wants to improve this library.

    D. If you want to support live editing of some sort, you will use fewer resources if you can extend and run the EQ Render View classes 
    directly as you won't have to go through the overhead of an XML parser. However, the solution I came up with is still closed source (for now). Again, sorry.


-------------------------------
Installation/Build Instructions
-------------------------------

Note: some of this will depend on your use case. If you don't need TeX, for example, don't grab BlahTeX and don't include the TeX classes in your build.

1. To add MathML to Image functionality you need to start by grabbing KISS XML and adding it and LibXML2.dylib to your build.

2. If you want to add support for TeX, go ahead and add BlahTeX to your build.

3. Add the STIX fonts to your build and include them in the info.plist file. If you don't work with PDFs, you don't need the TTF versions of the fonts.

4. At this point, you can add the main EQ-Library classes to your build and it should compile okay.

5. If you just need a PNG or JPEG output, the ConvertMathToImage class should make it relatively painless. 

    Create a UIImage with that class and use the UIImagePNGRepresentation() function on the returned image if you want to save it to a file.

6.  If you are wanting to draw directly in a context (including a PDF context), it takes some more work. 

    However, it is worth taking the time to learn, as the result will be drawn using the font libraries 
    which means it is a scalable vector instead of a raster image.
    
    I have included an example class to try and show the basics of how this would work, but much of that depends on what you need it to do.
    The code I extracted for an example came from a PDF layout class that used TextKit to handle most of the document and would add math to the 
    appropriate locations in the document. You may have an entirely different use case that is more (or less) complex. 
    
    Reading the example code should help you.



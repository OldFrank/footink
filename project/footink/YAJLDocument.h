//
//  YAJLDecoder.h
//  YAJL
//
//  Created by Gabriel Handford on 3/1/09.
//  Copyright 2009. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//


#include "YAJLParser.h"

typedef enum {
	YAJLDecoderCurrentTypeNone,
	YAJLDecoderCurrentTypeArray,
	YAJLDecoderCurrentTypeDict
} YAJLDecoderCurrentType;



@interface YAJLDocument : NSObject <YAJLParserDelegate> {
	
	id root_; // NSArray or NSDictionary
	YAJLParser *parser_;
	
	
	__weak NSMutableDictionary *dict_; // weak; if map in progress, points to the current map	
	__weak NSMutableArray *array_; // weak; If array in progress, points the current array
	__weak NSString *key_; // weak; If map in progress, points to current key
	
	NSMutableArray *stack_;
	NSMutableArray *keyStack_;
	
	YAJLDecoderCurrentType currentType_;
	
}

@property (readonly, nonatomic) id root; //! Root element

- (id)initWithData:(NSData *)data parserOptions:(YAJLParserOptions)parserOptions error:(NSError **)error;

@end

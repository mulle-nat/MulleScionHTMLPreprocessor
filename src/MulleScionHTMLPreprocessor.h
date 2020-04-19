//
//  MulleScionHTMLPreprocessor.h
//  MulleScion
//
//  Created by Nat! on 07.10.18.
//  Copyright © 2018 Mulle kybernetiK. All rights reserved.
//

#import "import.h"


#define MULLE_SCION_HTML_PREPROCESSOR_VERSION  ((0 << 20) | (2 << 8) | 1)


@interface MulleScionHTMLPreprocessor : NSObject

- (NSData *) preprocessedData:(NSData *) data;

@end

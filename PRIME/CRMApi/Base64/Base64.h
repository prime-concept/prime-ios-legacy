//
//  Base64.h
//  PRIME
//
//  Created by Admin on 02/02/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_Base64_h
#define PRIME_Base64_h

@interface Base64 : NSObject

+ (NSString *) encodeString: (NSString *) strData;
+ (NSString *) encodeData: (NSData *) objData;
+ (NSData *) decodeString: (NSString *) strBase64;

@end

#endif

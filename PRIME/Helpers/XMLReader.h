//
//  XMLReader.h
//  PRIME
//
//  Created by Davit on 8/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject <NSXMLParserDelegate>

+ (NSDictionary*)dictionaryForXMLData:(NSData*)data error:(NSError**)errorPointer;
+ (NSDictionary*)dictionaryForXMLString:(NSString*)string error:(NSError**)errorPointer;

@end

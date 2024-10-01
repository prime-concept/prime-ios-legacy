//
//  NSString+AllowCharactersInSet.h
//  PRIME
//
//  Created by Admin on 2/6/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

@interface NSString (AllowCharactersInSet)

- (NSString *)stringByAllowingOnlyCharactersInSet:(NSCharacterSet *)characterSet;

@end

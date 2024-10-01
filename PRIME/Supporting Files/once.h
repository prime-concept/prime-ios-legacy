//
//  once.h
//  PRIME
//
//  Created by Admin on 05/02/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_once_h
#define PRIME_once_h

#define pr_dispatch_once(expression...) { static dispatch_once_t onceToken; dispatch_once(&onceToken, ^expression); }

#define pr_dispatch_once_with_else(expression...) { NSArray* array = @[^expression]; static dispatch_once_t onceToken; __block BOOL b = NO; dispatch_once(&onceToken, ^{ ( (void (^)(void)) array.firstObject)(); b = YES; }); if(!b) { ( (void (^)(void)) array.lastObject)(); } }

#define pr_dispatch_once_with_else_ex(onceToken, expression...) { NSArray* array = @[^expression]; __block BOOL b = NO; dispatch_once(&onceToken, ^{ ( (void (^)(void)) array.firstObject)(); b = YES; }); if(!b) { ( (void (^)(void)) array.lastObject)(); } }

#endif

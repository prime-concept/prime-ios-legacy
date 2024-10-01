//
//  PRMessageStatusModel.m
//  PRIME
//
//  Created by Aram on 11/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRMessageStatusModel.h"

@implementation PRMessageStatusModel

#ifdef USE_COREDATA
@dynamic guid, status, delivered, state;
#endif

@end

//
//  PRTasklinkContent.h
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"
#import "PRTasklinkMessage.h"
#import "PRTasklinkTask.h"

@interface PRTasklinkContent : PRModel

@property (nonatomic, strong) PRTasklinkTask* task;
@property (nonatomic, strong) PRTasklinkMessage* message;

+ (RKObjectMapping*)mapping;

@end

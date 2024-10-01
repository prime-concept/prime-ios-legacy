//
//  PRTasklinkMessage.h
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"
#import "PRTasklinkMessageBody.h"

@interface PRTasklinkMessage : PRModel
@property (nonatomic, strong) NSNumber* requestId;
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSString* source;
@property (nonatomic, strong) PRTasklinkMessageBody* body;
@property (nonatomic, strong) NSNumber* type;

+ (RKObjectMapping*)mapping;

@end

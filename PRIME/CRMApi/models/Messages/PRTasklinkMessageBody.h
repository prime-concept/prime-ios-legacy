//
//  PRTasklinkMessageBody.h
//  PRIME
//
//  Created by Aram on 11/6/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRTasklinkMessageBody : PRModel

@property (nonatomic, strong) NSString* clientId;
@property (nonatomic, strong) NSString* chatId;
@property (nonatomic, strong) NSNumber* messageType;
@property (nonatomic, strong) NSString* messageId;
@property (nonatomic, strong) NSNumber* ttl;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSNumber* status;

+ (RKObjectMapping*)mapping;

@end

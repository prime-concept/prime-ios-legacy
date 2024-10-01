//
//  PRVoiceMessageModel.h
//  PRIME
//
//  Created by Aram on 12/26/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRVoiceMessageModel : PRModel

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* privacy;
@property (nonatomic, strong) NSString* uuid;
@property (nonatomic, strong) NSString* checksum;

+ (RKObjectMapping*)mapping;

@end

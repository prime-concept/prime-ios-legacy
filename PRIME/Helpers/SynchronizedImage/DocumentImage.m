//
//  DocumentImage.m
//  PRIME
//
//  Created by Nerses Hakobyan on 12/24/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import "DocumentImage.h"

@implementation DocumentImage

- (instancetype)initWithImage:(UIImage*)image andUid:(NSString*)udid andState:(NSNumber*)state
{
    self = [super init];

    if (self) {
        self.image = image;
        self.uid = udid;
        self.state = state;
    }

    return self;
}

#pragma mark NSCoding

#define kImageKey @"Image"
#define kIdKey @"Id"
#define kStateKey @"State"

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_image forKey:kImageKey];
    [encoder encodeObject:_uid forKey:kIdKey];
    [encoder encodeObject:_state forKey:kStateKey];
}

- (id)initWithCoder:(NSCoder*)decoder
{
    UIImage* image = [decoder decodeObjectForKey:kImageKey];
    NSString* uid = [decoder decodeObjectForKey:kIdKey];
    NSNumber* state = [decoder decodeObjectForKey:kStateKey];
    return [self initWithImage:image andUid:uid andState:state];
}

@end

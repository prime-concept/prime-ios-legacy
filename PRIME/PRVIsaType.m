//
//  PRVIsaType.m
//  PRIME
//
//  Created by Davit on 7/1/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRVisaType.h"

@implementation PRVisaType

- (instancetype)initWithTypeId:(NSNumber*)typeId
                       andName:(NSString*)typeName
{
    if (self = [super init]) {
        self.typeId = typeId;
        self.typeName = typeName;
    }
    return self;
}

@end

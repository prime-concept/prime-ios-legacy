//
//  Option.h
//  PRIME
//
//  Created by Admin on 3/26/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger, OPTION)
{
    OPTION_Avia,
    OPTION_VIPHall,
    OPTION_Transfer,
    OPTION_Hotel,
    OPTION_Restoran,
    OPTION_Other
};


@interface Option : NSObject

@property NSString *optionName;
@property NSString *imageName;
@property enum OPTION optionId;

+(instancetype) aviaOption;
+(instancetype) viphallOption;
+(instancetype) transferOption;
+(instancetype) hotelOption;
+(instancetype) restoranOption;
+(instancetype) otherOption;
@end

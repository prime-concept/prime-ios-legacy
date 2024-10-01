//
//  PRRequestDetailsParser.h
//  PRIME
//
//  Created by Artak on 5/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RequestDetailItemType) {
    RequestDetailItemType_text,
    RequestDetailItemType_field,
    RequestDetailItemType_link,
    RequestDetailItemType_button,
    RequestDetailItemType_separator,
    RequestDetailItemType_uber,
    RequestDetailItemType_unknown
};

@interface PRRequestDetailsParser : NSObject

+ (void) parseTaskDetail: (PRTaskDetailModel *) taskDetailModel
                    item: (void (^)(RequestDetailItemType type, NSString * name, NSString * value, NSString * icon, BOOL shariable)) onItemBlock
              groupStart: (void (^)(NSString * name, BOOL shariable)) onGroupStartBlock
                groupEnd: (void (^)(NSString * name)) onGroupEndBlock;

@end

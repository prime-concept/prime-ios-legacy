//
//  PRRequestDetailsParser.m
//  PRIME
//
//  Created by Artak on 5/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRRequestDetailsParser.h"

#import "PRTaskItemModel.h"

static NSString* const kGroup = @"group";
static NSString* const kText = @"text";
static NSString* const kField = @"field";
static NSString* const kLink = @"link";
static NSString* const kButton = @"button";
static NSString* const kSeparator = @"separator";
static NSString* const kUber = @"uber";

@interface PRRequestDetailsParser ()

+ (RequestDetailItemType)getItemType:(PRTaskItemModel*)item;
+ (NSString*)getItemName:(PRTaskItemModel*)item;
+ (NSString*)getItemValue:(PRTaskItemModel*)item;

@end

@implementation PRRequestDetailsParser

+ (void)parseTaskDetail:(PRTaskDetailModel*)taskDetailModel
                   item:(void (^)(RequestDetailItemType type, NSString* name, NSString* value, NSString* icon, BOOL shariable))onItemBlock
             groupStart:(void (^)(NSString* name, BOOL shariable))onGroupStartBlock
               groupEnd:(void (^)(NSString* name))onGroupEndBlock
{
    NSString* groupName = @"";
    BOOL shareable = YES;
    NSMutableArray* childItems = [NSMutableArray array];
    for (PRTaskItemModel* item in [taskDetailModel items]) {
        NSLog(@"name =%@ type =%@", item.itemName, item.itemType);

        if ([item.itemType isEqualToString:kGroup]) {

            onGroupStartBlock(groupName, shareable);

            for (PRTaskItemModel* childItem in childItems) {
                onItemBlock([self.class getItemType:childItem],
                    [self.class getItemName:childItem],
                    [self.class getItemValue:childItem],
                    [self.class getItemIcon:childItem],
                    [self.class getShariableValue:childItem]);
            }

            onGroupEndBlock(groupName);

            groupName = [self.class getItemName:item];
            shareable = [self.class getShariableValue:item];

            childItems = [NSMutableArray array]; // Create array for next group.
            continue;
        }

        [childItems addObject:item];
    }

    onGroupStartBlock(groupName, shareable);

    for (PRTaskItemModel* childItem in childItems) {
        onItemBlock([self.class getItemType:childItem],
            [self.class getItemName:childItem],
            [self.class getItemValue:childItem],
            [self.class getItemIcon:childItem],
            [self.class getShariableValue:childItem]);
    }

    onGroupEndBlock(groupName);
}

+ (RequestDetailItemType)getItemType:(PRTaskItemModel*)item
{
    NSString* itemType = item.itemType;

    if ((!itemType) || (itemType.length == 0)) {
        return RequestDetailItemType_unknown;
    }

    if ([itemType isEqualToString:kText]) {
        return RequestDetailItemType_text;
    }

    if ([itemType isEqualToString:kField]) {
        return RequestDetailItemType_field;
    }

    if ([itemType isEqualToString:kLink]) {
        return RequestDetailItemType_link;
    }

    if ([itemType isEqualToString:kButton]) {
        return RequestDetailItemType_button;
    }

    if ([itemType isEqualToString:kSeparator]) {
        return RequestDetailItemType_separator;
    }

    if ([itemType isEqualToString:kUber]) {
        return RequestDetailItemType_uber;
    }

    return RequestDetailItemType_unknown;
}

+ (NSString*)getItemName:(PRTaskItemModel*)item
{
    return (!item.itemName) ? @"" : item.itemName;
}

+ (NSString*)getItemValue:(PRTaskItemModel*)item
{
    return item.itemValue;
}

+ (NSString*)getItemIcon:(PRTaskItemModel*)item
{
    return item.itemIcon;
}

+ (BOOL)getShariableValue:(PRTaskItemModel*)item
{
    if ([item valueForKey:@"shareable"]) {
        return item.shareable;
    }

    return YES;
}

@end

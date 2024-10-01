//
//  DocumentImage.h
//  PRIME
//
//  Created by Nerses Hakobyan on 12/24/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DocumentImageStatus) {
    DocumentImageStatus_Created = 0,
    DocumentImageStatus_Deleted
};

@interface DocumentImage : NSObject <NSCoding>

- (instancetype)initWithImage:(UIImage*)image andUid:(NSString*)udid andState:(NSNumber*)state;

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSString* uid;
@property (strong, nonatomic) NSNumber* state;

@end

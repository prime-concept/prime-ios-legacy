//
//  XNAvatar.h
//  PRIME
//
//  Created by Admin on 6/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNAvatar : NSObject

+ (UIImage *) image;

+ (void) setImage: (UIImage *) image;

+ (void) synchronizeWithServer: (void (^)(UIImage * image)) update;

@end

//
//  SynchManager.h
//  PRIME
//
//  Created by Admin on 9/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SynchManager : NSObject

+ (SynchManager*)sharedClient;
- (void)addOperationWithBlock:(void (^)(void))block;

- (void)synchProfileContactsInContext:(NSManagedObjectContext*)context
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                           completion:(void (^)())completion;

- (void)synchProfilePersonalDataInContext:(NSManagedObjectContext*)context
                                     view:(UIView*)view
                                     mode:(PRRequestMode)mode
                               completion:(void (^)())completion;

- (void)synchProfileCarsInContext:(NSManagedObjectContext*)context
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                       completion:(void (^)())completion;

@end

//
//  PRFeedbackModel.h
//  PRIME
//
//  Created by Admin on 9/29/15.
//  Copyright © 2015 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface PRFeedbackModel : PRModel

@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSNumber *stars;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *objectType;


@end

NS_ASSUME_NONNULL_END


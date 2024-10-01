//
//  PRProfileBaseTypeModel.h
//  PRIME
//
//  Created by Artak on 1/22/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PRProfileBaseTypeModel : PRModel

@property (nullable, nonatomic, retain) NSNumber *typeId;
@property (nullable, nonatomic, retain) NSString *typeName;

@end

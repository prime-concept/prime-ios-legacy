//
//  PRVIsaType.h
//  PRIME
//
//  Created by Davit on 7/1/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRVisaType : NSObject

@property (strong, nonatomic) NSNumber* typeId;
@property (strong, nonatomic) NSString* typeName;

- (instancetype)initWithTypeId:(NSNumber*)typeId
                       andName:(NSString*)typeName;

@end

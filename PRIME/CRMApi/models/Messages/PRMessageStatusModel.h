//
//  PRMessageStatusModel.h
//  PRIME
//
//  Created by Aram on 11/20/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRMessageStatusModel : PRModel
@property (nonatomic, assign) BOOL delivered;
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSString* status;
@property (nonatomic, assign) MessageState state;

@end

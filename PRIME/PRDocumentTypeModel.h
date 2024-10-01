//
//  PRDocumentTypeModel.h
//  PRIME
//
//  Created by Hamlet on 2/20/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "PRModel.h"

@interface PRDocumentTypeModel : PRModel

@property (nonatomic, strong) NSNumber* typeId;
@property (nonatomic, strong) NSString* name;

+ (RKObjectMapping*)mapping;

@end

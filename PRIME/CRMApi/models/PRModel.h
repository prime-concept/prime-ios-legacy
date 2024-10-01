//
//  PRModel.h
//  PRIME
//
//  Created by Simon on 21/01/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRModel_h
#define PRIME_PRModel_h

#ifdef USE_COREDATA
typedef NSManagedObject PRModelBase;
#else
typedef NSObject PRModelBase;
#endif

@interface PRModel : PRModelBase

+ (RKObjectMapping*)mapping;

+ (void)setIdentificationAttributes:(NSArray*)attributes
                            mapping:(RKObjectMapping*)mapping;

- (void)save;

@end

#endif //PRIME_PRModel_h
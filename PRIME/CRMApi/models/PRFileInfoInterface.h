//
//  PRFileInfoInterface.h
//  PRIME
//
//  Created by Admin on 6/10/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#ifndef PRIME_PRFileInfoInterface_h
#define PRIME_PRFileInfoInterface_h

@protocol PRFileInfoInterface <NSObject>

@required

- (void) setDocumentId: (NSNumber *) documentId;

- (NSDate *) createdAt;
- (void) setCreatedAt: (NSDate *) createdAt;

- (NSString *) fileName;
- (void) setFileName: (NSString *) fileName;

@optional

- (void) save;

@end

#endif

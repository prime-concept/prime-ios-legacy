//
//  NSBundle+Convenience.h
//  PRIME
//
//  Created by Андрей Соловьев on 03.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Convenience)

- (BOOL)doesMatchURLScheme:(NSString *)scheme;

@end

NS_ASSUME_NONNULL_END

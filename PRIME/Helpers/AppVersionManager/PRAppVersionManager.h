//
//  PRAppVersionManager.h
//  PRIME
//
//  Created by Aram on 10/4/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

@interface PRAppVersionManager : NSObject
// Check if there is a new version of the application in the App Store. If update is available, go to App Store.
- (void)checkAppVersionAndShowAlertIfNeeded;

@end

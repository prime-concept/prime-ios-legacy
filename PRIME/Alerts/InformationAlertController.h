//
//  InformationAlertController.h
//  PRIME
//
//  Created by armens on 4/22/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef  enum AccessTo : NSInteger{
    AccessTo_Camera,
    AccessTo_Location,
    AccessTo_Document,
    AccessTo_PhotoLibrary,
    AccessTo_Contacts
} AccessTo;

@interface InformationAlertController : NSObject

+ (void)presentAlertDoesNotHaveAccessTo:(AccessTo)accessTo onPresenter:(UIViewController*)presenter;
+ (void)presentAlert:(UIViewController*)presenter alertTitle:(NSString*)title message:(NSString*)message okAction:(void(^ __nullable)()) okAction;

@end

NS_ASSUME_NONNULL_END

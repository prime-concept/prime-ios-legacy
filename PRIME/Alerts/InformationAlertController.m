//
//  InformationAlertController.m
//  PRIME
//
//  Created by armens on 4/22/19.
//  Copyright © 2019 XNTrends. All rights reserved.
//

#import "InformationAlertController.h"

@implementation InformationAlertController

+ (void)presentAlertDoesNotHaveAccessTo:(AccessTo)accessTo onPresenter:(UIViewController*)presenter;
{
    NSString* title = @"";
    switch (accessTo) {
        case AccessTo_Camera:
            title = @"camera";
            break;
        case AccessTo_PhotoLibrary:
            title = @"photo library";
            break;
        case AccessTo_Contacts:
            title = @"contacts";
            break;
        case AccessTo_Location:
            title = @"location";
            break;
        default:
            break;
    }

    NSString* alertTitle = [NSString stringWithFormat:@"This application does not have access to your %@", title];

    [self.class presentAlert:presenter
                  alertTitle:NSLocalizedString(alertTitle, nil)
                     message:NSLocalizedString(@"You can enable access in Privacy Settings", nil)
                    okAction:nil];
}

+ (void)presentAlert:(UIViewController*)presenter alertTitle:(NSString*)title message:(NSString*)message okAction:(void(^ __nullable)()) okAction
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(title, nil)
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction* __nullable action){
                                       if(okAction)
                                           okAction();
                                   }];

    [alert addAction:cancelButton];
    [presenter presentViewController:alert animated:YES completion:nil];
}

@end

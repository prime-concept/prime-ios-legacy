//
//  EditPhoneNumberViewController.m
//  PRIME
//
//  Created by Admin on 4/5/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "EditPhoneNumberViewController.h"

@interface EditPhoneNumberViewController ()

@end

@implementation EditPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareNavigationBar];

    
    _textFieldPhoneNumber.textColor = kAppLabelColor;
    
    if (![_phoneNumberString isEqualToString:@""] && _phoneNumberString != nil) {
        _textFieldPhoneNumber.formattedText = _phoneNumberString;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_textFieldPhoneNumber becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareNavigationBar
{
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", )
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(done)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", )
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(cancel)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
}


- (void) done
{
    [self.updateDelegate phoneNumberDidUpdateTo:_textFieldPhoneNumber.phoneNumber];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) cancel
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

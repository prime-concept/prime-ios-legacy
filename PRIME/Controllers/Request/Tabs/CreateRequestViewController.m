//
//  CreateRequestViewController.m
//  PRIME
//
//  Created by Admin on 3/19/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CreateRequestViewController.h"
#import "ContainerViewController.h"

@interface CreateRequestViewController ()

@end

@implementation CreateRequestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_tabBarContainer.layer setCornerRadius:5];
    [_tabBarContainer.layer setBorderWidth:1];
    [_tabBarContainer.layer setBorderColor:kAppLabelColor.CGColor];

    _buttonVipHall.tag = 1000;
    _buttonAvia.tag = 1001;
    _buttonHotel.tag = 1002;
    _buttonOther.tag = 1003;
    _buttonTransfer.tag = 1004;
    _buttonRestoran.tag = 1005;

    _activeButton = _buttonAvia;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        self.containerViewController = segue.destinationViewController;
    }
}

- (IBAction)changeTabAction:(UIButton*)sender
{
    //    _activeButton.selected = NO;
    //    _activeButton = sender;
    //    sender.selected = YES;
    //    NSDictionary *buttonSegueMaping = @{@(_buttonVipHall.tag) : SegueVipHall,
    //                                        @(_buttonAvia.tag) : SegueAvia,
    //                                        @(_buttonHotel.tag) : SegueHotel,
    //                                        @(_buttonOther.tag) : SegueOther,
    //                                        @(_buttonTransfer.tag) : SegueTransfer,
    //                                        @(_buttonRestoran.tag) : SegueVRestoran};
    //
    //    [self.containerViewController swapToViewControllers:buttonSegueMaping[@(sender.tag)]];
}
@end

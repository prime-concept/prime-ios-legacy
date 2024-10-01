//
//  DebugMenuViewController.m
//  PRIME
//
//  Created by Андрей Соловьев on 02.03.2023.
//  Copyright © 2023 XNTrends. All rights reserved.
//

#import "DebugMenuViewController.h"
#import <PureLayout.h>
#import "UIViewController+Convenience.h"
#import "Config.h"
#import "PRRequestManager.h"

@interface DebugMenuViewController ()

@end

@implementation DebugMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = UIColor.whiteColor;

	UIView *grabber = [UIView new];
	grabber.backgroundColor = UIColor.lightGrayColor;
	[self.view addSubview:grabber];
	[grabber autoSetDimensionsToSize:(CGSize){44, 4}];
	grabber.layer.cornerRadius = 2;
	[grabber autoAlignAxisToSuperviewAxis:ALAxisVertical];
	[grabber autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];

	UIStackView *vStack = [[UIStackView alloc] init];
	vStack.axis = UILayoutConstraintAxisVertical;

	[self.view addSubview:vStack];
	[vStack autoPinEdgesToSuperviewSafeAreaWithInsets:(UIEdgeInsets){20, 0, 0, 0}];

	UIView *prodRow = [self makeToggleRowWith:@"ПРОД"
										 isOn: Config.isProdEnabled
									   action:@selector(prodDidSwitch:)];

	[vStack addArrangedSubview:prodRow];

	UIView *bottomSpacer = [UIView new];
	[bottomSpacer autoSetDimension:ALDimensionHeight toSize:0 relation:NSLayoutRelationGreaterThanOrEqual];
	[vStack addArrangedSubview:bottomSpacer];
}

- (UIView *)makeToggleRowWith:(NSString *)title isOn:(BOOL)isOn action:(SEL) action {
	UIView *holder = [[UIView alloc] initWithFrame:(CGRect){0, 0, UIScreen.mainScreen.bounds.size.width, 44}];
	UILabel *label = [[UILabel alloc] init];
	label.text = title;
	label.textColor = UIColor.blackColor;

	UISwitch *swicth = [[UISwitch alloc] init];
	[swicth setOn:isOn];
	[swicth addTarget:self action:action forControlEvents:UIControlEventValueChanged];

	[holder addSubview:label];
	[holder addSubview:swicth];

	[holder autoSetDimension:ALDimensionHeight toSize:44];
	[label autoPinEdgesToSuperviewEdgesWithInsets:(UIEdgeInsets){0, 10, 0, 0} excludingEdge:ALEdgeRight];

	[swicth sizeToFit];
	[swicth autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
	[swicth autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

	return holder;
}

- (void)prodDidSwitch:(UISwitch *)sender {
	[self alert:@"Для применения необходим разлогин и перезапуск" action:^{
		Config.isProdEnabled = sender.isOn;
		[NSUserDefaults.standardUserDefaults setBool:NO forKey:kUserRegistered];
		[NSUserDefaults.standardUserDefaults synchronize];

		[Utils delay:1 block:^{
			exit(0);
		}];

	} cancel:^{
		[sender setOn:!sender.isOn];
	}];
}

@end

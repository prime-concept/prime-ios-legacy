//
//  PRAssistantInfoDataSource.m
//  PRIME
//
//  Created by Spartak on 2/2/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRAssistantInfoDataSource.h"
#import "PRAssistantInfoCell.h"
#import "PRPhoneNumberFormatter.h"

typedef NS_ENUM(NSInteger, PRAssistantAction) {
    PRAssistantAction_Phone,
    PRAssistantAction_Email
};

const CGFloat kAssistantInfoRowHeight = 40;

@interface PRAssistantInfoDataSource ()

@property (strong, nonatomic) NSString* assistantPhone;
@property (strong, nonatomic) NSString* assistantEmail;

@end

static const CGFloat kTitleLabelFontSize = 18.0f;
static const CGFloat kAssistantNameLabelFontSize = 17.0f;
static const CGFloat kMyAssistantLabelFontSize = 10.0f;
static const CGFloat kAssistantNameLabelHeight = 25.0f;
static const CGFloat kMyAssistantLabelHeight = 12.0f;
static NSString* const kTitleLabelText = @"Concierge";
static NSString* const kMyAssistantLabelText = @"My assistant";
#if defined(VTB24)
static NSString* const kEmailIconName = @"vtb_assistant_email";
static NSString* const kCallIconName = @"vtb_call_assistant";
#else
static NSString* const kEmailIconName = @"assistant_email";
static NSString* const kCallIconName = @"assistant_call";
#endif

@implementation PRAssistantInfoDataSource

- (instancetype)initWithAssistantPhone:(NSString*)phone email:(NSString*)email
{
    self = [super init];
    if (self) {
        _assistantPhone = phone;
        _assistantEmail = email;
    }
    return self;
}

#pragma mark - Public Functions

+ (UIView*)assistantTitleViewWithFram:(CGRect)frame asistentName:(NSString*)asistentName
{
    UIView* assistantTitleView = [[UIView alloc] initWithFrame:frame];

#if PrimeConciergeClub || PrivateBankingPRIMEClub || PrimeRRClub
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(assistantTitleView.frame), CGRectGetHeight(assistantTitleView.frame))];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:kTitleLabelFontSize];
    titleLabel.textColor = kChatTitleColor;
    titleLabel.text = NSLocalizedString(kTitleLabelText, nil);

    [assistantTitleView addSubview:titleLabel];

#else
    UILabel* assistantNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(assistantTitleView.frame), kAssistantNameLabelHeight)];
    assistantNameLabel.textAlignment = NSTextAlignmentCenter;
    assistantNameLabel.font = [UIFont systemFontOfSize:kAssistantNameLabelFontSize];
    assistantNameLabel.text = asistentName;

#if defined(Raiffeisen) || defined(VTB24)
    assistantNameLabel.textColor = kChatTitleColor;
#endif

    UILabel* myAssistantLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(assistantNameLabel.frame), CGRectGetWidth(assistantTitleView.frame), kMyAssistantLabelHeight)];
    myAssistantLabel.textAlignment = NSTextAlignmentCenter;
    myAssistantLabel.font = [UIFont systemFontOfSize:kMyAssistantLabelFontSize];
    myAssistantLabel.text = NSLocalizedString(kMyAssistantLabelText, nil);
    myAssistantLabel.textColor = kChatTitleColor;

    [assistantTitleView addSubview:assistantNameLabel];
    [assistantTitleView addSubview:myAssistantLabel];
#endif

    return assistantTitleView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_assistantEmail || !_assistantPhone) {
        return 1;
    }

    return 2;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PRAssistantInfoCell* cell = (PRAssistantInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"AssistantInfoCell"];

    cell.assistantInfoLabel.font = [UIFont systemFontOfSize:15];
    [cell.assistantInfoImageView setTintColor:kIconsColor];
    cell.assistantInfoImageView.contentMode = UIViewContentModeCenter;

    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.preservesSuperviewLayoutMargins = NO;
        cell.separatorInset = cell.layoutMargins = UIEdgeInsetsZero;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0, 51, 0, 0);
    }

    switch (indexPath.row) {
    case PRAssistantAction_Phone: {
        if (!_assistantPhone) {
            return [self configureEmailCell:cell];
        }
        return [self configurePhoneCell:cell];
    }
    case PRAssistantAction_Email: {
        return [self configureEmailCell:cell];
    }
    default:
        return nil;
    }
}

#pragma mark - Cell Configuration

- (PRAssistantInfoCell*)configurePhoneCell:(PRAssistantInfoCell*)cell
{
    cell.assistantInfoLabel.text = [PRPhoneNumberFormatter formatedStringForPhone:_assistantPhone];
    cell.assistantInfoImageView.image = [self imageWithName:kCallIconName];

    return cell;
}

- (PRAssistantInfoCell*)configureEmailCell:(PRAssistantInfoCell*)cell
{
    cell.assistantInfoLabel.text = _assistantEmail;
    cell.assistantInfoImageView.image = [self imageWithName:kEmailIconName];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return kAssistantInfoRowHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.row) {
    case PRAssistantAction_Phone: {
        if (!_assistantPhone) {
            [self emailAction];
            break;
        }
        [self callAction];
        break;
    }
    case PRAssistantAction_Email:
        [self emailAction];
        break;
    default:
        break;
    }
}

#pragma mark - Helpers

- (UIImage*)imageWithName:(NSString*)imageName
{
    UIImage* image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

#ifdef PrimeConciergeClub
    image = [UIImage imageNamed:[[NSString stringWithFormat:@"%@_", kTargetName] stringByAppendingString:imageName]];
#endif

    return image;
}

#pragma mark - Actions

- (void)callAction
{
    [PRGoogleAnalyticsManager sendEventWithName:kCallToAssistantClicked parameters:nil];
    NSString* phoneNumber = [@"telprompt://" stringByAppendingString:_assistantPhone];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (void)emailAction
{
    [PRGoogleAnalyticsManager sendEventWithName:kMailToAssistantClicked parameters:nil];
    NSString* phoneNumber = [@"mailto://" stringByAppendingString:_assistantEmail];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

@end

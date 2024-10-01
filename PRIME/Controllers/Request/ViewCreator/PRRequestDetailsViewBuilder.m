//
//  PRRequestDetailsViewBuilder.m
//  PRIME
//
//  Created by Artak on 5/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRRequestDetailsViewBuilder.h"
#import "PRUberView.h"

static const NSUInteger bottomMargin = 15;

@interface PRRequestDetailsViewBuilder ()

@property (strong, nonatomic) UIView* containerView;
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) id<PRRequestDetailsViewFactoryInterface> factory;

@end

@implementation PRRequestDetailsViewBuilder

- (instancetype)initForTableView:(UITableView*)tableView
                         factory:(id<PRRequestDetailsViewFactoryInterface>)factory
{
    if (self = [super init]) {
        _tableView = tableView;
        _factory = factory;
        _containerView = [_factory createContainerViewForTableView:_tableView];
    }

    return self;
}

#pragma mark - Header

- (void)makeHeaderForTaskId:(NSNumber*)taskId
                   withDate:(NSDate*)requestDate
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"dd.MM.YYYY HH:mm:ss"];

    //- Request ID.

    NSString* requestIdTitle = [NSString stringWithFormat:@"%@ # %@",
                                         NSLocalizedString(@"Request", ),
                                         taskId];

    UILabel* labelRequestId = [_factory createH1LabelWithText:requestIdTitle
                                                 forContainer:_containerView];

    [_containerView addSubview:labelRequestId];

    //- Request Date.

    NSString* requestDateFormated = [formater stringFromDate:requestDate];

    UILabel* labelRequestDate = [_factory createH2LabelWithText:requestDateFormated
                                                   forContainer:_containerView];

    [_containerView addSubview:labelRequestDate];
}

#pragma mark - Text

- (void)makeTextWithName:(NSString*)name
                   value:(NSString*)value
                    icon:(NSString*)icon
{
    BOOL isTitleVisible = (name && ![name isEqualToString:@""]);
    if (isTitleVisible) {
        UIView* labelTitle = [_factory createH2LabelWithText:name
                                                        icon:(isTitleVisible) ? nil : icon
                                                andLabelSize:H2LabelSize_Large
                                                forContainer:_containerView];
        [_containerView addSubview:labelTitle];
    }

    if (value && ![value isEqualToString:@""]) {
        UIView* labelText = [_factory createH2LabelWithText:value
                                                       icon:(isTitleVisible) ? nil : icon
                                               andLabelSize:H2LabelSize_Small
                                               forContainer:_containerView];
        [_containerView addSubview:labelText];
    }
}

#pragma mark - Label

- (void)makeLabelsWithName:(NSString*)name
                     value:(NSString*)value
{
    UILabel* labelLeft = [_factory createLabelWithText:name
                                                onSide:LabelSide_Left
                                          forContainer:_containerView];

    UILabel* labelRight = [_factory createLabelWithText:value
                                                 onSide:LabelSide_Right
                                           forContainer:_containerView];

    [_containerView addSubview:labelLeft];
    [_containerView addSubview:labelRight];
}

#pragma mark - Link

- (void)makeLinkViewWithTitle:(NSString*)title
                          url:(NSString*)url
                         icon:(NSString*)icon
                       target:(id)target
                       action:(SEL)action
{
    UIView* link = [_factory createLinkWithTitle:title
                                             url:url
                                            icon:icon
                                    forContainer:_containerView
                                          target:target
                                          action:action];

    [_containerView addSubview:link];
}

#pragma mark - Button

- (void)makeButtonWithTitle:(NSString*)title
                        url:(NSString*)url
                     target:(id)target
                     action:(SEL)action
{
    UIButton* button = [_factory createButtonWithTitle:title
                                                   url:url
                                          forContainer:_containerView
                                                target:target
                                                action:action];

    [_containerView addSubview:button];
}

#pragma mark - Separator

- (void)makeSeparatorViewWithName:(NSString*)name
                            value:(NSString*)value
{
    UIView* separator = [_factory createSeparatorForContainer:_containerView];

    [_containerView addSubview:separator];
}

#pragma mark - UBER

- (void)makeUberFieldWithValue:(NSString*)value
         andGestureRecognizers:(NSArray<UITapGestureRecognizer*>*)gestureRecognizers
                     withBlock:(void (^)(PRUberView* left, UILabel* right))block
{
    PRUberView* leftPart = [_factory createLeftPartForUberWithContainer:_containerView
                                                   andGestureRecognizer:(gestureRecognizers && gestureRecognizers.count) ? [gestureRecognizers firstObject] : nil];
    UILabel* rightPart = nil;

    if (!value) {
        leftPart.uberViewNameLabel.text = NSLocalizedString(@"Waiting for UBER", nil);
    }
    else {
        rightPart = [_factory createRightLabelForUberWithText:value
                                         andGestureRecognizer:[gestureRecognizers lastObject]
                                                 forContainer:_containerView];

        [_containerView addSubview:rightPart];
    }
    [_containerView addSubview:leftPart];
    block(leftPart, rightPart);
}

#pragma mark - Build Container

- (UIView*)build
{
    [_containerView setFrame:CGRectMake(CGRectGetMinX(_containerView.frame), CGRectGetMinY(_containerView.frame),
                                 CGRectGetWidth(_containerView.frame), CGRectGetHeight(_containerView.frame) + bottomMargin)];
    return _containerView;
}

@end

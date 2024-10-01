//
//  PRRequestDetailsViewBuilder.h
//  PRIME
//
//  Created by Artak on 5/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRUberView.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, H2LabelSize) {
    H2LabelSize_Large,
    H2LabelSize_Small
};

typedef NS_ENUM(NSInteger, LabelSide) {
    LabelSide_Left,
    LabelSide_Right
};

@protocol PRRequestDetailsViewFactoryInterface <NSObject>

@required

- (UIView*)createContainerViewForTableView:(UITableView*)tableView;

- (UILabel*)createH1LabelWithText:(NSString*)text
                     forContainer:(UIView*)containerView;

- (UILabel*)createH2LabelWithText:(NSString*)text
                     forContainer:(UIView*)containerView;

- (UIView*)createH2LabelWithText:(NSString*)text
                            icon:(NSString*)icon
                    andLabelSize:(H2LabelSize)labelSize
                    forContainer:(UIView*)containerView;

- (UIButton*)createButtonWithTitle:(NSString*)title
                               url:(NSString*)url
                      forContainer:(UIView*)containerView
                            target:(id)target
                            action:(SEL)action;

- (UIView*)createLinkWithTitle:(NSString*)title
                           url:(NSString*)url
                          icon:(NSString*)icon
                  forContainer:(UIView*)containerView
                        target:(id)target
                        action:(SEL)action;

- (UILabel*)createLabelWithText:(NSString*)text
                         onSide:(LabelSide)labelSide
                   forContainer:(UIView*)containerView;

- (PRUberView*)createLeftPartForUberWithContainer:(UIView*)containerView
                             andGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer;

- (UILabel*)createRightLabelForUberWithText:(NSString*)text
                       andGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer
                               forContainer:(UIView*)containerView;

- (UIView*)createSeparatorForContainer:(UIView*)containerView;

@end

@interface PRRequestDetailsViewBuilder : NSObject

- (instancetype)initForTableView:(UITableView*)tableView
                         factory:(id<PRRequestDetailsViewFactoryInterface>)factory;

- (void)makeHeaderForTaskId:(NSNumber*)taskId
                   withDate:(NSDate*)requestDate;

- (void)makeTextWithName:(NSString*)name
                   value:(NSString*)value
                    icon:(NSString*)icon;

- (void)makeLabelsWithName:(NSString*)name
                     value:(NSString*)value;

- (void)makeLinkViewWithTitle:(NSString*)title
                          url:(NSString*)url
                         icon:(NSString*)icon
                       target:(id)target
                       action:(SEL)action;

- (void)makeButtonWithTitle:(NSString*)title
                        url:(NSString*)url
                     target:(id)target
                     action:(SEL)action;

- (void)makeSeparatorViewWithName:(NSString*)name
                            value:(NSString*)value;

- (void)makeUberFieldWithValue:(NSString*)value
         andGestureRecognizers:(NSArray<UITapGestureRecognizer*>*)gestureRecognizers
                     withBlock:(void (^)(PRUberView* left, UILabel* right))block;

- (UIView*)build;

@end

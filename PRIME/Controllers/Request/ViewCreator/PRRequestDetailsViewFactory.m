//
//  PRRequestDetailsViewFactory.m
//  PRIME
//
//  Created by Artak on 5/25/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRRequestDetailsViewFactory.h"

#import "ContainerButton.h"

#import "FontAwesomeIconView.h"

#import "NBPhoneNumberUtil.h"

#import "TTTAttributedLabel.h"

#import "PRUberView.h"

// Margins
static const NSInteger kTopMargin = 15;
static const NSInteger kLeftMargin = 15;
static const NSInteger kRightMargin = 15;
static const NSInteger kLabelTopMargin = 5;

// Lebal heights
static const NSInteger kLabelHeightLarge = 20;
static const NSInteger kLabelHeightMedium = 18;
static const NSInteger kLabelHeightSmall = 15;

// Label font sizes
static const NSInteger kLabelFontLarge = 18;
static const NSInteger kLabelFontMedium = 16;
static const NSInteger kLabelFontSmall = 14;

// UI Control heights
static const NSInteger kButtonHeight = 30;
static const NSInteger kSeparatorHeight = 0.6;

// Button parameters
static const NSInteger kButtonCornerRadius = 5;
static const NSInteger kButtonFontSize = 15;

////////////////////////////////////////////////////////////////////////////////

@interface Container : UIView

- (CGSize)sizeThatFits:(CGSize)size;

- (void)addSubview:(UIView*)view;

@end

@implementation Container

- (CGSize)sizeThatFits:(CGSize)size
{
    UIView* view = [self.subviews lastObject];

    CGFloat fitHeight = CGRectGetMaxY(view.frame);

    return CGSizeMake(size.width, MAX(fitHeight, size.height));
}

- (void)addSubview:(UIView*)view
{
    [super addSubview:view];

    [self sizeToFit];
}

@end

////////////////////////////////////////////////////////////////////////////////

@implementation PRRequestDetailsViewFactory

+ (CGFloat)widthWithoutMarginForTableView:(UITableView*)tableView
{
    return (CGRectGetWidth(tableView.bounds) - kRightMargin - kLeftMargin);
}

- (UIView*)createContainerViewForTableView:(UITableView*)tableView
{
    CGFloat widthWithoutMargin = [self.class widthWithoutMarginForTableView:tableView];

    return [[Container alloc] initWithFrame:CGRectMake(kLeftMargin, 0, widthWithoutMargin, kTopMargin - kLabelTopMargin)];
}

+ (UILabel*)createLabelWithText:(NSString*)text
                   forContainer:(UIView*)containerView
                       fontSize:(CGFloat)fontSize
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame = CGRectMake(0, offsetY + kLabelTopMargin, width, kLabelHeightLarge);

    UILabel* label = [[UILabel alloc] init];
    label.frame = frame;
    label.text = text;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = kBlueTextColor;

    return label;
}

- (UILabel*)createH1LabelWithText:(NSString*)text
                     forContainer:(UIView*)containerView
{
    return [self.class createLabelWithText:text
                              forContainer:containerView
                                  fontSize:kLabelFontLarge];
}

- (UILabel*)createH2LabelWithText:(NSString*)text
                     forContainer:(UIView*)containerView
{
    return [self.class createLabelWithText:text
                              forContainer:containerView
                                  fontSize:kLabelFontMedium];
}

- (UIView*)createH2LabelWithText:(NSString*)text
                            icon:(NSString*)icon
                    andLabelSize:(H2LabelSize)labelSize
                    forContainer:(UIView*)containerView;
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetX = 0;

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame;

    if (labelSize == H2LabelSize_Large) {
        frame = CGRectMake(0, offsetY + kLabelTopMargin, width, kLabelHeightLarge);
    }
    else if (labelSize == H2LabelSize_Small) {
        frame = CGRectMake(0, offsetY + kLabelTopMargin, width, kLabelHeightMedium);
    }

    Container* groupView = [[Container alloc] initWithFrame:frame];

    if (icon && ![icon isEqualToString:@""]) {

        FontAwesomeIconView* iconView = [[FontAwesomeIconView alloc] initWithIcon:icon
                                                                           height:2 * kLabelFontMedium];

        iconView.frame = CGRectMake(0, 0, CGRectGetWidth(iconView.frame), 2 * kLabelHeightLarge);

        offsetX = CGRectGetWidth(iconView.frame) + kLeftMargin;

        [groupView addSubview:iconView];
    }

    frame = CGRectMake(offsetX, 0, width - offsetX, ((icon != nil) ? 2 : 1) * kLabelHeightLarge);

    TTTAttributedLabel* label = [[TTTAttributedLabel alloc] initWithFrame:frame];
    label.text = text;
    if (labelSize == H2LabelSize_Large) {
        [self setAttributesForLabel:label Font:[UIFont boldSystemFontOfSize:kLabelFontMedium]];
    }
    else if (labelSize == H2LabelSize_Small) {
        [self setAttributesForLabel:label Font:[UIFont systemFontOfSize:kLabelFontMedium]];
    }
    [self checkPhoneNumberInText:label];
    [label sizeToFit];
    if (CGRectGetHeight(label.frame) < (icon ? 2 : 1) * kLabelHeightLarge) {
        label.frame = frame;
    }

    [groupView addSubview:label];

    return groupView;
}

- (void)setAttributesForLabel:(TTTAttributedLabel*)label Font:(UIFont*)font
{
    [label setNumberOfLines:0];
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary* attributes = @{ NSFontAttributeName : font,
        NSParagraphStyleAttributeName : paragraphStyle };
    NSMutableAttributedString* shortAttributedString = [[NSMutableAttributedString alloc] initWithString:label.text attributes:attributes];
    label.attributedText = shortAttributedString;
}

- (void)searchInTextForPhoneNumberInLabel:(TTTAttributedLabel*)label WithPrefix:(NSString*)prefix andRange:(NSUInteger)index
{
    if (![[label.text substringWithRange:NSMakeRange(index, 1)] isEqualToString:prefix]) {
        return;
    }

    const int kPhoneNumberDigitCount = 11;
    __block NSUInteger phoneNumberDigitCount = 0;
    __block BOOL isValidNumber = NO;

    NSMutableString* modifiedString = [[NSMutableString alloc] initWithString:prefix];

    NSArray<NSString*>* phoneNumberSigns = @[ @" ", @"-", @"(", @")" ];

    [label.text enumerateSubstringsInRange:NSMakeRange(index + 1, [label.text length] - index - 1)
                                   options:NSStringEnumerationByComposedCharacterSequences
                                usingBlock:^(NSString* _Nullable currentLetter, NSRange substringRange, NSRange enclosingRange, BOOL* _Nonnull stop) {
                                    if ([phoneNumberSigns containsObject:currentLetter]) {
                                        [modifiedString appendString:currentLetter];

                                        return;
                                    }

                                    if (![currentLetter isAllDigits]) {
                                        *stop = YES;
                                        return;
                                    }

                                    phoneNumberDigitCount++;
                                    [modifiedString appendString:currentLetter];

                                    if (phoneNumberDigitCount == kPhoneNumberDigitCount) {
                                        isValidNumber = YES;
                                        *stop = YES;
                                    }

                                }];

    if (isValidNumber) {
        [label addLinkToPhoneNumber:modifiedString withRange:NSMakeRange(index, modifiedString.length)];
        label.delegate = _parentViewDelegate;
    }
}

- (void)checkPhoneNumberInText:(TTTAttributedLabel*)label
{
    for (int textIndex = 0; textIndex < [label.text length]; textIndex++) {
        NSRange range = NSMakeRange(textIndex, 1);
        [self searchInTextForPhoneNumberInLabel:label WithPrefix:@"+" andRange:range.location];
        [self searchInTextForPhoneNumberInLabel:label WithPrefix:@"-" andRange:range.location];
        [self searchInTextForPhoneNumberInLabel:label WithPrefix:@" " andRange:range.location];
    }
}

- (UILabel*)createLabelWithText:(NSString*)text
                         onSide:(LabelSide)labelSide
                   forContainer:(UIView*)containerView
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame = CGRectZero;

    if (labelSide == LabelSide_Left) {
        frame = CGRectMake(0, offsetY + kLabelTopMargin, width / 2, kLabelHeightSmall);
    }
    else if (labelSide == LabelSide_Right) {
        frame = CGRectMake(0 + width / 2, offsetY + kLabelTopMargin, width / 2, kLabelHeightSmall);
    }

    TTTAttributedLabel* label = [[TTTAttributedLabel alloc] initWithFrame:frame];
    label.frame = frame;
    label.text = text;

    [self setAttributesForLabel:label Font:[UIFont systemFontOfSize:kLabelFontSmall]];
    [self checkPhoneNumberInText:label];

    [label setNumberOfLines:0];
    [label sizeToFit];

    return label;
}

- (PRUberView*)createLeftPartForUberWithContainer:(UIView*)containerView
                             andGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame = CGRectMake(0, offsetY + kLabelTopMargin + 10, (gestureRecognizer ? width / 2 : width), kLabelHeightSmall);

    PRUberView* uberView = [[PRUberView alloc] initWithFrame:frame];

    if (gestureRecognizer && ![uberView.gestureRecognizers containsObject:gestureRecognizer]) {
        [uberView addGestureRecognizer:gestureRecognizer];
    }

    return uberView;
}

- (UILabel*)createRightLabelForUberWithText:(NSString*)text
                       andGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer
                               forContainer:(UIView*)containerView
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame = CGRectMake(0 + width / 2, offsetY + kLabelTopMargin + 9, width / 2, kLabelHeightSmall);

    UILabel* label = [[UILabel alloc] initWithFrame:frame];

    label.frame = frame;
    label.text = text;
    label.textColor = kUberEstimatedArriveTimeLabelColor;
    label.font = [UIFont systemFontOfSize:kLabelFontSmall];
    [label setNumberOfLines:0];
    [label sizeToFit];
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:gestureRecognizer];
    [containerView bringSubviewToFront:label];
    return label;
}

- (UIButton*)createButtonWithTitle:(NSString*)title
                               url:(NSString*)url
                      forContainer:(UIView*)containerView
                            target:(id)target
                            action:(SEL)action
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame = CGRectMake(0, offsetY + kLabelTopMargin, width, kButtonHeight);

    ContainerButton* button = [ContainerButton buttonWithType:UIButtonTypeCustom];

    button.frame = frame;
    button.backColor = kContainerButtonColor;
    button.backgroundColor = kContainerButtonColor;

    [button setTitle:title
            forState:UIControlStateNormal];

#if defined(PrimeConciergeClub)
    [button setTitleColor:[UIColor blackColor]
                 forState:UIControlStateNormal];
#else
    [button setTitleColor:[UIColor whiteColor]
                 forState:UIControlStateNormal];
#endif

    [button setTitleColor:kBlueTextColor
                 forState:UIControlStateHighlighted];

    button.layer.cornerRadius = kButtonCornerRadius;
    button.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    button.content = url;
    [button setUserInteractionEnabled:YES];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (UIView*)createLinkWithTitle:(NSString*)title
                           url:(NSString*)url
                          icon:(NSString*)icon
                  forContainer:(UIView*)containerView
                        target:(id)target
                        action:(SEL)action
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetX = 0;

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame = CGRectMake(0, offsetY + kLabelTopMargin, width, kButtonHeight);

    Container* groupView = [[Container alloc] initWithFrame:frame];

    if (icon && ![icon isEqualToString:@""]) {

        FontAwesomeIconView* iconView = [[FontAwesomeIconView alloc] initWithIcon:icon
                                                                           height:2 * kLabelFontSmall];

        iconView.frame = CGRectMake(0, 0, CGRectGetWidth(iconView.frame), kButtonHeight);

        offsetX = CGRectGetWidth(iconView.frame) + kLeftMargin;

        [groupView addSubview:iconView];
    }

    frame = CGRectMake(offsetX, 0, width - offsetX, kButtonHeight);

    ContainerButton* button = [ContainerButton buttonWithType:UIButtonTypeCustom];

    button.frame = frame;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.font = [UIFont systemFontOfSize:kLabelFontSmall];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    NSAttributedString* titleUnderlined = [[NSAttributedString alloc] initWithString:title
                                                                          attributes:@{
                                                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                                                                              NSFontAttributeName : button.titleLabel.font
                                                                          }];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [button setAttributedTitle:titleUnderlined
                      forState:UIControlStateNormal];

    [button setTitleColor:kBlueTextColor
                 forState:UIControlStateNormal];

    button.content = url;
    [button setUserInteractionEnabled:YES];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    CGSize constraint = CGSizeMake(CGRectGetWidth(button.frame), 5000.0f);
    CGRect titleFrame = [titleUnderlined boundingRectWithSize:constraint
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      context:nil];

    button.frame = CGRectMake(CGRectGetMinX(button.frame),
        CGRectGetMinY(button.frame),
        CGRectGetWidth(button.frame),
        MAX(CGRectGetHeight(titleFrame) + 10, kButtonHeight));

    [groupView addSubview:button];

    return groupView;
}

- (UIView*)createSeparatorForContainer:(UIView*)containerView
{
    CGFloat width = CGRectGetWidth(containerView.frame);

    CGFloat offsetY = CGRectGetMaxY(containerView.frame);

    CGRect frame = CGRectMake(0, offsetY + kLabelTopMargin, width, kSeparatorHeight);
    UIView* separator = [[UIView alloc] initWithFrame:frame];
    [separator.layer setShadowColor:kAppTintColor.CGColor];
    [separator.layer setShadowOpacity:1];
    [separator.layer setShadowRadius:1];
    [separator.layer setShadowOffset:CGSizeMake(0, 1)];

    separator.backgroundColor = kAppTintColor;

    return separator;
}

@end

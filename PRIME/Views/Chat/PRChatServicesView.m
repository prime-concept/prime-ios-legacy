//
//  PRChatServicesView.m
//  PRIME
//
//  Created by Taron on 4/27/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PRChatServicesView.h"
#import "PRUserDefaultsManager.h"

#define kAppTypePrime @"prime"
#define kAppTypeCorp @"corp"
#define kScaleFactor2x @"@2x"
#define kScaleFactor3x @"@3x"

#define kScaleFactor IS_IPHONE_6P ? kScaleFactor3x : kScaleFactor2x

@interface PRChatServiceCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView* iconImageView;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;

@end

@interface PRService : NSObject
@property (strong, nonatomic) PRServicesModel* info;
@property (strong, nonatomic) UIImage* icon;
@property (assign, nonatomic) NSInteger tag;

@end

///////////////////////////////////////////////////////////////////

@interface PRChatServicesView () <UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView* iconsCollectionView;
@property (strong, nonatomic) NSArray<PRService*>* services;
@property (strong, nonatomic) NSArray<PRServicesModel*>* storedServices;
@property (assign, nonatomic) CGFloat cellsInteritemSpacing;
@property (assign, nonatomic) NSInteger maxItemsCountInRow;
@property (assign, nonatomic) NSInteger sectionsCount;

@end

static const CGFloat kIconCellWidth = 44.0f;
static const CGFloat kMinInteritemSpacing = 4.0f;
static const NSInteger kMoreButtonTag = 11;
static NSString* const kMoreButtonImageName = @"more";

@implementation PRChatServicesView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _iconsCollectionView.delegate = self;
    _iconsCollectionView.dataSource = self;
    _cellsInteritemSpacing = kMinInteritemSpacing;

    _storedServices = [PRDatabase getServices];
    NSArray<PRService*>* sortedServices = [self getSortedServices:_storedServices];
    _services = [self sortServices:sortedServices];
    [self setupCollectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_services count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    PRServicesModel* serviceModel = _services[indexPath.row].info;
    PRChatServiceCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.iconImageView.image = _services[indexPath.row].icon;
    cell.nameLabel.text = serviceModel.name ?: @"";
    cell.nameLabel.textColor = kChatTaskIconTextColor;
    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    PRService* service = _services[indexPath.row];

    if (service.tag == kMoreButtonTag) {
        if (_delegate && [_delegate respondsToSelector:@selector(didPressMoreButton)]) {
            [self setState:PRChatServicesViewState_Expanded];
            [_delegate didPressMoreButton];
        }

        return;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(didSelectMenuItem:)]) {
        [self moveServiceToTheBeginning:service];
        [_delegate didSelectMenuItem:service.info];
    }
}

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionView*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return _cellsInteritemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, _cellsInteritemSpacing, 0, _cellsInteritemSpacing);
}

- (NSArray<PRService*>*)getSortedServices:(NSArray<PRServicesModel*>*)servicesArray
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kServicesOrder]) {
        [self saveServicesOrder:servicesArray];
    }

    NSMutableArray<PRService*>* tmpServicesArray = [NSMutableArray array];
    for (PRServicesModel* serviceInfo in servicesArray) {
        if(serviceInfo.image != nil) {
            PRService* service = [[PRService alloc] init];
            service.icon = [UIImage imageWithData:serviceInfo.image];
            service.info = serviceInfo;
            [tmpServicesArray addObject:service];
        }
    }
    return tmpServicesArray;
}

- (void)updateCollectionViewForItems
{
    _storedServices = [PRDatabase getServices];
    NSArray<PRService*>* sortedServices = [self getSortedServices:_storedServices];
    [self updateServices:sortedServices];

    [self updateServicesImages];
}

- (void)updateServicesImages
{
    _storedServices = [PRDatabase getServices];
    NSMutableArray<PRService*>* tmpServicesArray = [NSMutableArray array];
    __block NSInteger servicesCount = _storedServices.count;

    for (PRServicesModel* serviceInfo in _storedServices) {
        __weak PRChatServicesView* weakSelf = self;
        [self getServiceIconWithName:serviceInfo.icon
                             success:^(UIImage* image) {
                                 PRChatServicesView* strongSelf = weakSelf;
                                 if (!strongSelf) {
                                     return;
                                 }
                                 serviceInfo.image = UIImagePNGRepresentation(image);
                                 [serviceInfo save];

                                 PRService* service = [[PRService alloc] init];
                                 service.icon = image;
                                 service.info = serviceInfo;
                                 [tmpServicesArray addObject:service];

                                 if (tmpServicesArray.count == servicesCount) {
                                     [strongSelf updateServices:tmpServicesArray];
                                 }
                             }
                             failure:^{
                                 PRChatServicesView* strongSelf = weakSelf;
                                 if (!strongSelf) {
                                     return;
                                 }

                                 servicesCount--;
                                 if (tmpServicesArray.count == servicesCount) {
                                     [strongSelf updateServices:tmpServicesArray];
                                 }
                             }];
    }
}

- (NSString*)urlForIcon:(NSString*)name
{
    NSString* type = kAppTypePrime;
#if Raiffeisen || VTB24 || Otkritie || Platinum || Skolkovo || PrimeConciergeClub || PrivateBankingPRIMEClub || PrimeRRClub || Davidoff || PrimeClubConcierge
    type = kAppTypeCorp;
#endif

    NSString* nameWithSuffix = [[name lowercaseString] stringByAppendingString:kScaleFactor];
    return [NSString stringWithFormat:kServiceIconsUrl, type, nameWithSuffix];
}

- (void)getServiceIconWithName:(NSString*)icon
                       success:(void (^)(UIImage*))success
                       failure:(void (^)())failure
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self urlForIcon:icon]]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    UIImageView* imgview = [UIImageView new];
    [imgview setImageWithURLRequest:request
        placeholderImage:[UIImage new]
        success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
            image ? success(image) : failure();
        }
        failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error) {
            failure();
        }];
}

- (NSArray<PRService*>*)sortServices:(NSArray<PRService*>*)servicesArray
{
    NSString* orderedServiceIdString = [[NSUserDefaults standardUserDefaults] objectForKey:kServicesOrder];
    if (!orderedServiceIdString || [orderedServiceIdString isEqualToString:@""]) {
        return servicesArray;
    }

    NSArray<NSString*>* orderedServiceIdArray = [orderedServiceIdString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
    NSMutableArray<PRService*>* orderedServices = [[NSMutableArray alloc] initWithCapacity:servicesArray.count];
    NSMutableArray<PRService*>* newServices = [servicesArray mutableCopy]; // In case if we have new service, ID of which does not exist in orderedServiceIdArray.

    for (NSString* serviceId in orderedServiceIdArray) {
        if ([serviceId isEqualToString:@""]) {
            continue;
        }
        for (PRService* serviceModel in servicesArray) {
            if (serviceModel.info.serviceId.integerValue == [serviceId integerValue]) {
                [orderedServices addObject:serviceModel];
                [newServices removeObject:serviceModel];
                break;
            }
        }
    }

    [orderedServices addObjectsFromArray:newServices];

    return orderedServices;
}

- (void)updateServices:(NSArray<PRService*>*)servicesArray
{
    _services = [self sortServices:servicesArray];
    [[PRUserDefaultsManager sharedInstance] saveServicesImagesForWidgets:_services];
    [self setupCollectionView];
    [_iconsCollectionView reloadData];
}

- (void)moveServiceToTheBeginning:(PRService*)service
{
    NSInteger serviceIndex = [_services indexOfObject:service];
    if (serviceIndex == 0 || serviceIndex >= [_services count]) {
        return;
    }

    NSMutableArray<PRService*>* tmpServicesArray = [_services mutableCopy];
    [tmpServicesArray removeObjectAtIndex:serviceIndex];
    [tmpServicesArray insertObject:service atIndex:0];

    _services = [tmpServicesArray copy];

    if (([_services count] > _maxItemsCountInRow)) {
        [self addMoreButton];
    }

    [_iconsCollectionView reloadData];

    NSMutableArray<PRServicesModel*>* serviceModelsArray = [[NSMutableArray alloc] initWithCapacity:[_services count]];
    for (PRService* service in _services) {
        if (service.info) {
            [serviceModelsArray addObject:service.info];
        }
    }

    [self saveServicesOrder:serviceModelsArray];
}

- (void)saveServicesOrder:(NSArray<PRServicesModel*>*)servicesArray
{
    NSString* orderedServiceIdString = [NSString new];

    for (PRServicesModel* serviceModel in servicesArray) {
        orderedServiceIdString = [orderedServiceIdString stringByAppendingString:[NSString stringWithFormat:@"_%@", serviceModel.serviceId]];
    }

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:orderedServiceIdString forKey:kServicesOrder];
    [userDefaults synchronize];
}

#pragma mark - Helpers

- (NSInteger)heightForExpandedState
{
    CGFloat collectionViewHeight = CGRectGetHeight(_iconsCollectionView.frame);
    NSInteger result = ((collectionViewHeight + _cellsInteritemSpacing) * _sectionsCount);

    return result;
}

- (void)setupCollectionView
{
    CGFloat collectionViewWidth = CGRectGetWidth(_iconsCollectionView.frame);
    _maxItemsCountInRow = (NSInteger)(collectionViewWidth / (kIconCellWidth + kMinInteritemSpacing));

    CGFloat extraSpace = collectionViewWidth - kMinInteritemSpacing - (_maxItemsCountInRow * (kIconCellWidth + kMinInteritemSpacing));
    _cellsInteritemSpacing = kMinInteritemSpacing + (extraSpace / (_maxItemsCountInRow + 1));

    NSInteger servicesCount = [_services count] + 1;
    if ([self moreButtonIndex]) {
        servicesCount--;
    }

    _sectionsCount = servicesCount / _maxItemsCountInRow;
    NSInteger itemsCountOfIncompleteRow = servicesCount % _maxItemsCountInRow;

    if (itemsCountOfIncompleteRow != 0) {
        _sectionsCount += 1;
    }

    if (([_services count] > _maxItemsCountInRow) && ![self moreButtonIndex]) {
        [self addMoreButton];
    }
}

- (void)addMoreButton
{
    PRService* service = [PRService new];
    service.icon = [UIImage imageNamed:kMoreButtonImageName];
    service.tag = kMoreButtonTag;
    NSMutableArray<PRService*>* tmpArray = [_services mutableCopy];
    [tmpArray insertObject:service atIndex:_maxItemsCountInRow - 1];
    _services = [tmpArray copy];
}

- (NSInteger)moreButtonIndex
{
    for (NSInteger i = 0; i < [_services count]; i++) {
        if (_services[i].tag == kMoreButtonTag) {
            return i;
        }
    }

    return 0; // 'more' button can not hase index 0, so we use 0 value in case if this button does not find in array.
}

@end

@implementation PRChatServiceCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

#if !defined(Platinum) && !defined(Otkritie)
    _iconImageView.tintColor = kIconsColor;
#endif
}

@end

@implementation PRService
@end

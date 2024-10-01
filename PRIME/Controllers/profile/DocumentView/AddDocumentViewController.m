//
//  AddDocumentViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 2/8/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "AddDocumentViewController.h"
#import "DocumentDetailViewCell.h"
#import "DocumentImage.h"
#import "DocumentLargeViewController.h"
#import "PRVisaType.h"
#import "TextTableViewCell.h"
#import "UIPickerTextField.h"
#import "XNDocuments.h"
#import "SelectRelatedDocumentsViewController.h"
#import "Reachability.h"
#import "PRInfoTableViewCell.h"

typedef NS_ENUM(NSInteger, DocumentSection) {
    DocumentSection_AddDocumentImage = 0,
    DocumentSection_RelatedDocuments,
    DocumentSection_SelfInfo,
    DocumentSection_Info,
    DocumentSection_Date,
    DocumentSection_AdditionalInfo,
    DocumentSection_Comment,
    DocumentSection_DeleteDocument,
    DocumentSection_Count
};

typedef NS_ENUM(NSInteger, DocumentTypeVisa) {
    DocumentTypeVisa_SingleEntry = 2,
    DocumentTypeVisa_MultipleEntry,
    DocumentTypeVisa_SingleEntrySchengen,
    DocumentTypeVisa_MultipleEntrySchengen
};

typedef NS_ENUM(NSInteger, ActionSheetSelectedType) {
    ActionSheetSelectedType_Country = 0,
    ActionSheetSelectedType_VisaType,
    ActionSheetSelectedType_Birthday,
    ActionSheetSelectedType_IssueDate,
    ActionSheetSelectedType_ExpDate,
    ActionSheetSelectedType_None
};

@interface AddDocumentViewController () <SelectRelatedDocumentsViewControllerDelegate> {
    BOOL _isSaved;
    ActionSheetSelectedType _actionSheetSelectedType;
}

@property (strong, nonatomic) NSMutableArray<DocumentImage*>* images;
@property (strong, nonatomic) NSMutableArray<DocumentImage*>* contactDocumentImages;
@property (strong, nonatomic) id documentModel;

@property (strong, nonatomic) NSString* docFirstName;
@property (strong, nonatomic) NSString* docLastName;
@property (strong, nonatomic) NSString* docMiddleName;
@property (strong, nonatomic) NSString* docNumber;
@property (strong, nonatomic) NSString* docCitizenship;
@property (strong, nonatomic) NSString* docBirthPlace;
@property (strong, nonatomic) NSString* docAuthority;
@property (strong, nonatomic) NSString* docBirthDate;
@property (strong, nonatomic) NSString* docExpiryDate;
@property (strong, nonatomic) NSString* docIssueDate;
@property (strong, nonatomic) NSString* docCountryName;
@property (strong, nonatomic) NSString* docCountryCode;
@property (strong, nonatomic) NSString* docComment;
@property (strong, nonatomic) NSString* docVisaTypeName;
@property (strong, nonatomic) NSNumber* docVisaTypeId;
@property (strong, nonatomic) id docRelatedPassport;
@property (strong, nonatomic) NSMutableOrderedSet<id>* docRelatedVisas;
@property (strong, nonatomic) NSString* docIssuedAt;
@property (strong, nonatomic) NSString* docDomicile;
@property (strong, nonatomic) NSString* docInsuranceCompany;
@property (strong, nonatomic) NSString* docCoverage;
@property (strong, nonatomic) NSString* docAuthorityId;
@property (strong, nonatomic) NSString* docCategoryOfVehicleName;

@property (strong, nonatomic) CustomActionSheetViewController* countrySelectionVC;
@property (strong, nonatomic) CustomActionSheetViewController* visaTypeSelectionVC;
@property (strong, nonatomic) CustomActionSheetViewController* issueDateSelectionVC;
@property (strong, nonatomic) CustomActionSheetViewController* expDatelectionVC;
@property (strong, nonatomic) CustomActionSheetViewController* birthDaySelectionVC;

@property (strong, nonatomic) FDTakeController* takeController;
@property (strong, nonatomic) UIActionSheet* actionSheet;

@property (strong, nonatomic) UIResponder* activeField;

@property (strong, nonatomic) NSArray<PRVisaType*>* visaTypes;
@property (strong, nonatomic) PRVisaType* selectedVisaType;

@property (strong, nonatomic) NSString* countryName;
@property (strong, nonatomic) NSString* countryIsoCode;

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) UICollectionView* collectionView;

@property (strong, nonatomic) NSMutableArray<NSString*>* imageIds;

@property (strong, nonatomic) NSIndexPath* currentIndexPath;
@property (assign, nonatomic) BOOL isNewDocument;
@property (assign, nonatomic) BOOL isPassport;

@end

@implementation AddDocumentViewController

static const CGFloat kTableViewCellHeight = 45;
static const CGFloat kTableViewSectionFooterHeight = 30;
static const CGFloat kTableViewLastSectionFooterHeight = 45;
static const CGFloat kTableViewAddImageSectionHeaderHeight = 125;
static const CGFloat kCollectionViewInteritemSpacing = 17.5;
static const CGFloat kCollectionViewHeight = 90;
static NSString* const kCellIdentifier = @"documentCell";
static NSString* const kPassportVisaInfoCellIdentifier = @"PassportVisaInfoCell";
static const NSInteger kTextMaxLength = 60;

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.dataSource = self;
    _tableView.delegate = self;

    UITapGestureRecognizer* closKeyboardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(closeKeyboard:)];
    closKeyboardTapRecognizer.cancelsTouchesInView = NO;
    [_tableView addGestureRecognizer:closKeyboardTapRecognizer];

    _actionSheetSelectedType = ActionSheetSelectedType_None;
    _isNewDocument = !_documentId || [_documentId isEqualToNumber:@0];

    [self createCollectionView];
    [self collectVisaTypes];

    _takeController = [[FDTakeController alloc] init];
    _takeController.allowsEditingPhoto = NO;
    _takeController.delegate = self;

    _tableView.backgroundColor = kTableViewBackgroundColor;

    [self reload];
    [self loadAndSynchImages];

    [self becomeFirstResponder];
    [self setDocumentModelValuesToProperties];
    _isPassport = [PRDatabase isPassport:_type];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCollectionView)
                                                 name:@"DocumentImagesAreLoaded"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!_documentId) {
        return;
    }
    __weak id weakSelf = self;
    [self.lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            AddDocumentViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf reload];
        }
        otherwiseIfFirstTime:^{
            AddDocumentViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf reload];
        }
        otherwise:^{

        }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#if defined(Platinum) || defined(PrivateBankingPRIMEClub)
    [self.navigationController.navigationBar setTintColor:kNavigationBarTintColor];
#elif defined(PrimeRRClub)
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
#else
    [self.navigationController.navigationBar setTintColor:kIconsColor];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setTintColor:kNavigationBarTintColor];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_takeController dismiss];
    [self dismissCustomActionSheetIfOpen];
    [_actionSheet dismissWithClickedButtonIndex:1 animated:NO];
    [super viewDidDisappear:animated];
}

- (void)dismissCustomActionSheetIfOpen
{
    switch (_actionSheetSelectedType) {
    case ActionSheetSelectedType_Country: {
        if (_countrySelectionVC) {
            [_countrySelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    case ActionSheetSelectedType_VisaType: {
        if (_visaTypeSelectionVC) {
            [_visaTypeSelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    case ActionSheetSelectedType_Birthday: {
        if (_birthDaySelectionVC) {
            [_birthDaySelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    case ActionSheetSelectedType_IssueDate: {
        if (_issueDateSelectionVC) {
            [_issueDateSelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    case ActionSheetSelectedType_ExpDate: {
        if (_expDatelectionVC) {
            [_expDatelectionVC dismiss];
            _actionSheetSelectedType = ActionSheetSelectedType_None;
        }
    } break;
    default:
        break;
    }
}

- (void)setDocumentModelValuesToProperties
{
    _docFirstName = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).firstName : ((PRDocumentModel*)_documentModel).firstName;
    _docLastName = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).lastName : ((PRDocumentModel*)_documentModel).lastName;
    _docMiddleName = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).middleName : ((PRDocumentModel*)_documentModel).middleName;
    _docNumber = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).documentNumber : ((PRDocumentModel*)_documentModel).documentNumber;
    _docCitizenship = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).citizenship : ((PRDocumentModel*)_documentModel).citizenship;
    _docBirthPlace = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).birthPlace : ((PRDocumentModel*)_documentModel).birthPlace;
    _docBirthDate = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).birthDate : ((PRDocumentModel*)_documentModel).birthDate;
    _docAuthority = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).authority : ((PRDocumentModel*)_documentModel).authority;
    _docExpiryDate = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).expiryDate : ((PRDocumentModel*)_documentModel).expiryDate;
    _docIssueDate = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).issueDate : ((PRDocumentModel*)_documentModel).issueDate;
    _docCountryName = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).countryName : ((PRDocumentModel*)_documentModel).countryName;
    _docCountryCode = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).countryCode : ((PRDocumentModel*)_documentModel).countryCode;
    _docVisaTypeName = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).visaTypeName : ((PRDocumentModel*)_documentModel).visaTypeName;
    _docVisaTypeId = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).visaTypeId : ((PRDocumentModel*)_documentModel).visaTypeId;
    _docComment = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).comment : ((PRDocumentModel*)_documentModel).comment;

    _docRelatedPassport = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).relatedPassport : ((PRDocumentModel*)_documentModel).relatedPassport;
    _docRelatedVisas = _isContactDocument ? [((PRProfileContactDocumentModel*)_documentModel).relatedVisas mutableCopy] : [((PRDocumentModel*)_documentModel).relatedVisas mutableCopy];
    _docIssuedAt = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).issuedAt : ((PRDocumentModel*)_documentModel).issuedAt;
    _docDomicile = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).domicile : ((PRDocumentModel*)_documentModel).domicile;
    _docInsuranceCompany = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).insuranceCompany : ((PRDocumentModel*)_documentModel).insuranceCompany;
    _docCoverage = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).coverage : ((PRDocumentModel*)_documentModel).coverage;
    _docAuthorityId = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).authorityId : ((PRDocumentModel*)_documentModel).authorityId;
    _docCategoryOfVehicleName = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).categoryOfVehicleName : ((PRDocumentModel*)_documentModel).categoryOfVehicleName;

    _isNewDocument = !_documentId || [_documentId isEqualToNumber:@0];

    if (_isContactDocument && _isNewDocument) {
        [self mergePendingImages];
    }
}

#pragma mark - Visa Types

- (void)collectVisaTypes
{
    _visaTypes = @[
        [[PRVisaType alloc] initWithTypeId:@(DocumentTypeVisa_SingleEntry)
                                   andName:NSLocalizedString(@"single-entry", )],
        [[PRVisaType alloc] initWithTypeId:@(DocumentTypeVisa_MultipleEntry)
                                   andName:NSLocalizedString(@"multiple-entry", )],
        [[PRVisaType alloc] initWithTypeId:@(DocumentTypeVisa_SingleEntrySchengen)
                                   andName:NSLocalizedString(@"single-entry Schengen", )],
        [[PRVisaType alloc] initWithTypeId:@(DocumentTypeVisa_MultipleEntrySchengen)
                                   andName:NSLocalizedString(@"multiple-entry Schengen", )]
    ];
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification*)note
{

    if (!_isContactDocument) {
        __weak id weakSelf = self;
        [self.lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                          date:[NSDate date]
                                                                relativeToDate:nil
                                                                          then:^(PRRequestMode mode) {
                                                                              AddDocumentViewController* strongSelf = weakSelf;
                                                                              if (!strongSelf) {
                                                                                  return;
                                                                              }
                                                                              [PRRequestManager getDocument:((PRDocumentModel*)_documentModel).documentId
                                                                                                       view:strongSelf.view
                                                                                                       mode:mode
                                                                                                    success:^(PRDocumentModel* document) {
                                                                                                        AddDocumentViewController* strongSelf = weakSelf;
                                                                                                        if (!strongSelf) {
                                                                                                            return;
                                                                                                        }
                                                                                                        if (document != nil) {
                                                                                                            strongSelf.documentModel = document;
                                                                                                            [strongSelf.tableView reloadData];
                                                                                                        }

                                                                                                    }
                                                                                                    failure:nil];
                                                                          }];
    }
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return;
    }

    if (_images.count > _currentIndexPath.row) {
        DocumentImage* curDocImg = _images[_currentIndexPath.row];
        if (!_isContactDocument) {
            if (_documentId == nil || [_documentId isEqualToNumber:@0]) {
                [XNDocuments deletePendingImage:_imageIds[_currentIndexPath.row]];
            } else if ([curDocImg uid]) {
                [XNDocuments deleteImage:[curDocImg uid] ForDocument:_documentId view:self.view];
            }
        } else {
            if ([self isDocumentImageWithUid:curDocImg.uid containedInArray:_contactDocumentImages]) {
                curDocImg.state = @(DocumentImageStatus_Deleted);
            }
        }

        if ([self isDocumentImageWithUid:curDocImg.uid containedInArray:_images]) {
            [_images removeObject:curDocImg];
        }
        [_collectionView reloadData];
        [self prepareNavigationBar];
    }
}

#pragma mark - Delete document

- (void)deleteDocument
{
    if (_isContactDocument) {
        ((PRProfileContactDocumentModel*)_documentModel).state = @(ModelStatus_Deleted);
        [self done];
        return;
    }

    [_parentView deleteDocumentWithId:_documentId];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Load Document Images

- (void)loadAndSynchImages
{
    if (_isNewDocument) {
        return;
    }

    _images = [NSMutableArray array];
    _contactDocumentImages = [NSMutableArray array];

    __weak id weakSelf = self;
    NSNumber* documentId = _isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).documentId : ((PRDocumentModel*)_documentModel).documentId;

    [XNDocuments synchronizeWithServerForDocument:documentId
                                            added:^(DocumentImage* photo) {
                                                AddDocumentViewController* strongSelf = weakSelf;
                                                if (!strongSelf) {
                                                    return;
                                                }
                                                [strongSelf addImageToView:photo];

                                            }
                                          deleted:^(NSString* uid){
                                              //Not used yet.
                                          }];

    //TODO handle case whene documentid is nil.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XNDocuments imagesForDocument:documentId
                             withBlock:^(NSArray* photos) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     AddDocumentViewController* strongSelf = weakSelf;
                                     if (!strongSelf) {
                                         return;
                                     }

                                     [_images removeAllObjects];
                                     [_contactDocumentImages removeAllObjects];
                                     [_collectionView reloadData];

                                     for (DocumentImage* docimage in photos) {
                                         [strongSelf addImageToView:docimage];
                                     }
                                 });
                             }];
    });
}

- (void)reloadCollectionView
{
    if (_isNewDocument) {
        return;
    }

    if (!_images) {
        _images = [NSMutableArray array];
    }

    if (!_contactDocumentImages) {
        _contactDocumentImages = [NSMutableArray array];
    }

    __weak id weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XNDocuments imagesForDocument:_documentId
                             withBlock:^(NSArray* photos) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     AddDocumentViewController* strongSelf = weakSelf;
                                     if (!strongSelf) {
                                         return;
                                     }

                                     [_images removeAllObjects];
                                     [_contactDocumentImages removeAllObjects];

                                     for (DocumentImage* docimage in photos) {
                                         if (_isContactDocument) {
                                             if (![[strongSelf stateOfDocumentImageWithUid:docimage.uid
                                                                                   inArray:((PRProfileContactDocumentModel*)_documentModel).imagesData] isEqualToNumber:@(DocumentImageStatus_Deleted)]) {
                                                 [strongSelf addImageToView:docimage];
                                             }
                                         } else {
                                             [strongSelf addImageToView:docimage];
                                         }
                                     }

                                     if (_isContactDocument) {
                                         [strongSelf mergePendingImages];
                                     }

                                     [_collectionView reloadData];
                                 });
                             }];
    });
}

- (void)mergePendingImages
{
    NSArray<DocumentImage*>* pendingImages = ((PRProfileContactDocumentModel*)_documentModel).imagesData;

    if (pendingImages.count) {
        for (DocumentImage* docImage in pendingImages) {
            if (![docImage.state isEqualToNumber:@(DocumentImageStatus_Deleted)]) {
                [self addImageToView:docImage];
            }
        }
    }
}

- (BOOL)isDocumentImageWithUid:(NSString*)uid containedInArray:(NSArray<DocumentImage*>*)documentImages
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];
    return [documentImages filteredArrayUsingPredicate:predicate].count > 0;
}

- (NSNumber*)stateOfDocumentImageWithUid:(NSString*)uid inArray:(NSArray<DocumentImage*>*)documentImages
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];
    return [[documentImages filteredArrayUsingPredicate:predicate] firstObject].state;
}

#pragma mark - Visa Type Picker

- (UIPickerView*)getTypePicker
{
    UIPickerView* typePicker = [[UIPickerView alloc] init];
    typePicker.delegate = self;
    typePicker.dataSource = self;

    [typePicker selectRow:[self rowForVisaTypeId] inComponent:0 animated:NO];

    return typePicker;
}

- (NSInteger)rowForVisaTypeId
{
    if (_isContactDocument) {
        return ((PRProfileContactDocumentModel*)_documentModel && [((PRProfileContactDocumentModel*)_documentModel).visaTypeId integerValue] > 1) ? ((PRProfileContactDocumentModel*)_documentModel).visaTypeId.integerValue - 2 : 0;
    }
    return ((PRDocumentModel*)_documentModel && [((PRDocumentModel*)_documentModel).visaTypeId integerValue] > 1) ? ((PRDocumentModel*)_documentModel).visaTypeId.integerValue - 2 : 0;
}

#pragma mark - Country Picker

- (CountryPicker*)getCountryPicker
{
    CountryPicker* picker = [[CountryPicker alloc] init];
    picker.delegate = self;
    if (_documentModel) {
        [picker setSelectedCountryCode:_docCountryCode animated:NO];
    } else {
        [picker setSelectedCountryCode:@"RU" animated:NO];
    }

    return picker;
}

#pragma mark - Actions

- (void)deleteImage:(UILongPressGestureRecognizer*)gestureRecognizer
{
    const NSInteger documentType = [_type integerValue];
    if (_isPassport) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeletePassportPhotoPressed parameters:nil];
    } else if (documentType == DocumentType_Visa) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeleteVisaPhotoPressed parameters:nil];
    } else {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeleteDocumentPhotoPressed parameters:nil];
    }

    UIImageView* selectedImage = (UIImageView*)gestureRecognizer.view;
    if (selectedImage.image == nil || gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Delete photo", nil), nil];
    [_actionSheet showInView:self.view];
}

#pragma mark - Private Functions

- (void)createDatePickerForPickerController:(CustomActionSheetViewController*)pickerViewController
{
    if (!pickerViewController.picker) {
        pickerViewController.picker = [UIDatePicker new];
    }
}

- (UIView*)headerView
{
    UITableViewHeaderFooterView* header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];

    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Header"];
        header.backgroundColor = [UIColor clearColor];

        [header addSubview:_collectionView];
        [_collectionView setFrame:CGRectMake(kCollectionViewInteritemSpacing, kCollectionViewInteritemSpacing,
                                      CGRectGetWidth(_tableView.frame) - kCollectionViewInteritemSpacing * 2, kCollectionViewHeight)];
    }

    return header;
}

- (void)createCollectionView
{
    UICollectionViewFlowLayout* aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    aFlowLayout.minimumInteritemSpacing = kCollectionViewInteritemSpacing;
    aFlowLayout.minimumLineSpacing = kCollectionViewInteritemSpacing;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:aFlowLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView setShowsHorizontalScrollIndicator:NO];

    _collectionView.delegate = self;
    _collectionView.dataSource = self;

    [_collectionView registerClass:[UICollectionViewCell class]
        forCellWithReuseIdentifier:kCellIdentifier];
}

- (void)reload
{
    if (!_isContactDocument) {
        if (_documentId) {
            _documentModel = [PRDatabase getDocumentById:_documentId];
        } else {
            _documentModel = [PRDocumentModel MR_createEntity];
        }
    } else {
        _documentModel = (PRProfileContactDocumentModel*)_contactDocumentModel;
    }
    [_tableView reloadData];
}

- (void)closeKeyboard:(UITapGestureRecognizer*)sender
{
    [_activeField resignFirstResponder];
}

- (void)prepareNavigationBar
{
//    NSInteger type = [_type integerValue];
//    switch (type) {
//        case DocumentType_Passport:
//        case DocumentType_Foreign_Passport:
//        case DocumentType_National_Passport:
//        case DocumentType_Diplomatic_Passport:
//        case DocumentType_Passport_Any_Country:
//        case DocumentType_Service_Passport:
//        {
//            if (_docNumber == nil || _docAuthority == nil || _docCitizenship == nil || [_docNumber isEqualToString:@""] || [_docAuthority isEqualToString:@""] || [_docCitizenship isEqualToString:@""]) {
//                return;
//            }
//            break;
//        }
//        case DocumentType_Visa: {
//            if (_docNumber == nil || [_docNumber isEqualToString:@""]) {
//                return;
//            }
//            break;
//        }
//        case DocumentType_Birth_Certificate: {
//            if (_docNumber == nil || _docCitizenship == nil || [_docNumber isEqualToString:@""] || [_docCitizenship isEqualToString:@""]) {
//                return;
//            }
//            break;
//        }
//        case DocumentType_Driving_Licence:
//        case DocumentType_Insurance:
//        {
//            if (_docNumber == nil || [_docNumber isEqualToString:@""]) {
//                return;
//            }
//            break;
//        }
//        default:
//            break;
//    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", )
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(done)];
}

#pragma mark - Save Document

- (void)saveNewValuesForDocumentModel
{
    const NSInteger documentType = [_type integerValue];
    if (_isPassport) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileSavePassportButtonClicked parameters:nil];
    } else if (documentType == DocumentType_Visa) {
        [PRGoogleAnalyticsManager sendEventWithName:[NSString stringWithFormat:kMyProfileSaveVisaButtonClicked, _docVisaTypeName] parameters:nil];
    } else {
        [PRGoogleAnalyticsManager sendEventWithName:[NSString stringWithFormat:kMyProfileSaveDocumentButtonClicked, [PRDatabase getDocumentTypeById:_type].name] parameters:nil];
    }

    PRDocumentModel* documentModel = (PRDocumentModel*)_documentModel;
    documentModel.firstName = _docFirstName;
    documentModel.lastName = _docLastName;
    documentModel.middleName = _docMiddleName;
    documentModel.documentNumber = _docNumber;
    documentModel.citizenship = _docCitizenship;
    documentModel.birthPlace = _docBirthPlace;
    documentModel.authority = _docAuthority;
    documentModel.birthDate = _docBirthDate;
    documentModel.expiryDate = _docExpiryDate;
    documentModel.issueDate = _docIssueDate;

    if (!_docCountryName) {
        documentModel.countryName = [CountryPicker countryNamesByCode][@"RU"];
        documentModel.countryCode = @"RU";
    } else {
        documentModel.countryName = _docCountryName;
        documentModel.countryCode = _docCountryCode;
    }

    documentModel.visaTypeName = _docVisaTypeName;
    documentModel.visaTypeId = _docVisaTypeId;
    documentModel.comment = _docComment;
    documentModel.relatedPassport = (PRDocumentModel*)_docRelatedPassport;
    documentModel.relatedVisas = [_docRelatedVisas mutableCopy];
    documentModel.issuedAt = _docIssuedAt;
    documentModel.domicile = _docDomicile;
    documentModel.insuranceCompany = _docInsuranceCompany;
    documentModel.coverage = _docCoverage;
    documentModel.authorityId = _docAuthorityId;
    documentModel.categoryOfVehicleName = _docCategoryOfVehicleName;

    _documentModel = (PRDocumentModel*)documentModel;
}

- (void)saveNewValuesForContactDocumentModel
{
    const NSInteger documentType = [_type integerValue];
    if (_isPassport) {
        [PRGoogleAnalyticsManager sendEventWithName:kMyProfileSavePassportButtonClicked parameters:nil];
    } else if (documentType == DocumentType_Visa) {
        [PRGoogleAnalyticsManager sendEventWithName:[NSString stringWithFormat:kMyProfileSaveVisaButtonClicked, _docVisaTypeName] parameters:nil];
    } else {
        [PRGoogleAnalyticsManager sendEventWithName:[NSString stringWithFormat:kMyProfileSaveDocumentButtonClicked, [PRDatabase getDocumentTypeById:_type].name] parameters:nil];
    }

    PRProfileContactDocumentModel* documentModel = (PRProfileContactDocumentModel*)_documentModel;
    documentModel.firstName = _docFirstName;
    documentModel.lastName = _docLastName;
    documentModel.middleName = _docMiddleName;
    documentModel.documentNumber = _docNumber;
    documentModel.citizenship = _docCitizenship;
    documentModel.birthPlace = _docBirthPlace;
    documentModel.authority = _docAuthority;
    documentModel.birthDate = _docBirthDate;
    documentModel.expiryDate = _docExpiryDate;
    documentModel.issueDate = _docIssueDate;
    documentModel.visaTypeName = _docVisaTypeName;
    documentModel.visaTypeId = _docVisaTypeId;
    documentModel.profileContact = _contactModel;

    if (!_docCountryName) {
        documentModel.countryName = [CountryPicker countryNamesByCode][@"RU"];
        documentModel.countryCode = @"RU";
    } else {
        documentModel.countryName = _docCountryName;
        documentModel.countryCode = _docCountryCode;
    }

    documentModel.documentType = _type;
    documentModel.comment = _docComment;
    documentModel.relatedPassport = (PRProfileContactDocumentModel*)_docRelatedPassport;

    // Don't assign related visa directly, it will be handled in the update request.
    if (documentModel.relatedVisas.count == 0) {
        documentModel.relatedVisas = [_docRelatedVisas mutableCopy];
    }
    documentModel.issuedAt = _docIssuedAt;
    documentModel.domicile = _docDomicile;
    documentModel.insuranceCompany = _docInsuranceCompany;
    documentModel.coverage = _docCoverage;
    documentModel.authorityId = _docAuthorityId;
    documentModel.categoryOfVehicleName = _docCategoryOfVehicleName;

    if ([_type isEqual:@(DocumentType_Visa)]) {
        documentModel.visaTypeId = _visaTypes[[self rowForVisaTypeId]].typeId;
    } else {
        documentModel.visaTypeId = nil;
    }
    documentModel.imagesData = _contactDocumentImages;
    _documentModel = (PRProfileContactDocumentModel*)documentModel;
}

- (void)done
{
    self.navigationItem.rightBarButtonItem.enabled = NO;

    if (_isContactDocument) {

        if (!_documentModel) {
            _documentModel = [PRProfileContactDocumentModel MR_createEntityInContext:_mainContext];
            ((PRProfileContactDocumentModel*)_documentModel).state = _contactModel ? @(ModelStatus_Added) : @(ModelStatus_AddedWithoutParent);
        } else {
            _documentModel = [(PRProfileContactDocumentModel*)_documentModel MR_inContext:_mainContext];
            if (_documentId && ![_documentId isEqualToNumber:@0]) {
                if (![((PRProfileContactDocumentModel*)_documentModel).state isEqualToNumber:@(ModelStatus_Deleted)]) {
                    ((PRProfileContactDocumentModel*)_documentModel).state = @(ModelStatus_Updated);
                }
            }
        }

        [self saveNewValuesForContactDocumentModel];

        [(PRPersonalDataViewController*)_parentView addContactDocument:(PRProfileContactDocumentModel*)_documentModel];
        [self.navigationController popViewControllerAnimated:YES];
        if (_isNewDocument) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }

    [self saveNewValuesForDocumentModel];

    if ([_activeField isFirstResponder]) {
        [_activeField resignFirstResponder];
    }

    if ([_type isEqual:@(DocumentType_Visa)]) {
        ((PRDocumentModel*)_documentModel).visaTypeId = _visaTypes[[self rowForVisaTypeId]].typeId;
    } else {
        ((PRDocumentModel*)_documentModel).visaTypeId = nil;
    }

    __weak id weakSelf = self;
    ((PRDocumentModel*)_documentModel).documentType = _type;
    if (_documentId == nil || [_documentId isEqualToNumber:@0]) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
            AddDocumentViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            PRDocumentModel* document = [(PRDocumentModel*)strongSelf.documentModel MR_inContext:localContext];
            document.documentType = strongSelf.type;
        }];
        [PRRequestManager createDocument:_documentModel
            view:self.view
            mode:PRRequestMode_ShowErrorMessagesAndProgress
            success:^{
                AddDocumentViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf->_isSaved = YES;
                PRDocumentModel* document = [PRDatabase getDocumentById:((PRDocumentModel*)strongSelf.documentModel).documentId];

                if (strongSelf.imageIds.count) {
                    [XNDocuments attachImages:strongSelf.imageIds ForDocument:document.documentId];
                }

                if (_isPassport && (document.relatedVisas != nil || document.relatedVisas.count > 0)) {
                    [strongSelf linkDocuments:[document.relatedVisas array] toDocument:document.documentId forDocumentType:[_type integerValue]];
                } else if ([_type integerValue] == DocumentType_Visa && document.relatedPassport != nil) {
                    NSMutableArray<PRDocumentModel*>* relatedPassport = [NSMutableArray new];
                    [relatedPassport addObject:document.relatedPassport];
                    [strongSelf linkDocuments:relatedPassport toDocument:document.documentId forDocumentType:[_type integerValue]];
                }

                [strongSelf.parentView reload];
                [strongSelf.navigationController popViewControllerAnimated:YES];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
            failure:^{
                AddDocumentViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf->_isSaved = NO;
                strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
                [strongSelf.parentView reload];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }];
    } else {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
            AddDocumentViewController* strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            PRDocumentModel* document = [(PRDocumentModel*)strongSelf.documentModel MR_inContext:localContext];
            document.documentType = strongSelf.type;
        }];

        [PRRequestManager updateDocument:_documentModel
            view:self.view
            mode:PRRequestMode_ShowErrorMessagesAndProgress
            success:^() {
                AddDocumentViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                PRDocumentModel* document = (PRDocumentModel*)_documentModel;
                if (_isPassport) {
                    __block NSInteger counter = 0;
                    if (document.relatedVisas && document.relatedVisas.count > 0) {
                        for (PRDocumentModel* relatedVisa in document.relatedVisas) {
                            [PRRequestManager detachVisaFromPassportForDocument:relatedVisa.documentId view:nil mode:PRRequestMode_ShowNothing success:^{
                                counter++;
                                if (counter == document.relatedVisas.count) {
                                    [self linkDocuments:[document.relatedVisas array] toDocument:document.documentId forDocumentType:[_type integerValue]];
                                }
                            } failure:^{
                            }];
                        }
                    } else {
                        [self linkDocuments:[document.relatedVisas array] toDocument:document.documentId forDocumentType:[_type integerValue]];
                    }
                } else if ([_type integerValue] == DocumentType_Visa && _docRelatedPassport) {
                    NSMutableArray<PRDocumentModel*>* relatedPassport = [NSMutableArray new];
                    [relatedPassport addObject:(PRDocumentModel*)_docRelatedPassport];
                    [self linkDocuments:relatedPassport toDocument:document.documentId forDocumentType:[_type integerValue]];
                }
                strongSelf->_isSaved = YES;
                [strongSelf.parentView reload];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
            failure:^{
                AddDocumentViewController* strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf->_isSaved = NO;
                strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
                [strongSelf.parentView reload];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }];
    }
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    if (![parent isEqual:self.parentViewController] && !_isSaved && _documentId == nil && !_isContactDocument) {
        [_activeField resignFirstResponder];
        if (![PRRequestManager connectionRequired]) {
            [_documentModel MR_deleteEntity];
            [_parentView reload];
        }
    }
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController*)controller gotPhoto:(UIImage*)photo withInfo:(NSDictionary*)info
{
    DocumentImage* documentImage = [[DocumentImage alloc] init];
    documentImage.image = photo;
    documentImage.state = @(DocumentImageStatus_Created);
    if (!_isContactDocument && ((PRDocumentModel*)_documentModel).documentId && ![((PRDocumentModel*)_documentModel).documentId isEqualToNumber:@0]) {
        documentImage.uid = [XNDocuments addImage:photo ForDocument:((PRDocumentModel*)_documentModel).documentId];
    } else {
        documentImage.uid = [[NSUUID UUID] UUIDString];
        if (_imageIds == nil) {
            _imageIds = [NSMutableArray array];
        }
        [_imageIds addObject:documentImage.uid];
        [XNDocuments addLocalImage:documentImage ForDocument:@(INT_MAX)];
    }

    [self addImageToView:documentImage];
    [self prepareNavigationBar];

    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[_images count] - 1 inSection:0]
                            atScrollPosition:UICollectionViewScrollPositionRight
                                    animated:YES];
}

- (void)addImageToView:(DocumentImage*)documentImage
{
    if (_images == nil) {
        _images = [NSMutableArray array];
    }

    if (_contactDocumentImages == nil) {
        _contactDocumentImages = [NSMutableArray array];
    }

    if (documentImage != nil) {
        if (![self isDocumentImageWithUid:documentImage.uid containedInArray:_images]) {
            [_images addObject:documentImage];
        }

        if (_isContactDocument) {
            if (![self isDocumentImageWithUid:documentImage.uid containedInArray:_contactDocumentImages]) {
                documentImage.state = @(DocumentImageStatus_Created);
                [_contactDocumentImages addObject:documentImage];
            }
        }
    }

    [_collectionView reloadData];
}

- (NSInteger)tagForSection:(NSInteger)section andRow:(NSInteger)row
{
    return 100 + (section + 1) * 10 + row;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return kTableViewCellHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    const NSInteger documentType = [_type integerValue];
    if (indexPath.section == DocumentSection_AddDocumentImage) {
        if (_isPassport) {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileAddPassportPhotoButtonClicked parameters:nil];
        } else if (documentType == DocumentType_Visa) {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileAddVisaPhotoButtonClicked parameters:nil];
        } else {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileAddDocumentPhotoButtonClicked parameters:nil];
        }
        [_takeController takePhotoOrChooseFromLibrary];
    } else if (indexPath.section == DocumentSection_DeleteDocument) {
        if (_isPassport) {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeletePassportButtonClicked parameters:nil];
        } else if (documentType == DocumentType_Visa) {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeleteVisaButtonClicked parameters:nil];
        } else {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileDeleteDocumentButtonClicked parameters:nil];
        }
        [self deleteDocument];
    } else if (indexPath.section == DocumentSection_RelatedDocuments) {
        SelectRelatedDocumentsViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectRelatedDocumentsViewController"];
        viewController.parentView = self;
        viewController.delegate = self;
        viewController.isContactDocument = _isContactDocument;
        viewController.isPassport = _isPassport;
        viewController.contactId = _contactModel.contactId;
        viewController.mainContext = _mainContext;
        viewController.relatedDocumentsId = [self getRelatedDocumentsId];
        viewController.title = NSLocalizedString(@"Related Document", );
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == DocumentSection_AddDocumentImage ? kTableViewAddImageSectionHeaderHeight : 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    NSInteger type = [_type integerValue];
    switch (section) {
        case DocumentSection_AddDocumentImage: {
            return kTableViewSectionFooterHeight;
        }
        case DocumentSection_RelatedDocuments: {
            if (_isPassport || type == DocumentType_Visa) {
                return kTableViewSectionFooterHeight;
            }
            return 0;
        }
        case DocumentSection_SelfInfo: {
            return kTableViewSectionFooterHeight;
        }
        case DocumentSection_Info: {
            if (_isPassport || type == DocumentType_Visa || type == DocumentType_Birth_Certificate || type == DocumentType_Driving_Licence) {
                return kTableViewSectionFooterHeight;
            }
            return 0;
        }
        case DocumentSection_Date: {
            return kTableViewSectionFooterHeight;
        }
        case DocumentSection_AdditionalInfo: {
            if (type == DocumentType_Insurance || type == DocumentType_Driving_Licence) {
                return kTableViewSectionFooterHeight;
            }
            return 0;
        }
        case DocumentSection_Comment: {
            return kTableViewSectionFooterHeight;
        }
        case DocumentSection_DeleteDocument: {
            if (_isNewDocument) {
                return 0;
            }
            return kTableViewSectionFooterHeight;
        }
        default:
            break;
    }

    return 0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return section == DocumentSection_AddDocumentImage ? [self headerView] : nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (_isNewDocument) {
        return DocumentSection_Count - 1;
    }

    return DocumentSection_Count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger type = [_type integerValue];
    switch (section) {
        case DocumentSection_AddDocumentImage: {
            return 1;
        }
        case DocumentSection_RelatedDocuments: {
            if (_isPassport) {
                return _docRelatedVisas.count + 1;
            } else if (type == DocumentType_Visa) {
                return 1;
            }
            return 0;
        }
        case DocumentSection_SelfInfo: {
            return 3;
        }
        case DocumentSection_Info: {
            if (_isPassport) {
                return 4;
            }
            if (type == DocumentType_Visa || type == DocumentType_Driving_Licence) {
                return  2;
            }
            if (type == DocumentType_Birth_Certificate) {
                return 3;
            }
            return 0;
        }
        case DocumentSection_Date: {
            if (_isPassport || type == DocumentType_Driving_Licence) {
                return 5;
            }
            if (type == DocumentType_Other) {
                return 2;
            }
            if (type == DocumentType_Visa) {
                return 4;
            }
            if (type == DocumentType_Insurance) {
                return 3;
            }
            return 1;
        }
        case DocumentSection_AdditionalInfo: {
            if (type == DocumentType_Insurance || type == DocumentType_Driving_Licence) {
                return 2;
            }
            return 0;
        }
        case DocumentSection_Comment: {
            return 1;
        }
        case DocumentSection_DeleteDocument: {
            return 1;
        }
        default:
            break;
    }

    return 0;
}

- (TextTableViewCell*)createAddCell
{
    TextTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];
    NSString* text;
    if (_isPassport) {
        text = @"add passport photo";
    } else if ([_type integerValue] == DocumentType_Visa) {
        text = @"add visa photo";
    } else {
        text = @"add photo";
    }

    [cell configureCellByText:NSLocalizedString(text, )
                     andImage:[[UIImage imageNamed:@"addImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];

    return cell;
}

- (DocumentDetailViewCell*)createSelfInfoCellForIndexPath:(NSIndexPath*)indexPath
{
    DocumentDetailViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCell"];

    if (indexPath.row == 0) {

        [cell configureCellByName:NSLocalizedString(@"Last name", ) text:_docLastName andPlaceholder:NSLocalizedString(@"Last name", )];
    } else if (indexPath.row == 1) {

        [cell configureCellByName:NSLocalizedString(@"First name", ) text:_docFirstName andPlaceholder:NSLocalizedString(@"First name", )];
    } else if (indexPath.row == 2) {

        [cell configureCellByName:NSLocalizedString(@"Middle name", ) text:_docMiddleName andPlaceholder:NSLocalizedString(@"Middle name", )];
    }

    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = [self tagForSection:indexPath.section andRow:indexPath.row];
    return cell;
}

- (UITableViewCell*)createRelatedDocumentsCellsForIndexPath:(NSIndexPath*)indexPath
{
    PRInfoTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:kPassportVisaInfoCellIdentifier];

    if (_isPassport) {
        if([_tableView numberOfRowsInSection:DocumentSection_RelatedDocuments] - 1 == indexPath.row) {
            TextTableViewCell* addCell = [_tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];

            [addCell configureCellByText:NSLocalizedString(@"add visa", )
                             andImage:[[UIImage imageNamed:@"addImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [addCell setAccessoryType:UITableViewCellAccessoryNone];

            return addCell;
        }
        PRDocumentModel* data = (PRDocumentModel*)_docRelatedVisas[indexPath.row];
        NSString* country = [Utils countryNameFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
        UIImage* flag = [Utils countryFlagFromCode:data.countryCode ?: COUNTRY_CODE_RUSSIA];
        NSString* detail = [Utils fromMillisecondsToFormattedDate:data.expiryDate];
        NSString* localizedDetail = [NSLocalizedString(@"until: ", nil) stringByAppendingString:detail];
        [cell configureCellWithInfo:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Visa", nil), NSLocalizedString(country, nil)] detail:localizedDetail andImage:flag];

    } else if ([_type integerValue] == DocumentType_Visa) {
        if (!_docRelatedPassport) {
            TextTableViewCell* addCell = [_tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];

            [addCell configureCellByText:NSLocalizedString(@"add passport", )
                             andImage:[[UIImage imageNamed:@"addImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [addCell setAccessoryType:UITableViewCellAccessoryNone];

            return addCell;
        } else {
            NSString* country = [Utils countryNameFromCode:((PRProfileContactDocumentModel*)_docRelatedPassport).countryCode ?: COUNTRY_CODE_RUSSIA];
            UIImage* flag = [Utils countryFlagFromCode:((PRProfileContactDocumentModel*)_docRelatedPassport).countryCode ?: COUNTRY_CODE_RUSSIA];
            [cell configureCellWithInfo:((PRProfileContactDocumentModel*)_docRelatedPassport).documentNumber placeholder:NSLocalizedString(@"Passport Number", nil) detail:country andImage:flag];
        }
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    return cell;
}

- (DocumentDetailViewCell*)createDocumentInfoCellForIndexPath:(NSIndexPath*)indexPath
{
    DocumentDetailViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCell"];
    NSInteger type = [_type integerValue];

    if (indexPath.row == 0) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
        if (type == DocumentType_Visa) {
            NSString* textFieldValue = (_documentId == nil && !_docCountryName) ? [CountryPicker countryNamesByCode][@"RU"] : _docCountryName;
            [cell configureCellByName:NSLocalizedString(@"Country", ) text:textFieldValue andPlaceholder:NSLocalizedString(@"Country", )];
        } else {
            if (_docBirthDate) {
                _docBirthDate = [Utils fromMillisecondsToFormattedDate:_docBirthDate];
            }
            [cell configureCellByName:NSLocalizedString(@"Date of Birth", ) text:_docBirthDate andPlaceholder:NSLocalizedString(@"Date of Birth", )];
        }
    }
    if (indexPath.row == 1) {
        if (type == DocumentType_Visa) {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
            NSString* textFieldValue = (_documentId == nil && !_docVisaTypeId) ? _visaTypes[0].typeName : _docVisaTypeName;
            [cell configureCellByName:NSLocalizedString(@"Visa type", ) text:textFieldValue andPlaceholder:NSLocalizedString(@"Visa type", )];
        } else {
            if (_docBirthDate) {
                _docBirthDate = [Utils fromMillisecondsToFormattedDate:_docBirthDate];
            }
            [cell configureCellByName:NSLocalizedString(@"Place of Birth", ) text:_docBirthPlace andPlaceholder:NSLocalizedString(@"Place of Birth", )];
        }
    }
    if (indexPath.row == 2) {
        [cell configureCellByName:NSLocalizedString(@"Citizenship", ) text:_docCitizenship andPlaceholder:NSLocalizedString(@"Citizenship", )];
    }
    if (indexPath.row == 3) {
        NSString* textFieldValue = (_documentId == nil && !_docCountryName) ? [CountryPicker countryNamesByCode][@"RU"] : _docCountryName;
        cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
        [cell configureCellByName:NSLocalizedString(@"Country", ) text:textFieldValue andPlaceholder:NSLocalizedString(@"Country", )];
    }

    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = [self tagForSection:indexPath.section andRow:indexPath.row];

    return cell;
}

- (DocumentDetailViewCell*)createDocumentAdditionalInfoCellForIndexPath:(NSIndexPath*)indexPath
{
    DocumentDetailViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCell"];
    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = [self tagForSection:indexPath.section andRow:indexPath.row];

    if ([_type integerValue] == DocumentType_Driving_Licence) {
        if (indexPath.row == 0) {
            [cell configureCellByName:NSLocalizedString(@"Domicile", ) text:_docDomicile andPlaceholder:NSLocalizedString(@"Domicile", )];
        } else if (indexPath.row == 1) {
            [cell configureCellByName:NSLocalizedString(@"Vehicle Category", ) text:_docCategoryOfVehicleName andPlaceholder:NSLocalizedString(@"Category Name", )];
        }
        return cell;
    }
    if (indexPath.row == 0) {
        [cell configureCellByName:NSLocalizedString(@"Insurance Company", ) text:_docInsuranceCompany andPlaceholder:NSLocalizedString(@"Company Name", )];
    } else if (indexPath.row == 1) {
        [cell configureCellByName:NSLocalizedString(@"Coverage", ) text:_docCoverage andPlaceholder:NSLocalizedString(@"Coverage", )];
    }

    return cell;
}

- (DocumentDetailViewCell*)createDocumentDateCellForIndexPath:(NSIndexPath*)indexPath
{
    DocumentDetailViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCell"];
    NSInteger type = [_type integerValue];

    if (indexPath.row == 0) {
        NSString* text;
        if (_isPassport) {
            text = @"Passport Number";
        } else if ([_type integerValue] == DocumentType_Visa) {
            text = @"Visa Number";
        } else {
            text = @"Document Number";
        }
        [cell configureCellByName:text text:_docNumber andPlaceholder:NSLocalizedString(text, )];
    } else if (indexPath.row == 1) {
        if (type == DocumentType_Other) {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
            if (_docExpiryDate) {
                _docExpiryDate = [Utils fromMillisecondsToFormattedDate:_docExpiryDate];
            }
            [cell configureCellByName:NSLocalizedString(@"Expiration date", ) text:_docExpiryDate andPlaceholder:NSLocalizedString(@"If present", )];
        } else if (type == DocumentType_Insurance) {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
            if (_docIssueDate) {
                _docIssueDate = [Utils fromMillisecondsToFormattedDate:_docIssueDate];
            }
            [cell configureCellByName:NSLocalizedString(@"Issue date", ) text:_docIssueDate andPlaceholder:NSLocalizedString(@"Issue date", )];
        } else {
            [cell configureCellByName:NSLocalizedString(@"Issuing authority", ) text:_docAuthority andPlaceholder:NSLocalizedString(@"Issuing authority", )];
        }
    } else if (indexPath.row == 2) {
        if (type == DocumentType_Insurance) {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
            if (_docExpiryDate) {
                _docExpiryDate = [Utils fromMillisecondsToFormattedDate:_docExpiryDate];
            }
            [cell configureCellByName:NSLocalizedString(@"Expiration date", ) text:_docExpiryDate andPlaceholder:NSLocalizedString(@"If present", )];
        } else {
            cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
            if (_docIssueDate) {
                _docIssueDate = [Utils fromMillisecondsToFormattedDate:_docIssueDate];
            }
            [cell configureCellByName:NSLocalizedString(@"Issue date", ) text:_docIssueDate andPlaceholder:NSLocalizedString(@"Issue date", )];
        }
    } else if (indexPath.row == 3) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCellWithPicker"];
        if (_docExpiryDate) {
            _docExpiryDate = [Utils fromMillisecondsToFormattedDate:_docExpiryDate];
        }
        [cell configureCellByName:NSLocalizedString(@"Expiration date", ) text:_docExpiryDate andPlaceholder:NSLocalizedString(@"If present", )];
    } else if (indexPath.row == 4) {
        if (type == DocumentType_Driving_Licence) {
            [cell configureCellByName:NSLocalizedString(@"Issued At", ) text:_docIssuedAt andPlaceholder:@"Issued At"];
        } else {
            [cell configureCellByName:NSLocalizedString(@"Authority ID", ) text:_docAuthorityId andPlaceholder:NSLocalizedString(@"Authority ID", )];
        }
    }

    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = [self tagForSection:indexPath.section andRow:indexPath.row];

    return cell;
}

- (UITableViewCell*)createDocumentDeleteCell
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Delete"];
    NSString* text;
    if (_isPassport) {
        text = @"Delete passport";
    } else if ([_type integerValue] == DocumentType_Visa) {
        text = @"Delete visa";
    } else {
        text = @"Delete document";
    }
    cell.textLabel.text = NSLocalizedString(text, );
    cell.textLabel.textColor = kDeleteButtonColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

- (DocumentDetailViewCell*)createDocumentCommentCell
{
    DocumentDetailViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"DocumentDetailViewCell"];
    [cell configureCellByName:NSLocalizedString(@"Comments", ) text:_docComment andPlaceholder:nil];

    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = [self tagForSection:DocumentSection_Comment andRow:0];

    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;

    switch (indexPath.section) {
    case DocumentSection_AddDocumentImage: {
        cell = [self createAddCell];
    } break;
    case DocumentSection_RelatedDocuments: {
        cell = [self createRelatedDocumentsCellsForIndexPath:indexPath];
    } break;
    case DocumentSection_SelfInfo: {
        cell = [self createSelfInfoCellForIndexPath:indexPath];
    } break;
    case DocumentSection_Info: {
        cell = [self createDocumentInfoCellForIndexPath:indexPath];
    } break;
    case DocumentSection_Date: {
        cell = [self createDocumentDateCellForIndexPath:indexPath];
    } break;
    case DocumentSection_AdditionalInfo: {
        cell = [self createDocumentAdditionalInfoCellForIndexPath:indexPath];
    } break;
    case DocumentSection_Comment: {
        cell = [self createDocumentCommentCell];
    } break;
    case DocumentSection_DeleteDocument: {
        cell = [self createDocumentDeleteCell];
    } break;
    default:
        break;
    }

    return cell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_images count] > 2 ? [_images count] : 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    const NSInteger tag = 777;

    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:tag];
    if (!imageView) {
        imageView = [UIImageView newAutoLayoutView];
        [cell.contentView addSubview:imageView];
        imageView.tag = tag;
        [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.layer.borderWidth = 0.5;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;

        imageView.userInteractionEnabled = YES;

        UILongPressGestureRecognizer* lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteImage:)];
        lp.minimumPressDuration = 0.5; //Seconds.
        [imageView addGestureRecognizer:lp];
    }
    imageView.image = [_images count] > indexPath.row ? [[_images objectAtIndex:indexPath.row] image] : nil;

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return CGSizeMake(70, kCollectionViewHeight);
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath;
{
    if (indexPath.row >= [_images count]) {
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DocumentLarge" bundle: nil];
    DocumentLargeViewController* documentLargeViewController = (DocumentLargeViewController*)[storyboard
        instantiateViewControllerWithIdentifier:@"DocumentLargeViewController"];

    [self.navigationController pushViewController:documentLargeViewController animated:YES];

    documentLargeViewController.image = [_images[indexPath.row] image];
}

- (void)collectionView:(UICollectionView*)collectionView didHighlightItemAtIndexPath:(NSIndexPath*)indexPath;
{
    _currentIndexPath = indexPath;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    BOOL dateField = NO;
    NSDate* currentDate = [NSDate new];
    CustomActionSheetViewController* pickerViewController;
    NSInteger documentType = [_type integerValue];

    if (_isPassport || documentType == DocumentType_Visa || documentType == DocumentType_Driving_Licence) {
        if (textField.tag == [self tagForSection:DocumentSection_Date andRow:3]) {
            if (!_expDatelectionVC) {
                _expDatelectionVC = [[CustomActionSheetViewController alloc] init];
            }

            pickerViewController = _expDatelectionVC;
            [self createDatePickerForPickerController:pickerViewController];
            [(UIDatePicker*)pickerViewController.picker setMinimumDate:[NSDate date]];
            _actionSheetSelectedType = ActionSheetSelectedType_ExpDate;
            dateField = YES;
        }
        if (textField.tag == [self tagForSection:DocumentSection_Date andRow:2]) {
            if (!_issueDateSelectionVC) {
                _issueDateSelectionVC = [[CustomActionSheetViewController alloc] init];
            }

            pickerViewController = _issueDateSelectionVC;
            [self createDatePickerForPickerController:pickerViewController];
            [(UIDatePicker*)pickerViewController.picker setMaximumDate:[NSDate date]];
            _actionSheetSelectedType = ActionSheetSelectedType_IssueDate;
            dateField = YES;
        }
    }
    if (documentType == DocumentType_Other) {
        if (textField.tag == [self tagForSection:DocumentSection_Date andRow:1]) {
            if (!_expDatelectionVC) {
                _expDatelectionVC = [[CustomActionSheetViewController alloc] init];
            }

            pickerViewController = _expDatelectionVC;
            [self createDatePickerForPickerController:pickerViewController];
            [(UIDatePicker*)pickerViewController.picker setMinimumDate:[NSDate date]];
            _actionSheetSelectedType = ActionSheetSelectedType_ExpDate;
            dateField = YES;
        }
    }
    if (documentType == DocumentType_Insurance) {
        if (textField.tag == [self tagForSection:DocumentSection_Date andRow:2]) {
            if (!_expDatelectionVC) {
                _expDatelectionVC = [[CustomActionSheetViewController alloc] init];
            }

            pickerViewController = _expDatelectionVC;
            [self createDatePickerForPickerController:pickerViewController];
            [(UIDatePicker*)pickerViewController.picker setMinimumDate:[NSDate date]];
            _actionSheetSelectedType = ActionSheetSelectedType_ExpDate;
            dateField = YES;
        }
        if (textField.tag == [self tagForSection:DocumentSection_Date andRow:1]) {
            if (!_issueDateSelectionVC) {
                _issueDateSelectionVC = [[CustomActionSheetViewController alloc] init];
            }

            pickerViewController = _issueDateSelectionVC;
            [self createDatePickerForPickerController:pickerViewController];
            [(UIDatePicker*)pickerViewController.picker setMaximumDate:[NSDate date]];
            _actionSheetSelectedType = ActionSheetSelectedType_IssueDate;
            dateField = YES;
        }
    }
    if (_isPassport || documentType == DocumentType_Birth_Certificate || documentType == DocumentType_Driving_Licence) {
        if (textField.tag == [self tagForSection:DocumentSection_Info andRow:0]) {
            [PRGoogleAnalyticsManager sendEventWithName:kMyProfileBirthDateFieldClicked parameters:nil];
            if (!_birthDaySelectionVC) {
                _birthDaySelectionVC = [[CustomActionSheetViewController alloc] init];
            }

            pickerViewController = _birthDaySelectionVC;
            [self createDatePickerForPickerController:pickerViewController];
            [(UIDatePicker*)pickerViewController.picker setMaximumDate:[NSDate date]];
            _actionSheetSelectedType = ActionSheetSelectedType_Birthday;

#if defined(Otkritie)
            currentDate = [currentDate mt_dateYearsBefore:30];
#endif

            dateField = YES;
        }
    }
    if (_isPassport) {
        if (textField.tag == [self tagForSection:DocumentSection_Info andRow:3]) {
            if (!_countrySelectionVC) {
                _countrySelectionVC = [[CustomActionSheetViewController alloc] init];
                _countrySelectionVC.delegate = self;
                _countrySelectionVC.picker = [self getCountryPicker];
            }
            pickerViewController = _countrySelectionVC;
            _actionSheetSelectedType = ActionSheetSelectedType_Country;

            if (_documentId || _docCountryName != nil) {
                _countryIsoCode = _docCountryCode;
                _countryName = _docCountryName;
            } else {
                _countryName = [CountryPicker countryNamesByCode][@"RU"];
                _countryIsoCode = @"RU";
            }

            [_activeField resignFirstResponder];

            [pickerViewController showForField:(UIPickerTextField*)textField];
            [((CountryPicker*)pickerViewController.picker) setSelectedCountryCode:(_countryIsoCode != nil ? _countryIsoCode : @"RU")];

            return NO;
        }
    }
    if (documentType == DocumentType_Visa) {
        if (textField.tag == [self tagForSection:DocumentSection_Info andRow:1]) {
            if (!_visaTypeSelectionVC) {

                _visaTypeSelectionVC = [[CustomActionSheetViewController alloc] init];
                _visaTypeSelectionVC.delegate = self;
                _visaTypeSelectionVC.picker = [self getTypePicker];
            }
            pickerViewController = _visaTypeSelectionVC;
            _actionSheetSelectedType = ActionSheetSelectedType_VisaType;

            if (!_selectedVisaType) {
                _selectedVisaType = [[PRVisaType alloc] initWithTypeId:_docVisaTypeId
                                                               andName:_docVisaTypeName];
            } else {
                _selectedVisaType.typeId = (_isContactDocument ? ((PRProfileContactDocumentModel*)_documentModel).visaTypeId : ((PRDocumentModel*)_documentModel).visaTypeId);
                _selectedVisaType.typeName = _docVisaTypeName;
            }

            [((UIPickerView*)_visaTypeSelectionVC.picker) selectRow:[self rowForVisaTypeId] inComponent:0 animated:NO];
            [_activeField resignFirstResponder];

            [pickerViewController showForField:(UIPickerTextField*)textField];

            return NO;
        }
        if (textField.tag == [self tagForSection:DocumentSection_Info andRow:0]) {
            if (!_countrySelectionVC) {
                _countrySelectionVC = [[CustomActionSheetViewController alloc] init];
                _countrySelectionVC.delegate = self;
                _countrySelectionVC.picker = [self getCountryPicker];
            }
            pickerViewController = _countrySelectionVC;
            _actionSheetSelectedType = ActionSheetSelectedType_Country;

            if (_documentId || _docCountryName != nil) {
                _countryIsoCode = _docCountryCode;
                _countryName = _docCountryName;
            } else {
                _countryName = [CountryPicker countryNamesByCode][@"RU"];
                _countryIsoCode = @"RU";
            }

            [_activeField resignFirstResponder];

            [pickerViewController showForField:(UIPickerTextField*)textField];
            [((CountryPicker*)pickerViewController.picker) setSelectedCountryCode:(_countryIsoCode != nil ? _countryIsoCode : @"RU")];

            return NO;
        }
    }

    if (dateField) {

        [_activeField resignFirstResponder];

        pickerViewController.delegate = self;
        NSString* dateFormat = DATE_DAY_FORMAT;

#if defined(Otkritie)
        dateFormat = DATE_FORMAT_ddMMyyyy;
#endif

        [self createDatePickerForPickerController:pickerViewController];
        ((UIDatePicker*)pickerViewController.picker).datePickerMode = UIDatePickerModeDate;
        if (@available(iOS 13.4, *)) {
            ((UIDatePicker*)pickerViewController.picker).preferredDatePickerStyle = UIDatePickerStyleWheels;
        }

        if (!textField.text || [textField.text isEqualToString:@""]) {
            ((UIDatePicker*)pickerViewController.picker).date = currentDate;
        } else {
            ((UIDatePicker*)pickerViewController.picker).date = [NSDate mt_dateFromString:textField.text usingFormat:dateFormat] ?: currentDate;
        }
        [pickerViewController showForField:(UIPickerTextField*)textField];

        return NO;
    }

    _activeField = textField;
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger documentType = [_type integerValue];
    if (finalString.length > kTextMaxLength && finalString.length > textField.text.length) {
        return NO;
    }

    if (textField.tag == [self tagForSection:DocumentSection_SelfInfo andRow:0]) {
        _docLastName = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_SelfInfo andRow:1]) {
        _docFirstName = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_SelfInfo andRow:2]) {
        _docMiddleName = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_Info andRow:1] && (_isPassport || documentType == DocumentType_Birth_Certificate || documentType == DocumentType_Driving_Licence)) {
        _docBirthPlace = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_Info andRow:2] && (_isPassport || documentType == DocumentType_Birth_Certificate)) {
        _docCitizenship = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_Date andRow:0]) {
            _docNumber = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_Date andRow:1] && (_isPassport || documentType == DocumentType_Visa || documentType == DocumentType_Driving_Licence)) {
        _docAuthority = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_Date andRow:4] && _isPassport) {
        _docAuthorityId = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_Date andRow:4] && documentType == DocumentType_Driving_Licence) {
        _docIssuedAt = finalString;
    } else if (textField.tag == [self tagForSection:DocumentSection_Comment andRow:0]) {
        _docComment = finalString;
    } else if (documentType == DocumentType_Driving_Licence) {
        if (textField.tag == [self tagForSection:DocumentSection_AdditionalInfo andRow:0]) {
            _docDomicile = finalString;
        }
        if (textField.tag == [self tagForSection:DocumentSection_AdditionalInfo andRow:1]) {
            _docCategoryOfVehicleName = finalString;
        }
    } else if (documentType == DocumentType_Insurance) {
        if (textField.tag == [self tagForSection:DocumentSection_AdditionalInfo andRow:0]) {
            _docInsuranceCompany = finalString;
        }
        if (textField.tag == [self tagForSection:DocumentSection_AdditionalInfo andRow:1]) {
            _docCoverage = finalString;
        }
    }

    [self prepareNavigationBar];

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView*)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PRVisaType* visaType = _visaTypes[row];

    if (![_docVisaTypeName isEqualToString:visaType.typeName]) {
        [self prepareNavigationBar];
    }
    _docVisaTypeName = visaType.typeName;
    _docVisaTypeId = visaType.typeId;

    [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:DocumentSection_Info] ]
                      withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _visaTypes.count;
}

- (NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _visaTypes[row].typeName;
}

#pragma mark - CountryPickerDelegate

- (void)countryPicker:(__unused CountryPicker*)picker didSelectCountryWithName:(NSString*)name code:(NSString*)code
{
    if (![_docCountryCode isEqualToString:code]) {
        [self prepareNavigationBar];
    }
    _docCountryCode = code;
    _docCountryName = name;

    NSInteger row = [_type integerValue] == DocumentType_Visa ? 0 : 3;
    [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:row inSection:DocumentSection_Info] ]
                      withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - SelectionViewControllerDelegate

- (void)selectionViewControllerDidDoneFor:(CustomActionSheetViewController*)sheet
{
    _actionSheetSelectedType = ActionSheetSelectedType_None;
    if ([sheet isEqual:_countrySelectionVC]) {

        [PRGoogleAnalyticsManager sendEventWithName:kCountryPickerSelectButtonClicked parameters:nil];
        if (!_docCountryCode) {
            _countryName = [CountryPicker countryNamesByCode][@"RU"];
            _countryIsoCode = @"RU";

            _docCountryCode = _countryIsoCode;
            _docCountryName = _countryName;
        } else {
            _countryIsoCode = _docCountryCode;
            _countryName = _docCountryName;
        }
        NSInteger row = [_type integerValue] == DocumentType_Visa ? 0 : 3;
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:row inSection:DocumentSection_Info] ]
                          withRowAnimation:UITableViewRowAnimationNone];

        return;
    }
    if ([sheet isEqual:_visaTypeSelectionVC]) {
        [PRGoogleAnalyticsManager sendEventWithName:kVisaTypePickerSelectButtonClicked parameters:nil];
        if (!_docVisaTypeName) {

            PRVisaType* visaType = _visaTypes[0];
            _docVisaTypeName = visaType.typeName;
            _docVisaTypeId = visaType.typeId;
        }

        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:DocumentSection_Info] ]
                          withRowAnimation:UITableViewRowAnimationNone];

        return;
    }
    [PRGoogleAnalyticsManager sendEventWithName:kDatePickerSelectButtonClicked parameters:nil];
    NSString* dateString = nil;
    NSString* dateFormat = DATE_DAY_FORMAT;
    NSDate* currentDate = [NSDate new];

#if defined(Otkritie)
    dateFormat = DATE_FORMAT_ddMMyyyy;
    if ([sheet isEqual:_birthDaySelectionVC]) {
        currentDate = [currentDate mt_dateYearsBefore:30];
    }
#endif

    if (!((UIDatePicker*)sheet.picker).date) {
        dateString = [currentDate mt_stringFromDateWithFormat:dateFormat localized:NO];
    } else {
        dateString = [((UIDatePicker*)sheet.picker).date mt_stringFromDateWithFormat:dateFormat localized:NO];
    }
    NSIndexPath* indexPathToReload = nil;

    if ([sheet isEqual:_issueDateSelectionVC]) {

        if (![_docIssueDate isEqualToString:dateString]) {
            [self prepareNavigationBar];
        }
        _docIssueDate = dateString;
        NSInteger row = [_type integerValue] == DocumentType_Insurance ? 1 : 2;
        indexPathToReload = [NSIndexPath indexPathForRow:row inSection:DocumentSection_Date];
    } else if ([sheet isEqual:_expDatelectionVC]) {

        if (![_docExpiryDate isEqualToString:dateString]) {
            [self prepareNavigationBar];
        }
        _docExpiryDate = dateString;
        NSInteger row = 1;
        if (_isPassport || [_type integerValue] == DocumentType_Visa || [_type integerValue] == DocumentType_Driving_Licence) {
            row = 3;
        } else if ([_type integerValue] == DocumentType_Insurance) {
            row = 2;
        }
        indexPathToReload = [NSIndexPath indexPathForRow:row inSection:DocumentSection_Date];
    } else if (_birthDaySelectionVC) {

        if (![_docBirthDate isEqualToString:dateString]) {
            [self prepareNavigationBar];
        }
        _docBirthDate = dateString;
        indexPathToReload = [NSIndexPath indexPathForRow:0 inSection:DocumentSection_Info];
    }

    [_tableView reloadRowsAtIndexPaths:@[ indexPathToReload ]
                      withRowAnimation:UITableViewRowAnimationNone];
}

- (void)selectionViewControllerDidCancelFor:(CustomActionSheetViewController*)sheet
{
    _actionSheetSelectedType = ActionSheetSelectedType_None;
    if ([_countrySelectionVC isEqual:sheet]) {
        [PRGoogleAnalyticsManager sendEventWithName:kCountryPickerCancelButtonClicked parameters:nil];
        _docCountryCode = _countryIsoCode;
        _docCountryName = _countryName;
        NSInteger row = [_type integerValue] == DocumentType_Visa ? 0 : 3;
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:row inSection:DocumentSection_Info] ]
                          withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([_visaTypeSelectionVC isEqual:sheet]) {
        [PRGoogleAnalyticsManager sendEventWithName:kVisaTypePickerCancelButtonClicked parameters:nil];
        _docVisaTypeName = _selectedVisaType.typeName;
        _docVisaTypeId = _selectedVisaType.typeId;
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:DocumentSection_Info] ]
                          withRowAnimation:UITableViewRowAnimationNone];
    }
    [PRGoogleAnalyticsManager sendEventWithName:kDatePickerCancelButtonClicked parameters:nil];
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setRelatedDocuments:(NSArray*)relatedDocuments
{
    [self prepareNavigationBar];
    __weak id weakSelf = self;
    if (relatedDocuments == nil || relatedDocuments.count == 0) {
        if (_isContactDocument) {
            if (!_isPassport) {
                [PRRequestManager detachVisaFromPassportForContactDocument:_contactModel.contactId documentId:_documentId view:nil mode:PRRequestMode_ShowNothing success:^{
                    _docRelatedPassport = nil;
                } failure:^{}
                ];
            } else {
                for (PRProfileContactDocumentModel* relatedVisa in _docRelatedVisas) {
                    [PRRequestManager detachVisaFromPassportForContactDocument:_contactModel.contactId documentId:relatedVisa.documentId view:nil mode:PRRequestMode_ShowNothing success:^{
                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                        AddDocumentViewController* strongSelf = weakSelf;
                        if (!strongSelf) {
                            return;
                        }
                        strongSelf.docRelatedPassport = nil;
                        PRDocumentModel* document = [(PRDocumentModel*)strongSelf.documentModel MR_inContext:localContext];
                        document.relatedVisas = nil;
                    }];
                    } failure:^{}
                    ];
                }
            }
        } else {
            if (!_isPassport) {
                [PRRequestManager detachVisaFromPassportForDocument:_documentId view:nil mode:PRRequestMode_ShowNothing success:^{
                    _docRelatedPassport = nil;
                } failure:^{
                    _docRelatedPassport = nil;
                }];
            } else {
                for (PRDocumentModel* relatedVisa in _docRelatedVisas) {
                    [PRRequestManager detachVisaFromPassportForDocument:relatedVisa.documentId view:nil mode:PRRequestMode_ShowNothing success:^{
                    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                        AddDocumentViewController* strongSelf = weakSelf;
                        if (!strongSelf) {
                            return;
                        }
                        strongSelf.docRelatedPassport = nil;
                        PRDocumentModel* document = [(PRDocumentModel*)strongSelf.documentModel MR_inContext:localContext];
                        document.relatedVisas = nil;
                    }];
                    } failure:^{}
                     ];
                }
            }
        }
        return;
    }

    if (_isPassport) {
        _docRelatedVisas = [NSMutableOrderedSet orderedSetWithArray:relatedDocuments];
        return;
    }
    _docRelatedPassport = relatedDocuments[0];
}

-(NSArray*)getRelatedDocumentsId
{
    NSMutableArray<NSNumber*>* relatedDocumentsId = [NSMutableArray new];
    if (_isPassport && _docRelatedVisas && _docRelatedVisas.count > 0) {
        for (NSInteger i=0; i<_docRelatedVisas.count; i++) {
            PRDocumentModel* data = (PRDocumentModel*)_docRelatedVisas[i];
            NSNumber* documentIdNumber = data.documentId;
            [relatedDocumentsId addObject:documentIdNumber];
        }
        return relatedDocumentsId;
    } else if (_docRelatedPassport) {
        PRDocumentModel* data = (PRDocumentModel*)_docRelatedPassport;
        NSNumber* documentIdNumber = data.documentId;
        return @[documentIdNumber];
    }
    return relatedDocumentsId;
}

-(void)linkDocuments:(NSArray<PRDocumentModel*>*)relatedDocuments
          toDocument:(NSNumber*)documentId
     forDocumentType:(DocumentType)documentType
{

    if (documentType == DocumentType_Visa && relatedDocuments.count > 0) {
        PRDocumentModel* document = relatedDocuments[0];
        [PRRequestManager linkDocument:documentId toDocument:document.documentId view:self.view mode:PRRequestMode_ShowErrorMessagesAndProgress
                               success:^{}
                               failure:^{}];
    } else if (_docRelatedVisas.count > 0) {
        for (PRDocumentModel* relatedDocument in relatedDocuments) {
            [PRRequestManager linkDocument:relatedDocument.documentId toDocument:documentId view:self.view mode:PRRequestMode_ShowErrorMessagesAndProgress
                                   success:^{}
                                   failure:^{
            }];
        }
    }
}

@end


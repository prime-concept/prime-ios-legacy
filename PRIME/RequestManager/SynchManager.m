//
//  SynchManager.m
//  PRIME
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "PRLoyalCardModel.h"
#import "Reachability.h"
#import "SynchManager.h"
#import "XNDocuments.h"

@interface SynchManager ()
@property (nonatomic, strong) NSOperationQueue* operationQueue;
@property (nonatomic) BOOL connectionRequired;
@end

@implementation SynchManager

+ (SynchManager*)sharedClient
{
    static SynchManager* sharedClient = nil;

    pr_dispatch_once({
        sharedClient = [[self alloc] init];

        sharedClient.operationQueue = [[NSOperationQueue alloc] init];
        sharedClient.operationQueue.name = @"Synch operation Queue";
        sharedClient.operationQueue.maxConcurrentOperationCount = 1;
        sharedClient.operationQueue.suspended = YES;

        [[NSNotificationCenter defaultCenter] addObserver:sharedClient
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    });

    return sharedClient;
}

- (void)addOperationWithBlock:(void (^)(void))block
{
    _operationQueue.suspended = [PRRequestManager connectionRequired];

    NSAssert(_operationQueue != nil, @"_operationQueue can't be null");
    NSAssert(block != nil, @"block for operation can't be null");
    [_operationQueue addOperationWithBlock:block];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability* curReach = [notification object];
    BOOL connectionRequired = curReach.currentReachabilityStatus == NotReachable;

    if (!connectionRequired && _connectionRequired) {
        _connectionRequired = NO;
        _operationQueue.suspended = NO;
    } else if (connectionRequired) {
        _connectionRequired = YES;
        _operationQueue.suspended = YES;
    }
}

- (void)synchBonusCards
{
    NSArray<PRLoyalCardModel*>* bonusCards = [PRDatabase getDeletedDiscounts];

    for (PRLoyalCardModel* card in bonusCards) {
        [self addOperationWithBlock:^{
            [[CRMRestClient sharedClient] deleteDiscountWithId:card
                                                          lang:@"en"
                                                       success:^{
                                                           [card MR_deleteEntity];
                                                       }
                                                       failure:^(NSInteger statusCode, NSError* error){

                                                       }];
        }];
    }

    bonusCards = [PRDatabase getAddedDiscounts];
    for (PRLoyalCardModel* cardModel in bonusCards) {
        [self addOperationWithBlock:^{
            [[CRMRestClient sharedClient] createDiscount:cardModel
                                                    lang:@"en"
                                                 success:^{
                                                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext* localContext) {
                                                         PRLoyalCardModel* card = [cardModel MR_inContext:localContext];
                                                         card.syncStatus = @(0);
                                                     }];
                                                 }
                                                 failure:^(NSInteger statusCode, NSError* error){

                                                 }];
        }];
    }
}

#pragma mark - Synch Personal Data

- (void)synchProfilePersonalDataInContext:(NSManagedObjectContext*)context
                                     view:(UIView*)view
                                     mode:(PRRequestMode)mode
                               completion:(void (^)())completion;
{
    __block BOOL isSynchedPhones = [PRDatabase profilePhonesForModifyInContext:context].count == 0;
    __block BOOL isSynchedEmails = [PRDatabase profileEmailsForModifyInContext:context].count == 0;

    [self synchProfilePhonesInContext:context
                                 view:view
                                 mode:mode
                           completion:^{
                               isSynchedPhones = YES;
                               if (isSynchedEmails) {
                                   completion();
                               }
                           }];

    [self synchProfileEmailsInContext:context
                                 view:view
                                 mode:mode
                           completion:^{
                               isSynchedEmails = YES;
                               if (isSynchedPhones) {
                                   completion();
                               }
                           }];
}

- (void)synchProfilePhonesInContext:(NSManagedObjectContext*)context
                               view:(UIView*)view
                               mode:(PRRequestMode)mode
                         completion:(void (^)())completion
{

    NSArray<PRProfilePhoneModel*>* tmpProfilePhones = [PRDatabase profilePhonesForModifyInContext:context];

    for (PRProfilePhoneModel* phoneModel in tmpProfilePhones) {

        void (^completionBlock)(void) = ^{
            if (phoneModel == tmpProfilePhones.lastObject) {
                completion();
            }
        };
        if ([phoneModel.state isEqualToNumber:@(ModelStatus_Added)]) {

            // Add profile phone.
            [PRRequestManager addPhoneForProfile:phoneModel
                view:view
                mode:mode
                success:^{
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];

        } else if ([phoneModel.state isEqualToNumber:@(ModelStatus_Deleted)] && phoneModel.phoneId) {
            //      profile phone.
            [PRRequestManager deleteProfilePhoneWithPhoneId:phoneModel.phoneId
                view:view
                mode:mode
                success:^{
                    [[phoneModel MR_inContext:context] MR_deleteEntity];
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];

        } else if ([phoneModel.state isEqualToNumber:@(ModelStatus_Updated)] && phoneModel.phoneId) {

            // Update profile phone.
            [PRRequestManager updateProfilePhone:phoneModel
                view:view
                mode:mode
                success:^{
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        } else {
            completionBlock();
        }
    }
}

- (void)synchProfileEmailsInContext:(NSManagedObjectContext*)context
                               view:(UIView*)view
                               mode:(PRRequestMode)mode
                         completion:(void (^)())completion
{

    NSArray<PRProfileEmailModel*>* tmpProfileEmails = [PRDatabase profileEmailsForModifyInContext:context];

    for (PRProfileEmailModel* emailModel in tmpProfileEmails) {

        void (^completionBlock)(void) = ^{
            if (emailModel == tmpProfileEmails.lastObject) {
                completion();
            }
        };

        if ([emailModel.state isEqualToNumber:@(ModelStatus_Added)]) {

            // Add profile email.
            [PRRequestManager addEmailForProfile:emailModel
                view:view
                mode:mode
                success:^{
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        }

        else if ([emailModel.state isEqualToNumber:@(ModelStatus_Deleted)] && emailModel.emailId) {

            // Delete profile email.
            [PRRequestManager deleteProfileEmailWithEmailId:emailModel.emailId
                view:view
                mode:mode
                success:^{
                    [[emailModel MR_inContext:context] MR_deleteEntity];
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        }

        else if ([emailModel.state isEqualToNumber:@(ModelStatus_Updated)] && emailModel.emailId) {

            // Update profile email.
            [PRRequestManager updateProfileEmail:emailModel
                view:view
                mode:mode
                success:^{
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        } else {
            completionBlock();
        }
    }
}

#pragma mark - Synch Contacts

- (void)synchProfileContactsInContext:(NSManagedObjectContext*)context
                                 view:(UIView*)view
                                 mode:(PRRequestMode)mode
                           completion:(void (^)())completion

{
    NSArray<PRProfileContactModel*>* tmpProfileContacts = [PRDatabase profileContactsForModifyInContext:context];

    for (PRProfileContactModel* contactModel in tmpProfileContacts) {

        void (^completionBlock)(void) = ^{
            if (contactModel == tmpProfileContacts.lastObject) {
                completion();
            }
        };

        if ([contactModel.state isEqualToNumber:@(ModelStatus_Added)]) {

            //WORKAROUND: remove it after server will support putting phones and emails.
            NSOrderedSet* phones = contactModel.phones;
            NSOrderedSet* emails = contactModel.emails;
            NSOrderedSet* documents = contactModel.documents;

            [contactModel save];
            // Add profile contact.
            [PRRequestManager addContactForProfile:contactModel
                view:view
                mode:mode
                success:^(PRProfileContactModel* model) {

                    [contactModel setValue:phones forKey:@"phones"];
                    [model save];

                    for (PRProfileContactPhoneModel* phoneModel in phones) {
                        if ([phoneModel.state isEqualToNumber:@(ModelStatus_AddedWithoutParent)]) {

                            [phoneModel setState:@(ModelStatus_Added)];
                            if (!phoneModel.profileContact) {
                                phoneModel.profileContact = model;
                            }

                            [phoneModel save];

                            // Add contact phone.
                            [PRRequestManager addContactPhone:phoneModel
                                                withContactId:model.contactId
                                                         view:nil
                                                         mode:PRRequestMode_ShowNothing
                                                      success:^{

                                                      }
                                                      failure:^{

                                                      }];
                        }
                    }

                    [contactModel setValue:documents forKey:@"documents"];
                    [model save];

                    for (PRProfileContactDocumentModel* documentModel in documents) {
                        if ([documentModel.state isEqualToNumber:@(ModelStatus_AddedWithoutParent)]) {

                            [documentModel setState:@(ModelStatus_Added)];
                            if (!documentModel.profileContact) {
                                documentModel.profileContact = model;
                            }

                            [documentModel save];

                            // Add contact document.
                            [PRRequestManager addContactDocument:documentModel
                                                   withContactId:model.contactId
                                                            view:nil
                                                            mode:PRRequestMode_ShowNothing
                                                         success:^{

                                                             NSArray* images = documentModel.imagesData;
                                                             if (images.count) {

                                                                 NSMutableArray* tempArray = [NSMutableArray array];
                                                                 for (DocumentImage* image in images) {
                                                                     if ([image.state isEqualToNumber:@(DocumentImageStatus_Deleted)]) {
                                                                         [XNDocuments deleteImage:image.uid
                                                                                      ForDocument:documentModel.documentId
                                                                                             view:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]
                                                                                             mode:PRRequestMode_ShowNothing];
                                                                         continue;
                                                                     }
                                                                     [tempArray addObject:image.uid];
                                                                 }

                                                                 [XNDocuments attachImages:tempArray ForDocument:documentModel.documentId];

                                                                 documentModel.imagesData = nil;
                                                                 [documentModel save];
                                                             }

                                                             if ([PRDatabase isPassport:documentModel.documentType] && documentModel.relatedVisas && documentModel.relatedVisas.count > 0) {
                                                                 NSOrderedSet<PRProfileContactDocumentModel*>* relatedVisas = documentModel.relatedVisas;
                                                                 for (PRProfileContactDocumentModel* relatedVisa in relatedVisas) {
                                                                     [PRRequestManager linkDocument:relatedVisa.documentId
                                                                                         toDocument:documentModel.documentId
                                                                                         forContact:model.contactId
                                                                                               view:nil
                                                                                               mode:PRRequestMode_ShowNothing
                                                                                            success:^{}
                                                                                            failure:^{}];
                                                                 }
                                                             } else if (documentModel.documentType.integerValue == DocumentType_Visa && documentModel.relatedPassport) {
                                                                 [PRRequestManager linkDocument:documentModel.documentId
                                                                                     toDocument:documentModel.relatedPassport.documentId
                                                                                     forContact:model.contactId
                                                                                           view:nil
                                                                                           mode:PRRequestMode_ShowNothing
                                                                                        success:^{}
                                                                                        failure:^{}];
                                                             }

                                                         }
                                                         failure:^{

                                                         }];
                        }
                    }

                    [contactModel setValue:emails forKey:@"emails"];
                    [model save];

                    for (PRProfileContactEmailModel* emailModel in emails) {
                        if ([emailModel.state isEqualToNumber:@(ModelStatus_AddedWithoutParent)]) {

                            [emailModel setState:@(ModelStatus_Added)];
                            if (!emailModel.profileContact) {
                                emailModel.profileContact = model;
                            }

                            [emailModel save];

                            // Add contact email.
                            [PRRequestManager addContactEmail:emailModel
                                                withContactId:model.contactId
                                                         view:nil
                                                         mode:PRRequestMode_ShowNothing
                                                      success:^{

                                                      }
                                                      failure:^{

                                                      }];
                        }
                    }
                    completionBlock();
                }
                failure:^{
                    [contactModel setValue:phones forKey:@"phones"];
                    [contactModel save];

                    [contactModel setValue:emails forKey:@"emails"];
                    [contactModel save];

                    [contactModel setValue:documents forKey:@"documents"];
                    [contactModel save];
                    completionBlock();
                }];
        }

        else if ([contactModel.state isEqualToNumber:@(ModelStatus_Deleted)]) {

            if ([contactModel.contactId isEqualToNumber:@0]) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext* _Nonnull localContext) {
                    [[contactModel MR_inContext:localContext] MR_deleteEntity];
                }];
                continue;
            }
            // Remove profile contact.
            [PRRequestManager deleteProfileContactWithContactId:contactModel.contactId
                view:view
                mode:mode
                success:^{
                    [[contactModel MR_inContext:context] MR_deleteEntity];
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        }

        else if ([contactModel.state isEqualToNumber:@(ModelStatus_Updated)]) {

            // Update profile contact.
            [PRRequestManager updateProfileContact:contactModel
                view:view
                mode:mode
                success:^{
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        } else {
            completionBlock();
        }
    }

    NSArray<PRProfileContactModel*>* contactModels = [PRProfileContactModel MR_findAllInContext:context];
    for (PRProfileContactModel* contactModel in contactModels) {
        [self synchProfileContactsEmails:contactModel inContext:context];
        [self synchProfileContactsPhones:contactModel inContext:context];
        [self synchProfileContactsDocuments:contactModel inContext:context];
    }
}

- (void)synchProfileContactsEmails:(PRProfileContactModel*)contactModel inContext:(NSManagedObjectContext*)context
{
    for (PRProfileContactEmailModel* emailModel in contactModel.emails) {

        BOOL needToSynchEmail = ![contactModel.contactId isEqualToNumber:@0] && emailModel.emailId;

        if ([emailModel.state isEqualToNumber:@(ModelStatus_Added)] && ![contactModel.contactId isEqualToNumber:@0]) {

            // Add contact email.
            [PRRequestManager addContactEmail:emailModel
                                withContactId:contactModel.contactId
                                         view:nil
                                         mode:PRRequestMode_ShowNothing
                                      success:^{

                                      }
                                      failure:^{

                                      }];
        }

        else if ([emailModel.state isEqualToNumber:@(ModelStatus_Deleted)] && needToSynchEmail) {

            if (!emailModel.emailId || [emailModel.emailId isEqualToString:@"0"]) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext* _Nonnull localContext) {
                    [[emailModel MR_inContext:localContext] MR_deleteEntity];
                }];
                continue;
            }

            // Remove contact email.
            [PRRequestManager deleteProfileContactEmailWithContactId:contactModel.contactId
                                                             emailId:emailModel.emailId
                                                                view:nil
                                                                mode:PRRequestMode_ShowNothing
                                                             success:^{
                                                                 [[emailModel MR_inContext:context] MR_deleteEntity];
                                                             }
                                                             failure:^{

                                                             }];
        }

        else if ([emailModel.state isEqualToNumber:@(ModelStatus_Updated)] && needToSynchEmail) {

            // Update contact email.
            [PRRequestManager updateProfileContactEmail:emailModel
                                          withContactId:contactModel.contactId
                                                emailId:emailModel.emailId
                                                   view:nil
                                                   mode:PRRequestMode_ShowNothing
                                                success:^{

                                                }
                                                failure:^{

                                                }];
        }
    }
}

- (void)synchProfileContactsPhones:(PRProfileContactModel*)contactModel inContext:(NSManagedObjectContext*)context
{
    for (PRProfileContactPhoneModel* phoneModel in contactModel.phones) {

        BOOL needToSynchPhone = ![contactModel.contactId isEqualToNumber:@0] && phoneModel.phoneId;

        if ([phoneModel.state isEqualToNumber:@(ModelStatus_Added)] && ![contactModel.contactId isEqualToNumber:@0]) {

            // Add contact phone.
            [PRRequestManager addContactPhone:phoneModel
                                withContactId:contactModel.contactId
                                         view:nil
                                         mode:PRRequestMode_ShowNothing
                                      success:^{

                                      }
                                      failure:^{

                                      }];
        }

        else if ([phoneModel.state isEqualToNumber:@(ModelStatus_Deleted)] && needToSynchPhone) {

            if (!phoneModel.phoneId || [phoneModel.phoneId isEqualToString:@"0"]) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext* _Nonnull localContext) {
                    [[phoneModel MR_inContext:localContext] MR_deleteEntity];
                }];
                continue;
            }

            // Remove contact phone.
            [PRRequestManager deleteProfileContactPhoneWithContactId:contactModel.contactId
                                                             phoneId:phoneModel.phoneId
                                                                view:nil
                                                                mode:PRRequestMode_ShowNothing
                                                             success:^{
                                                                 [[phoneModel MR_inContext:context] MR_deleteEntity];
                                                             }
                                                             failure:^{

                                                             }];
        }

        else if ([phoneModel.state isEqualToNumber:@(ModelStatus_Updated)] && needToSynchPhone) {

            // Update contact phone.
            [PRRequestManager updateProfileContactPhone:phoneModel
                                          withContactId:contactModel.contactId
                                                phoneId:phoneModel.phoneId
                                                   view:nil
                                                   mode:PRRequestMode_ShowNothing
                                                success:^{

                                                }
                                                failure:^{

                                                }];
        }
    }
}

- (void)synchProfileContactsDocuments:(PRProfileContactModel*)contactModel inContext:(NSManagedObjectContext*)context
{
    for (PRProfileContactDocumentModel* documentModel in contactModel.documents) {

        NSArray* images = [documentModel.imagesData copy];

        BOOL needToSynchDocument = ![contactModel.contactId isEqualToNumber:@0] && ![documentModel.documentId isEqualToNumber:@0];

        if ([documentModel.state isEqualToNumber:@(ModelStatus_Added)] && ![contactModel.contactId isEqualToNumber:@0]) {

            // Add contact document.
            [PRRequestManager addContactDocument:documentModel
                                   withContactId:contactModel.contactId
                                            view:nil
                                            mode:PRRequestMode_ShowNothing
                                         success:^{
                                             if (images.count) {

                                                 NSMutableArray* tempArray = [NSMutableArray array];
                                                 for (DocumentImage* image in images) {
                                                     [tempArray addObject:image.uid];
                                                 }

                                                 [XNDocuments attachImages:tempArray ForDocument:documentModel.documentId];

                                                 documentModel.imagesData = nil;
                                                 [documentModel save];
                                             }
                                             if ([PRDatabase isPassport:documentModel.documentType] && documentModel.relatedVisas && documentModel.relatedVisas.count > 0) {
                                                 NSOrderedSet<PRProfileContactDocumentModel*>* relatedVisas = documentModel.relatedVisas;
                                                 for (PRProfileContactDocumentModel* relatedVisa in relatedVisas) {
                                                     [PRRequestManager linkDocument:relatedVisa.documentId
                                                                         toDocument:documentModel.documentId
                                                                         forContact:contactModel.contactId
                                                                               view:nil
                                                                               mode:PRRequestMode_ShowNothing
                                                                            success:^{}
                                                                            failure:^{}];
                                                 }
                                             } else if (documentModel.documentType.integerValue == DocumentType_Visa && documentModel.relatedPassport) {
                                                 [PRRequestManager linkDocument:documentModel.documentId
                                                                     toDocument:documentModel.relatedPassport.documentId
                                                                     forContact:contactModel.contactId
                                                                           view:nil
                                                                           mode:PRRequestMode_ShowNothing
                                                                        success:^{}
                                                                        failure:^{}];
                                             }

                                         }
                                         failure:^{

                                         }];
        }

        else if ([documentModel.state isEqualToNumber:@(ModelStatus_Deleted)] && needToSynchDocument) {

            if (!documentModel.documentId || [documentModel.documentId isEqualToNumber:@0]) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext* _Nonnull localContext) {
                    [[documentModel MR_inContext:localContext] MR_deleteEntity];
                }];
                continue;
            }

            // Remove contact document.
            [PRRequestManager deleteProfileContactDocumentWithContactId:contactModel.contactId
                                                             documentId:documentModel.documentId
                                                                   view:nil
                                                                   mode:PRRequestMode_ShowNothing
                                                                success:^{

                                                                    for (DocumentImage* image in images) {
                                                                        [XNDocuments deleteImage:image.uid
                                                                                     ForDocument:documentModel.documentId
                                                                                            view:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]
                                                                                            mode:PRRequestMode_ShowNothing];
                                                                    }
                                                                    [[documentModel MR_inContext:context] MR_deleteEntity];
                                                                }
                                                                failure:^{

                                                                }];
        }

        else if ([documentModel.state isEqualToNumber:@(ModelStatus_Updated)] && needToSynchDocument) {

            [PRRequestManager getProfileContactDocumentWithContactId:contactModel.contactId documentId:documentModel.documentId view:nil mode:PRRequestMode_ShowNothing success:^(NSArray *contactDocuments) {
                NSMutableOrderedSet<PRProfileContactDocumentModel*>* relatedVisas = ((PRProfileContactDocumentModel*)[contactDocuments firstObject]).relatedVisas;
                if (relatedVisas && relatedVisas.count > 0 && [PRDatabase isPassport:documentModel.documentType]) {
                    for (PRProfileContactDocumentModel* relatedVisa in relatedVisas) {
                        __block NSInteger counter = 0;
                        [PRRequestManager detachVisaFromPassportForContactDocument:contactModel.contactId documentId:relatedVisa.documentId view:nil mode:PRRequestMode_ShowNothing success:^{
                            counter++;
                            if (counter == relatedVisas.count) {
                                NSOrderedSet<PRProfileContactDocumentModel*>* newRelatedVisas = documentModel.relatedVisas;
                                for (PRProfileContactDocumentModel* newRelatedVisa in newRelatedVisas) {
                                    [PRRequestManager linkDocument:newRelatedVisa.documentId
                                                        toDocument:documentModel.documentId
                                                        forContact:contactModel.contactId
                                                              view:nil
                                                              mode:PRRequestMode_ShowNothing
                                                           success:^{}
                                                           failure:^{}];
                                }
                            }
                        } failure:^{}];
                    }
                } else {
                    NSOrderedSet<PRProfileContactDocumentModel*>* newRelatedVisas = documentModel.relatedVisas;
                    for (PRProfileContactDocumentModel* newRelatedVisa in newRelatedVisas) {
                        [PRRequestManager linkDocument:newRelatedVisa.documentId
                                            toDocument:documentModel.documentId
                                            forContact:contactModel.contactId
                                                  view:nil
                                                  mode:PRRequestMode_ShowNothing
                                               success:^{}
                                               failure:^{}];
                    }
                }
            } failure:^{}];

            if (documentModel.documentType.integerValue == DocumentType_Visa && documentModel.relatedPassport) {
                [PRRequestManager linkDocument:documentModel.documentId
                                    toDocument:documentModel.relatedPassport.documentId
                                    forContact:contactModel.contactId
                                          view:nil
                                          mode:PRRequestMode_ShowNothing
                                       success:^{}
                                       failure:^{}];
            }

            // Update contact document.
            [PRRequestManager updateProfileContactDocument:documentModel
                                             withContactId:contactModel.contactId
                                                documentId:documentModel.documentId
                                                      view:nil
                                                      mode:PRRequestMode_ShowNothing
                                                   success:^{

                                                       if (images.count) {

                                                           NSMutableArray* tempArray = [NSMutableArray array];

                                                           for (DocumentImage* image in images) {
                                                               if ([image.state isEqualToNumber:@(DocumentImageStatus_Deleted)]) {
                                                                   [XNDocuments deleteImage:image.uid
                                                                                ForDocument:documentModel.documentId
                                                                                       view:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]
                                                                                       mode:PRRequestMode_ShowNothing];
                                                                   continue;
                                                               }
                                                               [tempArray addObject:image.uid];
                                                           }

                                                           [XNDocuments attachImages:tempArray ForDocument:documentModel.documentId];

                                                           documentModel.imagesData = nil;
                                                           [documentModel save];
                                                       }

                                                   }
                                                   failure:^{

                                                   }];
        }
    }
}

#pragma mark - Synch Cars

- (void)synchProfileCarsInContext:(NSManagedObjectContext*)context
                             view:(UIView*)view
                             mode:(PRRequestMode)mode
                       completion:(void (^)())completion
{

    NSArray<PRCarModel*>* tmpProfileCars = [PRDatabase profileCarsForModifyInContext:context];

    for (PRCarModel* carModel in tmpProfileCars) {

        void (^completionBlock)(void) = ^{
            if (carModel == tmpProfileCars.lastObject) {
                completion();
            }
        };

        if ([carModel.state isEqualToNumber:@(ModelStatus_Added)]) {

            // Add profile car.
            [PRRequestManager addCarForProfile:carModel
                view:view
                mode:mode
                success:^{
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        }

        else if ([carModel.state isEqualToNumber:@(ModelStatus_Deleted)] && carModel.carId) {

            // Delete profile car.
            [PRRequestManager deleteProfileCarWithCarId:carModel.carId
                view:view
                mode:mode
                success:^{
                    [[carModel MR_inContext:context] MR_deleteEntity];
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        }

        else if ([carModel.state isEqualToNumber:@(ModelStatus_Updated)] && carModel.carId) {

            // Update profile car.
            [PRRequestManager updateCarForProfile:carModel
                view:view
                mode:mode
                success:^{
                    completionBlock();
                }
                failure:^{
                    completionBlock();
                }];
        } else {
            completionBlock();
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}

@end

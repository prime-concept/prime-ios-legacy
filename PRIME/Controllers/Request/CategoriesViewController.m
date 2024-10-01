//
//  CategoriesViewController.m
//  PRIME
//
//  Created by Artak Tsatinyan on 1/30/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CategoriesViewController.h"
#import "RequestsViewController.h"
#import "XNTLazyManager.h"

@interface CategoriesViewController ()

@property XNTLazyManager* lazyManager;
@end

@implementation CategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _categoriesDataSource = [[CategoriesDataSource alloc] init];
    _categoriesDataSource.parentView = self;
    _tableViewCategories.dataSource = _categoriesDataSource;
    _tableViewCategories.delegate = _categoriesDataSource;
    _tableViewCategories.backgroundColor = kTableViewBackgroundColor;

    _lazyManager = [[XNTLazyManager alloc] initWithObserver:self
                                                   selector:@selector(reachabilityChanged:)];
    [self reload];
    [self prepareNavigationBar];
}

- (void)reachabilityChanged:(NSNotification*)note
{
    [_lazyManager shouldBeUpdatedIfReachabilityChangedWithNotification:note
                                                                  date:[NSDate date]
                                                        relativeToDate:nil
                                                                  then:^(PRRequestMode mode) {
                                                                      [PRRequestManager getTasksTypesWithview:self.view
                                                                          mode:PRRequestMode_ShowNothing
                                                                          success:^(NSArray* types) {

                                                                              [self reload];

                                                                          }
                                                                          failure:^{

                                                                          }];
                                                                  }];
}

- (void)reload
{
    _categoriesDataSource.allCategories = [PRDatabase getTasksTypes];
    NSRange firstFiveObject = NSMakeRange(0, MIN(5, _categoriesDataSource.allCategories.count));
    _categoriesDataSource.categoriesToShow = [_categoriesDataSource.allCategories subarrayWithRange:firstFiveObject];

    [_tableViewCategories reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_lazyManager shouldBeUpdatedIfViewDidAppearWithDate:[NSDate date]
        relativeToDate:nil
        then:^(PRRequestMode mode) {
            [PRRequestManager getTasksTypesWithview:self.view
                mode:PRRequestMode_ShowOnlyProgress
                success:^(NSArray* types) {

                    [self reload];

                }
                failure:^{

                }];
        }
        otherwiseIfFirstTime:^{
            [self reload];
        }
        otherwise:^{

        }];
}

- (void)prepareNavigationBar
{
    [self setTitle:NSLocalizedString(@"Request Types", nil)];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

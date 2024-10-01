//
//  SelectCardViewController.m
//  PRIME
//
//  Created by Admin on 1/31/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "SelectCardViewController.h"
#import "PRCardData.h"

#import "XNTKeychainStore.h"

@interface SelectCardViewController ()

@end

@implementation SelectCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [[CardDataSource alloc] init];
    
    _dataSource.cardSection = [NSMutableArray objectFromKeychainWithKey: kCardDataKeyPath forClass: PRCardData.class];
    
    _tableView.dataSource = _dataSource;
    _tableView.delegate = _dataSource;
    
    [self prepareNavigationBar];
}


- (void) prepareNavigationBar
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end

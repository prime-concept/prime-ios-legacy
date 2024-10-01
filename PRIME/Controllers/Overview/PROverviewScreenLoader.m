//
//  PROverviewScreenLoader.m
//  PRIME
//
//  Created by Davit on 8/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "PROverviewBaseViewController.h"
#import "PROverviewScreenConstants.h"
#import "PROverviewScreenLoader.h"
#import "XMLReader.h"

@implementation PROverviewScreenLoader

- (NSDictionary*)loadXMLFile:(NSString*)filename
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:filename
                                                         ofType:@"xml"];
    NSData* xmlData = [[NSData alloc] initWithContentsOfFile:filePath];

    NSError* parseError = nil;
    return [XMLReader dictionaryForXMLData:xmlData error:&parseError];
}

- (void)loadScreensWithDelegate:(id<OverviewScreenLoaderDelegate>)delegate
{
    NSDictionary* pages = [self loadXMLFile:@"config"][kOverviewConfigKey][kOverviewPagesKey];
    NSArray* pagesArray = pages[kOverviewPageKey];

    for (int i = 0; i < [pages[kOverviewCountKey] integerValue]; i++) {

        NSDictionary* pageDictionary = [self loadXMLFile:pagesArray[i][kOverviewNameKey]];

        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* viewController = [mainStoryboard instantiateViewControllerWithIdentifier:pageDictionary[kOverviewPageKey][kOverviewTypeKey]];
        PROverviewBaseViewController* overviewBaseViewController = (PROverviewBaseViewController*)viewController;
        [overviewBaseViewController view];
        [overviewBaseViewController fillScreenWithData:pageDictionary[kOverviewPageKey]];

        if ([delegate respondsToSelector:@selector(onScreenLoaded:)]) {
            [delegate onScreenLoaded:overviewBaseViewController];
        }
    }
}

@end

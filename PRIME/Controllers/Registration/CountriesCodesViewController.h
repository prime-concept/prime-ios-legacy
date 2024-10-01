//
//  CountriesCodesViewController.h
//  PRIME
//
//  Created by Admin on 6/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryInfo : NSObject

@property(strong, nonatomic) NSString *countryName;
@property(strong, nonatomic) NSString *isoName;
@property(strong, nonatomic) NSString *isoCode;

@end

@protocol SelectCountry <NSObject>

- (void) countrySelected:(CountryInfo*) countryInfo;

@end


@interface CountriesCodesViewController : UITableViewController

+ (NSDictionary*) countryIsoMaping;
+ (NSString*) countryNameForIso:(NSString*)isoCode;
+ (NSDictionary*) counrtyNameIsoCodesMaping;

@property (strong, nonatomic) NSString *selectedCountry;
@property (weak, nonatomic) id<SelectCountry> selectCountryDelegate;
@end

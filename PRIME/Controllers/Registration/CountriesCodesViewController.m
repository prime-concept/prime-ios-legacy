//
//  CountriesCodesViewController.m
//  PRIME
//
//  Created by Artak on 6/1/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "CountriesCodesViewController.h"
#import "CountryCodeTableViewCell.h"

@implementation CountryInfo

@end

@interface CountriesCodesViewController ()

@property (strong, nonatomic) NSMutableArray<NSString*>* alphabetsArray;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* dictCodes;
@property (strong, nonatomic) NSMutableArray<NSMutableArray<CountryInfo*>*>* countryNames;

@end

@implementation CountriesCodesViewController

- (void)viewDidLoad
{
    [PRGoogleAnalyticsManager sendEventWithName:kCountriesScreenOpened parameters:nil];
    [super viewDidLoad];

    _alphabetsArray = [self.class alphabets];

    _dictCodes = [self.class counrtyNameIsoCodesMaping];
    _countryNames = [NSMutableArray array];

    NSMutableDictionary* tmpDic = [NSMutableDictionary dictionary];

    [_dictCodes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        NSString* countryName = key;
        NSString* firstLetter = [countryName substringToIndex:1];
        NSMutableArray* countryArrayWithSamePrefix = [tmpDic objectForKey:firstLetter];
        if (!countryArrayWithSamePrefix) {
            countryArrayWithSamePrefix = [NSMutableArray array];
            [tmpDic setObject:countryArrayWithSamePrefix forKey:firstLetter];
            [_countryNames addObject:countryArrayWithSamePrefix];
        }

        CountryInfo* countryInfo = [CountryInfo new];
        countryInfo.countryName = countryName;
        countryInfo.isoCode = [@"+" stringByAppendingString:obj];
        countryInfo.isoName = key;

        [countryArrayWithSamePrefix addObject:countryInfo];
    }];

    NSMutableArray* tmpArray = [NSMutableArray array];

    for (NSArray* countryArrayWithSamePrefix in _countryNames) {
        NSArray* sorted = [countryArrayWithSamePrefix sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(CountryInfo* obj1, CountryInfo* obj2) {
            return [obj1.countryName localizedCompare:obj2.countryName];
        }];

        [tmpArray addObject:sorted];
    }

    _countryNames = [[tmpArray sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSArray* obj1, NSArray* obj2) {
        CountryInfo* first = [obj1 firstObject];
        CountryInfo* second = [obj2 firstObject];
        return [[first.countryName substringToIndex:1] localizedCompare:[second.countryName substringToIndex:1]];
    }] mutableCopy];

    self.title = NSLocalizedString(@"Countries", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(close)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setNavigationBarAndStatusBarColors];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    if (_selectedCountry) {
        for (int i = 0; i < [_countryNames count]; i++) {
            for (int j = 0; j < [(NSArray*)_countryNames[i] count]; j++) {

                if ([((CountryInfo*)_countryNames[i][j]).countryName isEqualToString:_selectedCountry]) {
                    indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    [self.tableView selectRowAtIndexPath:indexPath
                                                animated:NO
                                          scrollPosition:UITableViewScrollPositionNone];
                    break;
                }
            }
        }
    }


    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)setNavigationBarAndStatusBarColors
{
    [[UIApplication sharedApplication] setStatusBarStyle:[self getStatusBarColor]];
    self.navigationController.navigationBar.barTintColor = [self getNavigationBarColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : [self getNavigationBarTitleColor] }];
}

- (UIStatusBarStyle)getStatusBarColor
{
    return UIStatusBarStyleLightContent;
}

- (UIColor*)getNavigationBarColor
{
    return kNavigationBarBarTintColor;
}

- (UIColor*)getNavigationBarTitleColor
{
    return kNavigationBarTitleColor;
}

- (NSArray*)partitionObjects:(NSArray*)array collationStringSelector:(SEL)selector

{
    UILocalizedIndexedCollation* collation = [UILocalizedIndexedCollation currentCollation];

    NSInteger sectionCount = [[collation sectionTitles] count]; //Section count is take from sectionTitles and not sectionIndexTitles.
    NSMutableArray<NSMutableArray*>* unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];

    //Create an array to hold the data for each section.
    for (int i = 0; i <= sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }

    //put each object into a section
    for (id object in array) {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }

    NSMutableArray* sections = [NSMutableArray arrayWithCapacity:sectionCount];

    //sort each section
    for (NSMutableArray* section in unsortedSections) {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }

    return sections;
}

+ (NSString*)countryNameForIso:(NSString*)isoCode
{
    return [[NSLocale systemLocale] displayNameForKey:NSLocaleCountryCode value:isoCode];
}

- (void)close
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                      }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    // Return the number of sections.
    return [_alphabetsArray count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [((NSMutableArray*)[_countryNames objectAtIndex:section])count];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return _alphabetsArray[section];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CountryCodeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCodeTableViewCell" forIndexPath:indexPath];

    CountryInfo* countryInfo = _countryNames[indexPath.section][indexPath.row];
    cell.labelCountryName.text = countryInfo.countryName;
    cell.labelIsoCode.text = countryInfo.isoCode;
    cell.labelIsoCode.font = [UIFont boldSystemFontOfSize:17];

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [PRGoogleAnalyticsManager sendEventWithName:[NSString stringWithFormat:kCountrySelected,(_countryNames[indexPath.section][indexPath.row]).countryName] parameters:nil];
    [_selectCountryDelegate countrySelected:_countryNames[indexPath.section][indexPath.row]];

    [self close];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView
{
    return _alphabetsArray;
}

+ (NSDictionary*)counrtyNameIsoCodesMaping
{
    return @{
        @"Afghanistan" : @"93",
        @"Albania" : @"355",
        @"Algeria" : @"213",
        @"American Samoa" : @"1684",
        @"Andorra" : @"376",
        @"Angola" : @"244",
        @"Anguilla" : @"1264",
        @"Antarctica" : @"672",
        @"Antigua and Barbuda" : @"1268",
        @"Argentina" : @"54",
        @"Armenia" : @"374",
        @"Aruba" : @"297",
        @"Australia" : @"61",
        @"Austria" : @"43",
        @"Azerbaijan" : @"994",
        @"Bahamas" : @"1242",
        @"Bahrain" : @"973",
        @"Bangladesh" : @"880",
        @"Barbados" : @"1246",
        @"Belarus" : @"375",
        @"Belgium" : @"32",
        @"Belize" : @"501",
        @"Benin" : @"229",
        @"Bermuda" : @"1441",
        @"Bhutan" : @"975",
        @"Bolivia" : @"591",
        @"Bosnia and Herzegovina" : @"387",
        @"Botswana" : @"267",
        @"Brazil" : @"55",
        @"British Indian Ocean Territory" : @"246",
        @"British Virgin Islands" : @"1284",
        @"Brunei" : @"673",
        @"Bulgaria" : @"359",
        @"Burkina" : @"226",
        @"Burundi" : @"257",
        @"Cambodia" : @"855",
        @"Cameroon" : @"237",
        @"Canada" : @"1",
        @"Cape Verde" : @"238",
        @"Cayman Islands" : @"1345",
        @"Central African Republic" : @"236",
        @"Chad" : @"235",
        @"Chile" : @"56",
        @"China" : @"86",
        @"Christmas Island" : @"61",
        @"Cocos Islands" : @"61",
        @"Colombia" : @"57",
        @"Comoros" : @"269",
        @"Cook Islands" : @"682",
        @"Costa Rica" : @"506",
        @"Croatia" : @"385",
        @"Cuba" : @"53",
        @"Curacao" : @"599",
        @"Cyprus" : @"357",
        @"Czech Republic" : @"420",
        @"Democratic Republic of the Congo" : @"243",
        @"Denmark" : @"45",
        @"Djibouti" : @"253",
        @"Dominica" : @"1767",
        @"Dominican Republic" : @"1",
        @"East Timor" : @"670",
        @"Ecuador" : @"593",
        @"Egypt" : @"20",
        @"El Salvador" : @"503",
        @"Equatorial Guinea" : @"240",
        @"Eritrea" : @"291",
        @"Estonia" : @"372",
        @"Ethiopia" : @"251",
        @"Falkland Islands" : @"500",
        @"Faroe Islands" : @"298",
        @"Fiji" : @"679",
        @"Finland" : @"358",
        @"France" : @"33",
        @"French Polynesia" : @"689",
        @"Gabon" : @"241",
        @"Gambia" : @"220",
        @"Georgia" : @"995",
        @"Germany" : @"49",
        @"Ghana" : @"233",
        @"Gibraltar" : @"350",
        @"Greece" : @"30",
        @"Greenland" : @"299",
        @"Grenada" : @"1473",
        @"Guam" : @"1671",
        @"Guatemala" : @"502",
        @"Guernsey" : @"44",
        @"Guinea" : @"224",
        @"Guine-Bissau" : @"245",
        @"Guyana" : @"592",
        @"Haiti" : @"509",
        @"Honduras" : @"504",
        @"Hong Kong" : @"852",
        @"Hungary" : @"36",
        @"Iceland" : @"354",
        @"India" : @"91",
        @"Indonesia" : @"62",
        @"Iran" : @"98",
        @"Iraq" : @"964",
        @"Ireland" : @"353",
        @"Isle of Man" : @"44",
        @"Israel" : @"972",
        @"Italy" : @"39",
        @"Ivory Coast" : @"225",
        @"Jamaica" : @"1876",
        @"Japan" : @"81",
        @"Jersey" : @"44",
        @"Jordan" : @"962",
        @"Kazakhstan" : @"7",
        @"Kenya" : @"254",
        @"Kiribati" : @"686",
        @"Kosovo" : @"383",
        @"Kuwait" : @"965",
        @"Kyrgyzstan" : @"996",
        @"Laos" : @"856",
        @"Latvia" : @"371",
        @"Lebanon" : @"961",
        @"Lesotho" : @"266",
        @"Liberia" : @"231",
        @"Libya" : @"218",
        @"Liechtenstein" : @"423",
        @"Lithuania" : @"370",
        @"Luxembourg" : @"352",
        @"Macao" : @"853",
        @"Macedonia" : @"389",
        @"Madagascar" : @"261",
        @"Malawi" : @"265",
        @"Malaysia" : @"60",
        @"Maldives" : @"960",
        @"Mali" : @"223",
        @"Malta" : @"356",
        @"Marshall Islands" : @"692",
        @"Mauritania" : @"222",
        @"Mauritius" : @"230",
        @"Mayotte" : @"262",
        @"Mexico" : @"52",
        @"Micronesia" : @"691",
        @"Moldova" : @"373",
        @"Monaco" : @"377",
        @"Mongolia" : @"976",
        @"Montenegro" : @"382",
        @"Montserrat" : @"1664",
        @"Morocco" : @"212",
        @"Mozambique" : @"258",
        @"Myanmar" : @"95",
        @"Namibia" : @"264",
        @"Nauru" : @"674",
        @"Nepal" : @"977",
        @"Netherlands" : @"31",
        @"Netherlands Antilles" : @"599",
        @"New Caledonia" : @"687",
        @"New Zealand" : @"64",
        @"Nicaragua" : @"505",
        @"Niger" : @"227",
        @"Nigeria" : @"234",
        @"Niue" : @"683",
        @"North Korea" : @"850",
        @"Northern Mariana Islands" : @"1670",
        @"Norway" : @"47",
        @"Oman" : @"968",
        @"Pakistan" : @"92",
        @"Palau" : @"680",
        @"Palestine" : @"970",
        @"Panama" : @"507",
        @"Papua New Guinea" : @"675",
        @"Paraguay" : @"595",
        @"Peru" : @"51",
        @"Philippines" : @"63",
        @"Pitcairn" : @"64",
        @"Poland" : @"48",
        @"Portugal" : @"351",
        @"Puerto Rico" : @"1",
        @"Qatar" : @"974",
        @"Republic of the Congo" : @"242",
        @"Reunion" : @"262",
        @"Romania" : @"40",
        @"Russia" : @"7",
        @"Rwanda" : @"250",
        @"Saint Barthelemy" : @"590",
        @"Saint Helena" : @"290",
        @"Saint Kitts and Nevis" : @"1869",
        @"Saint Lucia" : @"1758",
        @"Saint Martin" : @"590",
        @"Saint Pierre and Miquelon" : @"508",
        @"Saint Vincent and the Grenadines" : @"1784",
        @"Samoa" : @"685",
        @"San Marino" : @"378",
        @"Sao Tome and Principe" : @"239",
        @"Saudi Arabia" : @"966",
        @"Senegal" : @"221",
        @"Serbia" : @"381",
        @"Seychelles" : @"248",
        @"Sierra Leone" : @"232",
        @"Singapore" : @"65",
        @"Sint Maarten" : @"1721",
        @"Slovakia" : @"421",
        @"Slovenia" : @"386",
        @"Solomon Islands" : @"677",
        @"Somalia" : @"252",
        @"South Africa" : @"27",
        @"South Korea" : @"82",
        @"South Sudan" : @"211",
        @"Spain" : @"34",
        @"Sri Lanka" : @"94",
        @"Sudan" : @"249",
        @"Suriname" : @"597",
        @"Svalbard and Jan Mayen" : @"47",
        @"Swaziland" : @"268",
        @"Sweden" : @"46",
        @"Switzerland" : @"41",
        @"Syria" : @"963",
        @"Taiwan" : @"886",
        @"Tajikistan" : @"992",
        @"Tanzania" : @"255",
        @"Thailand" : @"66",
        @"Togo" : @"228",
        @"Tokelau" : @"690",
        @"Tonga" : @"676",
        @"Trinidad and Tobago" : @"1868",
        @"Tunisia" : @"216",
        @"Turkey" : @"90",
        @"Turkmenistan" : @"993",
        @"Turks and Caicos Islands" : @"1649",
        @"Tuvalu" : @"688",
        @"U.S. Virgin Islands" : @"1340",
        @"Uganda" : @"256",
        @"Ukraine" : @"380",
        @"United Arab Emirates" : @"971",
        @"United Kingdom" : @"44",
        @"United States" : @"1",
        @"Uruguay" : @"598",
        @"Uzbekistan" : @"998",
        @"Vanuatu" : @"678",
        @"Vatican" : @"379",
        @"Venezuela" : @"58",
        @"Vietnam" : @"84",
        @"Wallis and Futuna" : @"681",
        @"Western Sahara" : @"212",
        @"Yemen" : @"967",
        @"Zambia" : @"260",
        @"Zimbabwe" : @"263"
    };
}

+ (NSDictionary*)countryIsoMaping
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"1", @"US", @"1", @"AG", @"1", @"AI", @"1", @"AS", @"1", @"BB", @"1", @"BM", @"1", @"BS", @"1", @"CA", @"1", @"DM", @"1", @"DO",
                                @"1", @"GD", @"1", @"GU", @"1", @"JM", @"1", @"KN", @"1", @"KY", @"1", @"LC", @"1", @"MP", @"1", @"MS", @"1", @"PR", @"1", @"SX",
                                @"1", @"TC", @"1", @"TT", @"1", @"VC", @"1", @"VG", @"1", @"VI", @"7", @"RU", @"7", @"KZ",
                                @"20", @"EG", @"27", @"ZA",
                                @"30", @"GR", @"31", @"NL", @"32", @"BE", @"33", @"FR", @"34", @"ES", @"36", @"HU", @"39", @"IT",
                                @"40", @"RO", @"41", @"CH", @"43", @"AT", @"44", @"GB", @"44", @"GG", @"44", @"IM", @"44", @"JE", @"45", @"DK", @"46", @"SE", @"47", @"NO", @"47", @"SJ", @"48", @"PL", @"49", @"DE",
                                @"51", @"PE", @"52", @"MX", @"53", @"CU", @"54", @"AR", @"55", @"BR", @"56", @"CL", @"57", @"CO", @"58", @"VE",
                                @"60", @"MY", @"61", @"AU", @"61", @"CC", @"61", @"CX", @"62", @"ID", @"63", @"PH", @"64", @"NZ", @"65", @"SG", @"66", @"TH",
                                @"81", @"JP", @"82", @"KR", @"84", @"VN", @"86", @"CN",
                                @"90", @"TR", @"91", @"IN", @"92", @"PK", @"93", @"AF", @"94", @"LK", @"95", @"MM", @"98", @"IR",
                                @"211", @"SS", @"212", @"MA", @"212", @"EH", @"213", @"DZ", @"216", @"TN", @"218", @"LY",
                                @"220", @"GM", @"221", @"SN", @"222", @"MR", @"223", @"ML", @"224", @"GN", @"225", @"CI", @"226", @"BF", @"227", @"NE", @"228", @"TG", @"229", @"BJ",
                                @"230", @"MU", @"231", @"LR", @"232", @"SL", @"233", @"GH", @"234", @"NG", @"235", @"TD", @"236", @"CF", @"237", @"CM", @"238", @"CV", @"239", @"ST",
                                @"240", @"GQ", @"241", @"GA", @"242", @"CG", @"243", @"CD", @"244", @"AO", @"245", @"GW", @"246", @"IO", @"247", @"AC", @"248", @"SC", @"249", @"SD",
                                @"250", @"RW", @"251", @"ET", @"252", @"SO", @"253", @"DJ", @"254", @"KE", @"255", @"TZ", @"256", @"UG", @"257", @"BI", @"258", @"MZ",
                                @"260", @"ZM", @"261", @"MG", @"262", @"RE", @"262", @"YT", @"263", @"ZW", @"264", @"NA", @"265", @"MW", @"266", @"LS", @"267", @"BW", @"268", @"SZ", @"269", @"KM",
                                @"290", @"SH", @"291", @"ER", @"297", @"AW", @"298", @"FO", @"299", @"GL",
                                @"350", @"GI", @"351", @"PT", @"352", @"LU", @"353", @"IE", @"354", @"IS", @"355", @"AL", @"356", @"MT", @"357", @"CY", @"358", @"FI", @"358", @"AX", @"359", @"BG",
                                @"370", @"LT", @"371", @"LV", @"372", @"EE", @"373", @"MD", @"374", @"AM", @"375", @"BY", @"376", @"AD", @"377", @"MC", @"378", @"SM", @"379", @"VA",
                                @"380", @"UA", @"381", @"RS", @"382", @"ME", @"385", @"HR", @"386", @"SI", @"387", @"BA", @"389", @"MK",
                                @"420", @"CZ", @"421", @"SK", @"423", @"LI",
                                @"500", @"FK", @"501", @"BZ", @"502", @"GT", @"503", @"SV", @"504", @"HN", @"505", @"NI", @"506", @"CR", @"507", @"PA", @"508", @"PM", @"509", @"HT",
                                @"590", @"GP", @"590", @"BL", @"590", @"MF", @"591", @"BO", @"592", @"GY", @"593", @"EC", @"594", @"GF", @"595", @"PY", @"596", @"MQ", @"597", @"SR", @"598", @"UY", @"599", @"CW", @"599", @"BQ",
                                @"670", @"TL", @"672", @"NF", @"673", @"BN", @"674", @"NR", @"675", @"PG", @"676", @"TO", @"677", @"SB", @"678", @"VU", @"679", @"FJ",
                                @"680", @"PW", @"681", @"WF", @"682", @"CK", @"683", @"NU", @"685", @"WS", @"686", @"KI", @"687", @"NC", @"688", @"TV", @"689", @"PF",
                                @"690", @"TK", @"691", @"FM", @"692", @"MH",
                                @"800", @"001", @"808", @"001",
                                @"850", @"KP", @"852", @"HK", @"853", @"MO", @"855", @"KH", @"856", @"LA",
                                @"870", @"001", @"878", @"001",
                                @"880", @"BD", @"881", @"001", @"882", @"001", @"883", @"001", @"886", @"TW", @"888", @"001",
                                @"960", @"MV", @"961", @"LB", @"962", @"JO", @"963", @"SY", @"964", @"IQ", @"965", @"KW", @"966", @"SA", @"967", @"YE", @"968", @"OM",
                                @"970", @"PS", @"971", @"AE", @"972", @"IL", @"973", @"BH", @"974", @"QA", @"975", @"BT", @"976", @"MN", @"977", @"NP", @"979", @"001",
                                @"992", @"TJ", @"993", @"TM", @"994", @"AZ", @"995", @"GE", @"996", @"KG", @"998", @"UZ",
                                nil];
}

+ (NSMutableArray*)alphabets
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:@"A"];
    [array addObject:@"B"];
    [array addObject:@"C"];
    [array addObject:@"D"];
    [array addObject:@"E"];
    [array addObject:@"F"];
    [array addObject:@"G"];
    [array addObject:@"H"];
    [array addObject:@"I"];
    [array addObject:@"J"];
    [array addObject:@"K"];
    [array addObject:@"L"];
    [array addObject:@"M"];
    [array addObject:@"N"];
    [array addObject:@"O"];
    [array addObject:@"P"];
    [array addObject:@"Q"];
    [array addObject:@"R"];
    [array addObject:@"S"];
    [array addObject:@"T"];
    [array addObject:@"U"];
    [array addObject:@"V"];
    [array addObject:@"W"];
    [array addObject:@"Y"];
    //[array addObject:@"X"];
    [array addObject:@"Z"];

    return array;
}

@end

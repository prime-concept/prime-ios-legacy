//
//  TaskIcons.m
//  PRIME
//
//  Created by Artak on 2/27/15.
//  Copyright (c) 2015 XNTrends. All rights reserved.
//

#import "TaskIcons.h"

@implementation TaskIcons

+ (NSString*)imageNameFromTaskTypeId:(NSInteger)taskTypeId
{
    NSInteger taskTypeGroupId = [self taskTypeGroupId_from_taskTypeId:taskTypeId];

    switch (taskTypeGroupId) {
    case 268435623:
        return @"aeroflot";
    case 72:
        return @"alcohol";
    case 68:
        return @"animals";
    case 268435562:
        return @"art";
    case 268435628:
        return @"task_avia";
    case 94:
        return @"beautysalons";
    case 83:
        return @"children";
    case 3:
        return @"cinemaIcon";
    case 4:
        return @"circus";
    case 268435591:
        return @"client";
    case 86:
        return @"congratulations";
    case 24:
        return @"delivery";
    case 60:
        return @"documentsupport";
    case 104:
        return @"education";
    case 88:
        return @"event_org";
    case 59:
        return @"financialsupport";
    case 268435595:
        return @"flowers_icon";
    case 20:
        return @"guided_tour";
    case 98:
        return @"health";
    case 268435593:
        return @"car";
    case 12:
        return @"task_hotel";
    case 76:
        return @"info_only";
    case 268435569:
        return @"insurance_request";
    case 61:
        return @"jurisprudencesupport";
    case 2:
        return @"music";
    case 55:
        return @"newsletter_or_events_list";
    case 5:
        return @"nightlife";
    case 27:
        return @"other";
    case 268435588:
        return @"partner";
    case 268435607:
        return @"pond";
    case 268435592:
        return @"design";
    case 268435573:
        return @"real_estate";
    case 9:
        return @"restaurant_and_clubs";
    case 268435602:
        return @"sales";
    case 13:
        return @"shopping&gifts";
    case 93:
        return @"spa";
    case 14:
        return @"sport";
    case 268435626:
        return @"staff";
    case 268435584:
        return @"swimming_pool";
    case 48:
        return @"tmobile";
    case 10:
        return @"theatre";
    case 268435603:
        return @"tickets";
    case 17:
        return @"train";
    case 51:
        return @"vip-lounge";
    case 91:
        return @"visa_or_passport";
    case 70:
        return @"jewelry";
    case 52:
        return @"yacht-rent";

    default:
        break;
    }
    return @"info_only";
}

+ (NSInteger)taskTypeGroupId_from_taskTypeId:(NSInteger)taskTypeId
{
    switch (taskTypeId) {

    // Aeroflot
    case 268435594:
    case 268435608:
    case 268435609:
    case 268435611:
    case 268435612:
    case 268435613:
    case 268435614:
    case 268435616:
    case 268435617:
    case 268435618:
    case 268435619:
    case 268435620:
    case 268435621:
    case 268435622:
    case 268435623:
        return 268435623;

    // Alcohol / wine / cigars
    case 72:
        return 72;

    // Animals
    case 68:
        return 68;

    // Art
    case 7:
    case 8:
    case 268435562:
        return 268435562;

    // Avia
    case 16:
    case 43:
    case 53:
    case 54:
    case 268435576:
    case 268435577:
    case 268435600:
    case 268435601:
    case 268435628:
        return 268435628;

    // Beauty Salons
    case 94:
        return 94;

    // Children
    case 83:
        return 83;

    // Cinema
    case 3:
        return 3;

    // Circus
    case 4:
        return 4;

    // Client
    case 89:
    case 268435585:
    case 268435586:
    case 268435589:
    case 268435590:
    case 268435591:
        return 268435591;

    // Congratulations
    case 86:
        return 86;

    // Delivery
    case 24:
        return 24;

    // Document support
    case 60:
        return 60;

    // Education
    case 100:
    case 101:
    case 102:
    case 103:
    case 104:
        return 104;

    // Event org
    case 31:
    case 62:
    case 77:
    case 78:
    case 79:
    case 80:
    case 88:
        return 88;

    // Financial support
    case 59:
        return 59;

    // Flowers
    case 268435595:
        return 268435595;

    // Guided Tour
    case 20:
        return 20;

    // Health
    case 95:
    case 96:
    case 97:
    case 98:
        return 98;

    // Hire/Rental
    case 30:
    case 90:
    case 268435593:
        return 268435593;

    // Hotel
    case 12:
        return 12;

    // Info only
    case 22:
    case 64:
    case 67:
    case 69:
    case 73:
    case 74:
    case 76:
        return 76;

    //  Insurance
    case 18:
    case 268435569:
        return 268435569;

    // Jurisprudence support
    case 61:
        return 61;

    // Music
    case 2:
        return 2;

    // Newsletter/Events list
    case 55:
        return 55;

    // Nightlife
    case 5:
        return 5;

    // Other
    case 15:
    case 27:
        return 27;

    // Partner
    case 268435587:
    case 268435588:
        return 268435588;

    // Pond
    case 268435607:
        return 268435607;

    // PRIME Design
    case 268435592:
        return 268435592;

    // Real estate
    case 26:
    case 44:
    case 65:
    case 268435573:
        return 268435573;

    // Restaurant & Clubs
    case 9:
        return 9;

    // Sales
    case 63:
    case 268435561:
    case 268435563:
    case 268435602:
        return 268435602;

    // Shopping & Gifts
    case 13:
        return 13;

    // Spa
    case 93:
        return 93;

    // Sport
    case 14:
        return 14;

    // Staff
    case 47:
    case 268435626:
        return 268435626;

    // Swimming pool
    case 268435584:
        return 268435584;

    // T-mobile
    case 42:
    case 48:
    case 268435606:
        return 48;

    // Theatre
    case 10:
        return 10;

    // Tickets
    case 1:
    case 6:
    case 11:
    case 49:
    case 268435567:
    case 268435603:
        return 268435603;

    // Train
    case 17:
        return 17;

    // Vip lounge & fast track
    case 51:
        return 51;

    //  Visa/passport
    case 19:
    case 91:
        return 91;

    // Watch/jewelry
    case 70:
        return 70;

    // Yacht rent
    case 52:
        return 52;

    default:
        break;
    }

    // Info only
    return 76;
}

@end

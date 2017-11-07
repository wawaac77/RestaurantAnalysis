//
//  EventRestaurant.h
//  GFBS
//
//  Created by Alice Jin on 5/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwEn.h"
#import "MyEventImageModel.h"
#import "ZZTypicalInformationModel.h"

@class MyEventImageModel;
@class TwEn;
@class ZZTypicalInformationModel;

@interface EventRestaurant : NSObject


/****** selectively used by eventRestaurant Page *****/
@property (nonatomic, copy) NSString *restaurantId;
@property (nonatomic, strong) NSMutableArray<NSString *> *phone;
@property (nonatomic, strong) MyEventImageModel *restaurantBanner;
@property (nonatomic, strong) MyEventImageModel *restaurantIcon;
//@property (nonatomic, strong) TwEn *restaurantAddress;
//@property (nonatomic, strong) TwEn *restaurantName;

@property (nonatomic, strong) NSString *restaurantAddress;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, copy) NSString *operationHour;
@property (nonatomic, copy) NSString *features;
@property (nonatomic, strong) NSNumber *seats;
@property (nonatomic, strong) NSString *overview;


/****** for restaurant list page *****/
@property (nonatomic, strong) NSNumber *restaurantDistance;
@property (nonatomic, copy) NSNumber *rating;
@property (nonatomic, strong) ZZTypicalInformationModel *restaurantDistrict;
@property (nonatomic, strong) NSMutableArray <ZZTypicalInformationModel *> *restaurantCuisines;
@property (nonatomic, strong) NSMutableArray <ZZTypicalInformationModel *> *paymentMethod;
@property (nonatomic, strong) ZZTypicalInformationModel *costPerPerson;
@property (nonatomic, assign) NSNumber *restaurantMinPrice;
@property (nonatomic, assign) NSNumber *restaurantMaxPrice;
@property (nonatomic, strong) NSMutableArray <MyEventImageModel*> *restaurantImages;
@property (nonatomic, strong) NSMutableArray <MyEventImageModel*> *menuImages;

/****** parameters in setting *****/
@property (nonatomic, strong) NSNumber *displayYourRatings;
@property (nonatomic, strong) NSNumber *displayPopularTimes;
@property (nonatomic, strong) NSNumber *displayTopInterest;
@property (nonatomic, strong) NSNumber *displayGender;
@property (nonatomic, strong) NSNumber *displayAgeGroup;
@property (nonatomic, strong) NSNumber *displayCompetitiveInsights;

//****** others *****/
@property (nonatomic, strong) NSNumber *notificationNum;
@property (nonatomic, strong) NSMutableArray *allowArray;


@end

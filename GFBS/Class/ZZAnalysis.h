//
//  ZZAnalysis.h
//  GFBS
//
//  Created by Alice Jin on 21/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZRatingModel.h"
#import "ZZPopularTimeModel.h"
#import "ZZTopInterestModel.h"
#import "ZZReturnCustomerModel.h"
#import "ZZCustomerTier.h"
#import "ZZCustomerGenderModel.h"
#import "ZZCustomerAgeModel.h"
#import "ZZInsightSummary.h"

@interface ZZAnalysis : NSObject

@property (nonatomic, strong) NSString *restaurantAppMessage;

@property (nonatomic, strong) NSNumber *pendingBookingCount;

@property (nonatomic, strong) ZZRatingModel *restaurantRating;

@property (nonatomic, strong) NSMutableArray<ZZPopularTimeModel *> *restaurantPopularTime;

@property (nonatomic, strong) NSMutableArray<ZZTopInterestModel *>  *restaurantTopInterest;

@property (nonatomic, strong) ZZReturnCustomerModel *restaurantReturnCustomer;

@property (nonatomic, strong) ZZCustomerTier *restaurantCustomerTier;

@property (nonatomic, strong) ZZCustomerGenderModel *restaurantCustomerGender;

@property (nonatomic, strong) ZZCustomerAgeModel *restaurantCustomerAge;

@property (nonatomic, strong) ZZInsightSummary *insightSummary;

@end


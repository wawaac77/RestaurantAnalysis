//
//  ZZLeaderboardModel.h
//  GFBS
//
//  Created by Alice Jin on 10/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventRestaurant.h"


typedef NS_ENUM(NSInteger , InsightContentType){
    
    CuisineInsights = 0,
    
    LocationInsights = 1,
    
};


@interface ZZLeaderboardModel : NSObject

@property (nonatomic, strong) EventRestaurant *restaurant;
@property (nonatomic, strong) NSNumber *rank;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *rankChange;
@property (nonatomic, strong) NSNumber *reviewCount;

/** 帖子类型 */
@property (nonatomic, assign) InsightContentType type;


@end

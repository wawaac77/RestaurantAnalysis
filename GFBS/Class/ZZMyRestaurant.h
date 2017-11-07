//
//  ZZMyRestaurant.h
//  GFBS
//
//  Created by Alice Jin on 18/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventRestaurant.h"
#import "ZZUser.h"

@interface ZZMyRestaurant : NSObject

@property (nonatomic, strong) EventRestaurant *myRestaurant;
@property (nonatomic, strong) ZZUser *myUser;

//******  获取单例 *****/
+ (instancetype)shareRestaurant;

@end

//
//  ZZMyRestaurant.m
//  GFBS
//
//  Created by Alice Jin on 18/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZZMyRestaurant.h"

@implementation ZZMyRestaurant

+ (instancetype)shareRestaurant{
    static id  instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end

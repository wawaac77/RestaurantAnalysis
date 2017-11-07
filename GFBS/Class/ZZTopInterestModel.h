//
//  ZZTopInterestModel.h
//  GFBS
//
//  Created by Alice Jin on 21/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZInterest.h"

@interface ZZTopInterestModel : NSObject

@property(nonatomic, strong) NSNumber *rank;

@property(nonatomic, strong) ZZInterest *interest;

@property(nonatomic, strong) NSNumber *count;
@property(nonatomic, strong) NSNumber *countChange;


@end
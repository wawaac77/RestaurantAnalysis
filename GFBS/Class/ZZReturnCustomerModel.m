//
//  ZZReturnCustomerModel.m
//  GFBS
//
//  Created by Alice Jin on 21/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZZReturnCustomerModel.h"

@implementation ZZReturnCustomerModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    
    return @{
            
             @"freshCustomer" : @"newCustomer",
             
             };
}

@end

//
//  ZZCustomerTier.h
//  GFBS
//
//  Created by Alice Jin on 21/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZCustomerTier : NSObject

@property(nonatomic, strong) NSMutableArray <NSNumber *> *attendeeData;

@property(nonatomic, strong) NSMutableArray <NSNumber *> *hostData;

//others
@property(nonatomic, strong) NSNumber *current;
//0 is attendee; 1 is host

@end

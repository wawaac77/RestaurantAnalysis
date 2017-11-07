//
//  ZRBookingModel.h
//  GFBS
//
//  Created by Alice Jin on 7/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , bookingType){
    
    pendingBooking = 0,
    
    historyBooking = 1,
    
    comingBooking = 2,
    
};

@interface ZRBookingModel : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *bookingDate;
@property (nonatomic, copy) NSNumber *numOfPeople;
@property (nonatomic, copy) NSString *status;

/** booking类型 */
@property (nonatomic, assign) bookingType type;

@end

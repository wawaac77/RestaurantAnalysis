//
//  ZRBookingModel.m
//  GFBS
//
//  Created by Alice Jin on 7/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZRBookingModel.h"
#import "ZBLocalized.h"

@implementation ZRBookingModel

/*全局变量 */
static NSDateFormatter *fmt_;
static NSDateFormatter *outputFmt_;
static NSCalendar *calendar_;
static NSTimeZone *inputTimeZone_;
static NSTimeZone *outputTimeZone_;

/**
 只调用一次
 */
+(void)initialize
{
    fmt_ = [[NSDateFormatter alloc] init];
    outputFmt_ = [[NSDateFormatter alloc] init];
    calendar_ = [NSCalendar gf_calendar];
    inputTimeZone_ = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    outputTimeZone_ = [NSTimeZone localTimeZone];
    
    [fmt_ setTimeZone:inputTimeZone_];
    [outputFmt_ setTimeZone:outputTimeZone_];
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
         fmt_.locale = [NSLocale localeWithLocaleIdentifier:@"zh-Hant"];
         outputFmt_.locale = [NSLocale localeWithLocaleIdentifier:@"zh-Hant"];
    }
    
   
}


- (NSString *)bookingDate {
    //将服务器返回的数据进行处理
    fmt_.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    
    NSDate *creatAtDate = [fmt_ dateFromString:_bookingDate];
    //NSLog(@"_listEventUpdatedAt in content%@", _listEventUpdatedAt);
    //NSLog(@"createAtDate NSDate in content %@", creatAtDate);
    //判断
    
    if (creatAtDate.isThisYear) {//今年
        if ([calendar_ isDateInToday:creatAtDate]) {//今天
            //当前时间
            NSDate *nowDate = [NSDate date];
            
            NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *comps = [calendar_ components:unit fromDate:creatAtDate toDate:nowDate options:0];
            
            if (comps.hour >= 1) {
                return [NSString stringWithFormat:@"%zd %@",comps.hour, ZBLocalized(HourAgoStr, nil)];
            }else if (comps.minute >= 1){
                return [NSString stringWithFormat:@"%zd %@",comps.minute, ZBLocalized(MinAgoStr, nil)];
            }else
            {
                return ZBLocalized(JustNowStr, nil);
            }
         /*   
        }
        
        else if ([calendar_ isDateInYesterday:creatAtDate]){//昨天
            outputFmt_.dateFormat = @" HH:mm", ZBLocalized(YesterdayStr, nil);
            return [outputFmt_ stringFromDate:creatAtDate];
         */
            
        }else{//其他
            outputFmt_.dateFormat = @"MMM dd, HH:mm";
            return [outputFmt_ stringFromDate:creatAtDate];
            
        }
        
    }else{//非今年
        outputFmt_.dateFormat = @"MMM dd yyyy";
        return [outputFmt_ stringFromDate:creatAtDate];
    }
    
    //fmt_.doesRelativeDateFormatting = YES;
    return _bookingDate;

    
}

@end

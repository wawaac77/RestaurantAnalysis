//
//  ZZPopularTimeModel.h
//  GFBS
//
//  Created by Alice Jin on 21/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZPopularTimeModel : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *peak;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *data;


//others
@property(nonatomic, strong) NSNumber *current;
//0 is Mon-Thu; 1 is Fri-Sun

@end

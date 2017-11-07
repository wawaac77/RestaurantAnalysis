//
//  SubFillTableViewController.h
//  GFBS
//
//  Created by Alice Jin on 14/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventRestaurant.h"

@protocol FillinChildViewControllerDelegate;

@interface SubFillTableViewController : UITableViewController

@property (weak)id <FillinChildViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *tableType;
@property(nonatomic ,strong) EventRestaurant *thisRestaurant;

@end

@protocol FillinChildViewControllerDelegate <NSObject >

- (void) passValue:(EventRestaurant *) theValue;

@end

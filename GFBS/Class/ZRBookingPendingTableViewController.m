//
//  ZRBookingPendingTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 31/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZRBookingPendingTableViewController.h"

@interface ZRBookingPendingTableViewController ()

@end

@implementation ZRBookingPendingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(bookingType)type
{
    return pendingBooking;
}

@end

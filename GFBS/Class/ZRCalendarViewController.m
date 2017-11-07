//
//  ZRCalendarViewController.m
//  GFBS
//
//  Created by Alice Jin on 8/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZRCalendarViewController.h"
#import "NotificationViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "ZBLocalized.h"
#import "ZZMyRestaurant.h"

@interface ZRCalendarViewController ()

@end

@implementation ZRCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bookingType)type
{
    return comingBooking;
}

#pragma mark - 设置导航条
-(void)setUpNavBar
{
    //右边
    UIBarButtonItem *notificationBtn = [UIBarButtonItem ItemWithImage:[UIImage imageNamed:@"ic_fa-bell-o"] WithHighlighted:[UIImage imageNamed:@"ic_fa-bell-o"] Target:self action:@selector(notificationClicked)];
    
    notificationBtn.badgeValue = [NSString stringWithFormat:@"%@", [ZZMyRestaurant shareRestaurant].myRestaurant.notificationNum];
    
    self.navigationItem.rightBarButtonItem = notificationBtn;
    
    self.navigationItem.title = ZBLocalized(@"Calendar", nil);
    
}

//*********************** Button Clicked ************************//
#pragma -Button Clicked
- (void)notificationClicked
{
    NotificationViewController *notificationVC = [[NotificationViewController alloc] init];
    [self.navigationController pushViewController:notificationVC animated:YES];
}

@end

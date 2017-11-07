//
//  AppDelegate.h
//  GFBS
//
//  Created by apple on 16/11/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZUser.h"
#import "EventRestaurant.h"
#import "Crashlytics/Crashlytics.h"

#import <Google/SignIn.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <Firebase.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ZZUser *user;
@property (strong, nonatomic) EventRestaurant *restaurant;

+ (AppDelegate *) APP;


@end


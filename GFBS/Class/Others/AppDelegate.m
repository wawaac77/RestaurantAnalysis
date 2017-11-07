//
//  AppDelegate.m
//  GFBS
//
//  Created by apple on 16/11/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZZMyRestaurant.h"
#import "ZBLocalized.h"
#import <SDImageCache.h>
#import "GFTabBarController.h"
#import "GFAdViewController.h"
#import "LoginViewController.h"
#import "DHGuidePageHUD.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize user;
@synthesize restaurant;

+ (AppDelegate *) APP {
    return  (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefault objectForKey:@"KEY_USER_NAME"];
    NSString *userToken = [userDefault objectForKey:@"KEY_USER_TOKEN"];
    NSString *userlang = [userDefault objectForKey:@"KEY_USER_LANG"];
    NSString *myRestaurantId = [userDefault objectForKey:@"KEY_RESTAURANT_ID"];
    
    if (userlang == NULL) {
        [userDefault setObject:@"en" forKey:@"KEY_USER_LANG"];
    }
    
    [userDefault synchronize];

    //[[InternationalControl sharedInstance]
    
    if (userToken != NULL && userToken != nil) {
        
        ///UIWindow *window = [UIApplication sharedApplication].keyWindow;
        //window.rootViewController = [[GFTabBarController alloc]init];
        
        user = [[ZZUser alloc] init];
        user.userToken = userToken;
        user.userUserName = username;
        user.preferredLanguage = userlang;
        user.myRestaurantId = myRestaurantId;
        
        [ZZUser shareUser].userToken = userToken;
        [ZZUser shareUser].userUserName = username;
        [ZZUser shareUser].preferredLanguage = userlang;
        [ZZUser shareUser].myRestaurantId = myRestaurantId;
        
        NSLog(@"[ZZUser shareUser].userToken %@", [ZZUser shareUser].userToken);
        
        
        [ZZMyRestaurant shareRestaurant].myUser = user;
        [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantId = myRestaurantId;

        
        
        NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.restaurantId %@", [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantId);
        NSLog(@"[ZZMyRestaurant shareRestaurant].myUser %@", [ZZMyRestaurant shareRestaurant].myUser.userUserName);

        
        //初始化语言
        if ([userlang isEqualToString:@"en"]) {
            [[ZBLocalized sharedInstance]setLanguage:@"en"];
        } else if ([userlang isEqualToString:@"tw"]) {
            [[ZBLocalized sharedInstance]setLanguage:@"zh-Hant"];
        } else {
            [[ZBLocalized sharedInstance]initLanguage];
        }
        
        GFTabBarController *tabVC = [[GFTabBarController alloc] init];
        self.window.rootViewController = tabVC;
        
        [self.window makeKeyAndVisible];
        NSLog(@"userToken in default user %@", userToken);
        NSLog(@"userLang in default user %@", user.preferredLanguage);
        
        return YES;
    }
    
    //广告控制器
    //GFAdViewController *adVC = [[GFAdViewController alloc]init];
    
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    self.window.rootViewController = loginVC;

    [self.window makeKeyAndVisible];
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:BOOLFORKEY]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOLFORKEY];
    }
    
    //guide pages
    NSArray *imageNameArray = @[@"tutorial-1242x2208-1.jpg",@"tutorial-1242x2208-2.jpg",@"tutorial-1242x2208-3.jpg"];
    DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.window.frame imageNameArray:imageNameArray buttonIsHidden:YES];
    [self.window addSubview:guidePage];
    
    //清除过期缓存
    [[SDImageCache sharedImageCache] cleanDisk];
    
    [GFTopWindow gf_show];
    [FIRApp configure];
    
    /******** Google+ signin *********/
    /*
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
     */
    
    //[GIDSignIn sharedInstance].clientID = @"YOUR_CLIENT_ID";
    [GIDSignIn sharedInstance].delegate = self;
    
    /******** Facebook signin *********/
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //清除过期缓存
    [[SDImageCache sharedImageCache] cleanDisk];
    
    [GFTopWindow gf_show];
    //[FIRApp configure];
    
    return YES;
}

/************************* Facebook ************************/

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [FBSDKAppEvents activateApp];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    /************************* Facebook ************************/
    NSLog(@"application openURL");
    if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation]) {
        return YES;
    }
    
    /************************* Google+ ************************/
    else if ([[GIDSignIn sharedInstance] handleURL:url
                                 sourceApplication:sourceApplication
                                        annotation:annotation]) {
        return YES;
    }
    
    return NO;
}

/************************* Google+ ************************/
// [START signin_handler]
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
    NSString *givenName = user.profile.givenName;
    NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    // [START_EXCLUDE]
    NSDictionary *statusText = @{@"statusText":
                                     [NSString stringWithFormat:@"Signed in user: %@",
                                      fullName]};
    
    NSLog(@"UserName in GooglePlus %@",fullName);
    NSLog(@"UserId in GooglePlus %@",userId);
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ToggleAuthUINotification"
     object:nil
     userInfo:statusText];
    // [END_EXCLUDE]
    
    [ZZMyRestaurant shareRestaurant].myUser.userGoogleID = userId;
    
    //From integrations demo
    [[NSUserDefaults standardUserDefaults] setObject:fullName forKey:@"googlePlusLogin"];
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"googlePlusUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ForceUpdateLocation" object:self userInfo:[NSDictionary dictionaryWithObject:fullName?:@"" forKey:@"full_name"]];

}
// [END signin_handler]

// This callback is triggered after the disconnect call that revokes data
// access to the user's resources has completed.
// [START disconnect_handler]
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // [START_EXCLUDE]
    NSDictionary *statusText = @{@"statusText": @"Disconnected user" };
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ToggleAuthUINotification"
     object:nil
     userInfo:statusText];
    // [END_EXCLUDE]
}
// [END disconnect_handler]

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

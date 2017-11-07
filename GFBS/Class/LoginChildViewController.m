//
//  LoginChildViewController.m
//  GFBS
//
//  Created by Alice Jin on 26/5/2017.
//  Copyright © 2017 apple. All rights reserved.
//
#import "AppDelegate.h"
#import "LoginChildViewController.h"
#import "GFTabBarController.h"
#import "GFNavigationController.h"
#import "ForgetPasswordViewController.h"

#import "ZZMyRestaurant.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginChildViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *loginWithGoogleButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)forgetPasswordClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginUsingFirebaseButton;
- (IBAction)loginUsingFirebaseClicked:(id)sender;

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;
@property (strong , nonatomic)EventRestaurant *myRestaurant;

@end

@implementation LoginChildViewController

#pragma mark - 懒加载
-(GFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [GFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    
    //keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //layout
    [self setupLayout];
    
    //google
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveToggleAuthUINotification:)
     name:@"ToggleAuthUINotification"
     object:nil];
    
    [self toggleAuthUI];

}

-(void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)setupLayout {
    _loginWithFacebookButton.layer.cornerRadius = 5.0f;
    _loginWithFacebookButton.layer.masksToBounds = YES;
    _loginWithFacebookButton.backgroundColor = [UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1];
    [_loginWithFacebookButton addTarget:self action:@selector(loginFBButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    
    _loginWithGoogleButton.layer.cornerRadius = 5.0f;
    [_loginWithGoogleButton setClipsToBounds:YES];
    _loginWithGoogleButton.backgroundColor = [UIColor colorWithRed:211.0/255.0 green:72.0/255.0 blue:54.0/255.0 alpha:1];
    
    _passwordTextField.secureTextEntry = YES;
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSString *nameOfLoginUser = [result valueForKey:@"name"];
                NSString *idOfLoginUser = [result valueForKey:@"id"];
                
                NSLog(@"facebook public_profile nameOfLoginUser %@", nameOfLoginUser);
                NSLog(@"facebook id nameOfLoginUser %@", idOfLoginUser);
                
                NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                //NSURL *url = [[NSURL alloc] initWithURL: imageStringOfLoginUser];
                //[self.imageView setImageWithURL:url placeholderImage: nil];
            }
        }];
        
    }

    
    /*
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
     */
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)nextButtonClicked:(id)sender {
    
    NSLog(@"next > button clicked");
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //window.rootViewController = [[GFTabBarController alloc]init];
    
    //取消请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    NSString *email = _emailTextField.text;
    NSString *password = _passwordTextField.text;
    if (email.length == 0) {
        _emailTextField.text = @"alicej@gmail.com";
        _passwordTextField.text =@"123456";

    }
    
    NSDictionary *emailAndPassword = @ {@"email" : email, @"password" : password};
    NSDictionary *inData = @{
                             @"action" : @"login",
                             @"data" : emailAndPassword};
    NSDictionary *parameters = @{@"data" : inData};

    NSLog(@"upcoming events parameters %@", parameters);
    
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        ZZUser *thisUser = [[ZZUser alloc] init];
        thisUser = [ZZUser mj_objectWithKeyValues:data[@"data"]];
        //thisUser = [ZZUser mj_objectWithKeyValues:responseObject];
        
        
        if (thisUser == nil) {
            
            [SVProgressHUD showWithStatus:@"Incorrect Email or password ><"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        } else {
            
            [AppDelegate APP].user = [[ZZUser alloc] init];
            [AppDelegate APP].user = thisUser;
            
            NSLog(@"user token = %@", thisUser.userToken);
            
            //*************** defualt user set even app is turned off *********//
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:thisUser.userUserName forKey:@"KEY_USER_NAME"];
            [userDefaults setObject:thisUser.userToken forKey:@"KEY_USER_TOKEN"];
            
            if (thisUser.preferredLanguage == NULL || thisUser.preferredLanguage == nil) {
                thisUser.preferredLanguage = @"en";
            }
            
            [userDefaults setObject:thisUser.preferredLanguage forKey:@"KEY_USER_LANG"];
            
            [userDefaults synchronize];
            
            NSLog(@"this user %@", thisUser);
            NSLog(@"this user. userName %@", thisUser.usertName);
            NSLog(@"this user. memberId %@", thisUser.userID);
            [self getMyRestaurant];
            
            //***************  user in instancetype *********//
            [ZZMyRestaurant shareRestaurant].myUser = thisUser;
            
            /*
             [[FIRAuth auth]signInWithEmail:self.emailTextField.text
             password:self.passwordTextField.text
             completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
             if (error) {
             NSLog(@"%@", [error localizedDescription]);
             
             [SVProgressHUD showWithStatus:@"Busy network, please try later"];
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [SVProgressHUD dismiss];
             });
             
             
             }
             else{
             
             [AppDelegate APP].user = [[ZZUser alloc] init];
             [AppDelegate APP].user = thisUser;
             
             NSLog(@"user token = %@", thisUser.userToken);
             
             UIWindow *window = [UIApplication sharedApplication].keyWindow;
             window.rootViewController = [[GFTabBarController alloc]init];
             }
             }];
             */
        }
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    

}

- (void)getMyRestaurant {
    
    //取消请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    NSDictionary *inData = @{
                             @"action" : @"getMyRestaurant",
                             @"token" : userToken,
                             @"lang" : userLang,
                             };
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        EventRestaurant *response = data[@"data"];
        NSLog(@"response in restaurant %@", response);
        _myRestaurant = [EventRestaurant mj_objectWithKeyValues:response];
        
        //*************** defualt user set even app is turned off *********//
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:_myRestaurant.restaurantId forKey:@"KEY_RESTAURANT_ID"];
        [userDefaults synchronize];
        
        [AppDelegate APP].user.myRestaurantId = _myRestaurant.restaurantId;
        [AppDelegate APP].user.myRestaurantName = _myRestaurant.restaurantName;
        
        NSLog(@"this restaurant. Id %@", _myRestaurant.restaurantId);
        
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.rootViewController = [[GFTabBarController alloc]init];
        [window makeKeyWindow];
        
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
}

- (IBAction)forgetPasswordClicked:(id)sender {
    
    ForgetPasswordViewController *forgetVC = [[ForgetPasswordViewController alloc] init];
    forgetVC.view.frame = [UIScreen mainScreen].bounds;
    [self presentViewController:forgetVC animated:YES completion:nil];
    
}
- (IBAction)loginUsingFirebaseClicked:(id)sender {
    
}

#pragma mark - 监听键盘的弹出和隐藏
/*
- (void)keyBoardWillChageFrame:(NSNotification *)note
{
    //键盘最终的Frame
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //动画
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - GFScreenHeight);
    }];
    NSLog(@"KeyboardFrame.origin.y %f", keyBoadrFrame.origin.y);
    
}
 */

- (void)keyBoardWillHide:(NSNotification *)note
{
    //键盘最终的Frame
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //动画
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, - keyBoadrFrame.origin.y + GFScreenHeight);
    }];
    NSLog(@"KeyboardFrame.origin.y %f", keyBoadrFrame.origin.y);
}

- (void)keyBoardWillShow: (NSNotification *)note
{
    //键盘最终的Frame
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //动画
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - GFScreenHeight + 50);
    }];
    NSLog(@"KeyboardFrame.origin.y %f", keyBoadrFrame.origin.y);
    
}

/*
#pragma mark - 键盘弹出和退出
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 先退出之前的键盘
    [self.view endEditing:YES];
    // 再叫出键盘
    [self.emailTextField becomeFirstResponder];
}
 */

//************************login with Facebook *******************************//
- (void)loginFBButtonClicked {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             NSLog(@"facebookToken %@", result.token);
             
             /*
              NSString *nameOfLoginUser = [result valueForKey:@"name"];
              NSLog(@"facebook public_profile nameOfLoginUser %@", nameOfLoginUser);
              
              NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
              //NSURL *url = [[NSURL alloc] initWithURL: imageStringOfLoginUser];
              //[self.imageView setImageWithURL:url placeholderImage: nil];
              
              //NSLog(@"facebookId %@", result.);
              */
         }
     }];
}

#pragma mark - Google
//************************* Google signin **************************//

- (void)loginWithGoogleClicked {
    [[GIDSignIn sharedInstance] signIn];
    //self.googlePlusLogoutButtonInstance.enabled=YES;
    
}

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
    // ...
}

// Implement these methods only if the GIDSignInUIDelegate is not a subclass of
// UIViewController.

// Stop the UIActivityIndicatorView animation that was started when the user
// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    //[myActivityIndicator stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleAuthUI {
    if ([GIDSignIn sharedInstance].currentUser.authentication == nil) {
        // Not signed in
        //self.statusText.text = @"Google Sign in\niOS Demo";
        //self.signInButton.hidden = NO;
        //self.signOutButton.hidden = YES;
        //self.disconnectButton.hidden = YES;
    } else {
        // Signed in
        //self.signInButton.hidden = YES;
        //self.signOutButton.hidden = NO;
        //self.disconnectButton.hidden = NO;
    }
}

- (IBAction)didTapSignOut:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
}


@end

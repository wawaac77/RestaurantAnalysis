//
//  GFSettingViewController.m
//  高仿百思不得不得姐
//
//  Created by apple on 16/11/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "AppDelegate.h"
//#import "InternationalControl.h"

#import "GFTabBarController.h"
#import "ZBLocalized.h"
#import "GFSettingViewController.h"
#import "ZZUser.h"
#import "ZZTypicalInformationModel.h"
#import "ZZMyRestaurant.h"

#import "AboutZZViewController.h"
#import "ZZMessageAdminViewController.h"
#import "LoginViewController.h"
#import "ForgetPasswordViewController.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SDImageCache.h>
#import <UIImageView+WebCache.h>    
#import <SVProgressHUD.h>
#import "UILabel+LabelHeightAndWidth.h"

@interface GFSettingViewController () <UIAlertViewDelegate> 

//@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
//@property (weak, nonatomic) NSString *priceRange;

@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@property (strong, nonatomic) NSMutableArray<NSString *> *reuseIDArray;
@property (strong , nonatomic)GFHTTPSessionManager *manager;
@property (strong, nonatomic) ZZUser *thisUser;
@property (strong, nonatomic) EventRestaurant *thisRestaurant;

@property (strong, nonatomic) NSMutableArray<ZZTypicalInformationModel *> *industryArray;
@property (strong, nonatomic) NSMutableArray<ZZTypicalInformationModel *> *professionArray;
@property (strong, nonatomic) NSMutableArray<ZZTypicalInformationModel *> *interestsArray;

@property (strong, nonatomic) NSMutableArray<NSString *> *industry;
@property (strong, nonatomic) NSMutableArray<NSString *> *profession;
@property (strong, nonatomic) NSMutableArray<NSString *> *interests;

@property (strong, nonatomic) NSMutableArray<NSString *> *selectedPickerArray;

@property (strong, nonatomic) ZZTypicalInformationModel *selectedItem;

@property (strong, nonatomic) NSBundle *bundle;


@end

@implementation GFSettingViewController

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
    NSLog(@"changeLanguage viewDidLoad");
    //[self loadNewData];
    self.navigationItem.title = ZBLocalized(@"Settings", nil);
    //_thisUser = [AppDelegate APP].user;
    _thisUser = [ZZMyRestaurant shareRestaurant].myUser;
    _thisRestaurant = [[EventRestaurant alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguageInVC) name:@"changeLanguageInVC" object:nil];
    
    //[InternationalControl initUserLanguage];//初始化应用语言
    
    //NSBundle *bundle = [InternationalControl bundle];
    //self.bundle = bundle;
    
    
    //计算整个应用程序的缓存数据 --- > 沙盒（Cache）
    //NSFileManager
    //attributesOfItemAtPathe:指定文件路径，获取文件属性
    //把所有文件尺寸加起来    //获取缓存尺寸字符串赋值给cell的textLabel
    //[self registerCell];
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerView)];
    
    //[self.view addGestureRecognizer:tap];

    [self setUpReuseIDArray];
    
    NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.restaurantName in setting %@", [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantName);
    NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayGender in setting %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayGender);
    NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup in setting %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup);
  
}

- (void)dismissPickerView {
    [self.picker resignFirstResponder];
}

- (void)setUpPickerView {
    //_industryArray = [[NSMutableArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E", nil];
    _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 400, GFScreenWidth, 150)];
    _picker.dataSource = self;
    _picker.delegate = self;
    _picker.backgroundColor = [UIColor lightGrayColor];
}

- (void)setUpReuseIDArray {
    _reuseIDArray = [[NSMutableArray alloc] init];
    
    [_reuseIDArray insertObject:@"account" atIndex:0];
    [_reuseIDArray insertObject:@"basic" atIndex:1];

    for (int i = 2; i < 5; i++) {
        [_reuseIDArray insertObject:@"accessory" atIndex:i];
        NSLog(@"i = %zd", i);
    }
    
    [_reuseIDArray insertObject:@"indicator" atIndex:5];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return ZBLocalized(@"Your Account", nil);
    } else if (section == 1) {
        return ZBLocalized(@"Dashboard", nil);
    } else if (section == 2) {
        //return ZBLocalized(@"Visibility", nil);
    }
    
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 5;
    }
    return 30;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [UIColor darkGrayColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
    // Background color
    view.tintColor = [UIColor groupTableViewBackgroundColor];
    //CGRect headerFrame = header.frame;
    //header.textLabel.frame = headerFrame;
    //header.textLabel.textAlignment = NSTextAlignmentCenter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    NSString *cellID = _reuseIDArray[indexPath.section];
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        cellID = @"buttons";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSLog(@"cellID --- %@", cellID);
    
    if (cell == nil) {
        switch (indexPath.section) {
            case 0:{
                if (indexPath.row == 2) {
                    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellID];
                    cell.textLabel.font = [UIFont systemFontOfSize:15];
                } else {
                    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellID];
                    cell.textLabel.font = [UIFont systemFontOfSize:15];
                }
                break;
            }
                
               
            /*
            case 1:
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:cellID];
                break;
             */
                
            // section 1 & 2 can use same cellID
            default:
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:cellID];
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                break;
        }
    }

    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = [AppDelegate APP].user.myRestaurantName;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
            
            UILabel *accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(GFScreenWidth - 100, 10, 90, 30)];
            accessoryLabel.textAlignment = NSTextAlignmentRight;
            accessoryLabel.font = [UIFont systemFontOfSize:15];
            accessoryLabel.text = ZBLocalized(@"Log Out >", nil);
            [cell.contentView addSubview:accessoryLabel];
            
        } else if (indexPath.row == 1) {
            
            cell.textLabel.text = ZBLocalized(@"Change Password", nil);
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
        } else if (indexPath.row == 2) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
            [label setFont:[UIFont systemFontOfSize:15]];
            label.text = @"Language";
            [cell.contentView addSubview:label];
            
            CGFloat btnWidth = (GFScreenWidth - 20 - 10) / 2;
            
            UIButton *enButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, btnWidth, 30)];
            [enButton addTarget:self action:@selector(enButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [enButton setTitle:@"English" forState:UIControlStateNormal];
            [enButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            enButton.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
            enButton.layer.cornerRadius = 5.0f;
            enButton.layer.masksToBounds = YES;
            
            UIButton *twButton = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth + 20, 30, btnWidth, 30)];
            [twButton addTarget:self action:@selector(twButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [twButton setTitle:@"中文" forState:UIControlStateNormal];
            [twButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            twButton.backgroundColor = [UIColor grayColor];
            twButton.layer.cornerRadius = 5.0f;
            twButton.layer.masksToBounds = YES;

            [cell.contentView addSubview:enButton];
            [cell.contentView addSubview:twButton];
        }
    }
    
    else if (indexPath.section == 1) {
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = ZBLocalized( @"Your Ratings", nil);
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            
            cell.accessoryView = switchView;
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings);
            
            if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            switchView.tag = indexPath.row + 10 * indexPath.section;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = ZBLocalized( @"Popular Times", nil);
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            switchView.tag = indexPath.row + 10 * indexPath.section;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

            
            if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayPopularTimes isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = ZBLocalized( @"Top Interest", nil);
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            switchView.tag = indexPath.row + 10 * indexPath.section;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            
            if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = ZBLocalized( @"Gender", nil);
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            switchView.tag = indexPath.row + 10 * indexPath.section;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            
            if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayGender isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = ZBLocalized( @"Age Group", nil);
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            switchView.tag = indexPath.row + 10 * indexPath.section;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
                NSLog(@"switch set to ON");
            } else {
                [switchView setOn:NO animated:NO];
                NSLog(@"switch set to OFF");
            }
            
        }
        else if (indexPath.row == 5) {
            cell.textLabel.text = ZBLocalized( @"Competitive Insights", nil);
            
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            switchView.tag = indexPath.row + 10 * indexPath.section;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            
            if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayCompetitiveInsights isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            
        }
    }
    
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = ZBLocalized( @"Allow Notification", nil);
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            if ([[ZZMyRestaurant shareRestaurant].myUser.emailNotification isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            switchView.tag = indexPath.row;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            //[switchView release];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = ZBLocalized( @"Email Notification", nil);
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            if ([[ZZMyRestaurant shareRestaurant].myUser.emailNotification isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            switchView.tag = indexPath.row;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            //[switchView release];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = ZBLocalized(@"Sounds", nil);
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            
            if ([[ZZMyRestaurant shareRestaurant].myUser.sounds isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            switchView.tag = indexPath.row;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
        } else if (indexPath.row == 3) {
            cell.textLabel.text = ZBLocalized(@"Show on Lock Screen", nil);
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            
            if ([[ZZMyRestaurant shareRestaurant].myUser.showOnLockScreen isEqualToNumber:@1]) {
                [switchView setOn:YES animated:NO];
            } else {
                [switchView setOn:NO animated:NO];
            }
            switchView.tag = indexPath.row;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            return 70.0f;
        } else {
            return 44.0f;
        }
    }
    return 44.0f;
}

#pragma -mark TableView footer

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 50.0f;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.gf_width, 50)];
        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        joinButton.frame = CGRectMake(5, 10, self.view.gf_width - 10, 35);
        joinButton.layer.cornerRadius = 5.0f;
        joinButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [joinButton setClipsToBounds:YES];
        [joinButton setTitle:@"Message Admin" forState:UIControlStateNormal];
        [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [joinButton setBackgroundColor:[UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1]];
        [joinButton addTarget:self action:@selector(messageAdminButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:joinButton];
        return footerView;
        
    }
    
    return NULL;
    
}

//*********************** tableView UISwitch **************************//
#pragma -button clicked -------------------------------------
- (void)switchChanged:(id)sender {
    UISwitch *switchControl = sender;
    NSLog(@"sender.tag %ld", (long)switchControl.tag);
    int switchTag = (int)switchControl.tag;
    NSLog(@"This switch is %@", switchControl.on ? @"ON" : @"OFF");
    if (switchTag == 10) {
        _thisRestaurant.displayYourRatings = [NSNumber numberWithBool:switchControl.on];
        [ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings = [NSNumber numberWithBool:switchControl.on];
        [[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray replaceObjectAtIndex:2 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings];
        NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray[2] %@", [ZZMyRestaurant shareRestaurant].myRestaurant.allowArray[2]);
    } else if (switchTag == 11) {
        _thisRestaurant.displayPopularTimes = [NSNumber numberWithBool:switchControl.on] ;
        [ZZMyRestaurant shareRestaurant].myRestaurant.displayPopularTimes = [NSNumber numberWithBool:switchControl.on];
        [[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray replaceObjectAtIndex:3 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayPopularTimes];
    } else if (switchTag == 12) {
        _thisRestaurant.displayTopInterest = [NSNumber numberWithBool:switchControl.on] ;
        [ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest = [NSNumber numberWithBool:switchControl.on];
        [[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray replaceObjectAtIndex:4 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest];
    } else if (switchTag == 13) {
        _thisRestaurant.displayGender = [NSNumber numberWithBool:switchControl.on] ;
        [ZZMyRestaurant shareRestaurant].myRestaurant.displayGender = [NSNumber numberWithBool:switchControl.on];
        [[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray replaceObjectAtIndex:7 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayGender];
    } else if (switchTag == 14) {
        _thisRestaurant.displayAgeGroup = [NSNumber numberWithBool:switchControl.on] ;
        [ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup = [NSNumber numberWithBool:switchControl.on];
        [[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray replaceObjectAtIndex:8 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup];
    } else if (switchTag == 15) {
        _thisRestaurant.displayCompetitiveInsights = [NSNumber numberWithBool:switchControl.on] ;
        NSLog(@"hihihihhih %@",  _thisRestaurant.displayCompetitiveInsights);
        [ZZMyRestaurant shareRestaurant].myRestaurant.displayCompetitiveInsights = [NSNumber numberWithBool:switchControl.on];
        [[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray replaceObjectAtIndex:9 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayCompetitiveInsights];
    }
    
    //***** user setting ****//
    else if (switchTag == 20) {
        [ZZMyRestaurant shareRestaurant].myUser.allowNotification = [NSNumber numberWithBool:switchControl.on] ;
        NSLog(@"thisUser.AllowNotification %@",  [ZZMyRestaurant shareRestaurant].myUser.allowNotification);
    } else if (switchTag == 21) {
        [ZZMyRestaurant shareRestaurant].myUser.emailNotification  = [NSNumber numberWithBool:switchControl.on] ;
    } else if (switchTag == 22) {
        [ZZMyRestaurant shareRestaurant].myUser.sounds  = [NSNumber numberWithBool:switchControl.on] ;
    } else if (switchTag == 23) {
        [ZZMyRestaurant shareRestaurant].myUser.showOnLockScreen  = [NSNumber numberWithBool:switchControl.on] ;
    }
  
}
//*********************** End of tableView UISwitch **************************//

//*********************** Change Language **************************//
- (void)enButtonClicked {
    NSLog(@"English button clicked");
    NSString *language=[[ZBLocalized sharedInstance]currentLanguage];
    
    if ([language isEqualToString:@"en"]) {
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil  message:ZBLocalized(@"Are you sure?", nil)  delegate:self cancelButtonTitle: ZBLocalized(@"Cancel", nil) otherButtonTitles:ZBLocalized(@"Yes", nil), nil];
        alertView.tag = 1;
        [alertView show];
    }
}

- (void)twButtonClicked {
    NSLog(@"Chinese button clicked");
    
    NSString *language=[[ZBLocalized sharedInstance]currentLanguage];
    
    if ([language isEqualToString:@"en"]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil  message:ZBLocalized(@"Are you sure?", nil)  delegate:self cancelButtonTitle: ZBLocalized(@"Cancel", nil) otherButtonTitles:ZBLocalized(@"Yes", nil), nil];
        alertView.tag = 2;
        [alertView show];
        
    } else {
        
    }
}

- (void)initRootVC{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = [[GFTabBarController alloc]init];
    [window makeKeyWindow];
    
}


//************* alert view actions ***************//
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    UIAlertView *alert = alertView;
    if (buttonIndex == 1 && alertView.tag == 0) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [AppDelegate APP].user = nil;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"KEY_USER_NAME"];
        [userDefaults setObject:nil forKey:@"KEY_USER_TOKEN"];
        [userDefaults synchronize];
        
        [appDel.window makeKeyAndVisible];
        [appDel.window setRootViewController:loginVC];
        
    } else if (alertView.tag == 1 && buttonIndex == 1) {
        [[ZBLocalized sharedInstance]setLanguage:@"en"];
        [self initRootVC];
        
    } else if (alertView.tag == 2 && buttonIndex == 1) {
        [[ZBLocalized sharedInstance]setLanguage:@"zh-Hant"];
        [self initRootVC];
    } else if (alertView.tag == 3 && buttonIndex == 1) {
        ForgetPasswordViewController *forgetVC = [[ForgetPasswordViewController alloc] init];
        forgetVC.view.frame = [UIScreen mainScreen].bounds;
        [self presentViewController:forgetVC animated:YES completion:nil];
    }
}

//************* button clicked ***************//

- (void)messageAdminButtonClicked {
    ZZMessageAdminViewController *adminVC = [[ZZMessageAdminViewController alloc] init];
    [self.navigationController pushViewController:adminVC animated:YES];
}


//********************* didSelectRowAtIndexPath **************************//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil  message:ZBLocalized(@"Are you sure?", nil)  delegate:self cancelButtonTitle: ZBLocalized(@"Cancel", nil) otherButtonTitles:ZBLocalized(@"Yes", nil), nil];
            alertView.tag = 0;
            [alertView show];

        } else if (indexPath.row == 1) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil  message:ZBLocalized(@"Are you sure?", nil)  delegate:self cancelButtonTitle: ZBLocalized(@"Cancel", nil) otherButtonTitles:ZBLocalized(@"Yes", nil), nil];
            alertView.tag = 3;
            [alertView show];
        }
    }
    else if (indexPath.section == 1) {
        
        if (indexPath.row == 3) {
            
        }
        else if (indexPath.row == 4) {
            
        }
        else if (indexPath.row == 5) {
           
        }
    }
    else if (indexPath.section == 2) {
        
    }
        
}

//*********************** table view data **************************//
- (void)loadNewData {
 
    //取消请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    NSString *userID = [AppDelegate APP].user.userID;
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    NSLog(@"userID %@", userID);
    NSDictionary *inSubData = @{@"memberId" : userID};
    NSDictionary *inData = @{@"action" : @"getProfile", @"token" : userToken, @"lang" : userLang, @"data" : inSubData};
    
    NSDictionary *parameters = @{@"data" : inData};
    
    NSLog(@"publish content parameters %@", parameters);
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {

        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

//*********************** picker view **************************//
#pragma -picker data
- (void)loadIndustryData {
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    //----------------get industry array-----------------//
    NSDictionary *inData = @{@"action" : @"getIndustryList", @"token" : userToken, @"lang" : userLang};
    
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        NSLog(@"responseObject is %@", data);
        NSLog(@"responseObject - data is %@", data[@"data"]);
        self.industryArray = [ZZTypicalInformationModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        NSLog(@"industry array %@", _industryArray);
        
        for (int i = 0; i < _industryArray.count; i++) {
            [self.industry addObject:_industryArray[i].informationName];
        }
        NSLog(@"industry  %@", _industry);
        [self loadProfessionData];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

- (void)loadProfessionData {

    NSString *userToken = [AppDelegate APP].user.userToken;
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    //----------------get profession array-----------------//
    
    NSDictionary *inData1 = @{@"action" : @"getProfessionList", @"token" : userToken, @"lang" : userLang};
    
    NSDictionary *parameters1 = @{@"data" : inData1};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters1 success:^(id data) {
        
        self.professionArray = [ZZTypicalInformationModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        
        for (int i = 0; i < _professionArray.count; i++) {
            [self.profession addObject:_professionArray[i].informationName];
        }
        [self loadInterestsData];
        
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

- (void)loadInterestsData {
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    //----------------get interests array-----------------//
    NSDictionary *inData2 = @{@"action" : @"getInterestList", @"lang": userLang};
    
    NSDictionary *parameters2 = @{@"data" : inData2};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters2 success:^(id data) {
        
        self.interestsArray = [ZZTypicalInformationModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        //self.interests = [[NSMutableArray alloc] init];
        for (int i = 0; i < _interestsArray.count; i++) {
            [self.interests addObject:_interestsArray[i].informationName];
        }
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
}

- (void)updateProfile {
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    
    //----------------get profession array-----------------//
    
    
    NSDictionary *inSubData2 = @{
                                //@"name" : _thisUser.usertName,
                                //@"interests" : _thisUser.userInterests,
                                //@"maxPrice" : _thisUser.maxPrice,
                                //@"minPrice" : _thisUser.minPrice,
                                //@"allowNotification" : _thisUser.allowNotification,
                                //@"emailNotification" : _thisUser.emailNotification,
                                //@"allowNotification" : _thisUser.allowNotification,
                                //@"sounds" : _thisUser.sounds,
                                //@"showOnLockScreen" : _thisUser.showOnLockScreen,
                                //@"industry" : _thisUser.userIndustry.informationID,
                                //@"profession" : _thisUser.profession.informationID,
                                 //@"preferredLanguag" :
                                @"age" : [ZZMyRestaurant shareRestaurant].myUser.age,
                                //@"phone" :  ,
                                //@"gender" :_thisUser.gender
                                };
    NSDictionary *inData2 = @{@"action" : @"updateProfile", @"token" : userToken, @"data" : inSubData2,
                             @"canSeeMyProfile" : _thisUser.canSeeMyProfile,
                             @"canMessageMe" : _thisUser.canMessageMe,
                             @"canMyFriendSeeMyEmail" : _thisUser.canMyFriendSeeMyEmail};
    NSDictionary *parameters2 = @{@"data" : inData2};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters2 success:^(id data) {
        
       
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

- (void)updateRestaurant {
    
    NSLog(@"viewWillDisappear updateRestaurant");
    
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    
    //----------------get profession array-----------------//
    
    
    NSDictionary *inSubData2 = @{
                                 
                                 @"restaurantId" : [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantId,
                                 @"displayYourRatings" : [ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings,
                                 @"displayPopularTimes" : [ZZMyRestaurant shareRestaurant].myRestaurant.displayPopularTimes,
                                 @"displayTopInterest" : [ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest,
                                 @"displayGender" : [ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings,
                                 @"displayAgeGroup" : [ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup,
                                 @"displayCompetitiveInsights" : [ZZMyRestaurant shareRestaurant].myRestaurant.displayCompetitiveInsights,
           
                                 };
    NSDictionary *inData2 = @{@"action" : @"updateRestaurant", @"token" : userToken, @"data" : inSubData2};
                              
    NSDictionary *parameters2 = @{@"data" : inData2};
    
    NSLog(@"parameters2 %@", parameters2);
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters2 success:^(id data) {
        

        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];

}


- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear--> updateProfile");
    
    [self updateRestaurant];
}

- (void)changeLanguage {
    NSLog(@"changeLanguage");
    
    //[[InternationalControl sharedInstance]
    //[self viewDidLoad];
    [self.tableView reloadData];
    
}


/*
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"indexPathForSlectedRow in viewWillAppear %@", [self.tableView indexPathForSelectedRow]);
    NSLog(@"indexPathForSlectedRow in viewWillAppear.row %ld", [self.tableView indexPathForSelectedRow].row);
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[self.tableView indexPathForSelectedRow],nil] withRowAnimation:UITableViewRowAnimationNone];
}
 */

@end

//
//  CuisineTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 10/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "CuisineTableViewController.h"
//#import "SearchEventDetail.h"
#import "EventRestaurant.h"
#import "ZZTypicalInformationModel.h"
#import "ZBLocalized.h"
#import "ZZMyRestaurant.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SDImageCache.h>
#import <SVProgressHUD.h>

#define DEFAULT_COLOR_GOLD [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
static NSString*const ID = @"ID";

@interface CuisineTableViewController ()

@property(nonatomic ,strong) NSMutableArray<ZZTypicalInformationModel *> *cuisineArray;//


@property (strong , nonatomic)GFHTTPSessionManager *manager;

@end

@implementation CuisineTableViewController


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
    
    self.navigationItem.title = ZBLocalized(self.tableType, nil);
    //self.thisRestaurant = [[EventRestaurant alloc] init];
    [self setUpNavBar];
    [self setUpArray];
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setUpArray {
    
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    NSDictionary *inData = [[NSDictionary alloc] init];
    if ([self.tableType isEqualToString: @"Cuisine"]) {
        inData = @{@"action" : @"getCuisineList", @"lang" : userLang};
    }
    else if ([self.tableType isEqualToString: @"Payment Methods"]) {
        inData = @{@"action" : @"getPaymentMethod", @"lang" : userLang};
    }
    else if ([self.tableType isEqualToString: @"Cost per Person"]) {
        inData = @{@"action" : @"getCostPerPersonList", @"lang" : userLang};
    }
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.cuisineArray = [ZZTypicalInformationModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        
        if ([self.tableType isEqualToString: @"Cuisine"]) {
            for (int i = 0; i < _cuisineArray.count; i ++) {
                for (int j = 0; j < _thisRestaurant.restaurantCuisines.count; j ++) {
                    if ([_cuisineArray[i].informationName isEqualToString:_thisRestaurant.restaurantCuisines[j].informationName]) {
                        _cuisineArray[i].selected = @1;
                        NSLog(@"_cuisineArray selected %@", _cuisineArray[i].informationName);
                    }
                }
            }
        }
        
        else if ([self.tableType isEqualToString: @"Payment Methods"]) {
            for (int i = 0; i < _cuisineArray.count; i ++) {
                for (int j = 0; j < _thisRestaurant.paymentMethod.count; j ++) {
                    if ([_cuisineArray[i].informationName isEqualToString:_thisRestaurant.paymentMethod[j].informationName]) {
                        _cuisineArray[i].selected = @1;
                        NSLog(@"_cuisineArray selected %@", _cuisineArray[i].informationName);
                    }
                }
            }
        }
        
        else if ([self.tableType isEqualToString: @"Cost per Person"]) {
            for (int i = 0; i < _cuisineArray.count; i ++) {
                if ([_cuisineArray[i].informationName isEqualToString:_thisRestaurant.costPerPerson.informationName]) {
                    _cuisineArray[i].selected = @1;
                    NSLog(@"_cuisineArray selected %@", _cuisineArray[i].informationName);
                    break;
                }
                
            }
            
        }
        
        [self.tableView reloadData];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cuisineArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ID"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        //cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_fa_check"]];
        //[cell.textLabel setHighlightedTextColor:ZZGoldColor];
    }
    cell.textLabel.text = _cuisineArray[indexPath.row].informationName;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    if ([_cuisineArray[indexPath.row].selected isEqualToNumber:@1]) {
        imageView.image = [UIImage imageNamed:@"ic_fa-check"];
        cell.textLabel.textColor = ZZGoldColor;
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.accessoryView = imageView;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //General select change
    if ([self.tableType isEqualToString:@"Cuisine"]) { //multiphe selection
        if ([_cuisineArray[indexPath.row].selected isEqualToNumber:@1]) {
            _cuisineArray[indexPath.row].selected = @0;
        } else {
            _cuisineArray[indexPath.row].selected = @1;
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } else if ([self.tableType isEqualToString:@"Cost per Person"]) { // can only select one
        _cuisineArray[indexPath.row].selected = @1;
        for (int i = 0; i < _cuisineArray.count; i++) {
            if (!(i == indexPath.row)) {
                _cuisineArray[i].selected = @0;
            }
        }
        
        [self.tableView reloadData];
    }
    
}

- (void)setUpNavBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(okButtonClicked)];
    
}

- (void)okButtonClicked {
    
    
    if ([self.tableType isEqualToString: @"Cuisine"]) {
        _thisRestaurant.restaurantCuisines = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < _cuisineArray.count; i++) {
            if ([_cuisineArray[i].selected isEqualToNumber:@1]) {
                [_thisRestaurant.restaurantCuisines addObject:_cuisineArray[i]];
            }
        }
        [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantCuisines = _thisRestaurant.restaurantCuisines;
    } else if ([self.tableType isEqualToString: @"Payment Methods"]) {
        
    } else if ([self.tableType isEqualToString: @"Cost per Person"]) {
        for (int i = 0 ; i < _cuisineArray.count; i++) {
            if ([_cuisineArray[i].selected isEqual:@1]) {
                _thisRestaurant.costPerPerson = _cuisineArray[i];
                NSLog(@"_thisRestaurant.costPerPerson %@  %@", _thisRestaurant.costPerPerson.informationName, _cuisineArray[i].informationName);
                
                continue;
            }
        }
        [ZZMyRestaurant shareRestaurant].myRestaurant.costPerPerson = _thisRestaurant.costPerPerson;
        
    }
   
    [self passValueMethod];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)passValueMethod
{
    [_delegate passValueCuisine:_thisRestaurant];
}

@end

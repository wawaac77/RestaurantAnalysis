//
//  TypicalBookingTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 31/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "TypicalBookingTableViewController.h"
#import "AppDelegate.h"
#import "ZBLocalized.h"

#import "BookingCell.h"
#import "ZRBookingModel.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

static NSString *const ID = @"ID";

@interface TypicalBookingTableViewController ()

/*所有帖子数据*/
@property (strong , nonatomic)NSMutableArray<ZRBookingModel *> *bookings;

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

@property (strong, nonatomic) NSIndexPath *recordIndexPath;

@end

@implementation TypicalBookingTableViewController

#pragma mark - 消除警告
-(bookingType)type
{
    return 0;
}

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
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self setUpTable];
    [self setupRefresh];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupRefresh
{
    self.tableView.mj_header = [GFRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewEvents)];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 加载新数据
-(void)loadNewEvents
{
    //取消请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    NSLog(@"user token %@", userToken);
    
    NSDictionary *inData = [[NSDictionary alloc] init];
    if (self.type == 0) {
        inData = @{@"action" : @"getPendingBooking", @"token" : userToken, @"lang" : userLang};
    } else if (self.type == 1) {
        inData = @{@"action" : @"getBookingHistory", @"token" : userToken, @"lang" : userLang};
    } else if (self.type == 2) {
        inData = @{@"action" : @"getComingBooking", @"token" : userToken, @"lang" : userLang};
    }
    
    NSDictionary *parameters = @{@"data" : inData};
    
    NSLog(@"publish content parameters %@", parameters);
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.bookings = [ZRBookingModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        //[self saveUIImages];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
        [self.tableView.mj_header endRefreshing];
    }];
    
}

-(void)setUpTable
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    /*
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        // 如果tableView响应了setSeparatorInset: 这个方法,我们就将tableView分割线的内边距设为0.
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        // 如果tableView响应了setLayoutMargins: 这个方法,我们就将tableView分割线的间距距设为0.
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
     */
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookingCell class]) bundle:nil] forCellReuseIdentifier:ID];
    
    //[self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookingCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (self.type == 2) {
        UIButton *phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(GFScreenWidth - 40, 35, 20, 20)];
        [phoneButton setImage:[UIImage imageNamed:@"ic_phonecall_grey.png"] forState:UIControlStateNormal];
        phoneButton.tag = indexPath.row;
        [phoneButton addTarget:self action:@selector(callButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:phoneButton];
    }
    cell.thisBooking = _bookings[indexPath.row];
    
    return cell;
}

- (void)callButtonClicked: (UIButton *)button {
    NSString *phoneNum = _bookings[button.tag].name;
    NSString *phoneNumStr = [NSString stringWithFormat:@"tel:12125551212%@",phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: phoneNumStr]];
    
}


@end

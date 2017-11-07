//
//  ZRHomeTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 30/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "EventRestaurant.h"
#import "LoginViewController.h"
#import "ZRHomeTableViewController.h"
#import "NotificationViewController.h"
#import "ZRRatingViewController.h"
#import "ZRBookingViewController.h"
#import "LeaderboardViewController.h"
#import "ZZMyRestaurant.h"
#import "ZZAnalysis.h"

#import "UIBarButtonItem+Badge.h"

#import "MinScrollMenu.h"
#import "MinScrollMenuItem.h"
#import "LLLayer.h"
#import "ZZLineBarChart.h"

#import <HCSStarRatingView.h>
#import <PNChart.h>
#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import "UILabel+LabelHeightAndWidth.h"

@interface ZRHomeTableViewController () <MinScrollMenuDelegate> {
    NSMutableArray *sectionHeight;
    CGFloat messageCellHeight;
}

@property (strong , nonatomic)EventRestaurant *thisRestaurant;
@property (strong , nonatomic)NSMutableArray<NotificationItem *> *myNotifications;
@property (strong , nonatomic)ZZAnalysis *restaurantAnalysis;
@property (strong , nonatomic)NSMutableArray *allowArray;

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

//** Top Interest **//
@property (nonatomic, strong) MinScrollMenu *menu;
@property (weak, nonatomic) IBOutlet MinScrollMenu *ibMenu;

@end

@implementation ZRHomeTableViewController

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
    self.view.frame = [UIScreen mainScreen].bounds;
    sectionHeight = [[NSMutableArray alloc] initWithObjects:@80, @40, @40, @240, @160, @80, @240, @80, @100, @100, nil];
    self.allowArray = [[NSMutableArray alloc] initWithObjects:@1, @1, @1, @1, @1, @1, @1, @1, @1, @1, nil];
    
    self.thisRestaurant = [[EventRestaurant alloc] init];
    self.thisRestaurant = [ZZMyRestaurant shareRestaurant].myRestaurant;
    self.restaurantAnalysis = [[ZZAnalysis alloc] init];
    
    
    //[ZZMyRestaurant shareRestaurant].myRestaurant.allowArray = [[NSMutableArray alloc] initWithObjects:@1, @0, @0, @1, @1, @1,@1, @1,@1, @1, nil];
    
    /*
    for (int i = 0; i < [ZZMyRestaurant shareRestaurant].myRestaurant.allowArray.count; i ++ ) {
        NSLog(@"shareRestaurant allowArray * %@", [ZZMyRestaurant shareRestaurant].myRestaurant.allowArray[i]);
    }
    
    
    [ZZMyRestaurant shareRestaurant].myRestaurant.allowArray = self.allowArray;
     
     */
    
    
    [self setupRefresh];
    
    //[self loadNewData];
    
    //[self getNotification];
    //[self setUpNavBar];
    //[self setUpTable];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupRefresh
{
    
    self.tableView.mj_header = [GFRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.tableView.mj_header beginRefreshing];
    
    
    //self.tableView.mj_footer = [GFRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

#pragma mark - 设置导航条
-(void)setUpNavBar
{
    
    //左边
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem ItemWithImage:[UIImage imageNamed:@"ic_logo"] WithHighlighted:[UIImage imageNamed:@"ic_logo"] Target:self action:nil];
    
    //右边
    UIBarButtonItem *notificationBtn = [UIBarButtonItem ItemWithImage:[UIImage imageNamed:@"ic_fa-bell-o"] WithHighlighted:[UIImage imageNamed:@"ic_fa-bell-o"] Target:self action:@selector(notificationClicked)];
    
    notificationBtn.badgeValue = [NSString stringWithFormat:@"%@", [ZZMyRestaurant shareRestaurant].myRestaurant.notificationNum]; //NeedUpdate:I need the number of not checked through API
    
    self.navigationItem.rightBarButtonItem = notificationBtn;
    
    //self.navigationItem.title = ZBLocalized([AppDelegate APP].user.userUserName, nil);
    self.navigationItem.title = ZBLocalized(_thisRestaurant.restaurantName, nil);

    
}

- (void)setUpAllowArray {
    
    /*
    [_allowArray replaceObjectAtIndex:2 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings];
    [_allowArray replaceObjectAtIndex:3 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayPopularTimes];
    [_allowArray replaceObjectAtIndex:4 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest];
    [_allowArray replaceObjectAtIndex:7 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayGender];
    [_allowArray replaceObjectAtIndex:8 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup];
    [_allowArray replaceObjectAtIndex:9 withObject:[ZZMyRestaurant shareRestaurant].myRestaurant.displayCompetitiveInsights];
    */

    
    /*
    // 0--message
    [_allowArray insertObject:@1 atIndex:0];
    
    // 1 --booking
    [_allowArray insertObject:@1 atIndex:1];
    */
    
    
    // 2--your rating
    if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings isEqualToNumber:@0]) {
        
        [_allowArray replaceObjectAtIndex:2 withObject:@0];
    } else {
        [_allowArray replaceObjectAtIndex:2 withObject:@1];
    }
    
    // 3 --popular times
    if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayPopularTimes isEqualToNumber:@0]) {
        
        [_allowArray replaceObjectAtIndex:3 withObject:@0];
    } else {
        [_allowArray replaceObjectAtIndex:3 withObject:@1];
    }
    
    // 4 --top interest
    if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest isEqualToNumber:@0]) {
        
        [_allowArray replaceObjectAtIndex:4 withObject:@0];
    } else {
        [_allowArray replaceObjectAtIndex:4 withObject:@1];
    }
    
    /*
    // 5 --return customer
    
    [_allowArray insertObject:@0 atIndex:5];
    
    
    // 6 --customer tier
    [_allowArray insertObject:@0 atIndex:6];
    */
    
    // 7 --gender
    if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayGender isEqualToNumber:@0]) {
        
        [_allowArray replaceObjectAtIndex:7 withObject:@0];
    } else {
        [_allowArray replaceObjectAtIndex:7 withObject:@1];
    }
    
    // 8 -- age group
    if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayAgeGroup isEqualToNumber:@0]) {
        [_allowArray replaceObjectAtIndex:8 withObject:@0];
    } else {
        [_allowArray replaceObjectAtIndex:8 withObject:@1];
    }
    
    // 9 --competitive insight
    if ([[ZZMyRestaurant shareRestaurant].myRestaurant.displayCompetitiveInsights isEqualToNumber:@0]) {
        
        [_allowArray replaceObjectAtIndex:8 withObject:@0];
    } else {
        [_allowArray replaceObjectAtIndex:8 withObject:@1];
    }
    
    
}


-(void)setUpTable
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ([_allowArray[section] isEqualToNumber:@0]) {
        return 0;
    }
    return 5;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![_allowArray[indexPath.section] isEqualToNumber:@1]) {
        return 0;
    }
    if (indexPath.section == 0) {
        return ([self getTextViewHeight:self.restaurantAnalysis.restaurantAppMessage] + 30);
    }
    
    return [sectionHeight[indexPath.section] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *cellID = [NSString stringWithFormat:@"Section%ldRow%ld", indexPath.section, indexPath.row];
    NSLog(@"cellID %@", cellID);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (![_allowArray[indexPath.section] isEqualToNumber:@1]) {
        return cell;
    }
    
    if (indexPath.section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.numberOfLines = 2;
        label.text = ZBLocalized(@"Do you know...", nil);
        [cell.contentView addSubview:label];
        
        UILabel *bigLabel = [[UILabel alloc] init]; //NeedUpdate:Should calculate size based on amount of text
        [bigLabel setFont:[UIFont systemFontOfSize:13]];
        bigLabel.textColor = [UIColor darkGrayColor];
        bigLabel.text = self.restaurantAnalysis.restaurantAppMessage;
        if (self.restaurantAnalysis.restaurantAppMessage == NULL) {
            bigLabel.text = ZBLocalized(@"When nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn you refer a friend to use Zuzu the restaurant account, you'll gain a free promo ads at the marketplace.", nil); //Need
        }
     
                //from api
        if (self.restaurantAnalysis.restaurantAppMessage != NULL) {
            bigLabel.text = self.restaurantAnalysis.restaurantAppMessage;
        }
        
        bigLabel.numberOfLines = 0;
        
        [self getTextViewHeight:bigLabel.text];
        bigLabel.frame = CGRectMake(10, 30, GFScreenWidth - 20, messageCellHeight);

        [cell.contentView addSubview:bigLabel];
        
    } else if (indexPath.section == 1) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"ic_ fa-exclamation-triangle"];
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, GFScreenWidth - 50, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        NSString *pendingStr = ZBLocalized(@"Booking Pending", nil);
        NSNumber *sampleNum = [[NSNumber alloc] init];
        
        if (self.restaurantAnalysis.pendingBookingCount == NULL) {
            sampleNum = @0;
        } else {
            sampleNum = self.restaurantAnalysis.pendingBookingCount;
        }
        
        label.text = [NSString stringWithFormat:@"%@ %@", sampleNum, pendingStr];
        [cell.contentView addSubview:label];
    } else if (indexPath.section == 2) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.textColor = [UIColor colorWithRed:9.0/255.0 green:179.0/255.0 blue:81.0/255.0 alpha:1];
        label.text = ZBLocalized(@"Your Ratings", nil);
        [cell.contentView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 15, 10, 10)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:@"ic_fa-caret-up.png"]; // NeedUpdate: up or down
        //imageView.image = [UIImage imageNamed:@"ic_fa-caret-down.png"];
        [cell.contentView addSubview:imageView];
        
        HCSStarRatingView *starView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(GFScreenWidth - 100, 10, 90, 20)];
        starView.minimumValue = 0;
        starView.maximumValue = 5;
        NSLog(@"_thisRestaurant.rating~~~ %@", _thisRestaurant.rating);
        starView.value = [self.restaurantAnalysis.restaurantRating.rating floatValue];
        starView.allowsHalfStars = YES;
        starView.userInteractionEnabled = NO;
        starView.tintColor = [UIColor darkGrayColor];
        
        [cell.contentView addSubview:starView];
        
    } else if (indexPath.section == 3) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.text = ZBLocalized(@"Popular Times", nil);
        [cell.contentView addSubview:label];
        
        //Add bar chart
        PNBarChart * barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(10, 40, GFScreenWidth - 20, 160)];
        [barChart setXLabels:@[@"",@"",@"6a",@"",@"",@"9a",@"",@"",@"12p",@"",@"",@"3p",@"",@"",@"6p",@"",@"",@"9p",@"",@"",@"12a",@"",@"",@"3a",@"",@""]];
        //[barChart setXLabels:@[@"4a",@"5a",@"6a",@"7a",@"8a",@"9a",@"10a",@"11a",@"12p",@"1p",@"2p",@"3p",@"4p",@"5p",@"6p",@"7p",@"8p",@"9p",@"10p",@"11p",@"12a",@"1a",@"2a",@"3a"]];
        //[barChart setXLabels:@[@28,  @28, @23, @18, @8, @1,@27, @20, @23, @18, @8, @1,@28,  @28, @23, @18, @8, @1,@27, @20, @23, @18, @8, @1]];
        [barChart setYLabels:@[@"Tier", @10, @20, @30]];
        //fake data
        if ([self.restaurantAnalysis.restaurantPopularTime[1].current isEqualToNumber:@1]) {
            [barChart setYValues:@[@28,  @28, @23, @18, @8, @1,@27, @20, @23, @18, @8, @1,@28,  @28, @23, @18, @8, @1,@27, @20, @23, @18, @8, @1]];
        } else {
            [barChart setYValues:@[@1,  @3, @5, @7, @8, @3,@7, @20, @23, @18, @8, @1,@28,  @30, @23, @18, @8, @1,@5, @20, @23, @18, @8, @1]];
        }
        
        
        /*
        if ([self.restaurantAnalysis.restaurantPopularTime[1].current isEqualToNumber:@1]) {
            [barChart setYValues:self.restaurantAnalysis.restaurantPopularTime[1].data];// from api
        } else {
            [barChart setYValues:self.restaurantAnalysis.restaurantPopularTime[0].data]; // from api
        }
         */
        
         //from api
        barChart.barBackgroundColor = [UIColor clearColor];
        barChart.strokeColor = ZZGoldColor;
        barChart.labelFont = [UIFont systemFontOfSize:13.0];
        barChart.isShowNumbers = NO;
        barChart.barRadius = 1.0f;
        barChart.isGradientShow = false;
        barChart.yLabelSuffix = @"p";
        //barChart.showLevelLine = YES;
        //barChart.yMaxValue = 10;
        //barChart.yMinValue = 10;
        //barChart.yLabelSum = 4;
        //barChart.xLabelSkip = 5;
        //barChart.yChartLabelWidth = 30;
        //barChart.xLabelWidth = 20; //bar的间距
        //barChart.labelMarginTop = -5;
        barChart.chartMarginTop = 0;
        //barChart.chartMarginBottom = -5;
        //barChart.chartMarginLeft = 10;
        barChart.chartBorderColor = ZZGrayBorderColor;
        barChart.barWidth = 10;
        //[barChart setStrokeColors:@[ZZGreenRatingColor, ZZGoldColor, ZZGreenBarColor, ZZDarkBlueBarColor, [UIColor blackColor], ZZLightBlueBarColor]];
        [barChart strokeChart];
        [cell.contentView addSubview:barChart];
        
        //Add Botton Labels and Buttons
        CGFloat bottomY = 200;
        CGFloat labelW = 80;
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(GFScreenWidth/2 - labelW/2, bottomY, labelW, 20)];
        [bottomLabel setFont:[UIFont boldSystemFontOfSize:14]];
        bottomLabel.textColor = [UIColor grayColor];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([self.restaurantAnalysis.restaurantPopularTime[1].current isEqualToNumber:@1]) {
            bottomLabel.text = ZBLocalized(@"Mon - Thu", nil);
        } else {
            bottomLabel.text = ZBLocalized(@"Fri - Sun", nil);
        }
        
        [cell.contentView addSubview:bottomLabel];
        
        for (int i = 0; i < 2; i++) {
            UIButton *button = [[UIButton alloc] init];
            if (i == 0) {
                button.frame = CGRectMake(GFScreenWidth/2 - labelW/2 - 30, bottomY, 20, 20); // buttonX = GFScreenWidth/2 - 40  - 20 -10;
                [button setImage:[UIImage imageNamed:@"ic_fa-angle-left"] forState:UIControlStateNormal];
            } else if (i == 1) {
                button.frame = CGRectMake(GFScreenWidth/2 + labelW/2 + 10, bottomY, 20, 20); // buttonX = GFScreenWidth/2 + 40 + 10;
                [button setImage:[UIImage imageNamed:@"ic_fa-angle-right"] forState:UIControlStateNormal];
            }
            
            button.tag = i;
            //button.contentMode = UIViewContentModeScaleAspectFit;
            //button.contentHorizontalAlignment = UIViewContentModeScaleAspectFit;
            //button.contentVerticalAlignment = UIViewContentModeScaleAspectFit;
            [button addTarget:self action:@selector(bottomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
        }
        
    } else if (indexPath.section == 4) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.text = ZBLocalized(@"Top Interest", nil);
        [cell.contentView addSubview:label];
        
        _ibMenu.delegate = self;
        
        _menu = [[MinScrollMenu alloc] initWithFrame:CGRectMake(10, 40, GFScreenWidth - 20, 110)];
        _menu.delegate = self;
        
        [cell.contentView addSubview:_menu];
        
    } else if (indexPath.section == 5) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.text = ZBLocalized(@"Return Customer", nil);
        [cell.contentView addSubview:label];
        
       
        NSMutableArray *colors =[[NSMutableArray alloc] initWithObjects:ZZLightBlueBarColor, ZZGrayBorderColor, nil];
        
        ZZReturnCustomerModel *returnCustomerModel = [[ZZReturnCustomerModel alloc] init];
        returnCustomerModel = self.restaurantAnalysis.restaurantReturnCustomer;
        
        float newCustomerPercent = [returnCustomerModel.freshCustomer floatValue] / ([returnCustomerModel.freshCustomer floatValue] + [returnCustomerModel.returnCustomer floatValue]);
        NSNumber *newPercent = [NSNumber numberWithFloat:newCustomerPercent];
        NSNumber *returnPercent = [NSNumber numberWithFloat:1 - newCustomerPercent];
        
        //NSMutableArray *nums =[[NSMutableArray alloc] initWithObjects:newPercent, returnPercent, nil]; //from api
        NSMutableArray *nums =[[NSMutableArray alloc] initWithObjects:@1, @0, nil];
        /*
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(10, 40, GFScreenWidth - 20, 20)];
        LLLayer *layer = [LLLayer layerWithFrameNColor:CGRectMake(0, 0, GFScreenWidth - 20, 20) colors:colors nums:nums];
        [barView.layer addSublayer:layer];
        
        barView.layer.cornerRadius = 4.0f;
        barView.clipsToBounds = YES;
        */
        
        ZZLineBarChart *barChart = [[ZZLineBarChart alloc] init];
        [barChart setBarFrame:CGRectMake(10, 50, GFScreenWidth - 20, 20) nums:nums colors:colors upperLabels:NULL];
        

        [cell.contentView addSubview:barChart];
        
    }  else if (indexPath.section == 6) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.text = ZBLocalized(@"Customer-Tier Ratio", nil);
        [cell.contentView addSubview:label];
        
        //Add botton buttons
        CGFloat bottomY = 200;
        CGFloat labelW = 80;
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(GFScreenWidth/2 - labelW/2, bottomY, labelW, 20)];
        [bottomLabel setFont:[UIFont boldSystemFontOfSize:14]];
        bottomLabel.textColor = [UIColor grayColor];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        if ([self.restaurantAnalysis.restaurantCustomerTier.current isEqualToNumber:@1]) {
             bottomLabel.text = ZBLocalized(@"Host", nil);
        } else {
             bottomLabel.text = ZBLocalized(@"Attendee", nil);
        }
        
        [cell.contentView addSubview:bottomLabel];
        
        for (int i = 0; i < 2; i++) {
            UIButton *button = [[UIButton alloc] init];
            if (i == 0) {
                button.frame = CGRectMake(GFScreenWidth/2 - labelW/2 - 30, bottomY, 20, 20); // buttonX = GFScreenWidth/2 - 40 - 30 - 20 -10;
                [button setImage:[UIImage imageNamed:@"ic_fa-angle-left"] forState:UIControlStateNormal];
            } else if (i == 1) {
                button.frame = CGRectMake(GFScreenWidth/2 + labelW/2 + 10, bottomY, 20, 20); // buttonX = GFScreenWidth/2 + 40 + 10;
                [button setImage:[UIImage imageNamed:@"ic_fa-angle-right"] forState:UIControlStateNormal];
            }
            
            button.tag = i + 2;
            //button.contentMode = UIViewContentModeScaleAspectFit;
            //button.contentHorizontalAlignment = UIViewContentModeScaleAspectFit;
            //button.contentVerticalAlignment = UIViewContentModeScaleAspectFit;
            [button addTarget:self action:@selector(bottomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
        }
        
        //Add bar chart
        PNBarChart * barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(10, 40, GFScreenWidth - 20, 160)];
        
        [barChart setXLabels:@[@"1",@"2",@"3",@"4",@"5", @"6",@"7"]];
        [barChart setYLabels:@[@"0",  @"10", @"20", @"30"]];
        
        NSLog(@"self.restaurantAnalysis.restaurantCustomerTier.hostData %@", self.restaurantAnalysis.restaurantCustomerTier.hostData);
        [barChart setYValues:@[@5,  @13, @7, @18, @22, @10,@27]];
        
        if ([self.restaurantAnalysis.restaurantCustomerTier.current isEqualToNumber:@1]) {
            [barChart setYValues:@[@3,  @7, @12, @29, @6, @9,@1]];
        } else {
            [barChart setYValues:@[@5,  @13, @7, @18, @22, @1,@27]];
        }
        
        barChart.barBackgroundColor = ZZGrayBorderColor;
        //barChart.strokeColor = ZZGrayBorderColor;
        barChart.labelFont = [UIFont systemFontOfSize:13.0];
        barChart.legendFont = [UIFont systemFontOfSize:13.0];
        barChart.isShowNumbers = NO;
        barChart.barRadius = 4.0f;
        barChart.isGradientShow = false;
        //barChart.showLevelLine = YES;
        //barChart.yMaxValue = 20;
        //barChart.yLabelSum = 4;
        //barChart.yChartLabelWidth = 20;
        barChart.chartMarginTop = 5;
        //barChart.chartMarginBottom = 0;
        //barChart.chartMarginLeft = 10;
        barChart.chartBorderColor = ZZGrayBorderColor;
        barChart.barWidth = 24;
        [barChart setStrokeColors:@[ZZGreenRatingColor, ZZGoldColor, ZZGreenBarColor, ZZDarkBlueBarColor, [UIColor blackColor], ZZLightBlueBarColor, ZZGoldColor]];
        [barChart strokeChart];
        
        
        
        /*
        if (self.restaurantAnalysis.restaurantCustomerTier.hostData != NULL) {
            if ([self.restaurantAnalysis.restaurantCustomerTier.current isEqualToNumber:@1]) {
                [barChart setYValues:self.restaurantAnalysis.restaurantCustomerTier.hostData]; // from api
            } else {
                [barChart setYValues:self.restaurantAnalysis.restaurantCustomerTier.attendeeData]; // from api
            }
        }
        */
        
        NSLog(@"self.restaurantAnalysis.restaurantCustomerTier.attendeeData %@", self.restaurantAnalysis.restaurantCustomerTier.attendeeData);
        
        [cell.contentView addSubview:barChart];
        
        
        
    } else if (indexPath.section == 7) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.text = ZBLocalized(@"Gender", nil);
        [cell.contentView addSubview:label];
        
        NSMutableArray *colors =[[NSMutableArray alloc] initWithObjects:ZZLightBlueBarColor, ZZGrayBorderColor, nil];
        NSMutableArray *nums =[[NSMutableArray alloc] initWithObjects:@0.2, @0.8, nil];
        ZZLineBarChart *barChart = [[ZZLineBarChart alloc] init];
        [barChart setBarFrame:CGRectMake(40, 45, GFScreenWidth - 80, 20) nums:nums colors:colors upperLabels:NULL];
        
        [cell.contentView addSubview:barChart];
        
        
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 45, 20, 20)];
        imageView1.image = [UIImage imageNamed:@"ic_man.png"];
        imageView1.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView1];
        
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(GFScreenWidth - 30, 45, 20, 20)];
        imageView2.image = [UIImage imageNamed:@"ic_women.png"];
        imageView2.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView2];
        
        
    } else if (indexPath.section == 8) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.text = ZBLocalized(@"Age Group", nil);
        [cell.contentView addSubview:label];
        
        NSMutableArray *colors =[[NSMutableArray alloc] initWithObjects:[UIColor darkGrayColor],ZZLightBlueBarColor, ZZGoldColor,ZZDarkBlueBarColor, ZZGrayBorderColor, nil];
        NSMutableArray *nums =[[NSMutableArray alloc] initWithObjects:@0.2, @0.35, @0.28, @0.12, @0.05, nil];
         NSMutableArray *lowerLabels =[[NSMutableArray alloc] initWithObjects:@"0-19", @"20-35", @"36-45", @"46-65", @"66+", nil];
        
        ZZLineBarChart *barChart = [[ZZLineBarChart alloc] init];
        [barChart setBarFrame:CGRectMake(10, 45, GFScreenWidth - 20, 20) nums:nums colors:colors upperLabels:NULL lowerLabels:lowerLabels];
        
        [cell.contentView addSubview:barChart];
        
    } else if (indexPath.section == 9) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.text = ZBLocalized(@"Competitive Insights", nil);
        [cell.contentView addSubview:label];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, GFScreenWidth - 20, 25)];
        label1.font = [UIFont systemFontOfSize:14];
        label1.text = ZBLocalized(@"1. Cuisine - Position 10 out of 65", nil);
        label1.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, GFScreenWidth - 20, 25)];
        label2.font = [UIFont systemFontOfSize:14];
        label2.text = ZBLocalized(@"2. Location - Position 10 out of 65", nil);
        label2.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:label2];
        
    }




    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        ZRBookingViewController *bookingVC = [[ZRBookingViewController alloc] init];
        [self.navigationController pushViewController:bookingVC animated:YES];
        
    } else if (indexPath.section == 2) {
        ZRRatingViewController *ratingVC = [[ZRRatingViewController alloc] init];
        [self.navigationController pushViewController:ratingVC animated:YES];
    } else if (indexPath.section == 9) {
        LeaderboardViewController *insightsVC = [[LeaderboardViewController alloc] init];
        [self.navigationController pushViewController:insightsVC animated:YES];
    }
}


//*********************** Call API ************************//
- (void)loadNewData {
    
   
    
    
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
        
        if (data[@"data"] == NULL && data[@"data"] == nil) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            
            AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            
            [AppDelegate APP].user = nil;
            
            
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [userDefaults setObject:nil forKey:@"KEY_USER_NAME"];
            
            [userDefaults setObject:nil forKey:@"KEY_USER_TOKEN"];
            
            [userDefaults synchronize];
            
            
            
            [appDel.window makeKeyAndVisible];
            
            [appDel.window setRootViewController:loginVC];
            
        } else {
            EventRestaurant *response = data[@"data"];
            NSLog(@"response in restaurant %@", response);
            _thisRestaurant = [EventRestaurant mj_objectWithKeyValues:data[@"data"]];
            [AppDelegate APP].restaurant = _thisRestaurant;
            [AppDelegate APP].user.myRestaurantName = _thisRestaurant.restaurantName;
            [self setUpAllowArray];
            
            [ZZMyRestaurant shareRestaurant].myRestaurant = _thisRestaurant;
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.restaurantName %@", [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantName);
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.restaurantId %@", [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantId);
            
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayYourRatings);
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayPopularTimes);
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest);
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayGender);
            NSLog(@"[ZZMyRestaurant shareRestaurant].myRestaurant.displayTopInterest %@", [ZZMyRestaurant shareRestaurant].myRestaurant.displayCompetitiveInsights);
            
            
            
            [self setUpNavBar];
            [self setUpTable];
            [self.tableView reloadData];
            [self getNotification];
            [self.tableView.mj_header endRefreshing];
            
        }
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [self.tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
    }];
}

- (void)getNotification {
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    NSDictionary *inData = @{
                             @"action" : @"getNotificationList",
                             @"token" : userToken,
                             @"lang" : userLang,
                             };
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.myNotifications = [NotificationItem mj_objectArrayWithKeyValuesArray:data[@"data"]];
        [ZZUser shareUser].notificationNum = [NSNumber numberWithInteger:self.myNotifications.count];
        [ZZMyRestaurant shareRestaurant].myRestaurant.notificationNum = [NSNumber numberWithInteger:self.myNotifications.count] ;
        //NSLog(@"self.myNotifications %ld  %@", _myNotifications.count, [EventRestaurant shareRestaurant].notificationNum);
        [self setUpNavBar];
        [self getRestaurantAnalysis];
        [self.tableView.mj_header endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [self.tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
    }];
}

- (void)getRestaurantAnalysis {
    
    //取消请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    NSDictionary *inData = @{
                             @"action" : @"getRestaurantAnalysis",
                             @"token" : userToken,
                             @"lang" : userLang,
                             };
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.restaurantAnalysis = [ZZAnalysis mj_objectWithKeyValues:data[@"data"]];
        
        [self getTextViewHeight:self.restaurantAnalysis.restaurantAppMessage];
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [self.tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
    }];
}



//*********************** Button Clicked ************************//
#pragma -Button Clicked
- (void)notificationClicked
{
    NotificationViewController *notificationVC = [[NotificationViewController alloc] init];
    [self.navigationController pushViewController:notificationVC animated:YES];
}

- (void)bottomButtonClicked : (UIButton *)button {
    if (button.tag == 0) {
        NSLog(@"Populer times left");
    } else if (button.tag == 1) {
        NSLog(@"Pupular times right");
    } else if (button.tag == 2) {
        NSLog(@"Customer-tier left");
    } else if (button.tag == 3) {
        NSLog(@"Customer-tier right");
    }
    
    if (button.tag == 0 || button.tag == 1) {
        if ([self.restaurantAnalysis.restaurantPopularTime[1].current isEqualToNumber:@1]) {
            self.restaurantAnalysis.restaurantPopularTime[1].current = @0;
            self.restaurantAnalysis.restaurantPopularTime[0].current = @1;
        } else {
            self.restaurantAnalysis.restaurantPopularTime[1].current = @1;
            self.restaurantAnalysis.restaurantPopularTime[0].current = @0;
        }
        
        //NSIndexPath *currentPath = [NSIndexPath indexPathForRow:0 inSection:3];
        //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:currentPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        
        NSLog(@"Populer times left");
    } else if (button.tag == 2 || button.tag == 3) {
        
        if ([self.restaurantAnalysis.restaurantCustomerTier.current isEqualToNumber:@1]) {
            self.restaurantAnalysis.restaurantCustomerTier.current = @0;
        } else {
            self.restaurantAnalysis.restaurantCustomerTier.current = @1;
        }
        
        //NSIndexPath *currentPath = [NSIndexPath indexPathForRow:0 inSection:6];
        //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:currentPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        
        NSLog(@"Customer-tier right");
    }
    
    [self.tableView reloadData];
    
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[self.tableView indexPathForSelectedRow],nil] withRowAnimation:UITableViewRowAnimationNone];
}

//*********************** End of Button Clicked ************************//


//*********************** Top Interest ************************//
#pragma MinScrollMenuDelegate Method

- (NSInteger)numberOfMenuCount:(MinScrollMenu *)menu {
    return 3;
    //return self.restaurantAnalysis.restaurantTopInterest.count;
}

- (CGFloat)scrollMenu:(MinScrollMenu *)menu widthForItemAtIndex:(NSInteger)index {
    return self.view.gf_width / 3;
}

- (MinScrollMenuItem *)scrollMenu:(MinScrollMenu *)menu itemAtIndex:(NSInteger)index {
  
    NSLog(@"index%ld", index);
    MinScrollMenuItem *item = [menu dequeueItemWithIdentifer:@"imageItem"];
    //item.backgroundColor = [UIColor redColor];
    if (item == nil) {
        item = [[MinScrollMenuItem alloc] initWithType:ImageType reuseIdentifier:@"imageItem"];
        
    }
    /*
    UIImage *placeholder = [UIImage imageNamed:@"ic-interest-19"];
    [item.imageView sd_setImageWithURL:[NSURL URLWithString:self.restaurantAnalysis.restaurantTopInterest[index].interest.icon.imageUrl] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            item.imageView.image = placeholder;
            return;
        }
    }];
    NSLog(@"index %zd icon url %@", index, self.restaurantAnalysis.restaurantTopInterest[index].interest.icon.imageUrl);
    //item.imageView.image = [UIImage imageNamed:@"ic-interest-14"]; // cannot get from api, should find a way.
    item.textLabel.text = self.restaurantAnalysis.restaurantTopInterest[index].interest.interestName; // en or tw (api)
    item.timeLabel.text = [NSString stringWithFormat:@"%@", self.restaurantAnalysis.restaurantTopInterest[index].rank];
    */
    
    if (index == 0) {
        item.imageView.image = [UIImage imageNamed:@"ic-interest-14"];
        item.textLabel.text = @"Travel & Adventure";
        item.timeLabel.text = @"1";
        
    } else if (index == 1) {
        item.imageView.image = [UIImage imageNamed:@"ic-interest-15.png"];
        item.textLabel.text = @"Movies";
        item.timeLabel.text = @"2";
        
    } else if (index == 2) {
        item.imageView.image = [UIImage imageNamed:@"ic-interest-16.png"];
        item.textLabel.text = @"Financial Investment";
        item.timeLabel.text = @"3";
    }
    
    
    return item;
}

- (void)scrollMenu:(MinScrollMenu *)menu didSelectedItem:(MinScrollMenuItem *)item atIndex:(NSInteger)index {
    NSLog(@"tap index: %ld", index);
}

//*********************** End of Top Interest ************************//


- (CGFloat)getTextViewHeight: (NSString *)text {
    
    if (messageCellHeight > 0) {
        return messageCellHeight;
    }
    messageCellHeight = [UILabel getHeightByWidth:GFScreenWidth - 20 title:text font:[UIFont systemFontOfSize:14]];
    
    return messageCellHeight;
}
@end

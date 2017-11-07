//
//  ZRRatingSummaryTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 13/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZRRatingSummaryTableViewController.h"

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "NotificationViewController.h"
#import "ZZMyRestaurant.h"

#import <HCSStarRatingView.h>
#import <PNChart.h>
#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

@interface ZRRatingSummaryTableViewController ()

@property (strong , nonatomic)EventRestaurant *thisRestaurant;

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

@end

@implementation ZRRatingSummaryTableViewController

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
    //self.view.frame = [UIScreen mainScreen].bounds;
    
    self.thisRestaurant = [[EventRestaurant alloc] init];
    self.thisRestaurant.rating = [ZZMyRestaurant shareRestaurant].myRestaurant.rating;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupRefresh
{
    self.tableView.mj_header = [GFRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.tableView.mj_header beginRefreshing];
    
}

-(void)setUpTable
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        return 150;
    } else if (indexPath.row == 1) {
        return 80;
    } else if (indexPath.row == 2) {
        return 250;
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = [NSString stringWithFormat:@"Section%ldRow%ld", indexPath.section, indexPath.row];
    NSLog(@"cellID %@", cellID);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (indexPath.row == 0) {
        //Review Summary Label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.numberOfLines = 1;
        label.text = ZBLocalized(@"Review Summary", nil);
        [cell.contentView addSubview:label];
        
        //Num of Review Label
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 300, 20)];
        [label1 setFont:[UIFont systemFontOfSize:14]];
        label1.textColor = [UIColor darkGrayColor];
        label1.numberOfLines = 1;
        label1.text = ZBLocalized(@"91 Reviews", nil);
        [cell.contentView addSubview:label1];
        
        PNBarChart * barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(10, 50, GFScreenWidth - 120, 120)];
        [barChart setXLabels:@[@"1",@"2",@"3",@"4",@"5"]];
        [barChart setYValues:@[@4,  @10, @2, @6, @3]];
        barChart.barBackgroundColor = ZZGrayBorderColor;
        barChart.strokeColor = ZZGoldColor;
        barChart.labelFont = [UIFont systemFontOfSize:13.0];
        barChart.isShowNumbers = NO;
        barChart.barRadius = 4.0f;
        barChart.isGradientShow = false;
        barChart.yMaxValue = 5;
        barChart.chartMarginTop = 5;
        
        [barChart strokeChart];
        
        //barChart.backgroundColor = [UIColor redColor];
        [barChart setStrokeColors:@[ZZGoldColor, PNGrey, PNRed, PNGreen, PNGreen, PNGreen, PNRed, PNGreen]];
        barChart.rotateForXAxisText = YES;
        
        [cell.contentView addSubview:barChart];
        
        UILabel *largeRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(GFScreenWidth - 110, 30, 100, 70)];
        largeRatingLabel.text = [NSString stringWithFormat:@"%@",_thisRestaurant.rating];
        largeRatingLabel.textAlignment = NSTextAlignmentCenter;
        largeRatingLabel.font = [UIFont boldSystemFontOfSize:32];
        largeRatingLabel.textColor = ZZGreenRatingColor;
        [cell.contentView addSubview:largeRatingLabel];
        
        HCSStarRatingView *starView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(largeRatingLabel.frame.origin.x, largeRatingLabel.frame.origin.y + largeRatingLabel.gf_height, 100, 20)];
        starView.minimumValue = 0;
        starView.maximumValue = 5;
        NSLog(@"_thisRestaurant.rating~~~ %@", _thisRestaurant.rating);
        starView.value = [_thisRestaurant.rating floatValue];
        starView.allowsHalfStars = YES;
        starView.userInteractionEnabled = NO;
        starView.tintColor = [UIColor darkGrayColor];
        
        [cell.contentView addSubview:starView];
        
        
        
    } else if (indexPath.row == 1) {
        NSArray *items = [NSArray arrayWithObjects:@"Services", @"Food", @"Atmosphere", @"Hygiene", nil];
        for (int i = 0; i < 4; i++) {
            //declare
            UILabel *label = [[UILabel alloc] init];
            HCSStarRatingView *starView = [[HCSStarRatingView alloc] init];

            //set labels and starViews' frame
            CGFloat starWidth = GFScreenWidth / 2 - 100 - 10;
            CGFloat labelW = 90;
            if (i == 0) {
                label.frame = CGRectMake(10, 10, labelW, 30);
                starView.frame = CGRectMake(10 + labelW, 10, starWidth, 30);
            } else if (i == 1) {
                label.frame = CGRectMake(GFScreenWidth / 2, 10, labelW, 30);
                starView.frame = CGRectMake(GFScreenWidth / 2 + labelW, 10, starWidth, 30);
            } else if (i == 2) {
                label.frame = CGRectMake(10, 40, labelW, 30);
                starView.frame = CGRectMake(10 + labelW, 40, starWidth, 30);
            } else if (i == 3) {
                label.frame = CGRectMake(GFScreenWidth / 2, 40, labelW, 30);
                starView.frame = CGRectMake(GFScreenWidth / 2 + labelW, 40, starWidth, 30);
            }
            //set label property
            label.text = ZBLocalized(items[i], nil);
            label.font = [UIFont systemFontOfSize:13];
            label.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:label];
            
            //set starView property and value
            starView.minimumValue = 0;
            starView.maximumValue = 5;
            starView.value = [_thisRestaurant.rating floatValue];
            starView.allowsHalfStars = YES;
            starView.userInteractionEnabled = NO;
            starView.tintColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:starView];
        }
        
    } else if (indexPath.row == 2) {
        //Add Title Label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        label.numberOfLines = 1;
        label.text = ZBLocalized(@"What can be done better?", nil);
        [cell.contentView addSubview:label];
        
        //add pie chart
        NSArray *items = @[[PNPieChartDataItem dataItemWithValue:20 color:ZZDarkBlueBarColor description:@"Service"],
                           [PNPieChartDataItem dataItemWithValue:30 color:ZZGoldColor description:@"Food"],
                           [PNPieChartDataItem dataItemWithValue:35 color:[UIColor grayColor] description:@"Hygiene"],
                           [PNPieChartDataItem dataItemWithValue:15 color:PNBlue description:@"Atmosphere"],
                           ];
        
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake((CGFloat) (SCREEN_WIDTH / 2.0 - 100), 35, 200.0, 200.0) items:items];
        pieChart.descriptionTextColor = [UIColor whiteColor];
        pieChart.descriptionTextFont = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
        pieChart.descriptionTextShadowColor = [UIColor clearColor];
        pieChart.showAbsoluteValues = NO;
        pieChart.showOnlyValues = NO;
        pieChart.innerCircleRadius = 10;
        pieChart.outerCircleRadius = 90;
        [pieChart strokeChart];
        
        pieChart.legendStyle = PNLegendItemStyleStacked;
        pieChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
        
        UIView *legend = [pieChart getLegendWithMaxWidth:200];
        [legend setFrame:CGRectMake(130, 350, legend.frame.size.width, legend.frame.size.height)];
        //[cell.contentView addSubview:legend];
        
        [cell.contentView addSubview:pieChart];
       
    }
    
    return cell;
}


@end

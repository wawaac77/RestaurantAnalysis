//
//  LeaderboardAttendeesTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 10/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "LeaderboardAttendeesTableViewController.h"

#import "ZZLeaderboardModel.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

static NSString *const ID = @"ID";

@interface LeaderboardAttendeesTableViewController ()

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

@property (nonatomic, strong) NSMutableArray<ZZLeaderboardModel *> *rankList;

@end

@implementation LeaderboardAttendeesTableViewController

#pragma mark - 消除警告
-(InsightContentType)insightType
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
    self.rankList = [[NSMutableArray alloc] init];
    [self setupRefresh];
    [self setUpTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupRefresh
{
    self.tableView.mj_header = [GFRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNeweData)];
    [self.tableView.mj_header beginRefreshing];
    
}

- (void)loadNeweData {
    
    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }

    NSDictionary *inData = [[NSDictionary alloc] init];
    if (self.insightType == 0) {
        inData = @{@"action" : @"getRestaurantCuisineInsight", @"token" : userToken, @"lang" : userLang};
    } else if (self.insightType == 1) {
        inData = @{@"action" : @"getRestaurantLocationInsight", @"token" : userToken, @"lang" : userLang};
    }
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.rankList = [ZZLeaderboardModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        NSLog(@"rankList %ld", self.rankList.count);
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

-(void)setUpTable
{
    //self.tableView.contentInset = UIEdgeInsetsMake(33, 0, GFTabBarH, 0);
    //[self.tableView setFrame:self.view.bounds];
    NSLog(@"table width %f",self.view.gf_width);
    //self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    //self.tableView.separatorStyle = UITableViewStylePlain;
    
    //[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GFEventsCell class]) bundle:nil forCellReuseIdentifier:eventID];
  
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    [self.tableView reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _rankList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    ZZLeaderboardModel *thisRank = [_rankList objectAtIndex:indexPath.row];
    
    //Ranking Label
    UILabel *rankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 10, 30)];
    rankingLabel.text = [NSString stringWithFormat:@"%@", thisRank.rank];
   
    
    //Up or down arrow image view
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 14, 12, 12)];
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    int rankChange = (int)thisRank.rankChange;
    if (rankChange == 0) {
        arrowImageView.image = [UIImage imageNamed:@"see-big-picture-background"];
        rankingLabel.textColor = [UIColor blackColor];
    } else if (rankChange > 0) {
        arrowImageView.image = [UIImage imageNamed:@"ic_fa-caret-up.png"];
        rankingLabel.textColor = ZZGreenRatingColor;
    } else if (rankChange < 0) {
        arrowImageView.image = [UIImage imageNamed:@"ic_fa-caret-down.png"];
        rankingLabel.textColor = [UIColor redColor];
    }
    
    
    //Restaurant Name
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, GFScreenWidth - 160, 30)];
    nameLabel.text = thisRank.restaurant.restaurantName;
    nameLabel.font = [UIFont systemFontOfSize:15];
    
    
    //Star image view
    UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(GFScreenWidth - 25, 12.5, 15, 15)];
    starImageView.contentMode = UIViewContentModeScaleAspectFit;
    starImageView.image = [UIImage imageNamed:@"ic_fa_star_empty.png"];
    
    
    //Rating Label
    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(GFScreenWidth - 25 - 40, 5, 40, 30)];
    float thisRating = 0;
    if (thisRank.rating != NULL) {
        thisRating = [thisRank.rating floatValue];
    }
    ratingLabel.text = [NSString stringWithFormat:@"/ %.1f", thisRating];
    ratingLabel.textAlignment = NSTextAlignmentCenter;
    ratingLabel.textColor = [UIColor darkGrayColor];
    ratingLabel.font = [UIFont systemFontOfSize:14];
    
    
    //review image view
    UIImageView *reviewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(GFScreenWidth - 65 - 15, 12.5, 15, 15)];
    reviewImageView.contentMode = UIViewContentModeScaleAspectFit;
    reviewImageView.image = [UIImage imageNamed:@"ic_a-commenting-o.png"];
    
    
    //review num label
    UILabel *reviewNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(GFScreenWidth - 80 - 45, 5, 40, 30)];
    if (thisRank.reviewCount == NULL) {
        reviewNumLabel.text = @"0";
        
    } else {
        reviewNumLabel.text = [NSString stringWithFormat:@"%@", thisRank.reviewCount];
    }
    
    reviewNumLabel.textAlignment = NSTextAlignmentRight;
    reviewNumLabel.textColor = [UIColor darkGrayColor];
    reviewNumLabel.font = [UIFont systemFontOfSize:14];
    

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        [cell.contentView addSubview:rankingLabel];
        [cell.contentView addSubview:arrowImageView];
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:starImageView];
        [cell.contentView addSubview:ratingLabel];
        [cell.contentView addSubview:reviewImageView];
        [cell.contentView addSubview:reviewNumLabel];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld row is selected",indexPath.row);
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

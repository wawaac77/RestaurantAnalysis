//
//  BookingCell.m
//  GFBS
//
//  Created by Alice Jin on 31/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "BookingCell.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

@interface BookingCell ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) NSString *bookingId;

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

@end

@implementation BookingCell

#pragma mark - 懒加载
-(GFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [GFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return _manager;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setThisBooking:(ZRBookingModel *)thisBooking {
    self.timeLabel.text = [NSString stringWithFormat:@"%@ | %@ guests", thisBooking.bookingDate, thisBooking.numOfPeople];
    //self.timeLabel.frame = self.timeLabel.intrinsicContentSize.width
    self.nameLabel.text = thisBooking.name;
    NSLog(@"booking id %@", thisBooking._id);
    NSString *bookingId = [[NSString alloc] init];
    bookingId = thisBooking._id;
    self.bookingId = bookingId;
    
    if (![thisBooking.status isEqualToString:@"pending"]) {
        _acceptButton.hidden = YES;
        _cancelButton.hidden = YES;
    } else {
        _acceptButton.hidden = NO;
        _cancelButton.hidden = NO;
    }
    [_acceptButton addTarget:self action:@selector(acceptButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)acceptButtonClicked: (UIButton *) button {
    NSLog(@"accept button clicked");
    //取消请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    
    /*
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
     */
    NSLog(@"user token %@", userToken);
    
    _thisBooking = [[ZRBookingModel alloc] init];
    NSLog(@"self.bookingId %@", self.bookingId);
    NSDictionary *inSubData = @{@"bookingId" : self.bookingId, @"status" : @"accepted"};

    NSDictionary  *inData = @{@"action" : @"updateBookingStatus",
                              @"token" : userToken,
                              @"data" : inSubData};
    NSDictionary *parameters = @{@"data" : inData};
    
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        _acceptButton.hidden = YES;
        _cancelButton.hidden = YES;
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

- (void)cancelButtonClicked {
    NSLog(@"cancel button clicked");
    //取消请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    //2.凭借请求参数
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    NSDictionary *inSubData = @{@"bookingId" : self.bookingId, @"status" : @"rejected"};
    
    NSDictionary  *inData = @{@"action" : @"updateBookingStatus",
                              @"token" : userToken,
                              @"data" : inSubData};
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        _acceptButton.hidden = YES;
        _cancelButton.hidden = YES;
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

@end

//
//  TextFillingViewController.m
//  GFBS
//
//  Created by Alice Jin on 12/10/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "TextFillingViewController.h"
#import "ZZMyRestaurant.h"
#import "ZBLocalized.h"

@interface TextFillingViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation TextFillingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavBar];
    [self setUpTextView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNavBar {
    self.navigationItem.title = ZBLocalized(self.textType, nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(okButtonClicked)];
    
}

- (void)setUpTextView {
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, GFScreenWidth - 20, GFScreenHeight - GFNavMaxY - GFTabBarH - 20)];
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderWidth = 0.5f;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.cornerRadius = 4.0f;
    
    [self.view addSubview:self.textView];
    
    if ([self.textType isEqualToString:@"Overview Description"]) {
        self.textView.text = [ZZMyRestaurant shareRestaurant].myRestaurant.overview;
    }
    
    else if ([self.textType isEqualToString:@"Signature Dishes"]) {
        self.textView.text = [ZZMyRestaurant shareRestaurant].myRestaurant.features;
    }
    
    else if ([self.textType isEqualToString:@"Opening Hours"]) {
        self.textView.text = [ZZMyRestaurant shareRestaurant].myRestaurant.operationHour;
    }
    
}

- (void)okButtonClicked {
    
    if ([self.textType isEqualToString:@"Overview Description"]) {
        [ZZMyRestaurant shareRestaurant].myRestaurant.overview = self.textView.text;
    }
    
    else if ([self.textType isEqualToString:@"Signature Dishes"]) {
        [ZZMyRestaurant shareRestaurant].myRestaurant.features = self.textView.text;
    }
    
    else if ([self.textType isEqualToString:@"Opening Hours"]) {
        [ZZMyRestaurant shareRestaurant].myRestaurant.operationHour = self.textView.text;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end

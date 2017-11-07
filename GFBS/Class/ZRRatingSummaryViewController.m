//
//  ZRRatingSummaryViewController.m
//  GFBS
//
//  Created by Alice Jin on 31/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZRRatingSummaryViewController.h"
#import <PNChart.h>
#import <HACBarChart.h>

@interface ZRRatingSummaryViewController () {
    NSArray *data;
}

@property (weak, nonatomic) IBOutlet HACBarChart *chart;

@end

@implementation ZRRatingSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpReviewSummary];
    //[self setUpHorizentalBarChart];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpReviewSummary {
    PNBarChart * barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(10, 0, GFScreenWidth - 100, 200)];
    [barChart setXLabels:@[@"1",@"2",@"3",@"4",@"5"]];
    [barChart setYValues:@[@4,  @10, @2, @6, @3]];
    barChart.barBackgroundColor = PNBlue;
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
    
    [self.view addSubview:barChart];
}

- (void)setUpHorizentalBarChart {
    data = @[
             @{kHACPercentage:@1000, kHACColor  : [UIColor colorWithRed:0.000f green:0.620f blue:0.890f alpha:1.0f], kHACCustomText : @"January"},
             @{kHACPercentage:@875,  kHACColor  : [UIColor colorWithRed:0.431f green:0.000f blue:0.533f alpha:1.0f], kHACCustomText : @"February"},
             @{kHACPercentage:@875,  kHACColor  : [UIColor colorWithRed:0.922f green:0.000f blue:0.000f alpha:1.0f], kHACCustomText : @"March"},
             @{kHACPercentage:@875,  kHACColor  : [UIColor colorWithRed:0.000f green:0.671f blue:0.180f alpha:1.0f], kHACCustomText : @"April"},
             @{kHACPercentage:@750,  kHACColor  : [UIColor colorWithRed:1.000f green:0.000f blue:0.851f alpha:1.0f], kHACCustomText : @"May"},
             @{kHACPercentage:@750,  kHACColor  : [UIColor colorWithRed:1.000f green:0.808f blue:0.000f alpha:1.0f], kHACCustomText : @"June"},
             @{kHACPercentage:@625,  kHACColor  : [UIColor colorWithRed:0.294f green:0.843f blue:0.251f alpha:1.0f], kHACCustomText : @"July"},
             @{kHACPercentage:@500,  kHACColor  : [UIColor colorWithRed:1.000f green:0.404f blue:0.000f alpha:1.0f], kHACCustomText : @"August"},
             @{kHACPercentage:@500,  kHACColor  : [UIColor colorWithRed:0.282f green:0.631f blue:0.620f alpha:1.0f], kHACCustomText : @"September"},
             @{kHACPercentage:@375,  kHACColor  : [UIColor colorWithRed:0.776f green:0.000f blue:0.702f alpha:1.0f], kHACCustomText : @"October"},
             @{kHACPercentage:@250,  kHACColor  : [UIColor colorWithRed:0.282f green:0.631f blue:0.620f alpha:1.0f], kHACCustomText : @"November"},
             @{kHACPercentage:@125,  kHACColor  : [UIColor colorWithRed:0.776f green:0.000f blue:0.702f alpha:1.0f], kHACCustomText : @"December"}
             ];
    ////// CHART CONFIG
    _chart.showAxis                 = YES;   // Show axis line
    _chart.showProgressLabel        = YES;   // Show text for bar
    _chart.vertical                 = NO;   // Orientation chart
    _chart.reverse                  = YES;   // Orientation chart
    _chart.showDataValue            = YES;   // Show value contains _data, or real percent value
    _chart.showCustomText           = YES;   // Show custom text, in _data with key kHACCustomText
    _chart.barsMargin               = 0;     // Margin between bars
    _chart.sizeLabelProgress        = 30;    // Width of label progress text
    _chart.numberDividersAxisY      = 8;
    _chart.animationDuration        = 2;
    //    _chart.axisMaxValue             = 1500;    // If no define maxValue, get maxium of _data
    _chart.progressTextColor        = [UIColor darkGrayColor];
    _chart.axisYTextColor           = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    _chart.progressTextFont         = [UIFont fontWithName:@"DINCondensed-Bold" size:6];
    _chart.typeBar                  = HACBarType2;
    _chart.dashedLineColor          = [UIColor colorWithRed:0.44 green:0.66 blue:0.86 alpha:.3];
    _chart.axisXColor               = [UIColor colorWithRed:0.44 green:0.66 blue:0.86 alpha:1.0];
    _chart.axisYColor               = [UIColor colorWithRed:0.44 green:0.66 blue:0.86 alpha:1.0];
    _chart.showAxisZeroValue        = NO;
    //_chart.data = data3;
    _chart.data = data;
    _chart.vertical = NO;
    _chart.typeBar = HACBarType1;
    ////// CHART SET DATA
    [_chart draw];

    
    //_chart.frame = CGRectMake(0, 0, GFScreenWidth, 300);
    //[self.view addSubview:_chart];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[_chart draw];
}

@end

//
//  ZRSettingProfileTableViewController.h
//  GFBS
//
//  Created by Alice Jin on 31/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CuisineTableViewController.h"
#import "SubFillTableViewController.h"

//@protocol UIAlertViewDelegate;


@interface ZRSettingProfileTableViewController : UITableViewController <CuisineChildViewControllerDelegate, FillinChildViewControllerDelegate>

//@property (weak)id <UIAlertViewDelegate> delegate;

@end


/*
@protocol UIAlertViewDelegate <NSObject>

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
 */


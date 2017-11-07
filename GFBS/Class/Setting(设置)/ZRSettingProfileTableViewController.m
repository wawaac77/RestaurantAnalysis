//
//  ZRSettingProfileTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 31/8/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZRSettingProfileTableViewController.h"
#import "ImagePickerViewController.h"
#import "TextFillingViewController.h"
#import "ZBLocalized.h"
#import "EventRestaurant.h"
#import "ZZMyRestaurant.h"
//#import "ZZUser.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SDImageCache.h>
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>

static NSString *const cellID1 = @"cellID1";
static NSString *const cellID2 = @"cellID2";


@interface ZRSettingProfileTableViewController () <UIAlertViewDelegate>

@property (strong , nonatomic)GFHTTPSessionManager *manager;
@property (strong, nonatomic) EventRestaurant *thisRestaurant;

@end

@implementation ZRSettingProfileTableViewController

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
    self.thisRestaurant = [[EventRestaurant alloc] init];
    self.thisRestaurant = [ZZMyRestaurant shareRestaurant].myRestaurant;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return ZBLocalized(@"General Information", nil);
    } else if (section == 1) {
        return ZBLocalized(@"Location", nil);
    } else if (section == 2) {
        return ZBLocalized(@"Other Information", nil);
    } else if (section == 3) {
        return NULL;
    }
    
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 3) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 6;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = [[NSString alloc] init];
    
    if (indexPath.section == 0 || indexPath.section == 3) {
        cellID = cellID1;
    } else {
        cellID = cellID2;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        if (cellID == cellID1) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:cellID];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            //cell.textLabel.textColor = [UIColor grayColor];
            //cell.textLabel.font = [UIFont systemFontOfSize:15];
            
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_ fa-image.png"]];
            cell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
            cell.accessoryView.frame = CGRectMake(0, 0, 24, 24);
             
            
        } else {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:cellID];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = ZBLocalized([AppDelegate APP].user.myRestaurantName, nil);
            //cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        }
        
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = ZBLocalized( @"Telephone Number", nil);
            NSString *detail = @"";
            for (int i = 0; i < [ZZMyRestaurant shareRestaurant].myRestaurant.phone.count; i++) {
               
                detail = [detail stringByAppendingString: [NSString stringWithFormat:@"%@. ",[ZZMyRestaurant shareRestaurant].myRestaurant.phone[i]]];
            }
            
            
            NSLog(@"Telephone detail %@", detail);
            cell.detailTextLabel.text = detail;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = ZBLocalized( @"Cuisine", nil);
            
            NSString *detail = @"";
            for (int i = 0; i < [ZZMyRestaurant shareRestaurant].myRestaurant.restaurantCuisines.count; i++) {
                
                detail = [detail stringByAppendingString: [NSString stringWithFormat:@"%@. ",[ZZMyRestaurant shareRestaurant].myRestaurant.restaurantCuisines[i].informationName]];
            }
            
            NSLog(@"cuisine detail %@", detail);
            cell.detailTextLabel.text = detail;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        }
        
        else if (indexPath.row == 2) {
            cell.textLabel.text = ZBLocalized( @"Cost per Person", nil);
            cell.detailTextLabel.text = [ZZMyRestaurant shareRestaurant].myRestaurant.costPerPerson.informationName;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        }
    }
    
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = ZBLocalized( @"Opening Hours", nil);
            cell.detailTextLabel.text = [ZZMyRestaurant shareRestaurant].myRestaurant.operationHour;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = ZBLocalized( @"Signature Dishes", nil);
            cell.detailTextLabel.text = [ZZMyRestaurant shareRestaurant].myRestaurant.features;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = ZBLocalized( @"Overview Description", nil);
            cell.detailTextLabel.text = [ZZMyRestaurant shareRestaurant].myRestaurant.overview;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = ZBLocalized( @"Facilities", nil);
            
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = ZBLocalized( @"Number of Seats", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[ZZMyRestaurant shareRestaurant].myRestaurant.seats];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            
        }
        else if (indexPath.row == 5) {
            cell.textLabel.text = ZBLocalized( @"Payment Methods", nil);
            
            NSString *detail = @"";
            for (int i = 0; i < [ZZMyRestaurant shareRestaurant].myRestaurant.paymentMethod.count; i++) {
                detail = [detail stringByAppendingString: [NSString stringWithFormat:@"%@. ",[ZZMyRestaurant shareRestaurant].myRestaurant.paymentMethod[i].informationName]];
            }
            NSLog(@"cuisine detail %@", detail);
            cell.detailTextLabel.text = detail;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            
        }

    }
    
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = ZBLocalized( @"Upload Menu", nil);
            
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = ZBLocalized( @"Upload Photos", nil);
            
        }
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            ImagePickerViewController *imagePickerVC = [[ImagePickerViewController alloc] init];
            imagePickerVC.type = @"Restaurant Banner";
            [self.navigationController pushViewController:imagePickerVC animated:YES];
        }
                
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //cell.textLabel.text = ZBLocalized( @"Telephone Number", nil);
            SubFillTableViewController *fillVC = [[SubFillTableViewController alloc] init];
            fillVC.tableType = @"Telephone Number";
            fillVC.thisRestaurant = _thisRestaurant;
            fillVC.delegate = self;
            [self.navigationController pushViewController:fillVC animated:YES];

            
        }
        else if (indexPath.row == 1) {
            //cell.textLabel.text = ZBLocalized( @"Cuisine", nil);
            CuisineTableViewController *cuisineVC = [[CuisineTableViewController alloc] init];
            cuisineVC.tableType = @"Cuisine";
            cuisineVC.thisRestaurant = _thisRestaurant;
            cuisineVC.delegate = self;
            [self.navigationController pushViewController:cuisineVC animated:YES];
        }
        else if (indexPath.row == 2) {
            //cell.textLabel.text = ZBLocalized( @"Cost per Person", nil);
            CuisineTableViewController *cuisineVC = [[CuisineTableViewController alloc] init];
            cuisineVC.tableType = @"Cost per Person";
            cuisineVC.thisRestaurant = _thisRestaurant;
            cuisineVC.delegate = self;
            [self.navigationController pushViewController:cuisineVC animated:YES];
            
        }
    }
    
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            TextFillingViewController *textFillVC = [[TextFillingViewController alloc] init];
            textFillVC.textType = @"Opening Hours";
            [self.navigationController pushViewController:textFillVC animated:YES];
        }
        else if (indexPath.row == 1) {
            TextFillingViewController *textFillVC = [[TextFillingViewController alloc] init];
            textFillVC.textType = @"Signature Dishes";
            [self.navigationController pushViewController:textFillVC animated:YES];
            
        }
        else if (indexPath.row == 2) {
            TextFillingViewController *textFillVC = [[TextFillingViewController alloc] init];
            textFillVC.textType = @"Overview Description";
            [self.navigationController pushViewController:textFillVC animated:YES];
        }
        else if (indexPath.row == 3) {
            //cell.textLabel.text = ZBLocalized( @"Facilities", nil);
            
        }
        else if (indexPath.row == 4) {
            //cell.textLabel.text = ZBLocalized( @"Number of Seats", nil);
           
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please input the number of seats" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Done", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
            
        }
        else if (indexPath.row == 5) {
            CuisineTableViewController *cuisineVC = [[CuisineTableViewController alloc] init];
            cuisineVC.tableType = @"Payment Methods";
            cuisineVC.thisRestaurant = _thisRestaurant;
            cuisineVC.delegate = self;
            [self.navigationController pushViewController:cuisineVC animated:YES];
        }
        
    }
    
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            ImagePickerViewController *imagePickerVC = [[ImagePickerViewController alloc] init];
            imagePickerVC.type = @"Upload Menu";
            [self.navigationController pushViewController:imagePickerVC animated:YES];

            
        }
        else if (indexPath.row == 1) {
            //cell.textLabel.text = ZBLocalized( @"Upload Photos", nil);
            ImagePickerViewController *imagePickerVC = [[ImagePickerViewController alloc] init];
            imagePickerVC.type = @"Upload Photos";
            [self.navigationController pushViewController:imagePickerVC animated:YES];

            
        }
    }
    
}

//************************* pass value delegate ****************************//
- (void)passValueCuisine:(EventRestaurant *)theValue {
    
    [self.tableView reloadData];
}

- (void)passValue:(EventRestaurant *)theValue {
    if (theValue.phone != NULL) {
        [ZZMyRestaurant shareRestaurant].myRestaurant.phone = theValue.phone;
        
    }
    NSLog(@"pass value [EventRestaurant shareRestaurant] %@  %@", [ZZMyRestaurant shareRestaurant].myRestaurant.phone, theValue.phone[0]);
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}


#pragma - AlertView Delegate
//*************** alertView delegate *****************//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"[alertView] %@", [alertView textFieldAtIndex:0].text);
    
    [ZZMyRestaurant shareRestaurant].myRestaurant.seats = [NSNumber numberWithInteger:[[alertView textFieldAtIndex:0].text integerValue]];
    [self.tableView reloadData];
}

#pragma - imagePicker action
//*************** imagePicker *****************//
- (IBAction)imagePickerButtonClicked:(id)sender {
    
    /*
     AddLLImagePickerVC *imagePickerVC = [[AddLLImagePickerVC alloc] init];
     //imagePickerVC.view.frame = [UIScreen mainScreen].bounds;
     
     [self.navigationController pushViewController:imagePickerVC animated:YES];
     NSLog(@" %@", imagePickerVC.pickedImageArray);
     _pickedImagesArray = imagePickerVC.pickedImageArray;
     */
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    
    //self.pickedImage = chosenImage;
    NSLog(@"chosenImage %@", chosenImage);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end

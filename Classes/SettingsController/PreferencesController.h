//
//  SettingsController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "WeezBaseViewController.h"

@interface PreferencesController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>
{
    UITableView *tableView;
    
    // language picker
    UIView *selectorView;
    UIPickerView *pickerView;
    UINavigationItem *selectorNavigationItem;
    UIImageView *selectorBgImage;
    UIBarButtonItem *selectorRightButton;
    UIButton *btnLogout;
    AppChatPrivacyLevel currentChatPrivacyLevel;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIView *selectorView;
@property(nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property(nonatomic, retain) IBOutlet UINavigationItem *selectorNavigationItem;
@property(nonatomic, retain) IBOutlet UIImageView *selectorBgImage;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *selectorRightButton;
@property(nonatomic, retain) IBOutlet UIButton *btnLogout;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pickerBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pickerTopConstraint;

- (IBAction)logout:(id)sender;

@end

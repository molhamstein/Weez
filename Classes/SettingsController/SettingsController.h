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

@interface SettingsController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *settingsTableView;
    FollowType followType;
}

@property(nonatomic, retain) IBOutlet UITableView *settingsTableView;

@end

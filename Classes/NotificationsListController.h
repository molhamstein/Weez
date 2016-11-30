//
//  NotificationsListController.h
//  Weez
//
//  Created by Molham on 8/24/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppNotification.h"
#import "WeezBaseViewController.h"

@interface NotificationsListController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *listOfNotifications;
    UITableView *tableView;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIView *loaderView;
    UIRefreshControl *tableRefreshControl;
    AppNotification *selectedNotificationObject;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

@end

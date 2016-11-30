//
//  GroupListController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "WeezBaseViewController.h"

@interface GroupListController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *listOfGroups;
    Group *selectedGroup;
    UITableView *groupsTableView;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIView *loaderView;
}

@property (nonatomic, retain) IBOutlet UITableView *groupsTableView;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

@end

//
//  FollowingListController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "WeezBaseViewController.h"

@interface FollowingListController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *fullFollowingList;
    NSMutableArray *filteredList;
    Friend *selectedFriend;
    UITableView *usersTableView;
    UIView *searchView;
    UILabel *searchLabel;
    UITextField *searchTextField;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *backgroundButton;
    UIView *loaderView;
    FollowType followType;
}

@property (nonatomic, retain) IBOutlet UITableView *usersTableView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UILabel *searchLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (void)setFollowType:(FollowType)type;
- (IBAction)backgroundClick:(id)sender;

@end

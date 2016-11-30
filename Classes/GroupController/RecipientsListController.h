//
//  RecipientsListController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "WeezBaseViewController.h"
#import "Group.h"

@interface RecipientsListController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    // following lists
    NSMutableArray *fullFollowingList;
    NSMutableArray *filteredFollowingList;
    NSMutableArray *selectedFollowingList;
    // groups lists
    NSMutableArray *fullGroupList;
    NSMutableArray *filteredGroupList;
    NSMutableArray *selectedGroupList;
    BOOL isPublic;
    UITableView *usersTableView;
    UIView *searchView;
    UILabel *searchLabel;
    UITextField *searchTextField;
    UILabel *publicLabel;
    UISwitch *publicSwitch;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *backgroundButton;
    UIButton *rightButton;
    UIView *loaderView;
}

@property(nonatomic, retain) NSMutableArray *selectedFollowingList;
@property(nonatomic, retain) NSMutableArray *selectedGroupList;
@property(nonatomic) BOOL isPublic;
@property(nonatomic) SELECTION_MODE selectionMode;
@property (nonatomic, retain) IBOutlet UITableView *usersTableView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UILabel *searchLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) IBOutlet UILabel *publicLabel;
@property (nonatomic, retain) IBOutlet UISwitch *publicSwitch;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

-(Group*)getFirstSelectedGroup;
-(Friend*)getFirstSelectedFollower;

- (IBAction)backgroundClick:(id)sender;

@end

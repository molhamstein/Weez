//
//  MessagesListController.h
//  Weez
//
//  Created by Dania on 11/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeezBaseViewController.h"
#import "Timeline.h"
#import "SWTableViewCell.h"
#import "IBActionSheet.h"

@interface MessagesListController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, IBActionSheetDelegate>

{
    NSMutableArray *listOfMessages;
    NSMutableArray *filteredList;
    Timeline *selectedTimeline;
    Timeline *selectedTimelineToViewProfile;
    UITableView *usersTableView;
    UIRefreshControl *tableRefreshControl;
    UIView *searchView;
    UITextField *searchTextField;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *backgroundButton;
    UIView *loaderView;
    BOOL loadingInprogress;
}

@property (nonatomic, retain) IBOutlet UITableView *usersTableView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

@end

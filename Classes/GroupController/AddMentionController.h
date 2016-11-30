//
//  AddMentionController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "WeezBaseViewController.h"
#import "Group.h"

#define kTimelineMentionToTimeline 3
#define kEventMentionToTimelineCollection   1
#define kEventMentionToMap   2
#define kEventMentionToCreateGroup   5
#define kEventMentionToChat   6

@interface AddMentionController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *fullFollowingList;
    NSMutableArray *filteredList;
    NSMutableArray *fullGroupsList;
    NSMutableArray *filteredGroupsList;
    NSMutableArray *mentionedList;
    NSMutableArray *mentionedGroupsList;
    UITableView *usersTableView;
    UIView *searchView;
    UILabel *searchLabel;
    UITextField *searchTextField;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *backgroundButton;
    UIView *loaderView;
    TimelineType listType;
    int mentionType;
    BOOL enableGroups;
}

@property (nonatomic, retain) NSMutableArray *mentionedList;
@property (nonatomic, retain) NSMutableArray *mentionedGroupsList;
@property (nonatomic, retain) IBOutlet UITableView *usersTableView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UILabel *searchLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property int mentionType;
@property (nonatomic) BOOL enableGroups;
@property(nonatomic) SELECTION_MODE selectionMode;

- (void)setMentionListType:(TimelineType)type;
- (IBAction)backgroundClick:(id)sender;

- (NSMutableArray*) getAllMentionedUsersList;
-(Group*)getFirstSelectedGroup;
-(Friend*)getFirstSelectedFollower;

@end

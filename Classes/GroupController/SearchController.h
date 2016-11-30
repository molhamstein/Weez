//
//  SearchController.m
//  Weez
//
//  Created by Molham on 01/09/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "Tag.h"
#import "Location.h"
#import "WeezBaseViewController.h"
#import "GalleryView.h"

@interface SearchController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GalleryViewDelegate>
{
    NSMutableArray *listOfUsers;
    NSMutableArray *listOfLocations;
    NSMutableArray *listOfTags;
    UITableView *usersTableView;
    UIView *searchView;
    UILabel *searchLabel;
    UITextField *searchTextField;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *backgroundButton;
    UIView *loaderView;
    Friend *selectedFriend;
    Location *selectedLocation;
    Tag *selectedTag;
    //top
    SearchMode currentSearchMode;
    BOOL searchForTop;
    GalleryView* gallery;
    
    
    NSString *lastUsersSearchKeyword;
    NSString *lastLocationsSearchKeyword;
    NSString *lastTagsSearchKeyword;
    
    UIButton *usersTabButton;
    UIButton *locationsTabButton;
    UIButton *tagsTabButton;
}

@property (nonatomic, retain) IBOutlet UITableView *usersTableView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UILabel *searchLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property (nonatomic, retain) IBOutlet UIButton *usersTabButton;
@property (nonatomic, retain) IBOutlet UIButton *locationsTabButton;
@property (nonatomic, retain) IBOutlet UIButton *tagsTabButton;
@property (nonatomic, retain) IBOutlet GalleryView* gallery;



- (IBAction)backgroundClick:(id)sender;
- (IBAction)didTapUsersSegment:(id)sender;
- (IBAction)didTapLocationsSegment:(id)sender;
- (IBAction)didTapTagsSegment:(id)sender;

@end

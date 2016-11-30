//
//  TimelinesCollectionController.h
//  Weez
//
//  Created by Molham on 6/20/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Timeline.h"
#import "Tag.h"
#import "Event.h"
#import "WeezBaseViewController.h"
#import "SWTableViewCell.h"
#import "Group.h"
#import "IBActionSheet.h"

@import GoogleMaps;

@interface TimelinesCollectionController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SWTableViewCellDelegate, IBActionSheetDelegate>
{
    // views
    UITableView *timelinesTableView;
    UIImageView *coverImage;
    GMSMapView *googleMapView;
    UIView *loaderView;
    UIView *locationInfoContainer;
    UIButton *playAllButton;
    UIView *noResultView;
    UILabel *noResultLabel;
    UICollectionView *timelinesCollectionView;
    // LocationInfo views
    UIImageView *locationImage;
    UILabel *locationNameLabel;
    UILabel *locationFolowersTxtLabel;
    UIButton *followButton;
    UILabel *lblTotalMediaDuration;
    // data
    AppCollectionType collectionType;
    Tag *tag;
    NSString *locationId;
    NSMutableArray *listOfTimelines;
    NSMutableArray *listOfFriendsTimelines;
    Friend *selectedFriendToSubmit;
    Group *selectedGroupToSubmit;
    BOOL isPublic;
    Location *location;
    Event *event;
    Timeline *selectedTimeline;
    Timeline *selectedTimelineToViewProfile;
    BOOL isMoreData;
    BOOL isFriendSectionExist;
    int currentPage;
    BOOL loadingInProgress;
    BOOL shouldShareContent;
}

@property (nonatomic, retain) IBOutlet UITableView *timelinesTableView;
@property (nonatomic, retain) IBOutlet UICollectionView *timelinesCollectionView;
@property (nonatomic, retain) IBOutlet UIImageView *coverImage;
@property(nonatomic, retain) IBOutlet GMSMapView *googleMapView;
@property (nonatomic, strong) IBOutlet UIView *loaderView;
@property (nonatomic, strong) IBOutlet UIView *noResultView;
@property (nonatomic, strong) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) Timeline *selectedTimeline;
@property (nonatomic, retain) IBOutlet UIButton *playAllButton;
@property (nonatomic, retain) IBOutlet UIImageView *locationImage;
@property (nonatomic, retain) IBOutlet UILabel *locationNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationFolowersTxtLabel;
@property (nonatomic, retain) IBOutlet UIButton *followButton;
@property (nonatomic, retain) IBOutlet UIView *locationInfoContainer;
@property (nonatomic, retain) IBOutlet UILabel *lblTotalMediaDuration;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;

- (IBAction) playAllAction;
- (IBAction) followAction:(id)sender;
- (IBAction) showOnMap;
- (void) setType:(AppCollectionType)type withLocation:(Location*)location withTag:(Tag*)tag withEvent:(Event *)event;
- (IBAction)unwindEventMentionsSegue:(UIStoryboardSegue*)segue;
@end

//
//  ProfileController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserProfile.h"
#import "Media.h"
#import "Friend.h"
#import "Timeline.h"
#import "WeezBaseViewController.h"

#define kBoostsCollectionTag       0
#define kLocationsCollectionTag    1
#define kMediaCollectionTag        2

#define MAX_PROFILE_CELLS_COUNT    9

@interface ProfileController : WeezBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
{
    UIScrollView *scrollView;
    
    UILabel *userNameLabel;
    UILabel *bioLabel;
    UILabel *bioTitleLabel;
    UILabel *timelineTitleLabel;
    UILabel *boostsTitleLabel;
    UILabel *boostsCountLabel;
    UILabel *favLocationsTitleLabel;
    UILabel *favLocationsCountLabel;
    UILabel *duraionTitleLabel;
    UILabel *duraionLabel;
    UILabel *viewedTitleLabel;
    UILabel *viewedLabel;
    UILabel *locationsTitleLabel;
    UILabel *locationsLabel;
    UILabel *mediaTitleLabel;
    UILabel *mediaCountLabel;
    UILabel *mediaEmptyLabel;
    
    UILabel *followingTitleLabel;
    UILabel *followingLabel;
    UILabel *followersTitleLabel;
    UILabel *followersLabel;
    
    UIImageView *userImage;
    UIImageView *timelineCoverImage;
    UIView *headerContainer;
    UIView *timelineContainer;
    UIView *boostsContainer;
    UIView *favLocationsContainer;
    UIView *mediaContainer;
    UIView *privateContainer;
    
    NSLayoutConstraint *mediaContainerHeight;
    UILongPressGestureRecognizer *longPressRecognzer;
    UIView *bioContainer;
    NSLayoutConstraint *bioContainerHeight;
    
    UIView *loaderView;
    UICollectionView * boostsCollectionView;
    UICollectionView * favLocationsCollectionView;
    UICollectionView * mediaCollectionView;
    
    UIButton *followBtn;
    UIButton *settingsBtn;
    UIButton *editBtn;
    UIButton *chatBtn;
    UIImageView *progressBgImageView;
    UIImageView *progressImageView;
    UILabel *noBoostsLabel;
    UILabel *noFavLocationsLabel;
    UILabel *noMediaLabel;
    UILabel *privateLabel;
    
    UserProfile *activeUser;
    NSMutableArray *listOfMedia;
    Media *lastViewdMedia;
    int lastViewesMediaIndex;
    Timeline *selectedMedia;
    Location *selectedLocation;
    Event *selectedEvent;
    FollowType followType;
    
    NSMutableArray *combinedArrayOfFavEventAndLocations;
    
    BOOL isCollectionViewDirectionSetup;
    BOOL playTimeLineWithSpecificMedia;
    int selectedMediaIndex;
    Media *mediaToDelete;
    BOOL isDeletionMode;
    UIButton *_deleteButton;
    UIImage* navBarBackGroundImage;
    
}
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *bioLabel;
@property (nonatomic, retain) IBOutlet UILabel *bioTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *timelineTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *boostsTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *boostsCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *favLocationsTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *favLocationsCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *duraionTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *duraionLabel;
@property (nonatomic, retain) IBOutlet UILabel *viewedLabel;
@property (nonatomic, retain) IBOutlet UILabel *viewedTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationsTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationsLabel;
@property (nonatomic, retain) IBOutlet UILabel *mediaTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *mediaCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *mediaEmptyLabel;
@property (nonatomic, retain) IBOutlet UILabel *noBoostsLabel;
@property (nonatomic, retain) IBOutlet UILabel *noFavLocationsLabel;
@property (nonatomic, retain) IBOutlet UILabel *noMediaLabel;
@property (nonatomic, retain) IBOutlet UILabel *followingTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *followingLabel;
@property (nonatomic, retain) IBOutlet UILabel *followersTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *followersLabel;
@property (nonatomic, retain) IBOutlet UILabel *privateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *userImage;
@property (nonatomic, retain) IBOutlet UIImageView *timelineCoverImage;
@property (nonatomic, retain) IBOutlet UIView *headerContainer;
@property (nonatomic, retain) IBOutlet UIView *bioContainer;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *bioContainerHeight;
@property (nonatomic, retain) IBOutlet UIView *timelineContainer;
@property (nonatomic, retain) IBOutlet UIView *boostsContainer;
@property (nonatomic, retain) IBOutlet UIView *favlocationsContainer;
@property (nonatomic, retain) IBOutlet UIView *mediaContainer;
@property (nonatomic, retain) IBOutlet UIView *privateContainer;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *mediaContainerHeight;


@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property (nonatomic, retain) IBOutlet UIImageView *progressBgImageView;
@property (nonatomic, retain) IBOutlet UIImageView *progressImageView;
@property (nonatomic, retain) IBOutlet UICollectionView * boostsCollectionView;
@property (nonatomic, retain) IBOutlet UICollectionView * favLocationsCollectionView;
@property (nonatomic, retain) IBOutlet UICollectionView * mediaCollectionView;
@property (nonatomic, retain) IBOutlet UIButton *followBtn;
@property (nonatomic, retain) IBOutlet UIButton *settingsBtn;
@property (nonatomic, retain) IBOutlet UIButton *editBtn;
@property (nonatomic, retain) IBOutlet UIButton *chatBtn;
@property (nonatomic, retain) UserProfile *activeUser;
@property (nonatomic, retain) Media *lastViewdMedia;
@property int lastViewesMediaIndex;

- (void)setProfileWithUser:(User*)user;
- (void)setProfileWithTimeline:(Timeline*)timeline;
- (void)setProfileWithFriend:(Friend*)friendObj;
- (IBAction)followAction:(id)sender;
- (IBAction)playTimelineAction:(id)sender;
- (IBAction)showFollowers:(id)sender;
- (IBAction)showFollowing:(id)sender;
- (IBAction)chatAction:(id)sender;

@end

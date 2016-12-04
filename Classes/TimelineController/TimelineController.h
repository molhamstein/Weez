//
//  TimelineController.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeline.h"
#import "SSVideoPlayer.h"
#import "Location.h"
#import "IBActionSheet.h"
#import "Event.h"
#import "WeezBaseViewController.h"

@interface TimelineController : WeezBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, SSVideoPlayerDelegate, IBActionSheetDelegate>
{
    Timeline *activeTimeline;
    Location *timelineLocation;
    Event *timelineEvent;
    UIImageView *bgImageView;
    UIVisualEffectView *blurEffectView;
    UIView *detailsView;
    UIImageView *profileImageView;
    UIImageView *progressBgImageView;
    UIImageView *progressImageView;
    UILabel *usernameLabel;
    UILabel *lastDateLabel;
    UILabel *boostsCountLabel;
    UIImageView *boostsCountIcon;
    UIButton *startButton;
    UIButton *followButton;
    UIButton *shareButton;
    UIButton *boostButton;
    UIButton *mentionButton;
    UIButton *infoButton;
    UILabel *durationTitleLabel;
    UILabel *durationLabel;
    UIView *watchedView;
    UILabel *watchedTitleLabel;
    UILabel *watchedLabel;
    UILabel *locationTitleLabel;
    UILabel *locationLabel;
    UIButton *pauseButton;
    // mention & boost
    UIView *actorView;
    UIImageView *actorImageView;
    UILabel *actorTitleLabel;
    UILabel *actorLabel;
    // player
    NSMutableArray *listOfMedia;
    int playIndex;
    SSVideoPlayer *player;
    NSTimer *playImageTimer;
    int timeOut;
    BOOL isFullScreen;
    BOOL isDetailVisible;
    BOOL isMediaControllsVisible;
    BOOL isPaused;
    BOOL isFirstTime;
    BOOL hasNextTimeline; // used to show/hide next button in Location timeline
    BOOL hasPrevTimeline;
    BOOL isLoadingTimeline;
    UIView *playContainerView;
    UIView *footerContainerView;
    UICollectionView *timelineCollectionView;
    UIButton *closeButton;
    UIButton *overlayButton;
    UIView *mediaLocView;
    UIImageView *mediaLocImageView;
    UILabel *mediaLocLabel;
    UIActivityIndicatorView *loaderView;
    UILabel *privateLabel;
    UIView *privateContainer;
    UIView *swipeabaleLayout;
    CGFloat previousSwipeAmmount;
    
    BOOL playSpecificMedia;
    int initialMediaIndex;
}

@property(nonatomic, retain) IBOutlet UIImageView *bgImageView;
@property(nonatomic, retain) IBOutlet UIView *detailsView;
@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UIImageView *progressBgImageView;
@property(nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property(nonatomic, retain) IBOutlet UILabel *lastDateLabel;
@property(nonatomic, retain) IBOutlet UILabel *boostsCountLabel;
@property(nonatomic, retain) IBOutlet UIImageView *boostsCountIcon;
@property(nonatomic, retain) IBOutlet UIButton *startButton;
@property(nonatomic, retain) IBOutlet UIButton *followButton;
@property(nonatomic, retain) IBOutlet UIButton *shareButton;
@property(nonatomic, retain) IBOutlet UIButton *boostButton;
@property(nonatomic, retain) IBOutlet UIButton *mentionButton;
@property(nonatomic, retain) IBOutlet UIButton *infoButton;
@property(nonatomic, retain) IBOutlet UILabel *durationTitleLabel;
@property(nonatomic, retain) IBOutlet UILabel *durationLabel;
@property(nonatomic, retain) IBOutlet UIView *watchedView;
@property(nonatomic, retain) IBOutlet UILabel *watchedTitleLabel;
@property(nonatomic, retain) IBOutlet UILabel *watchedLabel;
@property(nonatomic, retain) IBOutlet UILabel *locationTitleLabel;
@property(nonatomic, retain) IBOutlet UILabel *locationLabel;
@property(nonatomic, retain) IBOutlet UIView *swipeabaleLayout;
@property (nonatomic, retain) IBOutlet UILabel *privateLabel;
@property (nonatomic, retain) IBOutlet UIView *privateContainer;
// mention & boost
@property(nonatomic, retain) IBOutlet UIView *actorView;
@property(nonatomic, retain) IBOutlet UIImageView *actorImageView;
@property(nonatomic, retain) IBOutlet UILabel *actorTitleLabel;
@property(nonatomic, retain) IBOutlet UILabel *actorLabel;
// player
@property (nonatomic,strong) SSVideoPlayer *player;
@property (nonatomic) BOOL isPaused;
@property (nonatomic,strong) IBOutlet UIView *playContainerView;
@property (nonatomic,strong) IBOutlet UIView *footerContainerView;
@property (nonatomic,retain) IBOutlet UICollectionView *timelineCollectionView;
@property (nonatomic,strong) IBOutlet UIButton *closeButton;
@property (nonatomic,strong) IBOutlet UIButton *overlayButton;
@property (nonatomic,strong) IBOutlet UIView *mediaLocView;
@property (nonatomic,strong) IBOutlet UIImageView *mediaLocImageView;
@property (nonatomic,strong) IBOutlet UILabel *mediaLocLabel;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *loaderView;
@property (nonatomic,strong) IBOutlet Location *timelineLocation;
@property (nonatomic,strong) IBOutlet Event *timelineEvent;
@property (nonatomic,strong) IBOutlet UIButton *pauseButton;
@property BOOL hasNextTimeline;
@property BOOL hasPrevTimeline;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipeabaleLayoutXCenterConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerContainerXCenterConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fullImageContainerXCenterConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mediaSelectionBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailsViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *boostButtonLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionButtonTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareButtonTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoButtonLeadingConstraint;

- (IBAction)cancelAction:(id)sender;
- (IBAction)profileAction:(id)sender;
- (IBAction)startAction:(id)sender;
- (IBAction)followAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)boostAction:(id)sender;
- (IBAction)mentionAction:(id)sender;
- (IBAction)infoAction:(id)sender;
- (IBAction)openLocationAction:(id)sender;
- (IBAction)unwindMentionSegue:(UIStoryboardSegue*)segue;
- (IBAction)actionPause:(id)sender;
-(IBAction)playPreviousMedia:(id)sender;
-(IBAction)playNextMedia:(id)sender;
- (void)setTimelineObject:(Timeline*)timelineObj withLocation:(Location*)location orEvent:(Event*)event;
- (void)setMediaList:(NSMutableArray*)mediaList withSelectedIndex:(int)indexToPlay;
@end


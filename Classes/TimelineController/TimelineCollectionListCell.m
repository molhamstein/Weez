//
//  TimelineListCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TimelineCollectionListCell.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "AppManager.h"

@implementation TimelineCollectionListCell

@synthesize thumbnailView;
@synthesize profileImageView;
@synthesize thumbnailImageView;
@synthesize progressBgImageView;
@synthesize progressImageView;
@synthesize usernameLabel;
@synthesize lastDateLabel;
@synthesize durationLabel;
@synthesize locationView;
@synthesize locationNoLabel;
@synthesize locationImageView;
@synthesize watchedView;
@synthesize watchedTimeLabel;
@synthesize progressLabel;
@synthesize profileButton;
@synthesize locationsButton;
@synthesize chatIndicator;
@synthesize mediaButton;
@synthesize moreButton;

// mention & boost
@synthesize actorView;
@synthesize actorImageView;
@synthesize actorLabel;

#pragma mark -
#pragma mark Cell main functions
// Populate cell and set content
- (void)populateCellWithContent:(Timeline*)timelineObject
{
    timelineObj = timelineObject;
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:timelineObject.smallThumb] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
    }];
    // round thumb image
    thumbnailView.backgroundColor = [UIColor clearColor];
    CALayer *imageLayer = thumbnailImageView.layer;
    [imageLayer setCornerRadius:thumbnailImageView.frame.size.width/2];
    [imageLayer setBorderWidth:0];
    [imageLayer setMasksToBounds:YES];
    
    // progress
    progressLabel.progressWidth = 4;
    [progressLabel setTransform:CGAffineTransformMakeScale(-1, 1)];
    progressLabel.trackColor = [UIColor clearColor];
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.progressColor = [UIColor whiteColor]; //[[AppManager sharedManager] getColorType:kAppColorRed];
    [progressLabel setProgress: 1.0f - (float)timelineObject.viewedPercentage / 100.0];

    
    // set profile
    TimelineCollectionListCell __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:timelineObject.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
    }];
    
    // username, duration and last updated date
    usernameLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    if(timelineObject.canChat)
        usernameLabel.textColor = [[AppManager sharedManager] getColorType:kAppColorDarkBlue];
    else
        usernameLabel.textColor = [[AppManager sharedManager] getColorType:kAppColorLightGray];
    usernameLabel.text = timelineObject.username;
    lastDateLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    lastDateLabel.text = [timelineObject getUpdatedDateString:YES];
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:timelineObject.mediaDuration];
    watchedTimeLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];    
    watchedTimeLabel.text = [[AppManager sharedManager] getMediaDuration:timelineObject.totalViewed];
    [watchedView setHidden:YES];
    // location
    [locationView setHidden:YES];
//    if (timelineObject.locationNo > 0)
//        [locationView setHidden:NO];
    locationNoLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    locationNoLabel.text = [NSString stringWithFormat:@"%i", timelineObject.locationNo];
    // mention & boost
    actorLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    actorLabel.text = timelineObject.actorUsername;
    [actorView setHidden:YES];
    [chatIndicator setHidden:YES];
    if (timelineObject.timelineType == kTimelineTypeBoost)
    {
        [watchedView setHidden:YES];
        [actorView setHidden:NO];
        actorImageView.image = [UIImage imageNamed:@"timelineBoostIcon"];
    }
    else if (timelineObject.timelineType == kTimelineTypeMention)
    {
        [watchedView setHidden:YES];
        [actorView setHidden:NO];
        actorImageView.image = [UIImage imageNamed:@"timelineMentionIcon"];
    }
    else if (timelineObject.timelineType == kTimelineTypeChat)
    {
        [watchedView setHidden:YES];
        [actorView setHidden:NO];
        actorLabel.text = @"";
        //actorImageView.image = [UIImage imageNamed:@"timelineChatIcon"];
        actorImageView.image = nil;
        
        // round chat indicator
        [chatIndicator setHidden:NO];
        CALayer *indicatorLayer = chatIndicator.layer;
        [indicatorLayer setCornerRadius:chatIndicator.frame.size.width/2];
        [indicatorLayer setBorderWidth:0];
        [indicatorLayer setMasksToBounds:YES];
    }
   
    // hide separator
    progressBgImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}


- (void)initSwipeActions:(id<SWTableViewCellDelegate>)delegate{
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = (CGRect){
        .size = CGSizeMake(self.frame.size.width/3, self.frame.size.height)
    };
    if(timelineObj.timelineType != kTimelineTypeGroup){
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionButton.backgroundColor = [UIColor whiteColor];
        [actionButton setImage:[UIImage imageNamed:@"moreActions"] forState:UIControlStateNormal];
        [actionButton setImageEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
        actionButton.tag = CELL_SWIPE_ACTION_TAG_MORE;
        moreButton = actionButton;
    }else{
        UIButton *swipeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        swipeButton.backgroundColor = [UIColor whiteColor];
        [swipeButton setImage:[UIImage imageNamed:@"composeTextMsg"] forState:UIControlStateNormal];
        [swipeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
        swipeButton.tag = CELL_SWIPE_ACTION_TAG_CHAT;
        moreButton = swipeButton;
    }
    self.allowedDirection = CADRACSwippableCellAllowedDirectionLeft;
    self.revealView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [moreButton setFrame:({
        CGRect frame = CGRectMake(0, 0, 50, 50);
        frame.origin.x = (bottomView.frame.size.width - frame.size.width) / 2.0;
        frame.origin.y = (bottomView.frame.size.height - frame.size.height) / 2.0;
        CGRectIntegral(frame);
    })];
    [bottomView addSubview:moreButton];
    //self.delegate = delegate;
}

// Clip cell to bounds
- (BOOL)clipsToBounds
{
    [super clipsToBounds];
    return YES;
}

@end

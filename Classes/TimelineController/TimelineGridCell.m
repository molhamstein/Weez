//
//  TimelineGridCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TimelineGridCell.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "AppManager.h"

@implementation TimelineGridCell

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
@synthesize locationsButton;
@synthesize profileButton;
@synthesize chatIndicator;
// mention & boost
@synthesize actorView;
@synthesize actorImageView;
@synthesize actorLabel;
@synthesize groupIndicator;
@synthesize mediaButton;

#pragma mark -
#pragma mark Cell main functions
// Populate cell and set content
- (void)populateCellWithContent:(Timeline*)timelineObject
{
    timelineObj = timelineObject;
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:timelineObject.largeThumb] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
    }];
    // set profile
    TimelineGridCell __weak *weakSelf = self;
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
    lastDateLabel.text = [timelineObject getUpdatedDateString:NO];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:timelineObject.mediaDuration];
    watchedTimeLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];    
    watchedTimeLabel.text = [[AppManager sharedManager] getMediaDuration:timelineObject.totalViewed];
    [watchedView setHidden:YES];
    // location
    [locationView setHidden:YES];
//    if (timelineObject.locationNo > 0)
//        [locationView setHidden:NO];
//    locationNoLabel.text = [NSString stringWithFormat:@"%i", timelineObject.locationNo];
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
    
    [groupIndicator setHidden:YES];
//    if (timelineObject.timelineType == kTimelineTypeGroup)
//    {
//        // round group indicator
//        [groupIndicator setHidden:NO];
//        CALayer *indicatorLayer = groupIndicator.layer;
//        [indicatorLayer setCornerRadius:groupIndicator.frame.size.width/2];
//        [indicatorLayer setBorderWidth:0];
//        [indicatorLayer setMasksToBounds:YES];
//    }
    
    // hide separator
    progressBgImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

- (void)initSwipeActions:(id<SWTableViewCellDelegate>)delegate{
    if(timelineObj.timelineType != kTimelineTypeGroup){
//        UIButton *swipeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        swipeButton.backgroundColor = [UIColor whiteColor];
//        [swipeButton setImage:[UIImage imageNamed:@"composeTextMsg"] forState:UIControlStateNormal];
//        [swipeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
//        swipeButton.tag = CELL_SWIPE_ACTION_TAG_CHAT;
//        
//        UIButton *swipeReportButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        swipeReportButton.backgroundColor = [UIColor whiteColor];
//        [swipeReportButton setImage:[UIImage imageNamed:@"reportUser"] forState:UIControlStateNormal];
//        [swipeReportButton setImageEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
//        swipeReportButton.tag = CELL_SWIPE_ACTION_TAG_REPORT;
//        
//        UIButton *swipeLocationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        swipeLocationsButton.backgroundColor = [UIColor whiteColor];
//        [swipeLocationsButton setImage:[UIImage imageNamed:@"userLocationsIcon"] forState:UIControlStateNormal];
//        [swipeLocationsButton setImageEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
//        swipeLocationsButton.tag = CELL_SWIPE_ACTION_TAG_LOCATIONS;
//        
//        if(timelineObj.locationNo > 0 && timelineObj.canChat)
//            self.rightUtilityButtons = @[swipeButton, swipeLocationsButton];
//        else if(timelineObj.locationNo > 0 && !timelineObj.canChat)
//            self.rightUtilityButtons = @[swipeLocationsButton];
//        else if(timelineObj.locationNo <= 0 && timelineObj.canChat)
//            self.rightUtilityButtons = @[swipeButton];
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.backgroundColor = [UIColor whiteColor];
        [moreButton setImage:[UIImage imageNamed:@"moreActions"] forState:UIControlStateNormal];
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
        moreButton.tag = CELL_SWIPE_ACTION_TAG_MORE;
        
        self.rightUtilityButtons = @[moreButton];
    }else{
        UIButton *swipeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        swipeButton.backgroundColor = [UIColor whiteColor];
        [swipeButton setImage:[UIImage imageNamed:@"composeTextMsg"] forState:UIControlStateNormal];
        [swipeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 24, 0, 0)];
        swipeButton.tag = CELL_SWIPE_ACTION_TAG_CHAT;
        
        self.rightUtilityButtons = @[swipeButton];
    }
    self.delegate = delegate;
}

@end

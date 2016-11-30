//
//  TimelineChatListCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TimelineChatListCell.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "AppManager.h"

@implementation TimelineChatListCell

@synthesize profileImageView;
@synthesize progressBgImageView;
@synthesize usernameLabel;
@synthesize lastDateLabel;
@synthesize actorLabel;
@synthesize messageLabel;
@synthesize mediaTypeView;
@synthesize mediaTypeImageView;
@synthesize mediaTypeLabel;
@synthesize groupIndicator;
@synthesize actorWidth;
@synthesize profileButton;

#pragma mark -
#pragma mark Cell main functions
// Populate cell and set content
- (void)populateCellWithContent:(Timeline*)timelineObject
{
    timelineObj = timelineObject;
    // set profile
    TimelineChatListCell __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:timelineObject.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
    }];
    // username, duration and last updated date
    usernameLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    usernameLabel.text = timelineObject.username;
    lastDateLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    lastDateLabel.text = [timelineObject getUpdatedDateString:YES];
    actorLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    messageLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    mediaTypeLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    // actor block
    NSString *actorName = timelineObject.actorUsername;
    if ([[[ConnectionManager sharedManager] userObject].objectId isEqualToString:timelineObject.actorId])
        actorName = [[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_ME"];
    actorLabel.text = [NSString stringWithFormat:@"%@: ", actorName];
    // hide message and media type
    messageLabel.hidden = YES;
    mediaTypeView.hidden = NO;
    // show message
    messageLabel.text = timelineObject.actorMessage;
    // check media case
    if (timelineObject.actorLastMediaType == kMediaTypeImage)
    {
        mediaTypeImageView.image = [UIImage imageNamed:@"messageTypePhoto"];
        mediaTypeLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_TYPE_PHOTO"];
    }
    else if (timelineObject.actorLastMediaType == kMediaTypeVideo)
    {
        mediaTypeImageView.image = [UIImage imageNamed:@"messageTypeVideo"];
        mediaTypeLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_TYPE_VIDEO"];
    }
    else if (timelineObject.actorLastMediaType == kMediaTypeAudio)
    {
        mediaTypeImageView.image = [UIImage imageNamed:@"messageTypeSound"];
        mediaTypeLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_TYPE_AUDIO"];
    }
    else if (timelineObject.actorLastMediaType == kMediaTypeLocation)
    {
        mediaTypeImageView.image = [UIImage imageNamed:@"searchLocations"];
        mediaTypeLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_TYPE_LOCATION"];
    }
    else// text case
    {
        mediaTypeView.hidden = YES;
        messageLabel.hidden = NO;
    }
    
    [groupIndicator setHidden:YES];
    if (timelineObject.timelineType == kTimelineTypeGroup)
    {
        [actorLabel sizeToFit];
        actorWidth.constant = actorLabel.frame.size.width;
    }
    else
    {
        actorWidth.constant = 0.01f;
    }
    
    // hide separator
    progressBgImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
    // panning cell
    UIPanGestureRecognizer *panning = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanning:)];
    panning.delegate = self;
    [self.contentView addGestureRecognizer:panning];
}

// Simultaneous gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

// Handle panning request
- (void)handlePanning:(UIPanGestureRecognizer *)sender
{
    /*let translation = recognizer.translationInView(self)
    
    if recognizer.state == .Changed {
        center = CGPointMake(center.x + translation.x, center.y)
        startSegue = frame.origin.x < -frame.size.width / 2.0                       // If swiped over 50%, return true
        label.textColor = startSegue ? UIColor.redColor() : UIColor.whiteColor()    // If swiped over 50%, become red
        recognizer.setTranslation(CGPointZero, inView: self)
    }
    if recognizer.state == .Ended {
        let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
        if delegate != nil {
            startSegue ? delegate!.something() : UIView.animateWithDuration(0.2) { self.frame = originalFrame }
        }
    }*/
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
        
        //        BOOL chatAlowed = timelineObj.canChat && ![timelineObj.userId isEqualToString:[ConnectionManager sharedManager].userObject.objectId];
        //
        //        if(timelineObj.locationNo > 0 && chatAlowed)
        //            self.rightUtilityButtons = @[swipeButton, swipeLocationsButton];
        //        else if(timelineObj.locationNo > 0 && !chatAlowed)
        //            self.rightUtilityButtons = @[swipeLocationsButton];
        //        else if(timelineObj.locationNo <= 0 && chatAlowed)
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

// Clip cell to bounds
- (BOOL)clipsToBounds
{
    [super clipsToBounds];
    return YES;
}

@end

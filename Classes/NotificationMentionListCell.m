//
//  NotificationMentionListCell.m
//  Weez
//
//  Created by Dania on 11/3/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "NotificationMentionListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"
#import "Friend.h"

@implementation NotificationMentionListCell

@synthesize imageView;
@synthesize titleLabel;
@synthesize descLabel;
@synthesize dateLabel;
@synthesize thumbnailView;
@synthesize thumbnailImageView;
@synthesize progressLabel;


#pragma mark -
#pragma mark Cell main functions

// Populate cell and set content
- (void)populateCellWithContent:(AppNotification*)object
{
    
    NSString *title;
    NSString *imgUrl;
    NSString *previewUrl;
    NSString *desc;
    
    if(object.type == kAppNotificationTypeSomeoneAddedYouToGroup)//group case
    {   title = [[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_ADDED_TO_GROUP"];
        desc = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_ADDED_TO_GROUP_DESC"], object.actor.username, object.group.name];
        imgUrl = object.actor.profilePic;
        previewUrl = object.group.image;
    }
    else//mention case
    {
        title = [[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_MENTIONED"];
        desc = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_MENTIONED_DESC"], object.actor.username];
        imgUrl = object.actor.profilePic;
        previewUrl = object.timeline.smallThumb;
    }
    
    // display name and username
    
    titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    titleLabel.text = title;
    
    // date
    dateLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    dateLabel.text = [object getCreatedDateString:YES];
    
    // location image
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.masksToBounds = YES;
    // set actor image
    NotificationMentionListCell __weak *weakSelf = self;
    [imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.imageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.imageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    
    if(object.type == kAppNotificationTypeSomeoneAddedYouToGroup)
    {
        [progressLabel setHidden:NO];
        progressLabel.progressWidth = 4;
        [progressLabel setTransform:CGAffineTransformMakeScale(-1, 1)];
        progressLabel.trackColor = [UIColor clearColor];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.progressColor = [UIColor whiteColor]; //[[AppManager sharedManager] getColorType:kAppColorRed];
        [progressLabel setProgress: 1.0f];
        
    }
    else
    {
        // progress
        progressLabel.progressWidth = 4;
        [progressLabel setTransform:CGAffineTransformMakeScale(-1, 1)];
        progressLabel.trackColor = [UIColor clearColor];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.progressColor = [UIColor whiteColor]; //[[AppManager sharedManager] getColorType:kAppColorRed];
        [progressLabel setProgress: 1.0f - (float)object.timeline.viewedPercentage / 100.0];

    }
    
    // set description
    NSString *originalText = desc;
    NSString *actorName = object.actor.username;
    NSMutableAttributedString *coloredTxt = [[NSMutableAttributedString alloc] initWithString:originalText];
    // Sets the font color of actor to blue.
    NSRange range = [originalText rangeOfString:actorName];
    if (range.location != NSNotFound)
        [coloredTxt addAttribute: NSForegroundColorAttributeName value:[[AppManager sharedManager] getColorType:kAppColorDarkBlue] range: NSMakeRange(range.location , actorName.length)];
    descLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    descLabel.attributedText = coloredTxt;
    
    //preview thumbnail
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:previewUrl] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
     }];
    // round thumb image
    thumbnailView.backgroundColor = [UIColor clearColor];
    CALayer *imageLayer = thumbnailImageView.layer;
    [imageLayer setCornerRadius:thumbnailImageView.frame.size.width/2];
    [imageLayer setBorderWidth:0];
    [imageLayer setMasksToBounds:YES];
    
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}


@end


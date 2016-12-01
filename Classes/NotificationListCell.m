//
//  NotificationListCell.m
//  Weez
//
//  Created by Molham on 8/24/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "NotificationListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"

@implementation NotificationListCell

@synthesize imageView;
@synthesize titleLabel;
@synthesize descLabel;
@synthesize dateLabel;

#pragma mark -
#pragma mark Cell main functions

// Populate cell and set content
- (void)populateCellWithContent:(AppNotification*)object
{
    
    NSString *title;
    NSString *imgUrl;
    NSString *desc;
    
    // compose notificaton message according to notification type
    switch (object.type) {
        case kAppNotificationTypeNewMessageInChat:
            title = [[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_NEW_CHAT_MESSAGE"];
            desc = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_NEW_CHAT_MESSAGE_DESC"], object.actor.username];
            imgUrl = object.actor.profilePic;
            break;
        case kAppNotificationTypeNewMessageInGroup:
            title = [[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_NEW_GROUP_MESSAGE"];
            desc = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_NEW_GROUP_MESSAGE_DESC"], object.group.name];
            imgUrl = object.group.image;
            break;
        case kAppNotificationTypeSomeoneMentionedYouInEvent:
            title = [[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_MENTIONED_IN_EVENT"];
            desc = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_MENTIONED_IN_EVENT_DESC"], object.actor.username, object.event.name];
            imgUrl = object.event.image;
            break;
        default:
            break;
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
    // set thumbnail
    NotificationListCell __weak *weakSelf = self;
    [imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.imageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.imageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    
    
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
    
    
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

@end

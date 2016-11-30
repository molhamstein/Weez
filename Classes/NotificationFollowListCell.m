//
//  NotificationFollowListCell.m
//  Weez
//
//  Created by Dania on 11/2/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "NotificationFollowListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"
#import "Friend.h"

@implementation NotificationFollowListCell

@synthesize imageView;
@synthesize titleLabel;
@synthesize descLabel;
@synthesize dateLabel;
@synthesize followButton;

#pragma mark -
#pragma mark Cell main functions

// Populate cell and set content
- (void)populateCellWithContent:(AppNotification*)object
{
    
    NSString *title;
    NSString *imgUrl;
    NSString *desc;
    
    title = [[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_NEW_FOLLOWER"];
    desc = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"NOTIFICATION_NEW_FOLLOWER_DESC"], object.actor.username];
    imgUrl = object.actor.profilePic;
    
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
    NotificationFollowListCell __weak *weakSelf = self;
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
    
    
    // follow/unfollow this user
    [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
    [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
    [followButton setTitle:@"" forState:UIControlStateNormal];
    // following this friend
    
    Friend *friendObject = [[Friend alloc] init];
    friendObject.objectId = object.actor.objectId;
    //if I follow the actore
    if ([friendObject isFollowing])
    {
        [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
        [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
        [followButton setTitle:@"" forState:UIControlStateNormal];
    }
    // this is my profile
    [followButton setHidden:NO];
    if ([object.actor.objectId isEqualToString:[[ConnectionManager sharedManager] userObject].objectId])
        [followButton setHidden:YES];
    
    
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}


@end

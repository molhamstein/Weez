//
//  FriendListCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "FriendListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"

@implementation FriendListCell

@synthesize profileImageView;
@synthesize displayNameLabel;
@synthesize usernameLabel;
@synthesize followButton;
@synthesize mentionImageView;
@synthesize separatorImageView;

#pragma mark -
#pragma mark Cell main functions
// Populate cell and set content
- (void)populateCellWithContent:(Friend*)friendObject
{
    // set profile image
    FriendListCell __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:friendObject.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
    }];
    // display name and username
    displayNameLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    usernameLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    displayNameLabel.text = friendObject.username;
    usernameLabel.text = @"";
    // hide mention image
    [mentionImageView setHidden:YES];
    // follow/unfollow this user
    [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
    [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
    [followButton setTitle:@"" forState:UIControlStateNormal];
    // following this friend
    if ([friendObject isFollowing])
    {
        [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
        [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
        [followButton setTitle:@"" forState:UIControlStateNormal];          
    }
    // this is my profile
    [followButton setHidden:NO];
    if ([friendObject.objectId isEqualToString:[[ConnectionManager sharedManager] userObject].objectId])
        [followButton setHidden:YES];
    // hide separateor
    separatorImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

// Populate cell and set content
- (void)populateCellWithContent:(Friend*)friendObject withMention:(BOOL)isMentioned
{
    // set profile image
    FriendListCell __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:friendObject.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
    }];
    // display name and username
    displayNameLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    usernameLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    displayNameLabel.text = friendObject.username;
    usernameLabel.text = @"";
    // hide mention image
    [mentionImageView setHidden:YES];
    if (isMentioned)
        [mentionImageView setHidden:NO];
    // hide follow button
    [followButton setHidden:YES];
    // hide separateor
    separatorImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

@end

//
//  MemberListCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "MemberListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"

@implementation MemberListCell

@synthesize profileImageView;
@synthesize displayNameLabel;
@synthesize usernameLabel;
@synthesize removeButton;
@synthesize adminImageView;
@synthesize separatorImageView;

#pragma mark -
#pragma mark Cell main functions
// Populate member cell and set content
- (void)populateMemberWithContent:(Friend*)friendObject withAdminList:(NSMutableArray*)adminList
{
    // set profile image
    MemberListCell __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:friendObject.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
    }];
    // display name and username
    displayNameLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    usernameLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    usernameLabel.text = @"";
//    displayNameLabel.text = friendObject.displayName;
    displayNameLabel.text = friendObject.username;
    // hide remove and amdin button
    [removeButton setHidden:YES];
    [adminImageView setHidden:YES];
    // admin can remove members
    NSString *myId = [[ConnectionManager sharedManager] userObject].objectId;
    if ([adminList containsObject:myId])
        [removeButton setHidden:NO];
    if ([friendObject.objectId isEqualToString:myId])
        [removeButton setHidden:YES];
    if ([adminList containsObject:friendObject.objectId])
    {
        [removeButton setHidden:YES];
        [adminImageView setHidden:NO];
    }
    // hide separateor
    separatorImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

// Populate group cell and set content
- (void)populateGroupWithContent:(Group*)groupObject withAdmin:(BOOL)isAdmin
{
    // set profile image
    MemberListCell __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:groupObject.image] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
    }];
    // display name and username
    displayNameLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    usernameLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    displayNameLabel.text = groupObject.name;
    // create list of users
    NSString *listStr = @"";
    NSMutableArray *tempList = [[NSMutableArray alloc] initWithArray:groupObject.members];
    int removeIndex = -1;
    for (int i = 0; i < [tempList count]; i++)
    {
        Friend *obj = (Friend*)[tempList objectAtIndex:i];
        if ([obj.objectId isEqualToString:[[ConnectionManager sharedManager] userObject].objectId])
        {
            removeIndex = i;
            break;
        }
    }
    if (removeIndex > -1)
    [tempList removeObjectAtIndex:removeIndex];
    switch ([tempList count])
    {
        case 0:
        {
            break;
        }
        case 1:
        {
            Friend *obj = [tempList objectAtIndex:0];
            listStr = [[[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_DESCRIPTION1"] stringByReplacingOccurrencesOfString:@"{name1}" withString:obj.username];
            break;
        }
        case 2:
        {
            Friend *obj1 = [tempList objectAtIndex:0];
            Friend *obj2 = [tempList objectAtIndex:1];
            listStr = [[[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_DESCRIPTION2"] stringByReplacingOccurrencesOfString:@"{name1}" withString:obj1.username];
            listStr = [listStr stringByReplacingOccurrencesOfString:@"{name2}" withString:obj2.username];
            break;
        }
        default:
        {
            Friend *obj1 = [tempList objectAtIndex:0];
            listStr = [[[AppManager sharedManager] getLocalizedString:@"GROUP_MEMBERS_DESCRIPTION3"] stringByReplacingOccurrencesOfString:@"{name1}" withString:obj1.username];
            listStr = [listStr stringByReplacingOccurrencesOfString:@"{number}" withString:[NSString stringWithFormat:@"%i", (int)[tempList count]-1]];
            break;
        }
    }
    usernameLabel.text = listStr;
    // admin can remove members
    [removeButton setHidden:YES];
    // hide admin
    adminImageView.hidden = ! isAdmin;
    // hide separateor
    separatorImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

- (void) setGroupSelected:(BOOL) selected{
    removeButton.hidden = YES;
    if(selected){
        adminImageView.hidden = NO;
        adminImageView.image = [UIImage imageNamed:@"friendMentionIconActive"];
    }else{
        adminImageView.hidden = YES;
    }
}

@end

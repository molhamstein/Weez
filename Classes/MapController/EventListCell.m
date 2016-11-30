//
//  EventListCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "EventListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"

@implementation EventListCell

@synthesize eventImageView;
@synthesize eventLabel;
@synthesize addressLabel;
@synthesize separatorImageView;
@synthesize followButton;
@synthesize mentionButton;
@synthesize playButton;

// Populate cell and set content
- (void)populateCellWithEventContent:(Event*)eventObject withFollow:(BOOL)withFollowing
{
    // display name and username
    eventLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    eventLabel.text = eventObject.name;
    // location image
    eventImageView.contentMode = UIViewContentModeScaleAspectFill;
    eventImageView.layer.masksToBounds = YES;
    // set thumbnail
    EventListCell __weak *weakSelf = self;
    [eventImageView sd_setImageWithURL:[NSURL URLWithString:eventObject.image] placeholderImage:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.eventImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.eventImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // show country/city
    addressLabel.hidden = NO;
    addressLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    // fill in address
    NSString *address = eventObject.location.address;
    addressLabel.text = address;

    // follow/unfollow this user
    [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
    [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
    [followButton setTitle:@"" forState:UIControlStateNormal];
    
    // following this friend
    if ([eventObject isFollowing])
    {
        [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
        [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
        [followButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    separatorImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

@end

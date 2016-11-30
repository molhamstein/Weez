//
//  LocationListCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "LocationListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"

@implementation LocationListCell

@synthesize locationImageView;
@synthesize locationLabel;
@synthesize addressLabel;
@synthesize statusLabel;
@synthesize chosenImageView;
@synthesize separatorImageView;
@synthesize followButton;

#pragma mark -
#pragma mark Cell main functions
// Populate cell and set content
- (void)populateCellWithContent:(Location*)locationObject withSelected:(BOOL)isSelected
{
    // display name and username
    locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    locationLabel.text = locationObject.name;
    // location image
    locationImageView.contentMode = UIViewContentModeScaleAspectFill;
    locationImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationListCell __weak *weakSelf = self;
    [locationImageView sd_setImageWithURL:[NSURL URLWithString:locationObject.image] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
    }];
    // chosen location
    chosenImageView.hidden = YES;
    followButton.hidden = YES;
    if (isSelected)
        chosenImageView.hidden = NO;
    // hide status
    statusLabel.hidden = YES;
    // hide separateor
    separatorImageView.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

// Populate cell and set content
- (void)populateCellWithContent:(Location*)locationObject
{
    // display name and username
    locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    locationLabel.text = locationObject.name;
    // location image
    locationImageView.contentMode = UIViewContentModeScaleAspectFill;
    locationImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationListCell __weak *weakSelf = self;
    [locationImageView sd_setImageWithURL:[NSURL URLWithString:locationObject.image] placeholderImage:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // chosen location
    chosenImageView.hidden = YES;
    // show country/city
    addressLabel.hidden = NO;
    addressLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    // fill in address
    NSString *address = @"-";
    if ([locationObject.city length] > 0)
    {
        address = locationObject.city;
        if ([locationObject.country length] > 0)
            address = [NSString stringWithFormat:@"%@, %@", locationObject.city, locationObject.country];
    }
    else if ([locationObject.country length] > 0)
        address = locationObject.country;
    addressLabel.text = address;
    // show status label
    statusLabel.hidden = NO;
    statusLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    // approved
    if (locationObject.status == kLocationStatusApproved)
    {
        statusLabel.text = [[AppManager sharedManager] getLocalizedString:@"LOCATION_STATUS_APPROVED"];
        statusLabel.textColor = [[AppManager sharedManager] getColorType:kAppColorGreen];
    }
    else if (locationObject.status == kLocationStatusRejected)
    {
        statusLabel.text = [[AppManager sharedManager] getLocalizedString:@"LOCATION_STATUS_REJECTED"];
        statusLabel.textColor = [[AppManager sharedManager] getColorType:kAppColorRed];
    }
    else// pending
    {
        statusLabel.text = [[AppManager sharedManager] getLocalizedString:@"LOCATION_STATUS_PENDING"];
        statusLabel.textColor = [UIColor lightGrayColor];
    }
    // hide separateor
    separatorImageView.hidden = YES;
    followButton.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
    // flip direction
    // EN case
    statusLabel.textAlignment = NSTextAlignmentRight;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR)
        statusLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)populateCellWithContent:(Location*)locationObject withFollow:(BOOL)withFollowing
{
    // display name and username
    locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    locationLabel.text = locationObject.name;
    // location image
    locationImageView.contentMode = UIViewContentModeScaleAspectFill;
    locationImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationListCell __weak *weakSelf = self;
    [locationImageView sd_setImageWithURL:[NSURL URLWithString:locationObject.image] placeholderImage:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // chosen location
    chosenImageView.hidden = YES;
    // hide status
    statusLabel.hidden = YES;
    // hide separateor
    separatorImageView.hidden = YES;
    if (withFollowing){
        followButton.hidden = NO;
        // follow/unfollow this user
        [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
        [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
        [followButton setTitle:@"" forState:UIControlStateNormal];
        // following this friend
        if ([locationObject isFollowing])
        {
            [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
            [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
            [followButton setTitle:@"" forState:UIControlStateNormal];
        }
    }else{
        followButton.hidden = YES;
    }
    
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

// Populate cell and set content
- (void)populateCellWithEventContent:(Event*)eventObject
{
    // display name and username
    locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    locationLabel.text = eventObject.name;
    // location image
    locationImageView.contentMode = UIViewContentModeScaleAspectFill;
    locationImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationListCell __weak *weakSelf = self;
    [locationImageView sd_setImageWithURL:[NSURL URLWithString:eventObject.image] placeholderImage:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // chosen location
    chosenImageView.hidden = YES;
    // show country/city
    addressLabel.hidden = NO;
    addressLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    // fill in address
    NSString *address = eventObject.location.address;
//    if ([eventObject.location.city length] > 0)
//    {
//        address = eventObject.location.city;
//        if ([eventObject.location.country length] > 0)
//            address = [NSString stringWithFormat:@"%@, %@", eventObject.location.city, eventObject.location.country];
//    }
//    else if ([eventObject.location.country length] > 0)
//        address = eventObject.location.country;
    addressLabel.text = address;
    
    statusLabel.hidden = YES;
    separatorImageView.hidden = YES;
    followButton.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
    // flip direction
    // EN case
    statusLabel.textAlignment = NSTextAlignmentRight;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR)
        statusLabel.textAlignment = NSTextAlignmentLeft;
}

// Populate cell and set content
- (void)populateCellWithEventContent:(Event*)eventObject isSelected:(BOOL)isSelected{
    // display name and username
    locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    locationLabel.text = eventObject.name;
    // location image
    locationImageView.contentMode = UIViewContentModeScaleAspectFill;
    locationImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationListCell __weak *weakSelf = self;
    [locationImageView sd_setImageWithURL:[NSURL URLWithString:eventObject.image] placeholderImage:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // chosen location
    chosenImageView.hidden = YES;
    if (isSelected)
        chosenImageView.hidden = NO;
    
    // show country/city
    addressLabel.hidden = NO;
    addressLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    // fill in address
    NSString *address = eventObject.location.address;
    addressLabel.text = address;
    
    statusLabel.hidden = YES;
    separatorImageView.hidden = YES;
    followButton.hidden = YES;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
    // flip direction
    // EN case
    statusLabel.textAlignment = NSTextAlignmentRight;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR)
        statusLabel.textAlignment = NSTextAlignmentLeft;
}

@end

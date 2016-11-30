//
//  GalleryCell.m
//  Weez
//
//  Created by Dania on 10/25/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "GalleryCell.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"

@implementation GalleryCell

@synthesize thumbImageView;
@synthesize titleLabel;
@synthesize descriptionLabel;

- (void)setDelegate:(id<GalleryCellDelegate>)cellDelegate
{
    delegate = cellDelegate;
}

- (void)populateCellWithFriend:(Friend*)friendObject
{
    // set profile image
    [thumbImageView sd_setImageWithURL:[NSURL URLWithString:[friendObject getProfilePicLink]] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if(delegate != NULL)
             [delegate onImageLoadingCompleted];
     }];
    // display name and username
    titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    descriptionLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    titleLabel.text = friendObject.username;
    
    NSString *follwoersString = [[[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_FOLLOWERS"] stringByReplacingOccurrencesOfString:@"{count}" withString:[NSString stringWithFormat:@"%i",friendObject.followersCount]];
    descriptionLabel.text = follwoersString;
    
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}


- (void)populateCellWithLocation:(Location*)locationObject
{
    thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbImageView.layer.masksToBounds = YES;
    // set thumbnail
    [thumbImageView sd_setImageWithURL:[NSURL URLWithString:locationObject.image] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if(delegate != NULL)
             [delegate onImageLoadingCompleted];
     }];
    // labels font
    descriptionLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    // labels text
    NSString *follwoersString = [[[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_FOLLOWERS"] stringByReplacingOccurrencesOfString:@"{count}" withString:[NSString stringWithFormat:@"%i",locationObject.locationFollowers]];
    descriptionLabel.text = follwoersString;
    titleLabel.text = locationObject.name;
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

// Populate cell and set content
- (void)populateCellWithTag:(Tag*)tagObject
{
    // display name and username
    titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    titleLabel.text = tagObject.display;
    // tag image
    thumbImageView.contentMode = UIViewContentModeCenter;
    thumbImageView.layer.masksToBounds = YES;
    
    // set profile image
    [thumbImageView sd_setImageWithURL:[NSURL URLWithString:tagObject.thumb] placeholderImage:[UIImage imageNamed:@"tagIcon"] options:SDWebImageRefreshCached
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if(delegate != NULL)
             [delegate onImageLoadingCompleted];
     }];
    
    // show media count
    descriptionLabel.hidden = NO;
    descriptionLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    NSString *address = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"SEARCH_TAGS_MEDIA_COUNT"], tagObject.mediaCount];
    descriptionLabel.text = address;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

@end

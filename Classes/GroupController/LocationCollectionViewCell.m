//
//  LocationCollectionViewCell.m
//  Weez
//
//  Created by Molham on 6/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "LocationCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "AppManager.h"


@implementation LocationCollectionViewCell

@synthesize thumbnailImageView;
@synthesize thumbnailView;
@synthesize durationLabel;
@synthesize nameLabel;

#pragma mark -
#pragma mark Cell main functions

- (void)populateCellWithEventContent:(Event*)eventObject
{
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationCollectionViewCell __weak *weakSelf = self;
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:eventObject.image] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.thumbnailImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.thumbnailImageView.image clipToCircle:YES withDiamter:85 borderColor:[UIColor whiteColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = eventObject.name;
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)populateSquareCellWithEventContent:(Event*)eventObject
{
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationCollectionViewCell __weak *weakSelf = self;
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:eventObject.image] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.thumbnailImageView.image = image;
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = eventObject.name;
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)populateCellWithLocationContent:(Location*)locationObject
{
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationCollectionViewCell __weak *weakSelf = self;
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:locationObject.image] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.thumbnailImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.thumbnailImageView.image clipToCircle:YES withDiamter:85 borderColor:[UIColor whiteColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = locationObject.name;
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)populateSquareCellWithLocationContent:(Location*)locationObject
{
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    LocationCollectionViewCell __weak *weakSelf = self;
    if(locationObject.image == nil)
        locationObject.image = @"https://s3-us-west-2.amazonaws.com/weez/profile-pics/location.png";
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:locationObject.image] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.thumbnailImageView.image = image;
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = locationObject.name;
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (BOOL)clipsToBounds{
    [super clipsToBounds];
    return YES;
}

@end

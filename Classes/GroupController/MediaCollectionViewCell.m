//
//  MediaCollectionViewCell.m
//  Weez
//
//  Created by Molham on 6/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "MediaCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "AppManager.h"


@implementation MediaCollectionViewCell

@synthesize thumbnailImageView;
@synthesize thumbnailView;
@synthesize durationLabel;
@synthesize deleteButton;

#pragma mark -
#pragma mark Cell main functions
// Populate cell and set content
- (void)populateCellWithContent:(Media*)mediaObject
{
    [deleteButton setHidden:YES];
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:mediaObject.thumbLink] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:mediaObject.duration];
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)populateCellWithMedia:(Media*)mediaObject
{
    [deleteButton setHidden:YES];
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:mediaObject.largeWideThumb] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:mediaObject.duration];
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)populateCellWithTimeline:(Timeline*)timelineObject
{
    [deleteButton setHidden:YES];
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    MediaCollectionViewCell __weak *weakSelf = self;
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:timelineObject.smallThumb] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.thumbnailImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.thumbnailImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:timelineObject.mediaDuration];
    
    [self setBackgroundColor:[UIColor clearColor]];
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)populateSquareCellWithTimeline:(Timeline*)timelineObject
{
    [deleteButton setHidden:YES];
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailImageView.layer.masksToBounds = YES;
    // set thumbnail
    MediaCollectionViewCell __weak *weakSelf = self;
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:timelineObject.smallThumb] placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.thumbnailImageView.image = image;
     }];
    // username, duration and last updated date
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:timelineObject.mediaDuration];
    
    [self setBackgroundColor:[UIColor clearColor]];
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)showDeleteMode:(BOOL)show
{
    if(show)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.thumbnailImageView.transform = CGAffineTransformMakeScale(0.88, 0.88);
            [deleteButton setHidden:NO];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.thumbnailImageView.transform = CGAffineTransformMakeScale(1, 1);
            [deleteButton setHidden:YES];
        }];
    }
}

- (BOOL)clipsToBounds{
    [super clipsToBounds];
    return YES;
}

@end

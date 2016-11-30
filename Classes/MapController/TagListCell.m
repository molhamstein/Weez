//
//  LocationListCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TagListCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"

@implementation TagListCell

@synthesize tagImageView;
@synthesize tagLabel;
@synthesize mediaCountLabel;

#pragma mark -
#pragma mark Cell main functions

// Populate cell and set content
- (void)populateCellWithContent:(Tag*)tagObject
{
    // display name and username
    tagLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    tagLabel.text = tagObject.display;
    // location image
    tagImageView.contentMode = UIViewContentModeCenter;
    tagImageView.layer.masksToBounds = YES;
    tagImageView.image = [UIImage imageNamed:@"tagIcon"];
    // set thumbnail
//    TagListCell __weak *weakSelf = self;
//    [tagImageView sd_setImageWithURL:[NSURL URLWithString:tagObject.image] placeholderImage:nil
//                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
//     {
//         weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
//     }];
    
    // show media count
    mediaCountLabel.hidden = NO;
    mediaCountLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    NSString *address = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"SEARCH_TAGS_MEDIA_COUNT"], tagObject.mediaCount];
    mediaCountLabel.text = address;
    // flip direction
    [[AppManager sharedManager] flipViewDirection:self.contentView];
}

@end

//
//  GalleryCell.h
//  Weez
//
//  Created by Dania on 10/25/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Friend.h"
#import "Location.h"
#import "Tag.h"

@protocol GalleryCellDelegate
-(void) onImageLoadingCompleted;
@end

@interface GalleryCell : UICollectionViewCell
{
    id<GalleryCellDelegate> delegate;
    UIImageView *thumbImageView;
    UILabel *titleLabel;
    UILabel *descriptionLabel;
}

@property(nonatomic, retain) IBOutlet UIImageView *thumbImageView;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *descriptionLabel;


- (void)setDelegate:(id<GalleryCellDelegate>)cellDelegate;
- (void)populateCellWithFriend:(Friend*)friendObject;
- (void)populateCellWithLocation:(Location*)locationObject;
- (void)populateCellWithTag:(Tag*)tagObject;

@end

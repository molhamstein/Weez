//
//  MediaCollectionViewCell.h
//  Weez
//
//  Created by Molham on 6/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"
#import "Timeline.h"


@interface MediaCollectionViewCell : UICollectionViewCell
{
    UIView *thumbnailView;
    UIImageView *thumbnailImageView;
    UILabel *durationLabel;
    UIButton *deleteButton;
}

@property (nonatomic, retain) IBOutlet UIView *thumbnailView;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;

- (void)populateCellWithContent:(Media*)MediaObject;
- (void)populateCellWithMedia:(Media*)mediaObject;
- (void)populateCellWithTimeline:(Timeline*)timelineObject;
- (void)populateSquareCellWithTimeline:(Timeline*)timelineObject;
- (void)showDeleteMode:(BOOL)show;

@end

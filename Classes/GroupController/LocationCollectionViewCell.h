//
//  LocationCollectionViewCell.h
//  Weez
//
//  Created by Molham on 6/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"
#import "Location.h"
#import "Event.h"
#import "GalleryCell.h"


@interface LocationCollectionViewCell : GalleryCell
{
    UIView *thumbnailView;
    UIImageView *thumbnailImageView;
    UILabel *durationLabel;
    UILabel *nameLabel;
}

@property (nonatomic, retain) IBOutlet UIView *thumbnailView;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

- (void)populateCellWithEventContent:(Event*)eventObject;
- (void)populateCellWithLocationContent:(Location*)locationObject;
- (void)populateSquareCellWithEventContent:(Event*)eventObject;
- (void)populateSquareCellWithLocationContent:(Location*)locationObject;

@end

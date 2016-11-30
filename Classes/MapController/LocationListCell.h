//
//  LocationListCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Location.h"
#import "Event.h"

@interface LocationListCell : UITableViewCell
{
    UIImageView *locationImageView;
    UILabel *locationLabel;
    UILabel *addressLabel;
    UILabel *statusLabel;
    UIImageView *chosenImageView;
    UIButton *followButton;
    UIImageView *separatorImageView;
}

@property(nonatomic, retain) IBOutlet UIImageView *locationImageView;
@property(nonatomic, retain) IBOutlet UILabel *locationLabel;
@property(nonatomic, retain) IBOutlet UILabel *addressLabel;
@property(nonatomic, retain) IBOutlet UILabel *statusLabel;
@property(nonatomic, retain) IBOutlet UIImageView *chosenImageView;
@property(nonatomic, retain) IBOutlet UIImageView *separatorImageView;
@property(nonatomic, retain) IBOutlet UIButton *followButton;

- (void)populateCellWithContent:(Location*)locationObject withSelected:(BOOL)isSelected;
- (void)populateCellWithContent:(Location*)locationObject;
- (void)populateCellWithContent:(Location*)locationObject withFollow:(BOOL)withFollowing;
- (void)populateCellWithEventContent:(Event*)eventObject isSelected:(BOOL)isSelected;

- (void)populateCellWithEventContent:(Event*)eventObject;
@end
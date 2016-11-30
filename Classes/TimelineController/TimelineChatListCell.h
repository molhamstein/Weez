//
//  TimelineChatListCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Timeline.h"
#import <SWTableViewCell.h>

@interface TimelineChatListCell : SWTableViewCell
{
    UIImageView *profileImageView;
    UIImageView *progressBgImageView;
    UILabel *usernameLabel;
    UILabel *lastDateLabel;
    UILabel *actorLabel;
    UILabel *messageLabel;
    UIView *mediaTypeView;
    UIImageView *mediaTypeImageView;
    UILabel *mediaTypeLabel;
    UIView *groupIndicator;
    NSLayoutConstraint *actorWidth;
    Timeline *timelineObj;
    UIButton *profileButton;
}

@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UIImageView *progressBgImageView;
@property(nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property(nonatomic, retain) IBOutlet UILabel *lastDateLabel;
@property(nonatomic, retain) IBOutlet UILabel *actorLabel;
@property(nonatomic, retain) IBOutlet UILabel *messageLabel;
@property(nonatomic, retain) IBOutlet UIView *mediaTypeView;
@property(nonatomic, retain) IBOutlet UIImageView *mediaTypeImageView;
@property(nonatomic, retain) IBOutlet UILabel *mediaTypeLabel;
@property(nonatomic, retain) IBOutlet UIView *groupIndicator;
@property(nonatomic, retain) IBOutlet NSLayoutConstraint *actorWidth;
@property(nonatomic, retain) IBOutlet UIButton *profileButton;

- (void)populateCellWithContent:(Timeline*)timelineObject;
- (void)initSwipeActions:(id<SWTableViewCellDelegate>)delegate;

@end
//
//  NotificationFollowListCell.h
//  Weez
//
//  Created by Dania on 11/2/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "AppNotification.h"

@interface NotificationFollowListCell : UITableViewCell
{
    UIImageView *imageView;
    UILabel *titleLabel;
    UILabel *descLabel;
    UILabel *dateLabel;
    UIButton *followButton;
    UIButton *acceptButton;
    UIButton *rejectButton;
    UIView *requestActionsContainer;
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *descLabel;
@property(nonatomic, retain) IBOutlet UILabel *dateLabel;
@property(nonatomic, retain) IBOutlet UIButton *followButton;
@property(nonatomic, retain) IBOutlet UIButton *acceptButton;
@property(nonatomic, retain) IBOutlet UIButton *rejectButton;
@property(nonatomic, retain) IBOutlet UIView *requestActionsContainer;

- (void)populateCellWithContent:(AppNotification*)object;

@end
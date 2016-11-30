//
//  NotificationMentionListCell.h
//  Weez
//
//  Created by Dania on 11/3/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//


#import "AppNotification.h"
#import <KAProgressLabel/KAProgressLabel.h>

@interface NotificationMentionListCell : UITableViewCell
{
    UIImageView *imageView;
    UILabel *titleLabel;
    UILabel *descLabel;
    UILabel *dateLabel;
    UIView *thumbnailView;
    UIImageView *thumbnailImageView;
    KAProgressLabel *progressLabel;
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *descLabel;
@property(nonatomic, retain) IBOutlet UILabel *dateLabel;
@property(nonatomic, retain) IBOutlet UIView *thumbnailView;
@property(nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, retain) IBOutlet KAProgressLabel *progressLabel;

- (void)populateCellWithContent:(AppNotification*)object;

@end

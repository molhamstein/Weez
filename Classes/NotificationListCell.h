//
//  NotificationListCell.h
//  Weez
//
//  Created by Molham on 8/24/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "AppNotification.h"

@interface NotificationListCell : UITableViewCell
{
    UIImageView *imageView;
    UILabel *titleLabel;
    UILabel *descLabel;
    UILabel *dateLabel;
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *descLabel;
@property(nonatomic, retain) IBOutlet UILabel *dateLabel;

- (void)populateCellWithContent:(AppNotification*)object;

@end
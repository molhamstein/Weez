//
//  EventListCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Location.h"
#import "Event.h"

@interface EventListCell : UITableViewCell
{
    UIImageView *eventImageView;
    UILabel *eventLabel;
    UILabel *addressLabel;
    UIImageView *separatorImageView;
    
    UIButton *mentionButton;
    UIButton *followButton;
    UIButton *playButton;
}

@property(nonatomic, retain) IBOutlet UIImageView *eventImageView;
@property(nonatomic, retain) IBOutlet UILabel *eventLabel;
@property(nonatomic, retain) IBOutlet UILabel *addressLabel;
@property(nonatomic, retain) IBOutlet UIImageView *separatorImageView;
@property(nonatomic, retain) IBOutlet UIButton *mentionButton;
@property(nonatomic, retain) IBOutlet UIButton *followButton;
@property(nonatomic, retain) IBOutlet UIButton *playButton;

- (void)populateCellWithEventContent:(Event*)eventObject withFollow:(BOOL)withFollowing;
@end
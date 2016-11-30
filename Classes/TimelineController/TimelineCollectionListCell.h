//
//  TimelineListCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Timeline.h"
#import <SWTableViewCell.h>
#import "CADRACSwippableCell.h"
#import <KAProgressLabel/KAProgressLabel.h>



@interface TimelineCollectionListCell : CADRACSwippableCell
{
    UIView *thumbnailView;
    UIImageView *profileImageView;
    UIImageView *thumbnailImageView;
    UIImageView *progressBgImageView;
    UIImageView *progressImageView;
    UILabel *usernameLabel;
    UILabel *lastDateLabel;
    UILabel *durationLabel;
    UIView *locationView;
    UILabel *locationNoLabel;
    UIImageView *locationImageView;
    UIView *watchedView;
    UILabel *watchedTimeLabel;
    KAProgressLabel *progressLabel;
    UIButton *profileButton;
    UIButton *mediaButton;
    UIButton *locationsButton;
    UIButton *moreButton;
    // mention & boost
    UIView *actorView;
    UIImageView *actorImageView;
    UIView *chatIndicator;
    UILabel *actorLabel;
    
    Timeline *timelineObj;
}

@property(nonatomic, retain) IBOutlet UIView *thumbnailView;
@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, retain) IBOutlet UIImageView *progressBgImageView;
@property(nonatomic, retain) IBOutlet UIImageView *progressImageView;
@property(nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property(nonatomic, retain) IBOutlet UILabel *lastDateLabel;
@property(nonatomic, retain) IBOutlet UILabel *durationLabel;
@property(nonatomic, retain) IBOutlet UIView *locationView;
@property(nonatomic, retain) IBOutlet UILabel *locationNoLabel;
@property(nonatomic, retain) IBOutlet UIImageView *locationImageView;
@property(nonatomic, retain) IBOutlet UIView *watchedView;
@property(nonatomic, retain) IBOutlet UILabel *watchedTimeLabel;
@property(nonatomic, retain) IBOutlet KAProgressLabel *progressLabel;
@property(nonatomic, retain) IBOutlet UIButton *profileButton;
@property(nonatomic, retain) IBOutlet UIButton *mediaButton;
@property(nonatomic, retain) IBOutlet UIButton *locationsButton;
@property UIButton *moreButton;
// mention & boost
@property(nonatomic, retain) IBOutlet UIView *actorView;
@property(nonatomic, retain) IBOutlet UIView *chatIndicator;
@property(nonatomic, retain) IBOutlet UIImageView *actorImageView;
@property(nonatomic, retain) IBOutlet UILabel *actorLabel;

- (void)populateCellWithContent:(Timeline*)timelineObject;
- (void)initSwipeActions:(id<SWTableViewCellDelegate>)delegate;

@end
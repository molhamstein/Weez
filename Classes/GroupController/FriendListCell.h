//
//  FriendListCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Friend.h"

@interface FriendListCell : UITableViewCell
{
    UIImageView *profileImageView;
    UILabel *displayNameLabel;
    UILabel *usernameLabel;
    UIButton *followButton;
    UIImageView *mentionImageView;
    UIImageView *separatorImageView;
}

@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UILabel *displayNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property(nonatomic, retain) IBOutlet UIButton *followButton;
@property(nonatomic, retain) IBOutlet UIImageView *mentionImageView;
@property(nonatomic, retain) IBOutlet UIImageView *separatorImageView;

- (void)populateCellWithContent:(Friend*)friendObject;
- (void)populateCellWithContent:(Friend*)friendObject withMention:(BOOL)isMentioned;

@end
//
//  MemberListCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Friend.h"
#import "Group.h"

@interface MemberListCell : UITableViewCell
{
    UIImageView *profileImageView;
    UILabel *displayNameLabel;
    UILabel *usernameLabel;
    UIButton *removeButton;
    UIImageView *adminImageView;
    UIImageView *separatorImageView;
}

@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UILabel *displayNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property(nonatomic, retain) IBOutlet UIButton *removeButton;
@property(nonatomic, retain) IBOutlet UIImageView *adminImageView;
@property(nonatomic, retain) IBOutlet UIImageView *separatorImageView;

- (void)populateMemberWithContent:(Friend*)friendObject withAdminList:(NSMutableArray*)adminList;
- (void)populateGroupWithContent:(Group*)groupObject withAdmin:(BOOL)isAdmin;
- (void) setGroupSelected:(BOOL) selected;

@end
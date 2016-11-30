//
//  NotificationsListController.m
//  Weez
//
//  Created by Molham on 8/24/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "NotificationsListController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "NotificationListCell.h"
#import "NotificationFollowListCell.h"
#import "NotificationMentionListCell.h"
#import "ProfileController.h"
#import "TimelinesCollectionController.h"
#import "AppNotification.h"
#import "ChatController.h"
#import "TimelineController.h"

@implementation NotificationsListController

@synthesize tableView;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize loaderView;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // hide view
    [noResultView setHidden:YES];
    [tableView setHidden:YES];
    // configure controls
    [self configureViewControls];
    [self loadNotifications];
}

// Configure view controls
- (void)configureViewControls
{
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_NOTIFICATIONS_TITLE"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"NOTIFICATIONS_NO_RESULT"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:tableView];
    
    // add refresh table control
    tableRefreshControl = [[UIRefreshControl alloc] init];
    [tableRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:tableRefreshControl];
    
    // tabs
    // prepare lists and clear data
    listOfNotifications = [[NSMutableArray alloc] init];
}

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTable{
    [self loadNotifications];
}

#pragma mark -
#pragma mark data

-(void) loadNotifications
{
    // start loading
    [loaderView setHidden:NO];
    [noResultView setHidden:YES];
    [[ConnectionManager sharedManager] getUserNotifications:^(NSMutableArray * resultsList) {
        
        // stop loader
        [loaderView setHidden:YES];
        [tableRefreshControl endRefreshing];
        
        listOfNotifications = [[NSMutableArray alloc] initWithArray:resultsList];
        
        // reload table
        [self.tableView reloadData];
        // no result
        if ([resultsList count] == 0){
            [noResultView setHidden:NO];
            [self.tableView setHidden:YES];
        }else{
            [noResultView setHidden:YES];
            [self.tableView setHidden:NO];
        }
    }
                                                    failure:^(NSError *error)
     {
         // stop loader
         [self.view setUserInteractionEnabled:YES];
         [loaderView setHidden:YES];
         [tableRefreshControl endRefreshing];
         // show notification error
         [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
     }];
    
}

#pragma mark -
#pragma mark Table view data source
// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Height for header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// Footer height
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

// Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// Height for row at index path
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // normal cell
    return CELL_NOTIFICATION_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfNotifications count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"notificationListCell";
    static NSString *CellIdentifier2 = @"notificationFollowListCell";
    static NSString *CellIdentifier3 = @"notificationMentionListCell";
    
    AppNotification *notificationObj = [listOfNotifications objectAtIndex:indexPath.row];
    switch (notificationObj.type) {
        case kAppNotificationTypeSomeoneStartedFollowingYou:
        {
            NotificationFollowListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
            [cell populateCellWithContent:notificationObj];
            // follow button
            cell.followButton.tag = indexPath.row;
            [cell.followButton addTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        case kAppNotificationTypeSomeoneMentionedYou:
        case kAppNotificationTypeSomeoneAddedYouToGroup:
        {
            NotificationMentionListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
            [cell populateCellWithContent:notificationObj];
            return cell;
        }
        default:
            break;
    }
    
    NotificationListCell *notificationCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    [notificationCell populateCellWithContent:notificationObj];
    
        
    return notificationCell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedNotificationObject = [listOfNotifications objectAtIndex:indexPath.row];
    [self handleTapping];
    // deselect row for next touch
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (void) handleTapping
{
    switch (selectedNotificationObject.type) {
        case kAppNotificationTypeSomeoneStartedFollowingYou:
            [self performSegueWithIdentifier:@"notificationsListProfileSegue" sender:self];
            break;
        case kAppNotificationTypeNewMessageInGroup:
        case kAppNotificationTypeSomeoneAddedYouToGroup:
        case kAppNotificationTypeNewMessageInChat:
            [self performSegueWithIdentifier:@"notificationsListChatSegue" sender:self];
            break;
        case kAppNotificationTypeSomeoneMentionedYou:
            [self performSegueWithIdentifier:@"notificationsListTimelineSegue" sender:self];
            break;
        case kAppNotificationTypeSomeoneMentionedYouInEvent:
            [self performSegueWithIdentifier:@"notificationsListTimelinesCollectionSegue" sender:self];
            break;
    }
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // user profile
    if ([[segue identifier] isEqualToString:@"notificationsListProfileSegue"])
    {
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        ProfileController *profileController = (ProfileController*)[navController viewControllers][0];
        [profileController setProfileWithUser:selectedNotificationObject.actor];
    }else if ([[segue identifier] isEqualToString:@"notificationsListChatSegue"])
    {
        if(selectedNotificationObject.type == kAppNotificationTypeNewMessageInChat){
            ChatController *chatController = (ChatController*)[segue destinationViewController];
            [chatController setTimeline:selectedNotificationObject.timeline];
            //[chatController setGroup:selectedNotificationObject.group withParent:self];
        }else{
            ChatController *chatController = (ChatController*)[segue destinationViewController];
            [chatController setGroup:selectedNotificationObject.group withParent:nil];
        }
    }else if ([[segue identifier] isEqualToString:@"notificationsListTimelineSegue"])
    {
        // pass the active user to profile page
        TimelineController *timelineController = segue.destinationViewController;
        [timelineController setTimelineObject:selectedNotificationObject.timeline withLocation:nil orEvent:nil];
    }else if ([[segue identifier] isEqualToString:@"notificationsListTimelinesCollectionSegue"])
    {
        UINavigationController *navController = [segue destinationViewController];
        TimelinesCollectionController *timelinesController = (TimelinesCollectionController*)[navController viewControllers][0];
        [timelinesController setType:kCollectionTypeEventTimelines withLocation:nil withTag:nil withEvent:selectedNotificationObject.event];
    }
}

// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Follow user
- (void)followUser:(UIButton*)sender
{
    [sender setEnabled:NO];
    int rowIndex = (int)sender.tag;
    AppNotification *notificationObj = [listOfNotifications objectAtIndex:rowIndex];
    
    Friend *friendObject = [[Friend alloc] init];
    friendObject.objectId = notificationObj.actor.objectId;
    
    [[ConnectionManager sharedManager].userObject followFriend:friendObject.objectId withPrivateProfile:friendObject.isPrivate];
    // animate the pressed voted image
    sender.alpha = 1.0;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         sender.alpha = 0.0;
         sender.transform = CGAffineTransformScale(sender.transform, 0.5, 0.5);
     }
                     completion:^(BOOL finished)
     {
         // following this friend
         FOLLOWING_STATE state = [friendObject getFollowingState];
         NSString *icon = @"friendFollowIcon";
         switch (state) {
             case REQUESTED:
                 icon = @"friendFollowIconPending";
                 break;
             case FOLLOWING:
                 icon = @"friendFollowIconActive";
                 break;
             case NOT_FOLLOWING:
                 icon = @"friendFollowIcon";
                 break;
                 
             default:
                 break;
         }
         [sender setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
         [sender setImage:[UIImage imageNamed:icon] forState:UIControlStateDisabled];
         [sender setTitle:@"" forState:UIControlStateNormal];

         
         [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionCrossDissolve animations:^
          {
              sender.alpha = 1.0;
              sender.transform = CGAffineTransformScale(sender.transform, 2.0, 2.0);
          }
                          completion:^(BOOL finished)
          {
              [sender setEnabled:YES];
          }];
     }];
    // follow/unfollow user
    [[ConnectionManager sharedManager] followUser:friendObject.objectId success:^(void)
     {
         // notify about timeline changes
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
     }
                                          failure:^(NSError * error)
     {
     }];
}

@end

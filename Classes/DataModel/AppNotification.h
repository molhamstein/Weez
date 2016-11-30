//
//  ChatMessage.h
//  Weez
//
//  Created by Molham on 8/24/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Media.h"
#import "Timeline.h"
#import "Group.h"
#import "Event.h"

@interface AppNotification : NSObject
{
    NSString *objectId;
    User *actor;
    NSDate *date;
    AppNotificationType type;
    
    User *user;
    Timeline *timeline;
    Group *group;
    Event *event;
}

@property (nonatomic,retain) NSString *objectId;
@property (nonatomic,retain) User *actor;
@property (nonatomic,retain) NSDate *date;
@property AppNotificationType type;

@property (nonatomic,retain) User *user;
@property (nonatomic,retain) Timeline *timeline;
@property (nonatomic,retain) Group *group;
@property (nonatomic,retain) Event *event;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (NSString*)getCreatedDateString:(BOOL)isShort;
@end

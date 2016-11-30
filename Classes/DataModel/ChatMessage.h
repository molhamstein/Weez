//
//  ChatMessage.h
//  Weez
//
//  Created by Molham on 8/2/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Media.h"
#import "Location.h"
#import "Friend.h"
#import "Event.h"

@interface ChatMessage : NSObject
{
    NSString *objectId;
    User *sender;
    NSDate *date;
    NSString *text;
    Media *media;
    Location *location;
    
    ChatMessage *parentMessage;
    NSString *groupId;
    
    Friend *timelineMsgUser;
    Location *timelineMsgLocation;
    Event *timelineMsgEvent;
    NSString *thumb;
}

@property (nonatomic,retain) NSString *objectId;
@property (nonatomic,retain) User *sender;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) Media *media;
@property (nonatomic,retain) Location *location;
@property (nonatomic,retain) ChatMessage *parentMessage;
@property (nonatomic,retain) NSString *groupId;

@property (nonatomic,retain) Friend *timelineMsgUser;
@property (nonatomic,retain) Location *timelineMsgLocation;
@property (nonatomic,retain) Event *timelineMsgEvent;
@property (nonatomic,retain) NSString *thumb;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (BOOL) isMediaMessage;
- (BOOL) isTimelineMsg;
- (NSString*) getMessageDescription;
@end

//  Weez
//
//  Created by Molham
//  Copyright © 2016 AlphaApps. All rights reserved.
//
//  inspired by

//  Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController


#import "JSQMediaItem.h"
#import "Media.h"
#import "Timeline.h"
#import "Location.h"
#import "Event.h"
#import "Friend.h"
#import "ChatMessage.h"
#import "ChatController.h"

@interface JSQCustomTimelineMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

@property (retain, nonatomic) Friend *timeline;
@property (retain, nonatomic) Location *location;
@property (retain, nonatomic) Event *event;
@property (retain, nonatomic) NSString *thumb;

@property (retain, nonatomic) ChatMessage *parentChatMessage;
@property (nonatomic, weak) id<ChatControllerDelegate> hostControllerDelegate;

- (instancetype)initWithTimeline:(Friend *)timeline orLocation:(Location*)location orEvent:(Event*)event withThumb:(NSString*)thumbUrl;

@end

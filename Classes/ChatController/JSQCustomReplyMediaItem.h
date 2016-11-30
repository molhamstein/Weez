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
#import "ChatMessage.h"
#import "ChatController.h"

/**
 *
 */
@interface JSQCustomReplyMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>


// data
@property (strong, nonatomic) UIView *container;

@property (strong, nonatomic) UILabel *lblText;

@property (retain, nonatomic) ChatMessage *parentChatMessage;
@property (nonatomic, weak) id<ChatControllerDelegate> hostControllerDelegate;
@property (copy, nonatomic) NSString *text;

- (instancetype)initWithText:(NSString*)text;

@end

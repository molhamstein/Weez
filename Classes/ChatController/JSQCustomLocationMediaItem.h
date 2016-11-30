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
#import "ChatMessage.h"
#import "ChatController.h"

/**
 *  The `JSQPhotoMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
 *  and represents a photo media message. An initialized `JSQPhotoMediaItem` object can be passed 
 *  to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `JSQPhotoMediaItem` to provide additional functionality or behavior.
 */
@interface JSQCustomLocationMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

/**
 *  The image for the photo media item. The default value is `nil`.
 */
@property (copy, nonatomic) UIImage *image;

@property (strong, nonatomic) ChatMessage *parentChatMessage;
@property (nonatomic, weak) id<ChatControllerDelegate> hostControllerDelegate;

/**
 *  The image for the photo media item. The default value is `nil`.
 */
@property (copy, nonatomic) NSString *imageUrl;

@property (nonatomic) float longitude;

@property (nonatomic) float latitude;

@property (nonatomic, assign) BOOL shouldshowProgress;

- (instancetype)initWithParentMsg:(ChatMessage*)msg Lat:(float)lat andLong:(float)lng showProgress:(BOOL)shouldShowProgress;

@end

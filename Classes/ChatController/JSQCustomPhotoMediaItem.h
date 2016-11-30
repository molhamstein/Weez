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
 *  The `JSQPhotoMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
 *  and represents a photo media message. An initialized `JSQPhotoMediaItem` object can be passed 
 *  to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `JSQPhotoMediaItem` to provide additional functionality or behavior.
 */
@interface JSQCustomPhotoMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

/**
 *  The image for the photo media item. The default value is `nil`.
 */
@property (copy, nonatomic) UIImage *image;

/**
 *  The image for the photo media item. The default value is `nil`.
 */
@property (copy, nonatomic) NSString *imageUrl;

//@property (copy, nonatomic) Media *mediaModel;
@property (copy, nonatomic) ChatMessage *chatMessage;

@property (retain, nonatomic) ChatMessage *parentChatMessage;
@property (nonatomic, weak) id<ChatControllerDelegate> hostControllerDelegate;

/**
 *  The thumb link for the photo media item. The default value is `nil`.
 */
@property (copy, nonatomic) NSString *thumbUrl;

@property (nonatomic, assign) BOOL shouldshowProgress;

/**
 *  Initializes and returns a photo media item object having the given image.
 *
 *  @param image The image for the photo media item. This value may be `nil`.
 *
 *  @return An initialized `JSQPhotoMediaItem` if successful, `nil` otherwise.
 *
 *  @discussion If the image must be dowloaded from the network, 
 *  you may initialize a `JSQPhotoMediaItem` object with a `nil` image. 
 *  Once the image has been retrieved, you can then set the image property.
 */
- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithChatMessage:(ChatMessage*)chatMessage showProgress:(BOOL)shouldShowProgress;

- (void) downloadFullSizeImage:(void (^)(UIImage* downloadedImage))onSuccess;
@end

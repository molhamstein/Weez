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
 *  The `JSQVideoMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
 *  and represents a video media message. An initialized `JSQVideoMediaItem` object can be passed
 *  to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `JSQVideoMediaItem` to provide additional functionality or behavior.
 */
@interface JSQCustomVideoMediaItemWithThumb : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

/**
 *  The URL that identifies a video resource.
 */
@property (nonatomic, strong) NSURL *fileURL;

@property (copy, nonatomic) Media *mediaModel;

@property (strong, nonatomic) ChatMessage *parentChatMessage;
@property (nonatomic, weak) id<ChatControllerDelegate> hostControllerDelegate;

/**
 *  A boolean value that specifies whether or not the video is ready to be played.
 * 
 *  @discussion When set to `YES`, the video is ready. When set to `NO` it is not ready.
 */
@property (nonatomic, assign) BOOL isReadyToPlay;

@property (nonatomic, strong) NSString *thumbURL;
/**
 *  Initializes and returns a video media item having the given fileURL.
 *
 *  @param fileURL       The URL that identifies the video resource.
 *  @param isReadyToPlay A boolean value that specifies if the video is ready to play.
 *
 *  @return An initialized `JSQVideoMediaItem` if successful, `nil` otherwise.
 *
 *  @discussion If the video must be downloaded from the network,
 *  you may initialize a `JSQVideoMediaItem` with a `nil` fileURL or specify `NO` for
 *  isReadyToPlay. Once the video has been saved to disk, or is ready to stream, you can
 *  set the fileURL property or isReadyToPlay property, respectively.
 */
- (instancetype)initWithFileURL:(NSURL *)fileURL andThumb:(NSString *)thumbUrl mediaModel:(Media*)mediaModel isReadyToPlay:(BOOL)isReadyToPlay;

- (void) downloadVideo:(void (^)(NSURL*))onSuccess;
@end

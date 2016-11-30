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
#import "JSQAudioMediaViewAttributes.h"

#import <AVFoundation/AVFoundation.h>
#import "ChatMessage.h"
#import "ChatController.h"
@protocol ChatControllerDelegate;

@class JSQCustomAudioMediaItem;

NS_ASSUME_NONNULL_BEGIN

@protocol JSQCustomAudioMediaItemDelegate <NSObject>

/**
 *  Tells the delegate if the specified `JSQCustomAudioMediaItem` changes the sound category or categoryOptions, or if an error occurs.
 */
- (void)audioMediaItem:(JSQCustomAudioMediaItem *)audioMediaItem
didChangeAudioCategory:(NSString *)category
               options:(AVAudioSessionCategoryOptions)options
                 error:(nullable NSError *)error;

- (void) audioWillPlay:(JSQCustomAudioMediaItem *)audioMediaItem;
@end


/**
 *  The `JSQCustomAudioMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
 *  and represents an audio media message. An initialized `JSQCustomAudioMediaItem` object can be passed
 *  to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `JSQCustomAudioMediaItem` to provide additional functionality or behavior.
 */
@interface JSQCustomAudioMediaItem : JSQMediaItem <JSQMessageMediaData, AVAudioPlayerDelegate, NSCoding, NSCopying>

/**
 *  The delegate object for audio event notifications.
 */
@property (nonatomic, weak, nullable) id<JSQCustomAudioMediaItemDelegate> delegate;

/**
 *  The view attributes to configure the appearance of the audio media view.
 */
@property (nonatomic, strong, readonly) JSQAudioMediaViewAttributes *audioViewAttributes;

/**
 *  A data object that contains an audio resource.
 */
@property (nonatomic, strong, nullable) NSData *audioData;

@property (nonatomic, strong, nullable) NSURL *fileUrl;

@property (nonatomic, strong, nullable) ChatMessage *parentChatMessage;
@property (nonatomic, weak) id<ChatControllerDelegate> hostControllerDelegate;

@property NSTimeInterval duration;

/**
 *  Initializes and returns a audio media item having the given audioData.
 *
 *  @param audioData              The data object that contains the audio resource.
 *  @param audioViewConfiguration The view attributes to configure the appearance of the audio media view.
 *
 *  @return An initialized `JSQCustomAudioMediaItem`.
 *
 *  @discussion If the audio must be downloaded from the network,
 *  you may initialize a `JSQVideoMediaItem` with a `nil` audioData.
 *  Once the audio is available you can set the `audioData` property.
 */
- (instancetype)initWithData:(nullable NSData *)audioData audioViewAttributes:(JSQAudioMediaViewAttributes *)audioViewAttributes audioLink:(NSURL*) fileUrl duration:(NSTimeInterval) duration NS_DESIGNATED_INITIALIZER;

/**
 *  Initializes and returns a default audio media item.
 *
 *  @return An initialized `JSQCustomAudioMediaItem`.
 *
 *  @discussion You must set `audioData` to enable the play button.
 */
//- (instancetype)init;

/**
 Initializes and returns a default audio media using the specified view attributes.

 @param audioViewAttributes The view attributes to configure the appearance of the audio media view.

 @return  An initialized `JSQCustomAudioMediaItem`.
 */
//- (instancetype)initWithAudioViewAttributes:(JSQAudioMediaViewAttributes *)audioViewAttributes;

/**
 *  Initializes and returns an audio media item having the given audioData.
 *
 *  @param audioData The data object that contains the audio resource.
 *
 *  @return An initialized `JSQCustomAudioMediaItem`.
 *
 *  @discussion If the audio must be downloaded from the network,
 *  you may initialize a `JSQCustomAudioMediaItem` with a `nil` audioData.
 *  Once the audio is available you can set the `audioData` property.
 */
- (instancetype)initWithData:(nullable NSData *)audioData;

/**
 *  Sets or updates the data object in an audio media item with the data specified at audioURL.
 *
 *  @param audioURL A File URL containing the location of the audio data.
 */
- (void)setAudioDataWithUrl:(nonnull NSURL *)audioURL;

- (void) stopAudioIfPlaying;

@end

NS_ASSUME_NONNULL_END

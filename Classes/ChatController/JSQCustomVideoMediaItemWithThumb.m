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


#import "JSQCustomVideoMediaItemWithThumb.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIImageView+WebCache.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "KAProgressLabel.h"

@interface JSQCustomVideoMediaItemWithThumb ()

@property (strong, nonatomic) UIImageView *cachedVideoImageView;
@property (strong, nonatomic) UIImageView *cachedPlayIcon;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) KAProgressLabel *downloadProgressIndicator;

@property BOOL isDownloadingVideo;

@end


@implementation JSQCustomVideoMediaItemWithThumb

#pragma mark - Initialization

- (instancetype)initWithFileURL:(NSURL *)fileURL andThumb:(NSString *)thumbUrl mediaModel:(Media*)mediaModel isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _isReadyToPlay = isReadyToPlay;
        _cachedVideoImageView = nil;
        _thumbURL = [thumbUrl copy];
        _mediaModel = mediaModel;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedVideoImageView = nil;
}

#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedVideoImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedVideoImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedVideoImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.fileURL == nil || !self.isReadyToPlay) {
        return nil;
    }
    
    if (self.cachedVideoImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];

        // parent message preview view if exists
        CGFloat shift = _parentChatMessage!=nil?CHAT_ORIGINAL_PREVIEW_HEIGHT :0;
        if(_parentChatMessage){
            UIView *parentMsgPreview = [[AppManager sharedManager] getChatMessagePreviewFor:_parentChatMessage inSize:CGSizeMake(size.width, CHAT_ORIGINAL_PREVIEW_HEIGHT) extraLeftSpacing:self.appliesMediaViewMaskAsOutgoing?0:5];
            // add button to parent messaege preview
            UIButton *parentMessageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, parentMsgPreview.frame.size.width, parentMsgPreview.frame.size.height)];
            [parentMessageBtn addTarget:self action:@selector(didPressParentMessage) forControlEvents:UIControlEventTouchUpInside];
            [parentMsgPreview addSubview:parentMessageBtn];
            [_container addSubview:parentMsgPreview];
        }
        
        UIImage *playIcon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = CGRectMake(0.0f, shift, size.width, size.height-(shift));
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        _cachedPlayIcon = [[UIImageView alloc] initWithImage:playIcon];
        _cachedPlayIcon.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        _cachedPlayIcon.contentMode = UIViewContentModeCenter;
        _cachedPlayIcon.clipsToBounds = YES;
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:_container isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedVideoImageView = imageView;
        [self.cachedVideoImageView sd_setImageWithURL:[NSURL URLWithString:self.thumbURL] placeholderImage:nil options:SDWebImageRetryFailed
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if(error){
                 // API has a delay generating thumbnails, so when failing for the first time give it a second try
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     if(!image){
                         [self.cachedVideoImageView sd_setImageWithURL:[NSURL URLWithString:self.thumbURL] placeholderImage:nil options:SDWebImageRetryFailed];
                     }else
                         NSLog(@"photo retrival error");
                 });
             }
         }];

        [self.container addSubview:self.cachedVideoImageView];
        [self.container addSubview:self.cachedPlayIcon];

        // add border arround the bubble
        CGRect borderFrame = CGRectMake(_container.frame.origin.x, _container.frame.origin.y, _container.frame.size.width, _container.frame.size.height);
        borderFrame.size.width += 1;
        borderFrame.size.height += 7;
        borderFrame.origin.x += self.appliesMediaViewMaskAsOutgoing?-3.5:2.5;
        borderFrame.origin.y += -3.5;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:borderFrame cornerRadius:23];
        CAShapeLayer *border = [CAShapeLayer layer];
        border.path = path.CGPath;
        if(self.appliesMediaViewMaskAsOutgoing)
            border.strokeColor = [[[AppManager sharedManager] getColorType:kAppColorBlue] CGColor];
        else
            border.strokeColor = [[[AppManager sharedManager] getColorType:kAppColorLightGray] CGColor];
        border.fillColor = [[UIColor clearColor] CGColor];
        border.lineWidth = 15.0;
        [self.container.layer addSublayer:border];
    }
    
    return self.container;
}

-(void) didPressParentMessage{
    if(!_parentChatMessage || !self.hostControllerDelegate)
        return;
    [self.hostControllerDelegate didTapParentMessage:_parentChatMessage];
}

- (CGSize)mediaViewDisplaySize{
    CGSize contentSize = [super mediaViewDisplaySize] ;
    CGSize extraSize = [[AppManager sharedManager] getExtraSizeForChatMessage];
    contentSize.width += extraSize.width;
    contentSize.height += extraSize.height;
    if(_parentChatMessage){
        contentSize.height += CHAT_ORIGINAL_PREVIEW_HEIGHT;
    }
    return contentSize;
}

- (void) downloadVideo:(void (^)(NSURL*)) onSuccess{
    @try {
        if(self.container == nil)
            return;
        if(!_isDownloadingVideo){
            // check if Video downloaded before
            if ([[AppManager sharedManager] fetchLocalVideoURL:_fileURL.lastPathComponent] == nil){
                _isDownloadingVideo = YES;
                
                // create a progress indiactor view and place it at the middle
                CGSize size = [self mediaViewDisplaySize];
                CGRect buttonFrame = CGRectMake(-20 + size.width/2, -20 + size.height/2, 40, 40);
                
                self.downloadProgressIndicator = [[KAProgressLabel alloc] initWithFrame:buttonFrame];
                self.downloadProgressIndicator.progressWidth = 3;
                self.downloadProgressIndicator.trackWidth = 3;
                //self.downloadProgressIndicator.trackTintColor = [UIColor whiteColor];
                self.downloadProgressIndicator.progressColor = [UIColor whiteColor];
                self.downloadProgressIndicator.progress = 0;
                [self.container addSubview:self.downloadProgressIndicator];
                
                self.cachedPlayIcon.hidden = YES;
                // download video
                [[ConnectionManager sharedManager] downloadVideoFromURL:_fileURL.absoluteString progress:^(CGFloat progress){
                    NSLog(@"progress: %f", progress);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.downloadProgressIndicator setProgress: progress];
                    });
                }
                success:^(NSURL *filePath){
                    NSLog(@"file path:%@", filePath.absoluteString);
                    [self.downloadProgressIndicator removeFromSuperview];
                    self.downloadProgressIndicator = nil;
                    _isDownloadingVideo = NO;
                    self.cachedPlayIcon.hidden = NO;
                    NSURL *localVideoUrlForPreview = [[AppManager sharedManager] fetchLocalVideoURL:_fileURL.lastPathComponent];
                    onSuccess(localVideoUrlForPreview);
                }
                failure:^(NSError *error){
                    [self.downloadProgressIndicator removeFromSuperview];
                    self.downloadProgressIndicator = nil;
                    _isDownloadingVideo = NO;
                    self.cachedPlayIcon.hidden = NO;
                    onSuccess(nil);
                }];
            }else{
                onSuccess([[AppManager sharedManager] fetchLocalVideoURL:_fileURL.lastPathComponent]);
                [self.downloadProgressIndicator removeFromSuperview];
                self.downloadProgressIndicator = nil;
                self.cachedPlayIcon.hidden = NO;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQCustomVideoMediaItemWithThumb *videoItem = (JSQCustomVideoMediaItemWithThumb *)object;
    
    return [self.fileURL isEqual:videoItem.fileURL]
            && self.isReadyToPlay == videoItem.isReadyToPlay;
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
        _thumbURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(thumbURL))];
        _mediaModel = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaModel))];
        _parentChatMessage = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(parentChatMessage))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
    [aCoder encodeObject:self.thumbURL forKey:NSStringFromSelector(@selector(thumbURL))];
    [aCoder encodeObject:self.mediaModel forKey:NSStringFromSelector(@selector(mediaModel))];
    [aCoder encodeObject:self.parentChatMessage forKey:NSStringFromSelector(@selector(parentChatMessage))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQCustomVideoMediaItemWithThumb *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL
                                                                    andThumb:self.thumbURL
                                                                    mediaModel:self.mediaModel
                                                                   isReadyToPlay:self.isReadyToPlay];
    copy.parentChatMessage = _parentChatMessage;
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end

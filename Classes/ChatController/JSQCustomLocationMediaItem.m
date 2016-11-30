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


#import "JSQCustomLocationMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KAProgressLabel.h"
#import "AppManager.h"

@interface JSQCustomLocationMediaItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

@property (strong, nonatomic) KAProgressLabel *downloadProgressIndicator;

@end


@implementation JSQCustomLocationMediaItem

#pragma mark - Initialization


- (instancetype)initWithParentMsg:(ChatMessage*)msg Lat:(float)lat andLong:(float)lng showProgress:(BOOL)shouldShowProgress{
    self = [super init];
    if (self) {
        _latitude = lat;
        _longitude = lng;
        
        _imageUrl = [[AppManager sharedManager] getGoogleStaticMaplinkForLat:lat lng:lng width:640 height:400];
        
        _cachedImageView = nil;
        _parentChatMessage = msg;
        _shouldshowProgress = shouldShowProgress;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = [image copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
//    if (self.image == nil) {
//        return nil;
//    }
    
    if (self.cachedImageView == nil) {
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
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(0.0f, shift, size.width, size.height-(shift));
        imageView.backgroundColor = [UIColor grayColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:_container isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
        
        
        JSQCustomLocationMediaItem __weak *weakSelf = self;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:_imageUrl] options:SDWebImageRetryFailed
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    weakSelf.cachedImageView.image = image;
                                    _image = image;
                                }else{
                                    NSLog(@"static map retrival error");
                                    //when failing for the first time give it a second try
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                       
                                        [manager downloadImageWithURL:[NSURL URLWithString:_imageUrl] options:SDWebImageRetryFailed
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                if(image){
                                                                    weakSelf.cachedImageView.image = image;
                                                                    _image = image;
                                                                }else
                                                                    NSLog(@"static map retrival error");
                                                            }];
                                    });
                                }
                                self.loadingView.hidden = YES;
                                [self.loadingView removeFromSuperview];
                                _shouldshowProgress = NO;
                            }];
        
        [self.container addSubview:self.cachedImageView];
        
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
        
        if(_shouldshowProgress){
            self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.loadingView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
            [self.loadingView startAnimating];
            [self.container addSubview:self.loadingView];
        }
    }else{
        _shouldshowProgress = NO;
        [self.loadingView setHidden:YES];
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

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.image.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        _imageUrl = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageUrl))];
        _latitude = [aDecoder decodeFloatForKey:NSStringFromSelector(@selector(latitude))];
        _longitude = [aDecoder decodeFloatForKey:NSStringFromSelector(@selector(longitude))];
        _shouldshowProgress = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(shouldshowProgress))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.imageUrl forKey:NSStringFromSelector(@selector(imageUrl))];
    [aCoder encodeFloat:self.latitude forKey:NSStringFromSelector(@selector(latitude))];
    [aCoder encodeFloat:self.longitude forKey:NSStringFromSelector(@selector(longitude))];
    [aCoder encodeBool:self.shouldshowProgress forKey:NSStringFromSelector(@selector(shouldshowProgress))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQCustomLocationMediaItem *copy = [[JSQCustomLocationMediaItem allocWithZone:zone] initWithParentMsg:_parentChatMessage Lat:_latitude andLong:_longitude showProgress:_shouldshowProgress];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end

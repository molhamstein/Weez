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


#import "JSQCustomTimelineMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIImageView+WebCache.h"
#import "AppManager.h"
#import "ConnectionManager.h"

@interface JSQCustomTimelineMediaItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;
@property (strong, nonatomic) UIImageView *cachedPlayIcon;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UIView *container;

@property BOOL isDownloadingVideo;

@end


@implementation JSQCustomTimelineMediaItem

#pragma mark - Initialization

- (instancetype)initWithTimeline:(Friend *)timeline orLocation:(Location*)location orEvent:(Event*)event withThumb:(NSString*)thumbUrl
{
    self = [super init];
    if (self) {
        _timeline = timeline;
        _event = event;
        _location = location;
        _thumb = thumbUrl;
        _cachedImageView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView{
    
    if (!self.timeline && !self.location && !self.event) {
        return nil;
    }
    
    if (self.cachedImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        self.container.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];
        
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
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, shift+20, 150, 26)];
        lblTitle.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.font = [[AppManager sharedManager]getFontType:kAppFontCellNumber];
        NSString *strTitle = @"";
        if(_timeline)
            strTitle = _timeline.username;
        else if(_location)
            strTitle = _location.name;
        else if(_event)
            strTitle = _event.name;
        strTitle = [NSString stringWithFormat:@"   %@   ", strTitle];
        lblTitle.text = strTitle;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = CGRectMake(0.0f, shift, size.width, size.height-(shift));
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        _cachedPlayIcon = [[UIImageView alloc] initWithImage:playIcon];
        _cachedPlayIcon.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        _cachedPlayIcon.contentMode = UIViewContentModeCenter;
        _cachedPlayIcon.clipsToBounds = YES;
        
        NSString *thumb = @"";
        if(!_thumb){
            if(_event)
                thumb = _event.image;
            else if(_location)
                thumb = _location.image;
            else if(_timeline)
                thumb = _timeline.profilePic;
        }else{
            thumb = _thumb;
        }
        
        self.cachedImageView = imageView;
        [self.cachedImageView sd_setImageWithURL:[NSURL URLWithString:thumb] placeholderImage:nil options:SDWebImageRetryFailed
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if(error){
                 // API has a delay generating thumbnails, so when failing for the first time give it a second try
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     if(!image){
                         [self.cachedImageView sd_setImageWithURL:[NSURL URLWithString:thumb] placeholderImage:nil options:SDWebImageRetryFailed];
                     }else
                         NSLog(@"photo retrival error");
                 });
             }
         }];
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:self.container isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        
        [self.container addSubview:self.cachedImageView];
        [self.container addSubview:self.cachedPlayIcon];
        [self.container addSubview:lblTitle];
        
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
    
    JSQCustomTimelineMediaItem *videoItem = (JSQCustomTimelineMediaItem *)object;
    
    return [self.timeline isEqual:videoItem.timeline] &&
        [self.event isEqual:videoItem.event] &&
        [self.location isEqual:videoItem.location];
}

- (NSUInteger)hash{
    return super.hash ^ self.timeline.hash ^ self.event.hash ^ self.location.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: timeline=%@, location=%@, event=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.timeline, self.location, self.event, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _timeline = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(timeline))];
        _location = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(location))];
        _event = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(event))];
        _thumb = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(thumb))];
        _parentChatMessage = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(parentChatMessage))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_timeline forKey:NSStringFromSelector(@selector(timeline))];
    [aCoder encodeObject:_location forKey:NSStringFromSelector(@selector(location))];
    [aCoder encodeObject:_thumb forKey:NSStringFromSelector(@selector(thumb))];
    [aCoder encodeObject:_event forKey:NSStringFromSelector(@selector(event))];
    [aCoder encodeObject:self.parentChatMessage forKey:NSStringFromSelector(@selector(parentChatMessage))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQCustomTimelineMediaItem *copy = [[[self class] allocWithZone:zone] initWithTimeline:_timeline orLocation:_location orEvent:_event withThumb:_thumb];
    copy.parentChatMessage = _parentChatMessage;
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end

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


#import "JSQCustomReplyMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIImage+JSQMessages.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KAProgressLabel.h"
#import "AppManager.h"
#import "ConnectionManager.h"


@interface JSQCustomReplyMediaItem ()


@end


@implementation JSQCustomReplyMediaItem

#pragma mark - Initialization


- (instancetype)initWithText:(NSString*)text{
    self = [super init];
    if (self) {
        _text = text;
        _container = nil;
        _lblText = nil;
    }
    return self;
}

- (void)clearCachedMediaViews{
    
    [super clearCachedMediaViews];
    _container = nil;
    _lblText = nil;
}

#pragma mark - Setters

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing{
    
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _container = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.text == nil) {
        return nil;
    }
    
    if (self.container == nil) {
        
        // shoudld init the label view before measuring the final size of the cell
        CGSize size = [super mediaViewDisplaySize];
        CGFloat extraLeftSpacing = self.appliesMediaViewMaskAsOutgoing?0:5;
        _lblText = [[UILabel alloc] initWithFrame: CGRectMake(extraLeftSpacing, 0, size.width-extraLeftSpacing, size.height)];
        _lblText.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
        _lblText.text = _text;
        
        size = [self mediaViewDisplaySize];
        
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        
        CGFloat shift = _parentChatMessage!=nil?CHAT_ORIGINAL_PREVIEW_HEIGHT :0;
        
        /// parent message view
        if(_parentChatMessage){
            UIView *originalMessageView = [[AppManager sharedManager] getChatMessagePreviewFor:_parentChatMessage inSize:CGSizeMake(size.width, CHAT_ORIGINAL_PREVIEW_HEIGHT) extraLeftSpacing:self.appliesMediaViewMaskAsOutgoing?0:5];
            // add button to parent messaege preview
            UIButton *parentMessageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, originalMessageView.frame.size.width, originalMessageView.frame.size.height)];
            [parentMessageBtn addTarget:self action:@selector(didPressParentMessage) forControlEvents:UIControlEventTouchUpInside];
            [originalMessageView addSubview:parentMessageBtn];
            [self.container addSubview:originalMessageView];
        }else{
            _lblText.textAlignment = NSTextAlignmentCenter;
        }

        _lblText.frame = CGRectMake(14 + extraLeftSpacing, shift, size.width-30, size.height-shift);
        _lblText.numberOfLines = 0;
//        self.container.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.container.backgroundColor = [UIColor whiteColor];
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:_container isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        
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

        [self.container addSubview:_lblText];
        
    }
    
    return self.container;
}

-(void) didPressParentMessage{
    if(!_parentChatMessage || !self.hostControllerDelegate)
        return;
    [self.hostControllerDelegate didTapParentMessage:_parentChatMessage];
}

- (CGSize)mediaViewDisplaySize{
    if(_parentChatMessage){
        CGSize contentSize = [super mediaViewDisplaySize] ;
        CGSize extraSize = [[AppManager sharedManager] getExtraSizeForChatMessage];
        contentSize.width += extraSize.width;
        CGRect stringRect = [_text boundingRectWithSize:CGSizeMake(contentSize.width, CGFLOAT_MAX)
                                                options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                             attributes:@{ NSFontAttributeName : [[AppManager sharedManager] getFontType:kAppFontDescription] }
                                                context:nil];
        CGSize stringSize = CGRectIntegral(stringRect).size;
        
        CGSize finalSize = CGSizeMake(contentSize.width, stringSize.height + 10);
        finalSize.height += CHAT_ORIGINAL_PREVIEW_HEIGHT + 20;
        return finalSize;
    }else{
        CGSize avatarSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault);
        
        //  from the cell xibs, there is a 2 point space between avatar and bubble
        CGFloat spacingBetweenAvatarAndBubble = 2.0f;
        CGFloat horizontalContainerInsets = 10.0f + 10.0f; // left incets + right incets
        CGFloat horizontalFrameInsets = 0 + 6.0f;
        CGFloat textBubbleLayoutWidth = 50.0f;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            textBubbleLayoutWidth = 240.0f;
        }
        
        CGFloat horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
        
        CGFloat maximumTextWidth = 312 - avatarSize.width - textBubbleLayoutWidth - horizontalInsetsTotal;
        
        CGRect stringRect = [_text boundingRectWithSize:CGSizeMake(maximumTextWidth, CGFLOAT_MAX)
                                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                          attributes:@{ NSFontAttributeName : [[AppManager sharedManager] getFontType:kAppFontDescription] }
                                                             context:nil];
        
        CGSize stringSize = CGRectIntegral(stringRect).size;
        
        CGFloat verticalContainerInsets = 10 + 10; ///top insets + bottom insets
        CGFloat verticalFrameInsets = 0 + 6;
        
        //  add extra 2 points of space (`self.additionalInset`), because `boundingRectWithSize:` is slightly off
        //  not sure why. magix. (shrug) if you know, submit a PR
        CGFloat verticalInsets = verticalContainerInsets + verticalFrameInsets + 2;
        
        //  same as above, an extra 2 points of magix
        CGFloat finalWidth = MAX(stringSize.width + horizontalInsetsTotal, 68) + 2;
        
        CGSize finalSize = CGSizeMake(finalWidth, stringSize.height + verticalInsets);
        return finalSize;
    }
}


//CGSize avatarSize = [self jsq_avatarSizeForMessageData:messageData withLayout:layout];
//
////  from the cell xibs, there is a 2 point space between avatar and bubble
//CGFloat spacingBetweenAvatarAndBubble = 2.0f;
//CGFloat horizontalContainerInsets = layout.messageBubbleTextViewTextContainerInsets.left + layout.messageBubbleTextViewTextContainerInsets.right;
//CGFloat horizontalFrameInsets = layout.messageBubbleTextViewFrameInsets.left + layout.messageBubbleTextViewFrameInsets.right;
//
//CGFloat horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
//CGFloat maximumTextWidth = [self textBubbleWidthForLayout:layout] - avatarSize.width - layout.messageBubbleLeftRightMargin - horizontalInsetsTotal;
//
//CGRect stringRect = [[messageData text] boundingRectWithSize:CGSizeMake(maximumTextWidth, CGFLOAT_MAX)
//                                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
//                                                  attributes:@{ NSFontAttributeName : layout.messageBubbleFont }
//                                                     context:nil];
//
//CGSize stringSize = CGRectIntegral(stringRect).size;
//
//CGFloat verticalContainerInsets = layout.messageBubbleTextViewTextContainerInsets.top + layout.messageBubbleTextViewTextContainerInsets.bottom;
//CGFloat verticalFrameInsets = layout.messageBubbleTextViewFrameInsets.top + layout.messageBubbleTextViewFrameInsets.bottom;
//
////  add extra 2 points of space (`self.additionalInset`), because `boundingRectWithSize:` is slightly off
////  not sure why. magix. (shrug) if you know, submit a PR
//CGFloat verticalInsets = verticalContainerInsets + verticalFrameInsets + self.additionalInset;
//
////  same as above, an extra 2 points of magix
//CGFloat finalWidth = MAX(stringSize.width + horizontalInsetsTotal, self.minimumBubbleWidth) + self.additionalInset;
//
//finalSize = CGSizeMake(finalWidth, stringSize.height + verticalInsets);

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.text.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: lbl=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.text, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _parentChatMessage = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(parentChatMessage))];
        _text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
    [aCoder encodeObject:self.parentChatMessage forKey:NSStringFromSelector(@selector(parentChatMessage))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQCustomReplyMediaItem *copy = [[JSQCustomReplyMediaItem allocWithZone:zone] initWithText:_text];
    copy.parentChatMessage = _parentChatMessage;
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end

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

#import "JSQCustomAudioMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"
#import "AppManager.h"

@interface JSQCustomAudioMediaItem ()

@property (strong, nonatomic) UIView *cachedMediaView;

@property (strong, nonatomic) UIButton *playButton;

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;
@property (strong, nonatomic) NSTimer *progressTimer;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property BOOL isDownloadingAudio;
@property BOOL blockAutoplayAfterDownload;

@end


@implementation JSQCustomAudioMediaItem

#pragma mark - Initialization

- (instancetype)initWithData:(nullable NSData *)audioData audioViewAttributes:(JSQAudioMediaViewAttributes *)audioViewAttributes audioLink:(NSURL*) fileUrl duration:(NSTimeInterval) duration
{
    NSParameterAssert(audioViewAttributes != nil);

    self = [super init];
    if (self) {
        _cachedMediaView = nil;
        _audioData = [audioData copy];
        _audioViewAttributes = audioViewAttributes;
        _fileUrl = fileUrl;
        _duration = duration;
        _blockAutoplayAfterDownload = NO;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)audioData
{
    return [self initWithData:audioData audioViewAttributes:[[JSQAudioMediaViewAttributes alloc] init] audioLink:[[NSURL alloc]init] duration:0.0];
}

- (instancetype)initWithAudioViewAttributes:(JSQAudioMediaViewAttributes *)audioViewAttributes
{
    return [self initWithData:nil audioViewAttributes:audioViewAttributes audioLink:[[NSURL alloc]init] duration:0.0];
}

//- (instancetype)init
//{
//    return [self initWithData:nil audioViewAttributes:[[JSQAudioMediaViewAttributes alloc] init] duration:0.0];
//}

- (void)dealloc
{
    _audioData = nil;
    _blockAutoplayAfterDownload = NO;
    [self clearCachedMediaViews];
}

- (void)clearCachedMediaViews
{
    [_audioPlayer stop];
    _audioPlayer = nil;

    _playButton = nil;
    _progressView = nil;
    _progressLabel = nil;
    _loadingView = nil;
    _isDownloadingAudio = NO;
    _blockAutoplayAfterDownload = NO;
    [self stopProgressTimer];

    _cachedMediaView = nil;
    [super clearCachedMediaViews];
}

#pragma mark - Setters

- (void)setAudioData:(NSData *)audioData
{
    _audioData = [audioData copy];
    [self clearCachedMediaViews];
}

- (void)setAudioDataWithUrl:(NSURL *)audioURL
{
    _audioData = [NSData dataWithContentsOfURL:audioURL];
    [self clearCachedMediaViews];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedMediaView = nil;
}

#pragma mark - Private

- (void)startProgressTimer
{
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(updateProgressTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)stopProgressTimer
{
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (void)updateProgressTimer:(NSTimer *)sender
{
    if (self.audioPlayer.playing) {
        self.progressView.progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
        self.progressLabel.text = [self timestampString:self.audioPlayer.currentTime
                                            forDuration:self.audioPlayer.duration];
    }
}

- (NSString *)timestampString:(NSTimeInterval)currentTime forDuration:(NSTimeInterval)duration
{
    // print the time as 0:ss or ss.x up to 59 seconds
    // print the time as m:ss up to 59:59 seconds
    // print the time as h:mm:ss for anything longer
    if (duration < 60) {
        if (self.audioViewAttributes.showFractionalSeconds) {
            return [NSString stringWithFormat:@"%.01f", currentTime];
        }
        else if (currentTime < duration) {
            return [NSString stringWithFormat:@"0:%02d", (int)round(currentTime)];
        }
        return [NSString stringWithFormat:@"0:%02d", (int)ceil(currentTime)];
    }
    else if (duration < 3600) {
        return [NSString stringWithFormat:@"%d:%02d", (int)currentTime / 60, (int)currentTime % 60];
    }

    return [NSString stringWithFormat:@"%d:%02d:%02d", (int)currentTime / 3600, (int)currentTime / 60, (int)currentTime % 60];
}

- (void)onPlayButton:(UIButton *)sender
{
    if(self.audioData != nil){
        NSString *category = [AVAudioSession sharedInstance].category;
        AVAudioSessionCategoryOptions options = [AVAudioSession sharedInstance].categoryOptions;

        if (category != self.audioViewAttributes.audioCategory || options != self.audioViewAttributes.audioCategoryOptions) {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setCategory:self.audioViewAttributes.audioCategory
                                             withOptions:self.audioViewAttributes.audioCategoryOptions
                                                   error:&error];
            if (self.delegate) {
                [self.delegate audioMediaItem:self didChangeAudioCategory:category options:options error:error];
            }
        }

        if (self.audioPlayer.playing) {
            self.playButton.selected = NO;
            [self stopProgressTimer];
            [self.audioPlayer stop];
        }
        else {
            [self.delegate audioWillPlay:self];
            // fade the button from play to pause
            [UIView transitionWithView:self.playButton
                              duration:.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.playButton.selected = YES;
                            }
                            completion:nil];

            [self startProgressTimer];
            [self.audioPlayer play];
        }
    }else{ // we need to download the Audio file first
        [self fetchAudioData];
    }
}

- (void) stopAudioIfPlaying{
    if(self.audioPlayer.isPlaying){
        [self onPlayButton:nil];
    }
    
    if(self.isDownloadingAudio){
        _blockAutoplayAfterDownload = YES;
    }
}

-(void) fetchAudioData{
    if(_fileUrl == nil)
        return;
    _isDownloadingAudio = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _audioData = [NSData dataWithContentsOfURL:_fileUrl];
        _isDownloadingAudio = NO;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.audioData error:nil];
        self.audioPlayer.delegate = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!_blockAutoplayAfterDownload){
                if(self.mediaView != nil){ // make sure the view is still alive and the user havent left it
                    [self refreshMediaViewStatus];
                    [self onPlayButton:nil];
                }
            }else{
                [self refreshMediaViewStatus];
            }
            _blockAutoplayAfterDownload = NO;
        });
    });
    [self refreshMediaViewStatus];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {

    // set progress to full, then fade back to the default state
    [self stopProgressTimer];
    self.progressView.progress = 1;
    [UIView transitionWithView:self.cachedMediaView
                      duration:.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.progressView.progress = 0;
                        self.playButton.selected = NO;
                        self.progressLabel.text = [self timestampString:self.audioPlayer.duration
                                                            forDuration:self.audioPlayer.duration];
                    }
                    completion:nil];
}

-(void) didPressParentMessage{
    if(!_parentChatMessage || !self.hostControllerDelegate)
        return;
    [self.hostControllerDelegate didTapParentMessage:_parentChatMessage];
}


#pragma mark - JSQMessageMediaData protocol

- (CGSize)mediaViewDisplaySize
{
    CGSize contentSize = CGSizeMake(160.0f,
                                    self.audioViewAttributes.controlInsets.top +
                                    self.audioViewAttributes.controlInsets.bottom +
                                    self.audioViewAttributes.playButtonImage.size.height);
    
    if(_parentChatMessage){
        contentSize.height += CHAT_ORIGINAL_PREVIEW_HEIGHT;
    }
    return contentSize;
}



- (UIView *)mediaView
{
    if (self.cachedMediaView == nil) {
        if (self.audioData) {
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.audioData error:nil];
            self.audioPlayer.delegate = self;
        }

        // reverse the insets based on the message direction
        CGFloat leftInset, rightInset;
        if (self.appliesMediaViewMaskAsOutgoing) {
            leftInset = self.audioViewAttributes.controlInsets.left;
            rightInset = self.audioViewAttributes.controlInsets.right;
        } else {
            leftInset = self.audioViewAttributes.controlInsets.right;
            rightInset = self.audioViewAttributes.controlInsets.left;
        }
        
        // create container view for the various controls
        CGSize size = [self mediaViewDisplaySize];
        
        UIView * playView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        playView.backgroundColor = [UIColor whiteColor];//self.audioViewAttributes.backgroundColor;
        playView.contentMode = UIViewContentModeCenter;
        playView.clipsToBounds = YES;
        
        // parent message preview view if exists
        CGFloat shift = _parentChatMessage!=nil?CHAT_ORIGINAL_PREVIEW_HEIGHT :0;
        if(_parentChatMessage){
            UIView *parentMsgPreview = [[AppManager sharedManager] getChatMessagePreviewFor:_parentChatMessage inSize:CGSizeMake(size.width, CHAT_ORIGINAL_PREVIEW_HEIGHT) extraLeftSpacing:self.appliesMediaViewMaskAsOutgoing?0:5];
            // add button to parent messaege preview
            UIButton *parentMessageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, parentMsgPreview.frame.size.width, parentMsgPreview.frame.size.height)];
            [parentMessageBtn addTarget:self action:@selector(didPressParentMessage) forControlEvents:UIControlEventTouchUpInside];
            [parentMsgPreview addSubview:parentMessageBtn];
            [playView addSubview:parentMsgPreview];
        }

        // create the play button
        CGRect buttonFrame = CGRectMake(leftInset,
                                        self.audioViewAttributes.controlInsets.top + shift,
                                        self.audioViewAttributes.playButtonImage.size.width,
                                        self.audioViewAttributes.playButtonImage.size.height);
        
        self.playButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [self.playButton setImage:self.audioViewAttributes.playButtonImage forState:UIControlStateNormal];
        [self.playButton setImage:self.audioViewAttributes.pauseButtonImage forState:UIControlStateSelected];
        [self.playButton addTarget:self action:@selector(onPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [playView addSubview:self.playButton];
        
        // create a label to show the duration / elapsed time
        NSString *durationString = [self timestampString:self.duration
                                             forDuration:self.duration];
        NSString *maxWidthString = [@"" stringByPaddingToLength:[durationString length] withString:@"0" startingAtIndex:0];

        // this is cheesy, but it centers the progress bar without extra space and
        // without causing it to wiggle from side to side as the label text changes
        CGSize labelSize = CGSizeMake(36, 18);
        if ([durationString length] < 4) {
            labelSize = CGSizeMake(18,18);
        }
        else if ([durationString length] < 5) {
            labelSize = CGSizeMake(24,18);
        }
        else if ([durationString length] < 6) {
            labelSize = CGSizeMake(30, 18);
        }

        CGRect labelFrame = CGRectMake(size.width - labelSize.width - rightInset,
                                       self.audioViewAttributes.controlInsets.top, labelSize.width, labelSize.height);
        self.progressLabel = [[UILabel alloc] initWithFrame:labelFrame];
        self.progressLabel.textAlignment = NSTextAlignmentLeft;
        self.progressLabel.adjustsFontSizeToFitWidth = YES;
        self.progressLabel.textColor = self.audioViewAttributes.tintColor;
        self.progressLabel.font = self.audioViewAttributes.labelFont;
        self.progressLabel.text = maxWidthString;

        // sizeToFit adjusts the frame's height to the font
        [self.progressLabel sizeToFit];
        labelFrame.origin.x = size.width - self.progressLabel.frame.size.width - rightInset;
        labelFrame.origin.y =  ((size.height +shift - self.progressLabel.frame.size.height) / 2);
        labelFrame.size.width = self.progressLabel.frame.size.width;
        labelFrame.size.height =  self.progressLabel.frame.size.height;
        self.progressLabel.frame = labelFrame;
        self.progressLabel.text = durationString;
        [playView addSubview:self.progressLabel];

        // create a progress bar
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGFloat xOffset = self.playButton.frame.origin.x + self.playButton.frame.size.width + self.audioViewAttributes.controlPadding;
        CGFloat width = labelFrame.origin.x - xOffset - self.audioViewAttributes.controlPadding;
        self.progressView.frame = CGRectMake(xOffset, ((size.height +shift - self.progressView.frame.size.height) / 2),
                                             width, self.progressView.frame.size.height);
        self.progressView.tintColor = self.audioViewAttributes.tintColor;
        [playView addSubview:self.progressView];

        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:playView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedMediaView = playView;
        
        
        // add border arround the bubble
        //if(_parentChatMessage){
            CGRect borderFrame = CGRectMake(_cachedMediaView.frame.origin.x, _cachedMediaView.frame.origin.y, _cachedMediaView.frame.size.width, _cachedMediaView.frame.size.height);
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
            [self.cachedMediaView.layer addSublayer:border];
        //}
        
    }

    return self.cachedMediaView;
}

- (void) refreshMediaViewStatus{
    @try {
        if(self.cachedMediaView == nil)
            return;
        if(_isDownloadingAudio){
            CGFloat shift = _parentChatMessage!=nil?CHAT_ORIGINAL_PREVIEW_HEIGHT :0;
            // create an activit indiactor view and place it over the play buttton
            // reverse the insets based on the message direction
            CGFloat leftInset, rightInset;
            if (self.appliesMediaViewMaskAsOutgoing) {
                leftInset = self.audioViewAttributes.controlInsets.left;
                rightInset = self.audioViewAttributes.controlInsets.right;
            } else {
                leftInset = self.audioViewAttributes.controlInsets.right;
                rightInset = self.audioViewAttributes.controlInsets.left;
            }
            CGRect buttonFrame = CGRectMake(leftInset,
                                            self.audioViewAttributes.controlInsets.top + shift,
                                            self.audioViewAttributes.playButtonImage.size.width,
                                            self.audioViewAttributes.playButtonImage.size.height);

            self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.loadingView.frame = buttonFrame;
            [self.loadingView startAnimating];
            [self.cachedMediaView addSubview:self.loadingView];
            
            self.playButton.hidden = YES;
        }else{
            [self.loadingView removeFromSuperview];
            self.playButton.hidden = NO;
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

    JSQCustomAudioMediaItem *audioItem = (JSQCustomAudioMediaItem *)object;
    if (self.audioData && ![self.audioData isEqualToData:audioItem.audioData]) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash
{
    return super.hash ^ self.audioData.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: audioData=%ld bytes, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], (unsigned long)[self.audioData length],
            @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSData *data = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(audioData))];
    return [self initWithData:data];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.audioData forKey:NSStringFromSelector(@selector(audioData))];
    
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQCustomAudioMediaItem *copy = [[[self class] allocWithZone:zone] initWithData:self.audioData
                                                                audioViewAttributes:self.audioViewAttributes audioLink:self.fileUrl duration:self.duration];
    copy.parentChatMessage = _parentChatMessage;
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
